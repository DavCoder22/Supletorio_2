const { Kafka } = require('kafkajs');
const { v4: uuidv4 } = require('uuid');

// Kafka configuration
const kafka = new Kafka({
  clientId: 'timezone-service-tester',
  brokers: [process.env.KAFKA_BROKER || 'localhost:9092'],
});

const producer = kafka.producer();
const consumer = kafka.consumer({ groupId: 'timezone-service-test-group' });

// Test data
const testEvent = {
  eventId: uuidv4(),
  timestamp: new Date().toISOString(),
  timezone: 'America/New_York',
  source: 'time-service-test',
};

async function runTest() {
  console.log('Starting Timezone Service Test...');
  
  // Connect to Kafka
  await producer.connect();
  await consumer.connect();
  
  // Subscribe to the output topic
  await consumer.subscribe({ 
    topic: process.env.KAFKA_TOPIC_TIMEZONE_RESOLVED || 'events.timezone.resolved',
    fromBeginning: false 
  });
  
  console.log('Kafka connected and subscribed to topics');
  
  // Set up message handler
  const messagePromise = new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      consumer.disconnect();
      reject(new Error('Timeout waiting for response'));
    }, 10000);
    
    consumer.run({
      eachMessage: async ({ topic, partition, message }) => {
        try {
          const event = JSON.parse(message.value.toString());
          
          // Check if this is our test event
          if (event.eventId === testEvent.eventId) {
            clearTimeout(timeout);
            console.log('\n✅ Test passed! Received timezone event:');
            console.log(JSON.stringify(event, null, 2));
            
            // Verify the response
            if (event.timezoneInfo && event.timezoneInfo.timezone === testEvent.timezone) {
              console.log('\n🎉 Timezone information is correct!');
              resolve();
            } else {
              reject(new Error('Invalid timezone information in response'));
            }
          }
        } catch (error) {
          clearTimeout(timeout);
          reject(error);
        }
      },
    });
  });
  
  // Send test event
  console.log(`\nSending test event to ${process.env.KAFKA_TOPIC_TIME_CREATED || 'events.time.created'}:`);
  console.log(JSON.stringify(testEvent, null, 2));
  
  await producer.send({
    topic: process.env.KAFKA_TOPIC_TIME_CREATED || 'events.time.created',
    messages: [
      { value: JSON.stringify(testEvent) },
    ],
  });
  
  console.log('\nWaiting for response... (timeout: 10s)');
  
  // Wait for the response or timeout
  await messagePromise;
  
  // Clean up
  await Promise.all([
    producer.disconnect(),
    consumer.disconnect(),
  ]);
  
  console.log('Test completed successfully!');
  process.exit(0);
}

runTest().catch(error => {
  console.error('\n❌ Test failed:');
  console.error(error);
  process.exit(1);
});
