require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Kafka } = require('kafkajs');
const mongoose = require('mongoose');
const { Sequelize } = require('sequelize');
const logger = require('./utils/logger');
const routes = require('./routes');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api', routes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Initialize database connections and start server
async function startServer() {
  try {
    // MongoDB connection
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/time_services');
    logger.info('Connected to MongoDB');

    // MySQL connection
    const sequelize = new Sequelize(
      process.env.MYSQL_DATABASE || 'time_services',
      process.env.MYSQL_USER || 'root',
      process.env.MYSQL_PASSWORD || 'password',
      {
        host: process.env.MYSQL_HOST || 'localhost',
        dialect: 'mysql',
        logging: false,
      }
    );

    // Test MySQL connection
    await sequelize.authenticate();
    logger.info('Connected to MySQL');

    // Initialize Kafka producer
    const kafka = new Kafka({
      clientId: 'minutes-service',
      brokers: [process.env.KAFKA_BROKER || 'localhost:9092'],
    });

    const producer = kafka.producer();
    await producer.connect();
    logger.info('Connected to Kafka');

    // Make producer available in app locals
    app.locals.kafkaProducer = producer;

    // Start the server
    app.listen(PORT, () => {
      logger.info(`Server is running on port ${PORT}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Handle shutdown
process.on('SIGINT', async () => {
  logger.info('Shutting down server...');
  if (app.locals.kafkaProducer) {
    await app.locals.kafkaProducer.disconnect();
    logger.info('Disconnected from Kafka');
  }
  await mongoose.connection.close();
  logger.info('Disconnected from MongoDB');
  process.exit(0);
});

startServer();
