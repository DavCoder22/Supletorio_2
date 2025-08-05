const { format, utcToZonedTime } = require('date-fns-tz');
const { es } = require('date-fns/locale');

/**
 * Formatea una fecha en un string legible con la zona horaria especificada
 * @param {Date} date - Fecha a formatear
 * @param {string} timezone - Zona horaria (ej. 'America/Guayaquil')
 * @returns {string} Fecha formateada (ej. 'Lunes 4 de Agosto, 18:00 UTC-5')
 */
function formatDateWithTimezone(date, timezone) {
  try {
    // Convertir la fecha a la zona horaria especificada
    const zonedDate = utcToZonedTime(date, timezone);
    
    // Formatear la fecha en español
    const formattedDate = format(zonedDate, "EEEE d 'de' MMMM, HH:mm", { 
      locale: es,
      timeZone: timezone 
    });
    
    // Obtener el offset de la zona horaria (ej. -05:00)
    const timeZoneOffset = format(zonedDate, 'XXX', { timeZone: timezone });
    
    // Convertir el offset a formato legible (ej. UTC-5)
    const offsetSign = timeZoneOffset.startsWith('-') ? '-' : '+';
    const offsetHours = Math.abs(parseInt(timeZoneOffset.split(':')[0]));
    const offsetStr = `UTC${offsetSign}${offsetHours}`;
    
    // Capitalizar la primera letra del día de la semana
    const finalDate = formattedDate.charAt(0).toUpperCase() + formattedDate.slice(1);
    
    return `${finalDate} ${offsetStr}`;
  } catch (error) {
    throw new Error(`Error al formatear la fecha: ${error.message}`);
  }
}

module.exports = { formatDateWithTimezone };
