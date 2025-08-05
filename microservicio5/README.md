# Formatter Service

Microservicio para formatear fechas con zonas horarias en un formato legible.

## Requisitos

- Node.js 14+
- npm o yarn

## Instalación

1. Clonar el repositorio
2. Instalar dependencias:
   ```
   npm install
   ```

## Uso

El servicio expone un endpoint POST en `/format-date` que acepta el siguiente formato:

```json
{
  "date": "2025-08-04T18:00:00.000Z",
  "timezone": "America/Guayaquil"
}
```

### Ejemplo de respuesta exitosa (200 OK):

```json
{
  "formattedDate": "Lunes 4 de Agosto, 18:00 UTC-5"
}
```

### Ejemplo de error (400 Bad Request):

```json
{
  "error": "Parámetros inválidos: date y timezone son requeridos"
}
```

## Iniciar el servidor

```
npm start
```

El servicio estará disponible en `http://localhost:3000`

## Pruebas

Para ejecutar las pruebas:

```
npm test
```
