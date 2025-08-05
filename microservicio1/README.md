# Microservicio de Hora

Un microservicio simple que devuelve la hora y fecha actual, empaquetado en un contenedor Docker para fácil despliegue con Terraform.

## Características

- Devuelve la hora actual formateada
- Incluye la fecha actual
- Muestra la zona horaria del servidor
- API RESTful simple
- Contenedorizado con Docker
- Listo para despliegue con Terraform

## Requisitos Previos

- Docker
- Docker Compose (para desarrollo local)
- Node.js (solo para desarrollo)

## Instalación Local (Desarrollo)

1. Clona este repositorio
2. Instala las dependencias:
   ```bash
   npm install
   ```
3. Inicia el servidor de desarrollo:
   ```bash
   npm run dev
   ```

## Uso con Docker

### Construir la imagen
```bash
docker build -t microservicio-hora .
```

### Ejecutar el contenedor
```bash
docker run -p 3000:3000 -d --name microservicio-hora microservicio-hora
```

### Usar Docker Compose (recomendado para desarrollo)
```bash
docker-compose up --build
```

## Endpoints

- `GET /hora` - Obtiene la hora y fecha actual
- `GET /status` - Verifica el estado del servidor

## Ejemplo de respuesta

```json
{
  "hora": "13:38:46",
  "fecha": "4/8/2025",
  "timezone": "America/Guayaquil"
}
```

## Despliegue con Terraform

Este microservicio está listo para ser desplegado usando Terraform. El Dockerfile incluido puede ser utilizado en cualquier orquestador de contenedores compatible con Docker.

### Variables de entorno

- `PORT`: Puerto en el que se ejecutará la aplicación (por defecto: 3000)
- `NODE_ENV`: Entorno de ejecución (production/development)

## Estructura del Proyecto

```
.
├── Dockerfile           # Configuración de Docker
├── docker-compose.yml   # Configuración para desarrollo local
├── package.json         # Dependencias y scripts
├── server.js            # Código fuente del microservicio
└── README.md            # Esta documentación
```

## Dependencias

- **Producción**:
  - Express: Framework web para Node.js
  - CORS: Middleware para habilitar CORS

- **Desarrollo**:
  - Nodemon: Para recarga automática
  - Docker: Para contenerizar la aplicación

## Licencia

Este proyecto está bajo la licencia MIT.
