# Timezone Service

A microservice that calculates timezone information for given timestamps and publishes the results to a Kafka topic. This service is part of a distributed system for time processing.

## Features

- Consumes time events from Kafka topic `events.time.created`
- Calculates timezone information for the provided timestamp
- Stores events in both MongoDB and MySQL for redundancy
- Publishes processed timezone information to `events.timezone.resolved` topic
- Provides health check endpoint for monitoring

## Prerequisites

- Node.js (v14 or later)
- npm or yarn
- Kafka broker running (default: localhost:9092)
- MongoDB instance (default: localhost:27017)
- MySQL server (default: localhost:3306)

## Installation

1. Clone the repository:

   ```bash
git clone <repository-url>
cd timezone-service
```

2. Install dependencies:

   ```bash
npm install
```

3. Copy the example environment file and update the values:

   ```bash
cp .env.example .env
```

4. Update the `.env` file with your configuration:

   ```env
# Server Configuration
PORT=3001

# Kafka Configuration
KAFKA_BROKER=localhost:9092
KAFKA_GROUP_ID=timezone-service-group
KAFKA_TOPIC_TIME_CREATED=events.time.created
KAFKA_TOPIC_TIMEZONE_RESOLVED=events.timezone.resolved

# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/timezone-service

# MySQL Configuration
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=root
MYSQL_DATABASE=timezone_service
```

## Running the Service

### Development Mode

```bash
npm run dev
```

### Production Mode

```bash
npm start
```

## API Endpoints

- `GET /health` - Health check endpoint
  - Returns: `{ status: "ok", service: "timezone-service" }`

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Port to run the service on | 3001 |
| KAFKA_BROKER | Kafka broker URL | localhost:9092 |
| KAFKA_GROUP_ID | Kafka consumer group ID | timezone-service-group |
| KAFKA_TOPIC_TIME_CREATED | Kafka topic to consume from | events.time.created |
| KAFKA_TOPIC_TIMEZONE_RESOLVED | Kafka topic to publish to | events.timezone.resolved |
| MONGODB_URI | MongoDB connection string | mongodb://localhost:27017/timezone-service |
| MYSQL_* | MySQL database connection details | See .env.example |

## Event Schema

### Consumed Event (events.time.created)

```json
{
  "timestamp": "2025-08-04T18:30:00.000Z",
  "timezone": "America/New_York",
  "source": "time-service"
}
```


### Published Event (events.timezone.resolved)

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2025-08-04T18:30:00.000Z",
  "timezone": "America/New_York",
  "source": "time-service",
  "timezoneInfo": {
    "timezone": "America/New_York",
    "offset": "-04:00",
    "zoneName": "America/New_York",
    "formattedTime": "2025-08-04T14:30:00-04:00",
    "isDST": true,
    "timezoneAbbr": "EDT"
  },
  "processedAt": "2025-08-04T18:30:05.123Z"
}
```


## Database Schema

### MongoDB Collection: timezoneevents

```javascript
{
  _id: ObjectId,
  eventId: String,
  timestamp: Date,
  timezone: String,
  offset: String,
  zoneName: String,
  isDST: Boolean,
  originalEvent: Object,
  processedAt: Date,
  __v: Number
}
```


### MySQL Table: timezone_events

```sql
CREATE TABLE `timezone_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event_id` varchar(36) NOT NULL,
  `timestamp` datetime NOT NULL,
  `timezone` varchar(50) NOT NULL,
  `offset_value` varchar(10) NOT NULL,
  `zone_name` varchar(100) DEFAULT NULL,
  `is_dst` tinyint(1) DEFAULT '0',
  `original_event` json DEFAULT NULL,
  `processed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```


## Development

### Running Tests

```bash
npm test
```


### Linting

```bash
npm run lint
```


## Deployment

The service is designed to be deployed in a containerized environment using Docker. A `Dockerfile` is provided for containerization.

### Building the Docker Image

```bash
docker build -t timezone-service .
```


### Running the Container

```bash
docker run -p 3001:3001 --env-file .env timezone-service
```


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
