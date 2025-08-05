const mysql = require('mysql2/promise');
const logger = require('../utils/logger');

// MySQL connection pool
let pool = null;

// Connect to MySQL and initialize database
async function connectToMySQL() {
  try {
    if (pool) {
      return pool;
    }

    // Create a connection to initialize the database if it doesn't exist
    const connection = await mysql.createConnection({
      host: process.env.MYSQL_HOST || 'localhost',
      port: process.env.MYSQL_PORT || 3306,
      user: process.env.MYSQL_USER || 'root',
      password: process.env.MYSQL_PASSWORD || 'root',
    });

    // Create the database if it doesn't exist
    await connection.query(
      `CREATE DATABASE IF NOT EXISTS \`${process.env.MYSQL_DATABASE || 'timezone_service'}\`;`
    );
    
    await connection.end();

    // Create a connection pool
    pool = mysql.createPool({
      host: process.env.MYSQL_HOST || 'localhost',
      port: process.env.MYSQL_PORT || 3306,
      user: process.env.MYSQL_USER || 'root',
      password: process.env.MYSQL_PASSWORD || 'root',
      database: process.env.MYSQL_DATABASE || 'timezone_service',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
    });

    // Initialize the database schema
    await initializeSchema();
    
    logger.info('MySQL connected successfully');
    return pool;
  } catch (error) {
    logger.error(`MySQL connection failed: ${error.message}`);
    throw error;
  }
}

// Initialize database schema
async function initializeSchema() {
  const connection = await pool.getConnection();
  try {
    // Create timezone_events table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS timezone_events (
        id INT AUTO_INCREMENT PRIMARY KEY,
        event_id VARCHAR(36) NOT NULL,
        timestamp DATETIME NOT NULL,
        timezone VARCHAR(50) NOT NULL,
        offset_value VARCHAR(10) NOT NULL,
        zone_name VARCHAR(100),
        is_dst TINYINT(1) DEFAULT 0,
        original_event JSON,
        processed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_event_id (event_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    logger.info('MySQL schema initialized');
  } catch (error) {
    logger.error(`Error initializing MySQL schema: ${error.message}`);
    throw error;
  } finally {
    connection.release();
  }
}

// Close MySQL connection pool
async function closeMySQLConnection() {
  try {
    if (pool) {
      await pool.end();
      pool = null;
      logger.info('MySQL connection closed');
    }
  } catch (error) {
    logger.error(`Error closing MySQL connection: ${error.message}`);
    throw error;
  }
}

// Save timezone event to MySQL
async function saveTimezoneEventToMySQL(eventData) {
  const connection = await pool.getConnection();
  try {
    const {
      eventId,
      timestamp,
      timezone,
      offset,
      zoneName,
      isDST,
      originalEvent
    } = eventData;

    await connection.query(
      `INSERT INTO timezone_events 
       (event_id, timestamp, timezone, offset_value, zone_name, is_dst, original_event)
       VALUES (?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         timestamp = VALUES(timestamp),
         timezone = VALUES(timezone),
         offset_value = VALUES(offset_value),
         zone_name = VALUES(zone_name),
         is_dst = VALUES(is_dst),
         original_event = VALUES(original_event),
         processed_at = NOW()
      `,
      [
        eventId,
        timestamp,
        timezone,
        offset,
        zoneName,
        isDST ? 1 : 0,
        JSON.stringify(originalEvent || {})
      ]
    );

    logger.info(`Timezone event saved to MySQL: ${eventId}`);
  } catch (error) {
    logger.error(`Error saving timezone event to MySQL: ${error.message}`);
    throw error;
  } finally {
    connection.release();
  }
}

module.exports = {
  connectToMySQL,
  closeMySQLConnection,
  saveTimezoneEventToMySQL,
  getPool: () => pool,
};
