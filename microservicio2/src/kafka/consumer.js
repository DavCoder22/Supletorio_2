const moment = require('moment-timezone');
const { publishTimezoneEvent } = require('.');
const logger = require('../utils/logger');
const { TimezoneEvent } = require('../database/mongodb');
const { saveTimezoneEventToMySQL } = require('../database/mysql');
const { v4: uuidv4 } = require('uuid');

// Process incoming time event and calculate timezone information
async function processTimeEvent(event) {
  try {
    const { timestamp, timezone, ...rest } = event;
    
    if (!timestamp) {
      throw new Error('Timestamp is required in the event');
    }

    // Get the current time in the specified timezone or use UTC as default
    const targetTimezone = timezone || 'UTC';
    const timeInZone = moment(timestamp).tz(targetTimezone);
    
    // Calculate timezone information
    const timezoneInfo = {
      timezone: targetTimezone,
      offset: timeInZone.format('Z'),
      zoneName: timeInZone.zoneName(),
      formattedTime: timeInZone.format('YYYY-MM-DDTHH:mm:ss.SSSZ'),
      isDST: timeInZone.isDST(),
      timezoneAbbr: timeInZone.format('z'),
    };

    logger.info(`Processed timezone for ${timestamp} in ${targetTimezone}:`, timezoneInfo);
    
    // Generate a unique event ID
    const eventId = event.eventId || uuidv4();
    
    try {
      // Save to MongoDB
      const mongoEvent = new TimezoneEvent({
        ...timezoneInfo,
        originalEvent: event,
        eventId,
      });
      await mongoEvent.save();
      
      // Save to MySQL
      await saveTimezoneEventToMySQL({
        eventId,
        timestamp: new Date(timestamp),
        timezone: timezoneInfo.timezone,
        offset: timezoneInfo.offset,
        zoneName: timezoneInfo.zoneName,
        isDST: timezoneInfo.isDST,
        originalEvent: event,
      });
      
      logger.info(`Saved timezone event with ID: ${eventId}`);
    } catch (dbError) {
      logger.error(`Error saving to database: ${dbError.message}`);
      // Continue processing even if database save fails
    }
    
    // Publish the timezone resolved event
    await publishTimezoneEvent({
      ...event,
      eventId,
      timezoneInfo,
    });
    
    return timezoneInfo;
  } catch (error) {
    logger.error(`Error processing time event: ${error.message}`);
    throw error;
  }
}

module.exports = {
  processTimeEvent,
};
