const { Sequelize } = require('sequelize');
const mongoose = require('mongoose');
const logger = require('../utils/logger');

// Initialize Sequelize (MySQL)
const sequelize = new Sequelize(
  process.env.MYSQL_DATABASE || 'time_services',
  process.env.MYSQL_USER || 'root',
  process.env.MYSQL_PASSWORD || 'password',
  {
    host: process.env.MYSQL_HOST || 'localhost',
    dialect: 'mysql',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
  }
);

// Define models
const TimeConversion = (sequelizeInstance) => {
  const TimeConversion = sequelizeInstance.define('TimeConversion', {
    id: {
      type: Sequelize.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    originalTime: {
      type: Sequelize.STRING,
      allowNull: false,
    },
    minutesSinceMidnight: {
      type: Sequelize.INTEGER,
      allowNull: false,
    },
    createdAt: {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW,
    },
  }, {
    tableName: 'time_conversions',
    timestamps: false,
  });

  return TimeConversion;
};

// MongoDB Schema
const timeConversionSchema = new mongoose.Schema({
  originalTime: {
    type: String,
    required: true,
  },
  minutesSinceMidnight: {
    type: Number,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Create MongoDB model
const MongoTimeConversion = mongoose.model('TimeConversion', timeConversionSchema);

// Test database connections
async function testConnections() {
  try {
    // Test MySQL connection
    await sequelize.authenticate();
    logger.info('MySQL connection has been established successfully.');
    
    // Test MongoDB connection
    await mongoose.connection.db.admin().ping();
    logger.info('MongoDB connection has been established successfully.');
    
    // Sync MySQL models
    await sequelize.sync({ alter: true });
    logger.info('MySQL models synchronized.');
  } catch (error) {
    logger.error('Unable to connect to the databases:', error);
    throw error;
  }
}

module.exports = {
  sequelize,
  TimeConversion,
  MongoTimeConversion,
  testConnections,
};
