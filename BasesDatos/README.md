# Microservicios de Tiempo y Fecha

Este proyecto implementa una arquitectura de microservicios para el manejo de tiempo, fechas y zonas horarias, utilizando tanto MySQL como MongoDB para el almacenamiento de datos.

## 🚀 Servicios

### 1. Time Service
- **Puerto**: 3000
- **Ruta**: `GET /time`
- **Función**: Devuelve la hora actual del sistema
- **Almacenamiento**: Registra cada consulta en ambas bases de datos

### 2. Timezone Service
- **Puerto**: 3001
- **Ruta**: `POST /timezone`
- **Parámetros**: `{ "time": "ISO_DATE_STRING", "timezone": "ZONE_NAME" }`
- **Función**: Convierte una fecha/hora a una zona horaria específica

### 3. Minutes Service
- **Puerto**: 3002
- **Ruta**: `POST /minutes`
- **Parámetros**: `{ "time": "ISO_DATE_STRING" }`
- **Función**: Calcula los minutos transcurridos desde la medianoche

### 4. Formatter Service
- **Puerto**: 3004
- **Ruta**: `POST /format`
- **Parámetros**: `{ "date": "ISO_DATE_STRING", "timezone": "ZONE_NAME" }`
- **Salida**: Ej. "Lunes 4 de Agosto, 18:00 UTC-5"

### 5. Aggregator Service
- **Puerto**: 3003
- **Ruta**: `GET /aggregate`
- **Función**: Orquesta las llamadas a los demás servicios

## 🗃️ Bases de Datos

### MySQL
- **Usuario**: `mongo1`
- **Contraseña**: `Sebasalejandro22`
- **Base de datos**: `time_services`

#### Tablas:
- `time_logs`: Registro de consultas de hora
- `timezone_logs`: Historial de conversiones
- `minutes_logs`: Cálculos de minutos
- `format_logs`: Historial de formateo
- `aggregation_logs`: Resultados de agregaciones

### MongoDB
- **URI**: `mongodb://mongo1:Sebasalejandro22@localhost:27017/time_services`
- **Base de datos**: `time_services`

## 🛠️ Despliegue

```bash
# Iniciar contenedores
docker-compose up -d --build

# Inicializar base de datos
docker cp init.sql mysql:/docker-entrypoint-initdb.d/init.sql
docker restart mysql
```

## 🌐 Endpoints

### Obtener hora actual
```http
GET http://localhost:3000/time
```

### Convertir zona horaria
```http
POST http://localhost:3001/timezone
Content-Type: application/json

{
  "time": "2025-08-04T18:30:00Z",
  "timezone": "America/Guayaquil"
}
```

### Obtener minutos desde medianoche
```http
POST http://localhost:3002/minutes
Content-Type: application/json

{
  "time": "2025-08-04T18:30:00Z"
}
```

### Formatear fecha
```http
POST http://localhost:3004/format
Content-Type: application/json

{
  "date": "2025-08-04T18:30:00Z",
  "timezone": "America/Guayaquil"
}
```

### Obtener datos agregados
```http
GET http://localhost:3003/aggregate
```

## 🔒 Seguridad
- Credenciales por defecto: usuario `mongo1` / contraseña `Sebasalejandro22`
- Se recomienda cambiar las credenciales en producción

## 📊 Monitoreo
```bash
# Ver estado de contenedores
docker-compose ps

# Ver logs
docker-compose logs -f [nombre_servicio]
```

## 📄 Licencia
MIT
