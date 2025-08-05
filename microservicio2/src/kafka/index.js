const { Kafka } = require('kafkajs');
const logger = require('../utils/logger');
const { processTimeEvent } = require('./consumer');

const kafka = new Kafka({
  clientId: 'timezone-service',
  brokers: [process.env.KAFKA_BROKER || 'localhost:9092'],
});

let producer;

// Initialize and start Kafka producer
async function startKafkaProducer() {
  try {
    producer = kafka.producer();
    await producer.connect();
    logger.info('Kafka Producer connected successfully');
  } catch (error) {
    logger.error(`Failed to connect Kafka Producer: ${error.message}`);
    throw error;
  }
}

// Initialize and start Kafka consumer
async function startKafkaConsumer() {
  try {
    const consumer = kafka.consumer({
      groupId: process.env.KAFKA_GROUP_ID || 'timezone-service-group',
    });

    await consumer.connect();
    await consumer.subscribe({
      topic: process.env.KAFKA_TOPIC_TIME_CREATED || 'events.time.created',
      fromBeginning: true,
    });

    await consumer.run({
      eachMessage: async ({ topic, partition, message }) => {
        try {
          const event = JSON.parse(message.value.toString());
          logger.info(`Received event from ${topic}: ${JSON.stringify(event)}`);
          
          // Process the time event
          await processTimeEvent(event);
          
        } catch (error) {
          logger.error(`Error processing message: ${error.message}`);
        }
      },
    });

    logger.info('Kafka Consumer started successfully');
  } catch (error) {
    logger.error(`Failed to start Kafka Consumer: ${error.message}`);
    throw error;
  }
}

// Publish timezone resolved event
async function publishTimezoneEvent(timeData, timezoneInfo) {
  try {
    const event = {
      ...timeData,
      timezoneInfo,
      processedAt: new Date().toISOString(),
      service: 'timezone-service',
    };

    await producer.send({
      topic: process.env.KAFKA_TOPIC_TIMEZONE_RESOLVED || 'events.timezone.resolved',
      messages: [
        {
          value: JSON.stringify(event),
        },
      ],
    });

    logger.info(`Published timezone event: ${JSON.stringify(event)}`);
  } catch (error) {
    logger.error(`Failed to publish timezone event: ${error.message}`);
    throw error;
  }
}

module.exports = {
  startKafkaProducer,
  startKafkaConsumer,
  publishTimezoneEvent,
};
