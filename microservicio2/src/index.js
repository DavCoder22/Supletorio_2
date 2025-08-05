require('dotenv').config();
const express = require('express');
const { startKafkaConsumer, startKafkaProducer } = require('./kafka');
const { connectToMongoDB } = require('./database/mongodb');
const { connectToMySQL } = require('./database/mysql');
const logger = require('./utils/logger');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'timezone-service' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error(`Error: ${err.message}`);
  res.status(500).json({ error: 'Internal Server Error' });
});

// Main function to start the service
async function startService() {
  try {
    // Initialize database connections
    await connectToMongoDB();
    await connectToMySQL();
    
    // Initialize Kafka producer and consumer
    await startKafkaProducer();
    await startKafkaConsumer();
    
    // Start the server
    app.listen(PORT, () => {
      logger.info(`Timezone Service running on port ${PORT}`);
    });
  } catch (error) {
    logger.error(`Failed to start service: ${error.message}`);
    process.exit(1);
  }
}

// Start the service
startService();

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error(`Unhandled Rejection at: ${promise}, reason: ${reason}`);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error(`Uncaught Exception: ${error.message}`);
  process.exit(1);
});

module.exports = app;
