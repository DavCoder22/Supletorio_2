const mongoose = require('mongoose');
const logger = require('../utils/logger');

// MongoDB connection
let mongoConnection = null;

// Connect to MongoDB
async function connectToMongoDB() {
  try {
    if (mongoConnection) {
      return mongoConnection;
    }

    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/timezone-service';
    
    const options = {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000,
      connectTimeoutMS: 10000,
    };

    mongoConnection = await mongoose.connect(mongoUri, options);
    
    logger.info('MongoDB connected successfully');
    
    // Set up event listeners
    mongoose.connection.on('error', (error) => {
      logger.error(`MongoDB connection error: ${error.message}`);
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected');
    });

    return mongoConnection;
  } catch (error) {
    logger.error(`MongoDB connection failed: ${error.message}`);
    throw error;
  }
}

// Close MongoDB connection
async function closeMongoDBConnection() {
  try {
    if (mongoConnection) {
      await mongoose.disconnect();
      mongoConnection = null;
      logger.info('MongoDB connection closed');
    }
  } catch (error) {
    logger.error(`Error closing MongoDB connection: ${error.message}`);
    throw error;
  }
}

// Timezone event schema
const timezoneEventSchema = new mongoose.Schema({
  timestamp: { type: Date, required: true },
  timezone: { type: String, required: true },
  offset: { type: String, required: true },
  zoneName: { type: String },
  isDST: { type: Boolean },
  originalEvent: { type: Object },
  processedAt: { type: Date, default: Date.now },
});

// Create model
const TimezoneEvent = mongoose.model('TimezoneEvent', timezoneEventSchema);

module.exports = {
  connectToMongoDB,
  closeMongoDBConnection,
  TimezoneEvent,
};
