const { calculateMinutes, validateTime, minutesToTimeString } = require('../services/timeService');

describe('Time Service', () => {
  describe('validateTime', () => {
    it('should validate correct time format', () => {
      expect(validateTime('00:00:00')).toBe(true);
      expect(validateTime('23:59:59')).toBe(true);
      expect(validateTime('12:30:45')).toBe(true);
    });

    it('should invalidate incorrect time format', () => {
      expect(validateTime('24:00:00')).toBe(false);
      expect(validateTime('12:60:00')).toBe(false);
      expect(validateTime('12:00:60')).toBe(false);
      expect(validateTime('12:00:0')).toBe(false);
      expect(validateTime('120000')).toBe(false);
      expect(validateTime('')).toBe(false);
      expect(validateTime(null)).toBe(false);
      expect(validateTime(undefined)).toBe(false);
    });
  });

  describe('calculateMinutes', () => {
    it('should convert time to minutes since midnight', () => {
      expect(calculateMinutes('00:00:00')).toBe(0);
      expect(calculateMinutes('01:00:00')).toBe(60);
      expect(calculateMinutes('12:30:00')).toBe(750);
      expect(calculateMinutes('23:59:59')).toBe(1439);
    });

    it('should round seconds to the nearest minute', () => {
      expect(calculateMinutes('00:00:29')).toBe(0);
      expect(calculateMinutes('00:00:30')).toBe(1);
      expect(calculateMinutes('12:30:29')).toBe(750);
      expect(calculateMinutes('12:30:30')).toBe(751);
    });

    it('should throw error for invalid time format', () => {
      expect(() => calculateMinutes('24:00:00')).toThrow();
      expect(() => calculateMinutes('12:60:00')).toThrow();
      expect(() => calculateMinutes('invalid')).toThrow();
    });
  });

  describe('minutesToTimeString', () => {
    it('should convert minutes to time string', () => {
      expect(minutesToTimeString(0)).toBe('00:00:00');
      expect(minutesToTimeString(60)).toBe('01:00:00');
      expect(minutesToTimeString(750)).toBe('12:30:00');
      expect(minutesToTimeString(1439)).toBe('23:59:00');
    });

    it('should throw error for invalid minutes', () => {
      expect(() => minutesToTimeString(-1)).toThrow();
      expect(() => minutesToTimeString(1440)).toThrow();
      expect(() => minutesToTimeString('invalid')).toThrow();
    });
  });
});
