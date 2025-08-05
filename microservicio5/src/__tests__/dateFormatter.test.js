const { formatDateWithTimezone } = require('../utils/dateFormatter');

describe('formatDateWithTimezone', () => {
  test('should format date in America/Guayaquil timezone', () => {
    const date = new Date('2025-08-04T23:00:00.000Z'); // 18:00 UTC-5
    const timezone = 'America/Guayaquil';
    
    const result = formatDateWithTimezone(date, timezone);
    // El resultado debería ser "Lunes 4 de Agosto, 18:00 UTC-5"
    expect(result).toMatch(/^Lunes 4 de Agosto, 18:00 UTC-5/);
  });

  test('should handle different timezone (Europe/Madrid)', () => {
    const date = new Date('2025-08-04T20:00:00.000Z'); // 22:00 UTC+2 (horario de verano)
    const timezone = 'Europe/Madrid';
    
    const result = formatDateWithTimezone(date, timezone);
    expect(result).toMatch(/^Lunes 4 de Agosto, 22:00 UTC\+2/);
  });

  test('should handle invalid date', () => {
    const invalidDate = 'no-es-una-fecha';
    const timezone = 'America/Guayaquil';
    
    expect(() => {
      formatDateWithTimezone(invalidDate, timezone);
    }).toThrow('Error al formatear la fecha');
  });

  test('should handle invalid timezone', () => {
    const date = new Date('2025-08-04T23:00:00.000Z');
    const invalidTimezone = 'No/Existe';
    
    expect(() => {
      formatDateWithTimezone(date, invalidTimezone);
    }).toThrow('Error al formatear la fecha');
  });
});
