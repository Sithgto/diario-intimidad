# Diario de Intimidad

Aplicación web para gestión de diarios personales con autenticación, roles de usuario y funcionalidades avanzadas como STT (Speech-to-Text).

## Arquitectura

- **Frontend**: React con TypeScript, Axios, React Router.
- **Backend**: Spring Boot con Java 17, JPA, JWT, BCrypt.
- **Base de Datos**: PostgreSQL.
- **Contenerización**: Docker Compose.

## Estructura del Proyecto

```
diario_intimidad/
├── backend/                 # API REST Spring Boot
│   ├── src/main/java/com/diario_intimidad/
│   │   ├── config/          # Configuraciones JWT, Security
│   │   ├── controller/      # Controladores REST
│   │   ├── dto/             # DTOs para requests/responses
│   │   ├── entity/          # Entidades JPA
│   │   ├── repository/      # Repositorios JPA
│   │   └── service/         # Servicios de negocio
│   ├── Dockerfile           # Contenedor backend
│   ├── pom.xml              # Dependencias Maven
│   └── wait-for-it.sh       # Script para esperar DB
├── frontend/                # Interfaz React
│   ├── src/
│   │   ├── components/      # Componentes reutilizables
│   │   ├── constants/       # Constantes (errores)
│   │   ├── contexts/        # Contextos React (Auth)
│   │   ├── pages/           # Páginas (Login, UserManagement, etc.)
│   │   └── App.tsx          # Configuración Router
│   ├── Dockerfile           # Contenedor frontend
│   └── package.json         # Dependencias NPM
├── DB/
│   └── init.sql             # Esquema y datos iniciales PostgreSQL
├── docker-compose.yml       # Orquestación servicios
├── .env                     # Variables de entorno
└── README.md                # Esta documentación
```

## Instalación y Ejecución

### Prerrequisitos
- Docker y Docker Compose instalados.
- Puertos 3005 (frontend), 8085 (backend), 5435 (PostgreSQL) libres.

### Pasos
1. Clona el repositorio.
2. Configura variables en `.env` si es necesario.
3. Ejecuta: `docker-compose up --build -d`
4. Accede a http://localhost:3005

### Usuario por Defecto
- **Email**: user@diario.com
- **Password**: password
- **Rol**: USER

## APIs Disponibles

### Autenticación
- `POST /api/auth/login` - Iniciar sesión (email, password) → JWT Token

### Usuarios (Requiere Token)
- `GET /api/usuarios` - Listar usuarios
- `GET /api/usuarios/{id}` - Obtener usuario
- `POST /api/usuarios` - Crear usuario
- `PUT /api/usuarios/{id}` - Actualizar usuario
- `DELETE /api/usuarios/{id}` - Eliminar usuario

### Diarios Anuales
- `GET /api/diarios-anuales` - Listar diarios
- `POST /api/diarios-anuales` - Crear diario
- `PUT /api/diarios-anuales/{id}` - Actualizar
- `DELETE /api/diarios-anuales/{id}` - Eliminar

### Días Maestro
- `GET /api/dias-maestro` - Listar días
- `POST /api/dias-maestro` - Crear día
- `PUT /api/dias-maestro/{id}` - Actualizar
- `DELETE /api/dias-maestro/{id}` - Eliminar

### Entradas Diarias
- `GET /api/entradas-diarias` - Listar entradas
- `GET /api/entradas-diarias/usuario/{usuarioId}/diario/{diarioId}` - Por usuario/diario
- `POST /api/entradas-diarias` - Crear entrada
- `PUT /api/entradas-diarias/{id}` - Actualizar
- `DELETE /api/entradas-diarias/{id}` - Eliminar

## Funcionalidades Implementadas

### Backend
- ✅ Autenticación JWT con roles (USER, ADMIN)
- ✅ Encriptación BCrypt para passwords
- ✅ CRUD completo para entidades principales
- ✅ Manejo de errores con @ControllerAdvice
- ✅ Configuración CORS para frontend
- ✅ Espera automática a DB con wait-for-it.sh
- ✅ FFmpeg instalado para STT

### Frontend
- ✅ Login con validación
- ✅ Gestión de usuarios (solo ADMIN)
- ✅ Documentación APIs integrada
- ✅ Navegación con React Router
- ✅ Contexto de autenticación
- ✅ Manejo de errores centralizado
- ✅ Diseño moderno con CSS
- ✅ Favicon personalizado

### Base de Datos
- ✅ Esquema completo con relaciones
- ✅ Datos iniciales (usuario admin)
- ✅ Healthcheck para Docker

## Cambios Realizados Durante Desarrollo

### Inicialización
- Creación estructura carpetas backend, frontend, DB
- Configuración Docker Compose con PostgreSQL, backend, frontend
- Variables de entorno en .env

### Backend
- Proyecto Spring Boot con Maven
- Dependencias: Web, JPA, PostgreSQL, Security, JWT, Validation, Lombok
- Entidades JPA: Usuario, DiarioAnual, DiaMaestro, EntradaDiaria
- Repositorios JPA con consultas personalizadas
- Servicios con lógica de negocio
- Controladores REST con CORS
- Configuración JWT: JwtUtil, SecurityConfig, JwtAuthenticationFilter
- DTOs: LoginRequest, LoginResponse
- Encriptación passwords con BCrypt
- Bean PasswordEncoder
- FFmpeg en Dockerfile para STT

### Frontend
- Proyecto React con TypeScript
- Dependencias: axios, react-router-dom
- Componentes: Login, UserManagement, ApiDocs
- Contexto AuthContext para estado global
- Router con rutas protegidas
- Constantes de errores en errors.ts
- CSS moderno con gradientes y responsividad
- Favicon de libro

### Base de Datos
- init.sql con tablas: usuario, diario_anual, mes_maestro, dia_maestro, campos_diario, entrada_diaria, valores_campo, meta_anual, meta_mensual, pago
- Usuario admin por defecto
- Healthcheck en Docker Compose

### Docker
- Dockerfile backend: Multi-stage build, wait-for-it.sh
- Dockerfile frontend: Build y Nginx
- docker-compose.yml: Servicios con depends_on y healthcheck
- Puertos: 5435 (DB), 8085 (backend), 3005 (frontend)

### Problemas Resueltos
- ERR_CONNECTION_REFUSED: Implementado wait-for-it.sh para esperar DB
- Favicon 404: Configurado link a PNG con type
- Errores JWT: Actualizado a jjwt 0.11.5 compatible
- Build fallos: Corregido dependencias y ENTRYPOINT

## Próximas Funcionalidades (Pendientes)
- STT con Google Cloud Speech-to-Text
- Generación PDF de diarios
- Pagos con Stripe
- Administración completa de diarios
- Metas anuales/mensuales
- Calendario de entradas

## Comandos Útiles
- `docker-compose up --build` - Construir y ejecutar
- `docker-compose down` - Detener servicios
- `docker-compose logs backend` - Ver logs backend
- `docker-compose exec postgres psql -U diario_user -d diario_intimidad` - Acceder DB

## Contribución
1. Fork el proyecto
2. Crea rama feature
3. Commit cambios
4. Push y PR

## Licencia
MIT