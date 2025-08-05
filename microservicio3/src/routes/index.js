const express = require('express');
const router = express.Router();
const { calculateMinutes, validateTime } = require('../services/timeService');
const logger = require('../utils/logger');

// Endpoint to convert time to minutes since midnight
router.post('/convert', async (req, res) => {
  try {
    const { time } = req.body;
    
    // Validate input
    if (!time) {
      return res.status(400).json({ error: 'Time is required' });
    }

    if (!validateTime(time)) {
      return res.status(400).json({ error: 'Invalid time format. Use HH:MM:SS' });
    }

    // Calculate minutes since midnight
    const minutes = calculateMinutes(time);
    
    // Get Kafka producer from app locals
    const { kafkaProducer } = req.app.locals;
    
    // Send message to Kafka
    await kafkaProducer.send({
      topic: 'events.minutes.calculated',
      messages: [
        {
          key: 'time-conversion',
          value: JSON.stringify({
            originalTime: time,
            minutesSinceMidnight: minutes,
            timestamp: new Date().toISOString()
          })
        }
      ]
    });

    logger.info(`Converted ${time} to ${minutes} minutes since midnight`);
    
    // Save to databases (MongoDB and MySQL)
    await Promise.all([
      saveToMongoDB(time, minutes),
      saveToMySQL(time, minutes)
    ]);

    res.json({
      originalTime: time,
      minutesSinceMidnight: minutes
    });
  } catch (error) {
    logger.error('Error in /convert endpoint:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get conversion history
router.get('/history', async (req, res) => {
  try {
    // Get history from both databases
    const [mongoHistory, mysqlHistory] = await Promise.all([
      getMongoHistory(),
      getMySQLHistory()
    ]);

    res.json({
      mongo: mongoHistory,
      mysql: mysqlHistory
    });
  } catch (error) {
    logger.error('Error fetching history:', error);
    res.status(500).json({ error: 'Failed to fetch history' });
  }
});

// Helper functions for database operations
async function saveToMongoDB(time, minutes) {
  try {
    const db = mongoose.connection.db;
    const collection = db.collection('time_conversions');
    await collection.insertOne({
      originalTime: time,
      minutesSinceMidnight: minutes,
      createdAt: new Date()
    });
  } catch (error) {
    logger.error('Error saving to MongoDB:', error);
    throw error;
  }
}

async function saveToMySQL(time, minutes) {
  try {
    const { sequelize } = require('../models');
    const TimeConversion = require('../models/timeConversion')(sequelize);
    
    await TimeConversion.create({
      originalTime: time,
      minutesSinceMidnight: minutes,
      createdAt: new Date()
    });
  } catch (error) {
    logger.error('Error saving to MySQL:', error);
    throw error;
  }
}

async function getMongoHistory(limit = 10) {
  try {
    const db = mongoose.connection.db;
    const collection = db.collection('time_conversions');
    return await collection
      .find()
      .sort({ createdAt: -1 })
      .limit(limit)
      .toArray();
  } catch (error) {
    logger.error('Error fetching from MongoDB:', error);
    throw error;
  }
}

async function getMySQLHistory(limit = 10) {
  try {
    const { sequelize } = require('../models');
    const TimeConversion = require('../models/timeConversion')(sequelize);
    
    return await TimeConversion.findAll({
      order: [['createdAt', 'DESC']],
      limit: limit
    });
  } catch (error) {
    logger.error('Error fetching from MySQL:', error);
    throw error;
  }
}

module.exports = router;
