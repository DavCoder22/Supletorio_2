require('dotenv').config();
const express = require('express');
const axios = require('axios');
const mongoose = require('mongoose');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT || 3003;

// Middleware
app.use(express.json());

// Conexión a MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Conectado a MongoDB'))
  .catch(err => console.error('Error conectando a MongoDB:', err));

// Modelo para MongoDB
const AggregatedData = mongoose.model('AggregatedData', new mongoose.Schema({
  timeData: Object,
  timezoneData: Object,
  minutesData: Object,
  createdAt: { type: Date, default: Date.now }
}));

// Pool de conexión a MySQL
const pool = mysql.createPool({
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Crear tabla en MySQL si no existe
async function createTableIfNotExists() {
  const connection = await pool.getConnection();
  try {
    await connection.query(`
      CREATE TABLE IF NOT EXISTS aggregated_results (
        id INT AUTO_INCREMENT PRIMARY KEY,
        time_data JSON,
        timezone_data JSON,
        minutes_data JSON,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Tabla de MySQL verificada/creada');
  } catch (error) {
    console.error('Error al crear la tabla en MySQL:', error);
  } finally {
    connection.release();
  }
}

createTableIfNotExists();

// Función para obtener datos de los servicios
async function fetchDataFromServices() {
  try {
    // Obtener datos del servicio de tiempo
    const timeResponse = await axios.get(`${process.env.TIME_SERVICE_URL}/time`);
    
    // Obtener datos del servicio de zona horaria (usando la hora obtenida)
    const timezoneResponse = await axios.get(
      `${process.env.TIMEZONE_SERVICE_URL}/timezone?time=${timeResponse.data.time}`
    );
    
    // Obtener datos del servicio de minutos (usando la hora obtenida)
    const minutesResponse = await axios.get(
      `${process.env.MINUTES_SERVICE_URL}/minutes?time=${timeResponse.data.time}`
    );

    return {
      timeData: timeResponse.data,
      timezoneData: timezoneResponse.data,
      minutesData: minutesResponse.data
    };
  } catch (error) {
    console.error('Error al obtener datos de los servicios:', error.message);
    throw error;
  }
}

// Ruta para obtener y guardar datos agregados
app.get('/aggregate', async (req, res) => {
  try {
    // Obtener datos de los servicios
    const data = await fetchDataFromServices();
    
    // Guardar en MongoDB
    const mongoResult = await new AggregatedData(data).save();
    
    // Guardar en MySQL
    const [mysqlResult] = await pool.query(
      'INSERT INTO aggregated_results (time_data, timezone_data, minutes_data) VALUES (?, ?, ?)',
      [
        JSON.stringify(data.timeData),
        JSON.stringify(data.timezoneData),
        JSON.stringify(data.minutesData)
      ]
    );

    res.json({
      success: true,
      message: 'Datos agregados exitosamente',
      mongoId: mongoResult._id,
      mysqlId: mysqlResult.insertId,
      data: data
    });
  } catch (error) {
    console.error('Error en /aggregate:', error);
    res.status(500).json({
      success: false,
      message: 'Error al procesar la solicitud',
      error: error.message
    });
  }
});

// Ruta de estado del servicio
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'aggregator-service',
    timestamp: new Date().toISOString()
  });
});

// Iniciar el servidor
app.listen(PORT, () => {
  console.log(`Servidor de agregación ejecutándose en http://localhost:${PORT}`);
});

// Manejo de errores no capturados
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);n});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});
