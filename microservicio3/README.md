# Minutes Service

A microservice that converts a given time to minutes since midnight and publishes the result to a Kafka topic.

## Features

- Converts time in HH:MM:SS format to minutes since midnight
- Stores conversion history in both MongoDB and MySQL
- Publishes conversion events to Kafka
- RESTful API for time conversion
- Health check endpoint

## Prerequisites

- Node.js 16+
- MongoDB
- MySQL
- Kafka
- npm or yarn

## Prerequisites

- Docker and Docker Compose
- Node.js 16+ (only needed for local development without Docker)

## Installation with Docker (Recommended)

1. Clone the repository
2. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
3. Build and start the services:
   ```bash
   docker-compose up -d --build
   ```
4. The service will be available at `http://localhost:3002`

## Local Development (without Docker)

1. Make sure you have MongoDB, MySQL, and Kafka running locally
2. Clone the repository
3. Install dependencies:
   ```bash
   npm install
   ```
4. Copy `.env.example` to `.env` and update the configuration:
   ```bash
   cp .env.example .env
   ```
5. Update the `.env` file with your local database and Kafka configurations

## Running the Service

Start the service in development mode:
```bash
npm run dev
```

Start the service in production mode:
```bash
npm start
```

## API Endpoints

### Convert Time to Minutes
```
POST /api/convert
```

**Request Body:**
```json
{
  "time": "14:30:00"
}
```

**Response:**
```json
{
  "originalTime": "14:30:00",
  "minutesSinceMidnight": 870
}
```

### Get Conversion History
```
GET /api/history
```

**Response:**
```json
{
  "mongo": [
    {
      "_id": "60d5ec9f4b3f8b5d5c8b4a2f",
      "originalTime": "14:30:00",
      "minutesSinceMidnight": 870,
      "createdAt": "2023-06-26T12:00:00.000Z"
    }
  ],
  "mysql": [
    {
      "id": 1,
      "originalTime": "14:30:00",
      "minutesSinceMidnight": 870,
      "createdAt": "2023-06-26T12:00:00.000Z"
    }
  ]
}
```

### Health Check
```
GET /health
```

**Response:**
```json
{
  "status": "UP"
}
```

## Kafka Topics

The service publishes to the following Kafka topic:
- `events.minutes.calculated`: When a time is successfully converted to minutes

## Database Schema

### MongoDB
Collection: `time_conversions`
```
{
  _id: ObjectId,
  originalTime: String,
  minutesSinceMidnight: Number,
  createdAt: Date
}
```

### MySQL
Table: `time_conversions`
```
id: INT (Primary Key, Auto Increment)
originalTime: VARCHAR(8)
minutesSinceMidnight: INT
createdAt: DATETIME
```

## Environment Variables

See `.env.example` for all available environment variables.

## Running Tests

```bash
npm test
```

## License

MIT
