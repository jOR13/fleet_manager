# Fleet Manager - Sistema de Gestión de Flotas

Una aplicación Ruby on Rails completa para gestionar vehículos y servicios de mantenimiento con API REST y interfaz web bilingüe.

## 🚀 Inicio Rápido

### Prerrequisitos
- Ruby 3.0+
- Rails 7.0+
- PostgreSQL 12+
- Node.js y Yarn

### Instalación

```bash
# Clonar el repositorio
git clone <your-repo-url>
cd fleet-manager

# Instalar dependencias
bundle install
yarn install

# Configurar base de datos
rails db:create
rails db:migrate
rails db:seed

# Iniciar servidor
rails server
```

### Acceso a la Aplicación

- **Aplicación Web:** http://localhost:3000
- **Documentación API:** http://localhost:3000/api-docs
- **Reportes:** http://localhost:3000/en/reports

### Credenciales de Prueba

```
Email: admin@example.com
Password: password123
```

## 📋 Características Principales

### ✅ Funcionalidades Completas
- CRUD completo de vehículos y servicios de mantenimiento
- API REST con autenticación JWT
- Interfaz web responsive y bilingüe (ES/EN)
- Sistema de reportes con exportación CSV/Excel
- Filtros, búsqueda y paginación
- Reglas de negocio automáticas
- Documentación API interactiva (Swagger)

### 🏗️ Arquitectura Técnica
- **Backend:** Ruby on Rails 7.x
- **Base de Datos:** PostgreSQL
- **Frontend:** Bulma CSS + Stimulus JS
- **API:** JSON con serialización optimizada
- **Testing:** RSpec + FactoryBot
- **Documentación:** Swagger/OpenAPI 3

## 🔗 Endpoints de la API

### Autenticación
```
POST /api/v1/auth/login
```

### Vehículos
```
GET    /api/v1/vehicles                 # Listar con filtros
POST   /api/v1/vehicles                 # Crear
GET    /api/v1/vehicles/:id             # Ver detalle
PUT    /api/v1/vehicles/:id             # Actualizar
DELETE /api/v1/vehicles/:id             # Eliminar
```

### Servicios de Mantenimiento
```
GET  /api/v1/vehicles/:vehicle_id/maintenance_services  # Listar servicios
POST /api/v1/vehicles/:vehicle_id/maintenance_services  # Crear servicio
PATCH /api/v1/maintenance_services/:id                  # Actualizar servicio
```

### Reportes
```
GET /api/v1/reports/maintenance_summary?from=2024-01-01&to=2024-12-31&format=json
```

## 📊 Ejemplo de Uso de la API

### 1. Autenticación
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password123"
  }'
```

**Respuesta:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "admin@example.com",
    "name": "Admin User",
    "role": "admin"
  }
}
```

### 2. Crear Vehículo
```bash
curl -X POST http://localhost:3000/api/v1/vehicles \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle": {
      "vin": "1HGBH41JXMN109186",
      "brand": "Toyota",
      "model": "Corolla",
      "year": 2020,
      "plate": "ABC-123",
      "mileage": 15000
    }
  }'
```

### 3. Crear Servicio de Mantenimiento
```bash
curl -X POST http://localhost:3000/api/v1/vehicles/1/maintenance_services \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "maintenance_service": {
      "description": "Oil change and filter replacement",
      "status": "pending",
      "date": "2024-01-15",
      "cost_cents": 5000,
      "priority": "medium",
      "service_type": "Preventive Maintenance"
    }
  }'
```

### 4. Obtener Reporte
```bash
curl -X GET "http://localhost:3000/api/v1/reports/maintenance_summary?from=2024-01-01&to=2024-12-31" \
  -H "Authorization: Bearer <TOKEN>"
```

## 🧪 Testing

### Ejecutar Pruebas
```bash
bundle exec rspec

bundle exec rspec spec/models

bundle exec rspec spec/requests

bundle exec rspec --format documentation
```

### Cobertura de Pruebas
- ✅ Modelos: Validaciones y callbacks
- ✅ Controllers API: CRUD completo
- ✅ Requests: Autenticación y autorización
- ✅ Factories: Datos de prueba consistentes

## 📁 Estructura del Proyecto

```
app/
├── controllers/
│   ├── api/v1/              # Controllers API
│   ├── application_controller.rb
│   ├── vehicles_controller.rb
│   └── reports_controller.rb
├── models/
│   ├── vehicle.rb           # Modelo vehículo
│   ├── maintenance_service.rb # Modelo servicio
│   └── user.rb              # Modelo usuario
├── serializers/             # Serialización JSON
├── views/                   # Vistas HTML
└── javascript/              # Stimulus controllers

config/
├── routes.rb                # Definición de rutas
└── locales/                 # Archivos de traducción

spec/
├── models/                  # Pruebas de modelos
├── requests/                # Pruebas de API
└── factories/               # Factories para testing

swagger/
└── v1/
    └── swagger.yaml         # Documentación OpenAPI
```

## 🔧 Configuración Avanzada

### Variables de Entorno
```bash
JWT_SECRET: "your-secret-key"
DATABASE_URL: "postgres://user:pass@localhost/fleet_manager_development"
```

### Base de Datos
```bash
rails db:migrate

rails db:seed

```

## 🎯 Reglas de Negocio

### Estados de Vehículos
- `active`: Sin servicios pendientes
- `inactive`: Fuera de servicio
- `in_maintenance`: Tiene servicios pending/in_progress

### Estados de Servicios
- `pending`: Programado, no iniciado
- `in_progress`: En ejecución
- `completed`: Finalizado (requiere completed_at)

### Validaciones Principales
- VIN y placa únicos (case-insensitive)
- Fechas no futuras
- Costos no negativos
- Años entre 1990-2050

## 📈 Funcionalidades de Reportes

### Métricas Incluidas
- Total de órdenes de mantenimiento
- Costos totales y promedios
- Desglose por estado de servicio
- Agrupación por vehículo
- Top 3 vehículos por costo
- Tendencias mensuales

### Formatos de Exportación
- JSON (para APIs)
- CSV (para análisis)
- Excel (.xlsx) con formato

## 🌐 Interfaz Web

### Características
- Diseño responsive con Bulma CSS
- Soporte bilingüe (Español/Inglés)
- Filtros reactivos
- Exportación de reportes
- Navegación intuitiva

### Páginas Principales
1. `/` - Dashboard de vehículos
2. `/vehicles/:id` - Detalle de vehículo
3. `/vehicles/:id/maintenance_services` - Servicios
4. `/reports` - Dashboard de reportes
5. `/api-docs` - Documentación API

## 🔒 Seguridad

### Autenticación
- JWT con expiración configurable
- Passwords hasheados con bcrypt
- Headers de autorización estándar

### Validaciones
- Sanitización de parámetros
- Validaciones de entrada estrictas
- Prevención de inyección SQL

## 📚 Recursos Adicionales

### Documentación
- **API Documentation:** `/api-docs` (Swagger UI)
- **Presentation Guide:** `PRESENTATION.md`

