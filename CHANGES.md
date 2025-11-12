# Registro de Cambios - Diario de Intimidad

## Resumen de Desarrollo

Este documento registra todos los cambios realizados durante la construcción del proyecto "Diario de Intimidad" desde la inicialización hasta la versión actual.

## Cambios por Fecha

### 2025-11-12 - Formulario Diario Diario y Cambios Visuales
- **Backend - Formulario Diario Diario**
  - Creado servicio `DailyEntryService` para lógica de entradas diarias
  - Creado controlador `DailyEntryController` con endpoints GET `/api/daily-entry/today` y POST `/api/daily-entry/save`
  - Creados DTOs `DailyEntryResponse` y `DailyEntryRequest` para manejo de datos
  - Creados repositorios `CamposDiarioRepository` y `ValoresCampoRepository`
  - Agregado método `findByMesMaestroIdAndDiaNumero` en `DiaMaestroRepository`
  - Modificado `UsuarioService` para manejar contraseñas sin encriptar en autenticación
  - Cambiado `estadoLlenado` en `EntradaDiaria` de `Double` a `BigDecimal` para compatibilidad con DECIMAL

- **Frontend - Formulario Diario Diario**
  - Creada página `DailyEntry.tsx` con formulario dinámico
  - Lógica condicional: días NORMAL muestran lectura_biblica, días DOMINGO muestran diario_anual + versiculo_diario
  - Campos dinámicos basados en `CamposDiario` (TEXTO, TEXTAREA, AUDIO)
  - Agregada ruta `/daily-entry` en `App.tsx`
  - Enlace "📖 Diario Diario" en navegación principal

- **Frontend - Cambios Visuales**
  - Cambiado color de fondo a #0900D2 (azul oscuro)
  - Ajustados colores de texto a blanco para visibilidad
  - Cards con fondo semi-transparente rgba(255, 255, 255, 0.95)
  - Header con fondo semi-transparente negro
  - Navegación con texto blanco y hover azul claro
  - Página de login con fondo azul oscuro

- **Backend - Usuario Admin**
  - Contraseña de admin cambiada a 'S@1thgto.2@25' sin encriptar inicialmente
  - Modificado `UsuarioService.authenticate` para comparar directamente si contraseña no está encriptada

- **Frontend - Gestión de Usuarios**
  - Agregada sección "Mi Perfil" deshabilitada para ADMIN y USER
  - Ocultar sección "Mi Perfil" cuando se está editando
  - Solo ADMIN puede cambiar rol de otros usuarios, no el propio

- **Git y GitHub**
  - Inicializado repositorio Git local
  - Creado `.gitignore` para archivos innecesarios
  - Subido código a rama master en GitHub (https://github.com/Sithgto/diario-intimidad.git)
  - Creada rama "enrique" local y remota

### 2025-11-12 - Correcciones de Esquema y Entidades Faltantes
- **Backend - Entidades JPA Completas**
  - Creada entidad `MesMaestro.java` para tabla `mes_maestro`
  - Creada entidad `CamposDiario.java` con enum `TipoEntrada` (TEXTO, TEXTAREA, AUDIO)
  - Creada entidad `ValoresCampo.java` para tabla `valores_campo`
  - Creada entidad `MetaAnual.java` para tabla `meta_anual`
  - Creada entidad `MetaMensual.java` para tabla `meta_mensual`
  - Creada entidad `Pago.java` para tabla `pago`
  - Agregada relación `@ManyToOne` en `DiaMaestro` con `MesMaestro`

- **Backend - Corrección de Esquema**
  - Cambiado `estado_llenado` de `DECIMAL(5,2)` a `DOUBLE PRECISION` en `init.sql`
  - Cambiado `spring.jpa.hibernate.ddl-auto` a `update` para actualizar esquema automáticamente
  - Usuario admin actualizado: `sithgto@gmail.com` con contraseña `S@1thgto.2@25` (sin encriptar inicialmente)

- **Backend - Logs de Depuración**
  - Agregados logs en `AuthController` y `UsuarioService` para autenticación
  - Logs para usuario encontrado, tipo de contraseña, matches exitosos/fallidos

- **Frontend - Header en Gestión de Usuarios**
  - Agregado header con menú principal en página `UserManagement.tsx`
  - Menú dinámico según rol: ADMIN ve más opciones, USER ve limitado

- **Frontend - Gestión de Usuarios por Roles**
  - Implementada lógica de roles: ADMIN ve lista completa, USER solo su perfil
  - Campo opcional de nueva contraseña para usuarios USER en edición
  - Ocultar secciones de crear/eliminar para USER
  - Lista de usuarios solo visible para ADMIN

- **Docker - Espera al Backend**
  - Modificado `Dockerfile` del frontend para esperar al backend con `wait-for-it.sh`
  - CMD actualizado para iniciar nginx solo después de que backend responda

### 2025-11-12 - Mejoras en Interfaz de Usuario y Gestión de Usuarios
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

- **Backend - Usuario Administrador**
  - Cambiado usuario admin por defecto a Sithgto@gmail.com con contraseña S@1thgto.2@25
  - Modificado init.sql para usuario inicial sin encriptar
  - Actualizado UsuarioService para manejar contraseñas sin encriptar en autenticación

- **Backend - Logs de Depuración**
  - Agregados logs detallados en AuthController y UsuarioService
  - Logs para seguimiento de login: usuario encontrado, contraseña encriptada, matches
  - Ayuda en diagnóstico de problemas de autenticación

- **Backend - Configuración CORS**
  - Agregada regla para permitir requests OPTIONS en SecurityConfig
  - Solucionado problema de preflight requests CORS desde frontend

- **Frontend - Menú Dinámico**
  - Header ahora muestra diferentes opciones según estado de login
  - Logueado: Inicio, Gestionar Usuarios, Documentación APIs, usuario actual, Logout
  - No logueado: Inicio, Login
  - Iconos para mejor UX: 👤 para usuario, 🚪 para logout

- **Frontend - CRUD Completo de Usuarios**
  - Implementado formulario completo para crear usuarios (email, password, rol)
  - Agregada funcionalidad de editar usuarios (email, rol)
  - Botón de eliminar con confirmación
  - Lista de usuarios con select para cambiar rol directamente
  - Integración completa con APIs backend

- **Frontend - Corrección ESLint**
  - Agregado eslint-disable para uso de confirm en eliminación de usuarios
  - Solucionado error de compilación en build

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
- ✅ Interfaz web moderna y responsiva con tema azul oscuro
- ✅ Gestión de usuarios basada en roles (ADMIN/USER)
- ✅ Documentación APIs integrada
- ✅ Manejo de errores centralizado
- ✅ Contenerización completa con Docker
- ✅ Espera automática a servicios dependientes (DB y backend)
- ✅ Esquema DB completo con todas las entidades JPA
- ✅ Logs de depuración en backend
- ✅ FFmpeg para procesamiento multimedia
- ✅ Formulario diario diario con campos dinámicos
- ✅ Lógica condicional NORMAL/DOMINGO
- ✅ Repositorio Git en GitHub con ramas

## Próximas Implementaciones (Pendientes)
- STT con Google Cloud Speech-to-Text
- Generación de PDFs de diarios
- Sistema de pagos con Stripe
- Metas anuales y mensuales
- Calendario interactivo de entradas
- Administración completa de diarios anuales

## Notas Técnicas
- Backend espera automáticamente a PostgreSQL con wait-for-it.sh
- Frontend espera al backend antes de servir con wait-for-it.sh
- Frontend usa contexto React para autenticación
- DB inicializa con usuario sithgto@gmail.com / S@1thgto.2@25 (sin encriptar inicialmente)
- Esquema DB completo con 10 tablas y todas las entidades JPA
- Gestión de usuarios basada en roles (ADMIN/USER)
- DDL auto update para evolución automática del esquema
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
Proyecto completamente funcional con esquema DB completo, entidades JPA sincronizadas, gestión de usuarios por roles, logs de depuración, formulario diario diario con campos dinámicos, tema visual azul oscuro, repositorio Git en GitHub y documentación actualizada. Listo para desarrollo adicional de funcionalidades avanzadas como STT, PDFs y pagos.