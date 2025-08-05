/**
 * Validates time string format (HH:MM:SS)
 * @param {string} time - Time string in HH:MM:SS format
 * @returns {boolean} - True if valid, false otherwise
 */
function validateTime(time) {
  const timeRegex = /^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/;
  return timeRegex.test(time);
}

/**
 * Converts time string to minutes since midnight
 * @param {string} time - Time string in HH:MM:SS format
 * @returns {number} - Minutes since midnight
 */
function calculateMinutes(time) {
  if (!validateTime(time)) {
    throw new Error('Invalid time format. Expected HH:MM:SS');
  }

  const [hours, minutes, seconds] = time.split(':').map(Number);
  return hours * 60 + minutes + Math.round(seconds / 60);
}

/**
 * Converts minutes since midnight to time string (HH:MM:SS)
 * @param {number} minutes - Minutes since midnight
 * @returns {string} - Time string in HH:MM:SS format
 */
function minutesToTimeString(minutes) {
  if (minutes < 0 || minutes >= 1440) {
    throw new Error('Minutes must be between 0 and 1439');
  }

  const hours = Math.floor(minutes / 60);
  const mins = Math.floor(minutes % 60);
  return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:00`;
}

module.exports = {
  validateTime,
  calculateMinutes,
  minutesToTimeString
};
