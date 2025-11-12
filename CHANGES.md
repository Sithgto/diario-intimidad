# Registro de Cambios - Diario de Intimidad

## Resumen de Desarrollo

Este documento registra todos los cambios realizados durante la construcción del proyecto "Diario de Intimidad" desde la inicialización hasta la versión actual.

## Cambios por Fecha

### 2025-11-12 - Mejoras en Interfaz de Usuario
- **Frontend - Página de Inicio Pública**
  - Ruta raíz "/" ahora es pública, sin requerir login
  - Login solo requerido para áreas reservadas (/users, /api-docs)
  - Nueva interfaz de landing page con menú horizontal superior
  - Iconos en navbar: 🏠 Inicio, 🔐 Login
  - Contenido promocional del Diario de Intimidad
  - Beneficios destacados: registro diario, análisis de emociones, privacidad, bienestar mental
  - Placeholder para portada del diario (diseño con gradiente)
  - Diseño responsivo para móviles y desktop

- **Frontend - Configuración SPA**
  - Agregado nginx.conf personalizado para React Router
  - Configuración try_files para fallback a index.html
  - Solucionado error 404 en rutas del lado cliente
  - Actualizado Dockerfile frontend para usar nginx.conf

- **Frontend - Estilos**
  - Nuevos estilos CSS para layout de landing page
  - Header sticky con navbar horizontal
  - Sección hero con texto e imagen
  - Diseño moderno con gradientes y sombras

- **Frontend - Favicon**
  - Cambiado favicon a icono de libro abierto
  - Actualizado enlace en index.html

- **Frontend - Página de Login**
  - Rediseñado formulario de login más pequeño y centrado
  - Agregado contenedor centrado con fondo gradiente
  - Estilos específicos para login-card con ancho máximo de 400px
  - Texto en español: "Iniciar Sesión", "Email", "Contraseña"

- **Frontend - Corrección de Navegación**
  - Reemplazado window.location.href con useNavigate de React Router
  - Cambiado enlaces <a href> por componentes <Link> para navegación SPA
  - Mejorado manejo de navegación en componentes Home y header

### 2025-11-11 - Desarrollo Completo
- **Inicialización del Proyecto**
  - Creación estructura de carpetas: `backend/`, `frontend/`, `DB/`
  - Configuración Docker Compose con PostgreSQL, Spring Boot, React
  - Variables de entorno en `.env`

- **Backend (Spring Boot)**
  - Proyecto Maven con Java 17
  - Dependencias: Spring Web, JPA, PostgreSQL, Security, JWT, Validation, Lombok
  - Entidades JPA: Usuario, DiarioAnual, DiaMaestro, EntradaDiaria con Lombok
  - Repositorios JPA con consultas personalizadas
  - Servicios de negocio con lógica CRUD
  - Controladores REST con CORS para frontend
  - Sistema de autenticación JWT completo
  - Configuraciones: SecurityConfig, JwtUtil, JwtAuthenticationFilter
  - DTOs: LoginRequest, LoginResponse
  - Encriptación BCrypt para passwords
  - FFmpeg instalado en contenedor para STT
  - Script wait-for-it.sh para esperar DB

- **Frontend (React/TypeScript)**
  - Proyecto con Vite/React
  - Dependencias: axios, react-router-dom
  - Componentes: Login, UserManagement, ApiDocs
  - Contexto AuthContext para estado global
  - Router con rutas protegidas por roles
  - Constantes de errores centralizadas
  - CSS moderno con gradientes y responsividad
  - Favicon personalizado (icono de libro)

- **Base de Datos (PostgreSQL)**
  - Esquema completo en `init.sql`: 10 tablas con relaciones
  - Usuario administrador por defecto
  - Healthcheck en Docker Compose

- **Docker y Contenerización**
  - Dockerfile backend: Multi-stage build con wait-for-it
  - Dockerfile frontend: Build + Nginx
  - docker-compose.yml: Orquestación con depends_on y healthcheck
  - Puertos: 5435 (DB), 8085 (backend), 3005 (frontend)

- **Problemas Resueltos**
  - ERR_CONNECTION_REFUSED: Implementado wait-for-it.sh
  - Favicon 404: Configurado link PNG con type correcto
  - Errores JWT: Actualizado a jjwt 0.11.5 compatible
  - Build fallos: Corregido ENTRYPOINT y dependencias
  - Beans duplicados: Eliminado passwordEncoder duplicado en SecurityConfig
  - Script wait-for-it.sh: Corregido para busybox nc en Alpine (separar host:puerto)
  - Dependencias faltantes: Agregado Lombok, axios, react-router-dom

- **Documentación**
  - README.md completo con instalación, APIs, funcionalidades
  - Registro de cambios en CHANGES.md

## Funcionalidades Implementadas
- ✅ Autenticación JWT con roles USER/ADMIN
- ✅ CRUD completo para usuarios, diarios, días, entradas
- ✅ Interfaz web moderna y responsiva
- ✅ Gestión de usuarios (solo ADMIN)
- ✅ Documentación APIs integrada
- ✅ Manejo de errores centralizado
- ✅ Contenerización completa con Docker
- ✅ Espera automática a servicios dependientes
- ✅ FFmpeg para procesamiento multimedia

## Próximas Implementaciones (Pendientes)
- STT con Google Cloud Speech-to-Text
- Generación de PDFs de diarios
- Sistema de pagos con Stripe
- Metas anuales y mensuales
- Calendario interactivo de entradas
- Administración completa de diarios anuales

## Notas Técnicas
- Backend espera automáticamente a PostgreSQL con wait-for-it.sh
- Frontend usa contexto React para autenticación
- DB inicializa con usuario admin@diario.com / password
- Todos los servicios en Docker con healthchecks
- APIs protegidas con JWT, públicas solo login

## Comandos de Verificación
```bash
# Construir y ejecutar
docker-compose up --build -d

# Ver logs
docker-compose logs backend
docker-compose logs frontend

# Acceder DB
docker-compose exec postgres psql -U diario_user -d diario_intimidad

# Detener
docker-compose down
```

## Estado Final
Proyecto completamente funcional y documentado, listo para desarrollo adicional de funcionalidades avanzadas.