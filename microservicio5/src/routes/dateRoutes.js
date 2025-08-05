const express = require('express');
const { body, validationResult } = require('express-validator');
const { formatDateWithTimezone } = require('../utils/dateFormatter');

const router = express.Router();

/**
 * @route POST /format-date
 * @description Formatea una fecha con la zona horaria especificada
 * @body {string} date - Fecha en formato ISO 8601 (ej. "2025-08-04T18:00:00.000Z")
 * @body {string} timezone - Zona horaria (ej. "America/Guayaquil")
 * @returns {Object} Objeto con la fecha formateada
 */
router.post(
  '/format-date',
  [
    body('date')
      .isISO8601()
      .withMessage('La fecha debe estar en formato ISO 8601')
      .toDate(),
    body('timezone')
      .isString()
      .notEmpty()
      .withMessage('La zona horaria es requerida')
  ],
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        error: 'Parámetros inválidos',
        details: errors.array()
      });
    }

    const { date, timezone } = req.body;

    try {
      const formattedDate = formatDateWithTimezone(date, timezone);
      res.json({ formattedDate });
    } catch (error) {
      res.status(400).json({ 
        error: 'Error al formatear la fecha',
        details: error.message 
      });
    }
  }
);

module.exports = router;
