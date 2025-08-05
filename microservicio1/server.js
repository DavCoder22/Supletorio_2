const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Ruta principal que devuelve la hora actual
app.get('/hora', (req, res) => {
    const fechaActual = new Date();
    const horaActual = fechaActual.toLocaleTimeString();
    const fechaFormateada = fechaActual.toLocaleDateString();
    
    res.json({
        hora: horaActual,
        fecha: fechaFormateada,
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
    });
});

// Ruta de verificación de estado
app.get('/status', (req, res) => {
    res.json({ status: 'Servidor en funcionamiento' });
});

// Iniciar el servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
    console.log(`Para obtener la hora actual, visita: http://localhost:${PORT}/hora`);
});
