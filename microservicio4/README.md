# Aggregator Service

Microservicio encargado de orquestar las llamadas a otros servicios de tiempo, agregar sus resultados y almacenarlos en MongoDB y MySQL.

## Requisitos

- Node.js (v14 o superior)
- MongoDB (ejecutándose en localhost:27017)
- MySQL (ejecutándose en localhost:3306)
- Los demás microservicios de tiempo (time-service, timezone-service, minutes-service)

## Instalación

1. Clonar el repositorio
2. Instalar dependencias:
   ```bash
   npm install
   ```
3. Configurar las variables de entorno en el archivo `.env`

## Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:

```
# Configuración de los servicios
TIME_SERVICE_URL=http://localhost:3000
TIMEZONE_SERVICE_URL=http://localhost:3001
MINUTES_SERVICE_URL=http://localhost:3002

# Configuración de MongoDB
MONGODB_URI=mongodb://localhost:27017/aggregator_db

# Configuración de MySQL
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=tu_contraseña
MYSQL_DATABASE=aggregator_db

# Puerto del servidor
PORT=3003
```

## Uso

1. Iniciar el servidor:
   ```bash
   npm start
   ```
   o para desarrollo con recarga automática:
   ```bash
   npm run dev
   ```

2. Endpoints disponibles:
   - `GET /aggregate`: Obtiene datos de los servicios de tiempo y los guarda en las bases de datos
   - `GET /health`: Verifica el estado del servicio

## Estructura del Proyecto

- `index.js`: Punto de entrada de la aplicación
- `.env`: Configuración de entorno
- `package.json`: Dependencias y scripts

## Almacenamiento de Datos

Los datos se guardan en:
- **MongoDB**: Colección `aggregateddatas`
- **MySQL**: Tabla `aggregated_results`

## Ejemplo de Respuesta

```json
{
  "success": true,
  "message": "Datos agregados exitosamente",
  "mongoId": "60f1a9b9e6b3f3b3e4f5d6e7",
  "mysqlId": 42,
  "data": {
    "timeData": { "time": "2023-08-04T23:50:00.000Z" },
    "timezoneData": { "timezone": "America/Guayaquil", "offset": -5 },
    "minutesData": { "minutes": 1430 }
  }
}
```
