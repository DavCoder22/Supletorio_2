const { Sequelize } = require('sequelize');
const logger = require('../utils/logger');

async function initializeDatabase() {
  // Create a connection without specifying the database
  const sequelize = new Sequelize('', process.env.MYSQL_USER || 'root', process.env.MYSQL_PASSWORD || 'password', {
    host: process.env.MYSQL_HOST || 'localhost',
    dialect: 'mysql',
    logging: false,
  });

  try {
    // Create the database if it doesn't exist
    await sequelize.query(`CREATE DATABASE IF NOT EXISTS ${process.env.MYSQL_DATABASE || 'time_services'}`);
    logger.info('Database created or already exists');

    // Connect to the database
    await sequelize.close();
    const db = new Sequelize(
      process.env.MYSQL_DATABASE || 'time_services',
      process.env.MYSQL_USER || 'root',
      process.env.MYSQL_PASSWORD || 'password',
      {
        host: process.env.MYSQL_HOST || 'localhost',
        dialect: 'mysql',
        logging: false,
      }
    );

    // Define the model
    const TimeConversion = db.define('TimeConversion', {
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

    // Sync the model with the database
    await TimeConversion.sync({ alter: true });
    logger.info('Database tables synchronized');
    
    return true;
  } catch (error) {
    logger.error('Error initializing database:', error);
    throw error;
  } finally {
    await sequelize.close();
  }
}

// Run the initialization if this script is called directly
if (require.main === module) {
  initializeDatabase()
    .then(() => {
      logger.info('Database initialization completed');
      process.exit(0);
    })
    .catch((error) => {
      logger.error('Database initialization failed:', error);
      process.exit(1);
    });
}

module.exports = { initializeDatabase };
