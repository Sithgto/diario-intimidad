# Registro de Cambios - Diario de Intimidad

### 2025-11-24 - Implementación de Navegación por Fecha desde Calendario a Entrada Diaria
- **Archivos afectados:** frontend/src/pages/DailyEntry.tsx, frontend/src/pages/Calendario.tsx, backend/src/main/java/com/diario_intimidad/dto/DailyEntryRequest.java, backend/src/main/java/com/diario_intimidad/controller/DailyEntryController.java, backend/src/main/java/com/diario_intimidad/service/DailyEntryService.java, CHANGES.md
- **Cambios específicos realizados:**
  - **DailyEntry.tsx**: Agregado `useSearchParams` para obtener parámetro `date` de la URL; modificada lógica de carga para usar fecha del parámetro o actual; agregado envío de fecha en request de guardado; cambiado botón "Cerrar" para navegar a `/calendario`.
  - **Calendario.tsx**: Agregado `useNavigate`; modificado `handleDayClick` para navegar a `/daily-entry?date=YYYY-MM-DD` en lugar de mostrar detalles en el mismo componente.
  - **DailyEntryRequest.java**: Agregado campo `fecha` (String) con getter/setter.
  - **DailyEntryController.java**: Modificado `saveEntry` para usar fecha del request o `LocalDate.now()`.
  - **DailyEntryService.java**: Modificado `getTodayData` para devolver versículo por defecto ("Juan 3:16") cuando no hay `DiaMaestro` o `versiculoReference` vacío, asegurando siempre se muestre texto del versículo.
  - **CHANGES.md**: Documentados todos los cambios realizados.
- **Explicación del porqué se realiza el cambio:** Para permitir que los usuarios accedan directamente a la entrada diaria de cualquier fecha desde el calendario, guardando con la fecha correcta y mostrando siempre el texto del versículo.
- **Resultado esperado:** Navegación fluida desde calendario a entrada diaria con fecha específica, guardado correcto por fecha, y visualización consistente del versículo bíblico.

### 2025-11-24 - Mejoras Críticas de Seguridad: Secreto JWT Externalizado, Configuración DDL Segura y Validaciones de Entrada
- **Archivos afectados:** backend/src/main/java/com/diario_intimidad/config/JwtUtil.java, backend/src/main/resources/application.properties, backend/src/main/java/com/diario_intimidad/dto/LoginRequest.java, backend/src/main/java/com/diario_intimidad/controller/AuthController.java, docker-compose.yml, .env.example, .env, CHANGES.md
- **Cambios específicos realizados:**
  - **JwtUtil.java**: Movido secreto JWT hardcodeado a variable de entorno `@Value("${jwt.secret:...}")` con constructor para inyección segura.
  - **application.properties**: Cambiado `ddl-auto=create-drop` a `update` para evitar pérdida de datos en producción; desactivado `show-sql` para no exponer queries en logs; agregado configuración JWT_SECRET.
  - **LoginRequest.java**: Agregadas validaciones `@NotBlank`, `@Email` y `@Size(min=6)` para email y contraseña.
  - **AuthController.java**: Agregado `@Valid` al endpoint de login para activar validaciones automáticas.
  - **docker-compose.yml**: Agregada variable de entorno `JWT_SECRET` para el contenedor backend.
  - **.env.example**: Documentada nueva variable `JWT_SECRET` con instrucciones de generación segura.
  - **.env**: Creado archivo de configuración con JWT_SECRET generado criptográficamente (`zgTDOWmLbnV3uY388cqql/hF22CHIssSGrR3/B/K1Oc=`) y contraseña de BD segura (`2356fcba96acdde9b74eb9b4b062928f`).
  - **CHANGES.md**: Documentadas todas las mejoras de seguridad implementadas.
- **Explicación del porqué se realiza el cambio:** Para corregir vulnerabilidades críticas identificadas en la auditoría de seguridad: secreto JWT expuesto, configuración de BD insegura que borra datos automáticamente, falta de validaciones que permiten inyección de datos maliciosos, y exposición de información sensible en logs.
- **Resultado esperado:** Secreto JWT seguro y configurable, base de datos protegida contra pérdida accidental de datos, validaciones robustas que previenen ataques de entrada, y configuración preparada para entornos de producción seguros.

### 2025-11-24 - Actualización de PostgreSQL a Versión 17, Driver JDBC Compatible y Revisión de Dependencias Futuras
- **Archivos afectados:** docker-compose.yml, backend/pom.xml, backend/src/main/resources/application.properties, CHANGES.md
- **Cambios específicos realizados:**
  - **docker-compose.yml**: Actualizada imagen de PostgreSQL de `postgres:13` a `postgres:17` para usar la versión más reciente con mejoras de rendimiento y seguridad.
  - **backend/pom.xml**: Actualizada dependencia del driver JDBC de PostgreSQL de versión implícita (42.6.0) a `42.7.3` para compatibilidad completa con PostgreSQL 17.
  - **backend/src/main/resources/application.properties**: Verificado dialecto de Hibernate (mantenido como `PostgreSQLDialect` ya que es compatible con PostgreSQL 17).
  - **CHANGES.md**: Documentados todos los cambios realizados y recomendaciones para futuras actualizaciones de dependencias.
- **Explicación del porqué se realiza el cambio:** Para actualizar la base de datos a PostgreSQL 17 aprovechando sus mejoras de rendimiento, seguridad y nuevas características, asegurando compatibilidad completa con el driver JDBC actualizado y preparando el proyecto para futuras mejoras de dependencias.
- **Resultado esperado:** Base de datos PostgreSQL 17 funcionando correctamente con el driver JDBC compatible, mejor rendimiento y estabilidad, y documentación completa de cambios realizados y recomendaciones futuras.

### 2025-11-21 - Configuración CORS para Permitir Orígenes Temporales en el Backend y Actualización de URLs de API en el Frontend
- **Archivos afectados:** backend/src/main/java/com/diario_intimidad/config/SecurityConfig.java, frontend/src/constants/api.ts, frontend/src/pages/Login.tsx, frontend/src/pages/UserManagement.tsx, frontend/src/pages/DiarioAnual.tsx, frontend/src/pages/DailyEntry.tsx, frontend/src/pages/Calendario.tsx, frontend/src/pages/Biblia.tsx
- **Cambios específicos realizados:**
  - **SecurityConfig.java**: Agregadas importaciones para CorsConfiguration, CorsConfigurationSource y UrlBasedCorsConfigurationSource; modificado filterChain para incluir configuración CORS con cors().configurationSource(corsConfigurationSource()); agregado método corsConfigurationSource() que configura patrones de origen "*", métodos permitidos (GET, POST, PUT, DELETE, OPTIONS), headers "*" y allowCredentials true.
  - **api.ts**: Nuevo archivo con constante API_BASE_URL = 'http://192.168.1.40:8085'.
  - **Login.tsx, UserManagement.tsx, DiarioAnual.tsx, DailyEntry.tsx, Calendario.tsx, Biblia.tsx**: Agregado import de API_BASE_URL y reemplazadas todas las URLs hardcoded 'http://localhost:8085' con '${API_BASE_URL}'.
- **Explicación del porqué se realiza el cambio:** Para resolver problemas de CORS que impiden el acceso desde el frontend al backend, permitiendo temporalmente todos los orígenes; y para corregir las URLs de API en el frontend que apuntaban a localhost en lugar del servidor remoto, permitiendo que el frontend acceda al backend correctamente desde cualquier PC.
- **Resultado esperado:** Las solicitudes CORS desde el frontend al backend se permiten sin errores, y el frontend puede validar credenciales y hacer peticiones a la API del servidor remoto en lugar de localhost.

### 2025-11-20 - Corrección Completa de API Bíblica, Interfaz de Versículos, Lógica de Días, Mejoras Visuales, Botón Scroll to Top, Estilos de Campos, Gestión CRUD de Entradas Diarias y Redirección si Ya Rellenada
- **Archivos afectados:** backend/src/main/java/com/diario_intimidad/controller/BibleController.java, frontend/src/pages/DailyEntry.tsx, backend/src/main/java/com/diario_intimidad/service/DailyEntryService.java, backend/src/main/java/com/diario_intimidad/controller/DailyEntryController.java, backend/src/main/java/com/diario_intimidad/dto/CalendarEntryResponse.java, backend/src/main/java/com/diario_intimidad/repository/EntradaDiariaRepository.java, frontend/src/App.tsx, frontend/src/components/ScrollToTop.tsx, CHANGES.md
- **Cambios específicos realizados:**
  - **BibleController.java**: Unificada API a bible-api.deno.dev para todas las traducciones; corregido parsing de respuesta como List<Map> en lugar de Map; agregado parámetro includeNumbers para incluir/excluir números de versículos; actualizado getBookCode con nombres correctos en español; agregado logs de error.
  - **DailyEntry.tsx**: Cambiado logoUrl a nombreLogo; ajustado tamaño del logo a 120px; eliminado display de título y año del diario; agregado estado showNumbers con checkbox "Mostrar números de versículos" (default false); convertido botones "Escuchar" y "Recargar" a iconos circulares con tooltips; modificado fetchVerses para incluir parámetro includeNumbers; agregado logs detallados para depuración; aplicado fondo gris oscuro (#e0e0e0) a campos que contienen "Oración" o "Prioridades" sin afectar color del texto; implementado gestión CRUD con estados isSaved y hasChanges, botones condicionales "Guardar", "Cerrar" y "Actualizar"; agregado redirección automática a inicio si la entrada ya está rellenada.
  - **DailyEntryService.java**: Corregida lógica para NORMAL/DOMINGO: NORMAL envía lecturaBiblica como versiculoDiario, DOMINGO envía versiculoDiario; agregado carga de valores existentes si hay entrada previa.
  - **DailyEntryController.java**: Agregados logs detallados de la respuesta enviada al frontend; agregado extracción de userId de authentication para cargar valores existentes.
  - **CalendarEntryResponse.java**: Agregado campo valoresCampo para devolver valores existentes.
  - **EntradaDiariaRepository.java**: Agregado método findByUsuarioIdAndFechaEntrada para buscar entradas existentes.
  - **App.tsx**: Agregado componente ScrollToTop para navegación al inicio.
  - **ScrollToTop.tsx**: Nuevo componente con botón flotante que aparece al hacer scroll vertical, permite volver al inicio con animación suave.
  - Reiniciados servicios para aplicar cambios.
- **Explicación del porqué se realiza el cambio:** Para resolver problemas de carga de versículos bíblicos, actualizar campos y lógica de días, mejorar la interfaz con opciones de visualización, botones intuitivos, depuración completa, navegación mejorada, diferenciación visual de campos específicos, gestión completa de entradas diarias con estados CRUD y redirección automática si ya rellenada.
- **Resultado esperado:** Versículos se cargan automáticamente según tipo de día, API funciona correctamente con bible-api.deno.dev, interfaz permite controlar números de versículos, botones circulares con tooltips mejoran UX, botón scroll to top facilita navegación, campos "Oración" y "Prioridades" tienen fondo gris distintivo, gestión CRUD permite guardar, cerrar y actualizar entradas, redirección automática si ya rellenada, logs permiten debugging completo.

## Resumen de Desarrollo

Este documento registra todos los cambios realizados durante la construcción del proyecto "Diario de Intimidad" desde la inicialización hasta la versión actual.

## Tecnologías y Dependencias

- **Backend:**
  - Java: 21
  - Spring Boot: 3.2.0
  - PostgreSQL: 13

- **Frontend:**
  - React: 18.2.0
  - TypeScript: 4.9.0

- **Contenerización:**
  - Docker
## Cambios por Fecha
### 2025-11-19 - Corrección de Script wait-for-it.sh en Contenedores Docker
- **Archivos afectados:** frontend/Dockerfile, backend/Dockerfile
- **Cambios específicos realizados:** Agregada la instalación de `dos2unix` y su ejecución sobre los scripts `wait-for-it.sh` en los Dockerfiles de frontend y backend.
- **Explicación del porqué se realiza el cambio:** Para solucionar el error `exec /wait-for-it.sh: no such file or directory` causado por finales de línea de Windows (CRLF) en un entorno Linux (LF). La conversión a formato Unix asegura la correcta ejecución del script.
- **Resultado esperado:** Los contenedores inician sin errores relacionados con el script `wait-for-it.sh`, mejorando la estabilidad del arranque de los servicios.

### 2025-11-19 - Cambio de Color de Fondo a Blanco y Mejoras en Diario Anual
- **Archivos afectados:** frontend/src/App.tsx, frontend/src/components/Header.tsx, frontend/src/index.css, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Cambiado el color de fondo a blanco, actualizado header y footer, mejorado el manejo de Diario Anual con nuevas funcionalidades.
- **Explicación del porqué se realiza el cambio:** Para mejorar la estética visual y la funcionalidad del diario anual.
- **Resultado esperado:** Interfaz más clara y funcional.

### 2025-11-19 - Modificación Completa de Diario Anual Funcionando
- **Archivos afectados:** CHANGES.md, DB/init.sql, backend/src/main/java/com/diario_intimidad/config/SecurityConfig.java, backend/src/main/java/com/diario_intimidad/config/WebConfig.java, backend/src/main/java/com/diario_intimidad/controller/DiarioAnualController.java, backend/src/main/java/com/diario_intimidad/service/DiarioAnualService.java, backend/src/main/resources/application.properties, docker-compose.yml, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Actualizaciones en configuración de seguridad, web, controlador y servicio de Diario Anual, cambios en base de datos y frontend.
- **Explicación del porqué se realiza el cambio:** Para completar y corregir la funcionalidad de modificación de diarios anuales.
- **Resultado esperado:** Diario Anual completamente funcional con todas las operaciones CRUD.

### 2025-11-19 - Mejora en Manejo de Diarios con Imágenes por Defecto
- **Archivos afectados:** CHANGES.md, DB/init.sql, backend/src/main/java/com/diario_intimidad/controller/DiarioAnualController.java, backend/src/main/java/com/diario_intimidad/entity/DiarioAnual.java, backend/src/main/resources/application.properties, frontend/public/images/default-cover.jpg, frontend/public/images/default-logo.jpg, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Agregadas imágenes por defecto para carátula y logo, actualizada entidad DiarioAnual, controlador y frontend.
- **Explicación del porqué se realiza el cambio:** Para proporcionar una mejor experiencia visual con imágenes por defecto cuando no se suben personalizadas.
- **Resultado esperado:** Los diarios muestran imágenes por defecto mejorando la presentación.

### 2025-11-19 - Implementación de Manejo de Diarios Anuales con Tarjetas Básicas
- **Archivos afectados:** CHANGES.md, DB/init.sql, backend/src/main/java/com/diario_intimidad/config/SecurityConfig.java, backend/src/main/java/com/diario_intimidad/config/WebConfig.java, backend/src/main/java/com/diario_intimidad/controller/DiarioAnualController.java, backend/src/main/java/com/diario_intimidad/entity/DiarioAnual.java, backend/src/main/resources/application.properties, frontend/package.json, frontend/src/App.tsx, frontend/src/components/ErrorDisplay.tsx, frontend/src/components/Menu.tsx, frontend/src/contexts/ErrorContext.tsx, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Implementado sistema de manejo de errores, actualizado controlador y entidad, agregado proxy en package.json, mejorado frontend con tarjetas para diarios.
- **Explicación del porqué se realiza el cambio:** Para proporcionar una interfaz de usuario mejorada con tarjetas para gestionar diarios anuales y manejo centralizado de errores.
- **Resultado esperado:** Gestión intuitiva de diarios con tarjetas y errores manejados globalmente.

### 2025-11-19 - Redirección Automática a Página HOY Después de Login
- **Archivos afectados:** CHANGES.md, frontend/src/pages/Login.tsx
- **Cambios específicos realizados:** Agregada redirección automática a la página HOY tras login exitoso.
- **Explicación del porqué se realiza el cambio:** Para mejorar el flujo de usuario dirigiéndolo directamente a la funcionalidad principal.
- **Resultado esperado:** Usuarios acceden inmediatamente a la página HOY después de iniciar sesión.

### 2025-11-19 - Color Homogéneo en Azul para Header y Footer
- **Archivos afectados:** frontend/src/App.tsx, frontend/src/components/Menu.tsx, frontend/src/index.css, frontend/src/pages/Login.tsx
- **Cambios específicos realizados:** Aplicado color azul homogéneo en header, footer y otros componentes.
- **Explicación del porqué se realiza el cambio:** Para mantener consistencia visual en toda la aplicación.
- **Resultado esperado:** Apariencia uniforme y profesional.

### 2025-11-19 - Mejora en Pantalla de Login
- **Archivos afectados:** frontend/package.json, frontend/src/App.tsx, frontend/src/components/Footer.tsx, frontend/src/components/Header.tsx, frontend/src/components/Menu.tsx, frontend/src/index.css, frontend/src/pages/ApiDocs.tsx, frontend/src/pages/Calendario.tsx, frontend/src/pages/DailyEntry.tsx, frontend/src/pages/Login.tsx, frontend/src/pages/UserManagement.tsx
- **Cambios específicos realizados:** Mejorada la pantalla de login con estilos actualizados, agregado footer, actualizado header y menú.
- **Explicación del porqué se realiza el cambio:** Para proporcionar una experiencia de login más atractiva y funcional.
- **Resultado esperado:** Pantalla de login mejorada con mejor usabilidad.

### 2025-11-19 - Eliminación de Selección de Diario en Página HOY
- **Archivos afectados:** CHANGES.md, DB/init.sql, frontend/package.json, frontend/src/App.tsx, frontend/src/components/Menu.tsx, frontend/src/contexts/AuthContext.tsx, frontend/src/index.tsx, frontend/src/pages/ApiDocs.tsx, frontend/src/pages/DailyEntry.tsx
- **Cambios específicos realizados:** Eliminada la selección de diario en la página HOY, actualizado contexto de autenticación y otras páginas.
- **Explicación del porqué se realiza el cambio:** Para simplificar la interfaz eliminando selecciones innecesarias.
- **Resultado esperado:** Página HOY más directa y fácil de usar.

### 2025-11-19 - Cambio de Menú a HOY y Encriptación de Contraseñas
- **Archivos afectados:** CHANGES.md, DB/init.sql, backend/Dockerfile, backend/pom.xml, backend/src/main/java/com/diario_intimidad/entity/CamposDiario.java, backend/src/main/java/com/diario_intimidad/repository/CamposDiarioRepository.java, backend/src/main/java/com/diario_intimidad/service/DailyEntryService.java, backend/src/main/resources/application.properties, docker-compose.yml, frontend/src/components/Menu.tsx, frontend/src/pages/ApiDocs.tsx, frontend/src/pages/Calendario.tsx, frontend/src/pages/DailyEntry.tsx, frontend/src/pages/UserManagement.tsx
- **Cambios específicos realizados:** Cambiado menú principal a "HOY", implementada encriptación de contraseñas, actualizadas dependencias y servicios.
- **Explicación del porqué se realiza el cambio:** Para mejorar la navegación y seguridad con contraseñas encriptadas.
- **Resultado esperado:** Menú centrado en HOY y mayor seguridad en autenticación.

### 2025-11-19 - Modificación de Tareas Diarias
- **Archivos afectados:** DB/init.sql
- **Cambios específicos realizados:** Actualizadas las tareas diarias en la base de datos inicial.
- **Explicación del porqué se realiza el cambio:** Para ajustar y mejorar las tareas diarias disponibles.
- **Resultado esperado:** Tareas diarias actualizadas y funcionales.

### 2025-11-18 - Adición de Estados de Carga para Subidas de Imágenes, Deshabilitación del Botón "Actualizar" Durante Carga, y Mensaje "Subiendo imagen..."
- **Archivos afectados:** frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Agregados estados de carga para subidas de imágenes, deshabilitación del botón "Actualizar" durante la carga, y mensaje "Subiendo imagen..." para feedback visual.
- **Explicación del porqué se realiza el cambio:** Para mejorar la experiencia del usuario proporcionando retroalimentación durante las subidas de imágenes y previniendo envíos múltiples mientras se procesa la carga.
- **Resultado esperado:** Los usuarios ven un indicador de carga y no pueden actualizar mientras se sube una imagen, reduciendo errores y mejorando la usabilidad.

### 2025-11-18 - Implementación de Subida Automática de Imágenes al Seleccionar Archivo, Eliminación de Estados selectedFile y Botones, y Actualización de handleUpdate
- **Archivos afectados:** frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Implementada subida automática de imágenes al seleccionar archivos para carátula y logo; eliminados los estados selectedFile y los botones manuales de subida; actualizada la función handleUpdate para manejar el nuevo flujo de subida automática.
- **Explicación del porqué se realiza el cambio:** Para simplificar la experiencia del usuario eliminando pasos manuales innecesarios, automatizando el proceso de subida de imágenes y reduciendo la complejidad del estado del componente.
- **Resultado esperado:** Los usuarios pueden seleccionar archivos y las imágenes se suben automáticamente sin necesidad de botones adicionales, mejorando la eficiencia y reduciendo posibles errores en la interfaz.

### 2025-11-18 - Corrección de la URL de upload para evitar doble slash y cambio de WebConfig a ruta absoluta para servir imágenes
- **Archivos afectados:** backend/src/main/java/com/diario_intimidad/config/WebConfig.java, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** En WebConfig.java, cambiada la ubicación de recursos de "file:uploads/" a "file:/app/uploads/" para usar ruta absoluta; corregida la construcción de URL de upload en el frontend para evitar doble slash al concatenar baseUrl y ruta relativa.
- **Explicación del porqué se realiza el cambio:** Para resolver problemas de acceso a imágenes en el contenedor Docker usando rutas absolutas, y evitar errores de URL malformadas causadas por doble slash en las solicitudes de upload.
- **Resultado esperado:** Las imágenes se sirven correctamente desde rutas absolutas en el servidor, y las URLs de upload se construyen sin doble slash, mejorando la estabilidad de las subidas de archivos.

### 2025-11-18 - Correcciones en DiarioAnual.tsx: Cambio de response.json() a text() en upload, Ajuste de URLs, Visualización única de imágenes en formulario, y Aseguramiento de actualización de lista
- **Archivos afectados:** frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Cambiado response.json() a text() en la función de upload; ajustadas las URLs para correcta resolución; implementada visualización única de imágenes en el formulario; asegurado que la lista se actualice correctamente después de operaciones.
- **Explicación del porqué se realiza el cambio:** Para corregir errores en el manejo de respuestas de upload, mejorar la resolución de URLs, evitar duplicaciones en la visualización de imágenes, y garantizar que la lista refleje los cambios inmediatamente.
- **Resultado esperado:** Las subidas de archivos funcionan correctamente, las URLs se resuelven apropiadamente, las imágenes se muestran sin duplicados, y la lista se actualiza automáticamente tras modificaciones.

### 2025-11-18 - Adición de Imágenes por Defecto para Carátula y Logo, Uso en Frontend y Ocultación de Botón en Modo Edición
- **Archivos afectados:** frontend/public/images/default-cover.jpg, frontend/public/images/default-logo.jpg, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Agregadas imágenes por defecto default-cover.jpg y default-logo.jpg en frontend/public/images/; implementado uso de estas imágenes en el frontend cuando no hay imágenes personalizadas subidas; ocultado el botón "Crear Nuevo Diario" en modo edición para evitar confusión.
- **Explicación del porqué se realiza el cambio:** Para proporcionar una experiencia visual consistente mostrando imágenes por defecto cuando los usuarios no han subido carátulas o logos personalizados, y para mejorar la interfaz ocultando acciones irrelevantes durante la edición de diarios.
- **Resultado esperado:** Los usuarios ven imágenes por defecto en lugar de espacios vacíos, y la interfaz es más limpia en modo edición sin botones distractores.

### 2025-11-18 - Cambio de ddl-auto a 'none' para Usar Solo init.sql y Evitar Conflictos de Esquema
- **Archivos afectados:** backend/src/main/resources/application.properties
- **Cambios específicos realizados:** Cambiado spring.jpa.hibernate.ddl-auto de 'create' a 'none' en application.properties para usar únicamente el esquema definido en init.sql y evitar conflictos de esquema.
- **Explicación del porqué se realiza el cambio:** Para prevenir que Hibernate modifique automáticamente el esquema de la base de datos, asegurando que solo se use el esquema definido en init.sql y evitando conflictos potenciales durante el desarrollo y despliegue.
- **Resultado esperado:** El esquema de la base de datos se mantiene consistente con init.sql sin modificaciones automáticas de Hibernate, reduciendo riesgos de conflictos de esquema.

### 2025-11-18 - Cambio de ddl-auto a 'create' para Resolver Error de Validación de Esquema y Reinicio del Backend
- **Archivos afectados:** backend/src/main/resources/application.properties
- **Cambios específicos realizados:** Cambiado spring.jpa.hibernate.ddl-auto de 'update' a 'create' en application.properties para resolver errores de validación de esquema; reiniciado el backend para aplicar el cambio.
- **Explicación del porqué se realiza el cambio:** Para resolver errores de validación de esquema que ocurrían con 'update', cambiando a 'create' que recrea el esquema completamente, y reiniciar el backend para asegurar que los cambios se apliquen correctamente.
- **Resultado esperado:** El esquema se recrea sin errores de validación, y el backend se reinicia exitosamente, permitiendo el funcionamiento correcto de la aplicación.

### 2025-11-18 - Adición de ALTER TABLE en init.sql para Actualizar Esquema con Nuevas Columnas y Reinicio del Backend
- **Archivos afectados:** DB/init.sql
- **Cambios específicos realizados:** Agregados comandos ALTER TABLE en init.sql para añadir nuevas columnas al esquema de la base de datos; reiniciado el backend para aplicar los cambios en el esquema.
- **Explicación del porqué se realiza el cambio:** Para actualizar el esquema de la base de datos con nuevas columnas requeridas para expandir funcionalidades, y asegurar que el backend se sincronice con los cambios del esquema.
- **Resultado esperado:** El esquema se actualiza exitosamente con las nuevas columnas, y el backend se reinicia sin problemas, permitiendo el funcionamiento correcto de las nuevas funcionalidades.

### 2025-11-18 - Adición de Campo Status a DiarioAnual con Filtro y Select Dropdown
- **Archivos afectados:** backend/src/main/java/com/diario_intimidad/entity/DiarioAnual.java, DB/init.sql, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Agregado campo status de tipo String con valores posibles "Desarrollo", "Descatalogado", "Activo" en la entidad DiarioAnual con anotaciones @NotNull y @Column(nullable = false); actualizado esquema en init.sql agregando columna status VARCHAR(50) NOT NULL y modificando inserts para incluir status 'Activo'; en DiarioAnual.tsx agregado status a la interfaz, estado del formulario y validaciones, select dropdown en formulario con opciones, display de status en tarjetas, filtro con checkbox para mostrar solo "Activo" por defecto con opción de mostrar todos.
- **Explicación del porqué se realiza el cambio:** Para categorizar los diarios anuales según su estado de desarrollo y permitir a los usuarios filtrar la vista para enfocarse en diarios activos, mejorando la organización y usabilidad de la gestión de diarios.
- **Resultado esperado:** Los usuarios pueden asignar status a diarios, ver el status en las tarjetas, y filtrar para mostrar solo diarios "Activo" o todos, facilitando la navegación y gestión según el estado del diario.

### 2025-11-18 - Adición de Campos de Timestamp, Detección de Cambios en Archivos Seleccionados, Layout Mejorado de Carátula y Logo, e Historial Básico de Fechas
- **Archivos afectados:** frontend/src/pages/DiarioAnual.tsx, backend/src/main/java/com/diario_intimidad/entity/DiarioAnual.java, backend/src/main/java/com/diario_intimidad/controller/DiarioAnualController.java
- **Cambios específicos realizados:** Agregados campos de timestamp (createdAt, updatedAt) en la entidad DiarioAnual con anotaciones @CreationTimestamp y @UpdateTimestamp; implementada detección de cambios en archivos seleccionados mediante comparación de estado previo y actual en el frontend; mejorado el layout de carátula y logo con estilos CSS responsivos y previsualización en tiempo real; agregado historial básico de fechas mostrando la fecha de creación y última modificación en la interfaz.
- **Explicación del porqué se realiza el cambio:** Para mejorar el seguimiento de cambios en los diarios anuales, proporcionar feedback visual inmediato sobre selecciones de archivos, optimizar la presentación de elementos visuales clave, y ofrecer un historial simple para que los usuarios puedan ver cuándo se crearon o modificaron sus diarios.
- **Resultado esperado:** Los usuarios ven timestamps precisos para creación y actualización, detectan cambios en archivos antes de confirmar, disfrutan de un layout más atractivo y funcional para carátulas y logos, y acceden a un historial básico de fechas que facilita la gestión de sus diarios.

### 2025-11-18 - Adición de Proxy en package.json para Resolver NETWORK_ERROR en Uploads y Reinicio de Servicios
- **Archivos afectados:** frontend/package.json
- **Cambios específicos realizados:** Agregada la línea "proxy": "http://localhost:8085" en el archivo package.json para redirigir las solicitudes API al backend durante el desarrollo.
- **Explicación del porqué se realiza el cambio:** Para resolver errores NETWORK_ERROR en las subidas de archivos, ya que el frontend en modo desarrollo no puede hacer solicitudes directas al backend en un puerto diferente sin configuración de proxy.
- **Resultado esperado:** Las subidas de archivos funcionan correctamente sin errores de red, permitiendo que las solicitudes se proxyen automáticamente al backend.
- **Servicios**
  - Reinicio de servicios para aplicar los cambios

### 2025-11-18 - Mejoras en DiarioAnual: Previsualización de Imágenes y Subida Manual
- **Archivos afectados:** frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Agregadas funciones handlePortadaSelect, handlePortadaUpload, handleLogoSelect, handleLogoUpload para manejo de selección y subida de archivos; agregado estado para previsualización (portadaPreview, logoPreview); cambiadas etiquetas de inputs a "Carátula" y "Logo"; agregados placeholders como "Ejemplo: 2023", "Ejemplo: Mi Diario 2023", etc.; implementado renderizado condicional de imágenes de previsualización y subidas.
- **Explicación del porqué se realiza el cambio:** Para mejorar la experiencia del usuario al permitir previsualizar imágenes antes de subirlas y controlar manualmente el proceso de subida, además de hacer la interfaz más intuitiva con etiquetas claras y ejemplos.
- **Resultado esperado:** Los usuarios pueden seleccionar archivos, ver una previsualización antes de subir, subir manualmente con botones dedicados, y ver las imágenes subidas en la interfaz.

### 2025-11-18 - Redirección Automática Después de Login
- **Archivos afectados:** frontend/src/pages/Login.tsx
- **Cambios específicos realizados:** En la función handleSubmit, después de login(response.data.token, response.data.email, response.data.rol), agregado navigate('/daily-entry').
- **Explicación del porqué se realiza el cambio:** Para mejorar la experiencia del usuario dirigiendo automáticamente a la funcionalidad principal del diario después del login, en lugar de la página de inicio.
- **Resultado esperado:** Los usuarios son redirigidos automáticamente a la página de entrada diaria tras un login exitoso.

### 2025-11-18 - Incorporación de logoUrl en DiarioAnual y CRUD Frontend Completo
- **Archivos afectados:** backend/src/main/java/com/diario_intimidad/entity/DiarioAnual.java, frontend/src/pages/DiarioAnual.tsx, backend/src/main/java/com/diario_intimidad/controller/DiarioAnualController.java
- **Cambios específicos realizados:** Agregado campo logoUrl de tipo String en la entidad DiarioAnual con anotación @Column(name = "logo_url"); implementadas funciones handleCreate, handleUpdate, handleDelete en DiarioAnual.tsx con llamadas a API; agregado método PUT en DiarioAnualController.java para actualizar campos no nulos; configurado cascade delete en relaciones.
- **Explicación del porqué se realiza el cambio:** Para completar el modelo de DiarioAnual con soporte para logos, y proporcionar una interfaz completa de gestión CRUD para que los usuarios puedan administrar sus diarios anuales.
- **Resultado esperado:** Los diarios anuales pueden tener logos asociados, y los usuarios pueden crear, leer, actualizar y eliminar diarios a través de la interfaz web.
### 2025-11-18 - Implementación de Subida de Imágenes para portadaUrl y logoUrl en DiarioAnual
- **Archivos afectados:** backend/src/main/java/com/diario_intimidad/controller/DiarioAnualController.java, backend/src/main/java/com/diario_intimidad/config/WebConfig.java, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Agregado método uploadImage en DiarioAnualController.java que recibe MultipartFile, genera nombre único con UUID, guarda en uploads/images/, retorna URL relativa; configurado WebConfig.java con addResourceHandler("/uploads/**").addResourceLocations("file:uploads/"); implementado manejo de subida en DiarioAnual.tsx con FormData y llamadas al endpoint.
- **Explicación del porqué se realiza el cambio:** Para permitir que los usuarios suban imágenes para las carátulas y logos de sus diarios anuales, almacenándolas en el servidor y sirviéndolas estáticamente.
- **Resultado esperado:** Los usuarios pueden subir imágenes que se almacenan en el servidor y se muestran correctamente en la aplicación.
### 2025-11-18 - Implementación del Sistema Global de Manejo de Errores en el Frontend
- **Archivos afectados:** frontend/src/contexts/ErrorContext.tsx, frontend/src/components/ErrorDisplay.tsx, frontend/src/App.tsx, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Creado ErrorContext con useState para error, setError y clearError; creado ErrorDisplay componente que muestra error en posición fija con botón de cerrar; envuelto App en ErrorProvider; usado useError en DiarioAnual.tsx para setError en catches.
- **Explicación del porqué se realiza el cambio:** Para proporcionar un manejo consistente y centralizado de errores en toda la aplicación frontend, mejorando la experiencia del usuario al mostrar errores de manera clara y permitir su cierre.
- **Resultado esperado:** Los errores se muestran en una notificación fija en la esquina superior derecha, y los usuarios pueden cerrarlos manualmente.
### 2025-11-18 - Adición de Validaciones de Obligatoriedad para Campos en DiarioAnual
- **Archivos afectados:** backend/src/main/java/com/diario_intimidad/entity/DiarioAnual.java, frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Agregadas anotaciones @NotNull en titulo y temaPrincipal en la entidad (anio ya era nullable=false); agregadas validaciones en handleCreate y handleUpdate en DiarioAnual.tsx para verificar que anio, titulo y temaPrincipal no estén vacíos.
- **Explicación del porqué se realiza el cambio:** Para asegurar que los diarios anuales tengan información esencial completa, previniendo la creación de registros incompletos.
- **Resultado esperado:** Los usuarios reciben errores de validación si intentan crear o actualizar un diario sin anio, titulo o temaPrincipal.
### 2025-11-18 - Eliminación de Botones "Subir Archivo" y Subida Automática de Imágenes con Validación
- **Archivos afectados:** frontend/src/pages/DiarioAnual.tsx, backend/src/main/java/com/diario_intimidad/controller/DiarioAnualController.java
- **Cambios específicos realizados:** Eliminados botones "Subir Archivo" para portada y logo; implementada subida automática de imágenes al crear/actualizar diario anual; agregada validación de campos requeridos (anio, titulo, temaPrincipal) antes de la subida.
- **Explicación del porqué se realiza el cambio:** Para simplificar la interfaz de usuario eliminando pasos manuales de subida, automatizando el proceso y asegurando que solo se suban imágenes cuando los campos requeridos estén completos.
- **Resultado esperado:** Los usuarios crean o actualizan diarios con subida automática de imágenes solo si los campos requeridos están validados, mejorando la eficiencia y reduciendo errores.

### 2025-11-18 - Cambio de Layout a Tarjetas en DiarioAnual.tsx, Inclusión de Imagen por Defecto, Botón "Crear Nuevo Diario" y Formulario Condicional
- **Archivos afectados:** frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Cambiado el layout de lista a tarjetas para mostrar los diarios anuales; incluida una imagen por defecto cuando no hay portada; agregado botón "Crear Nuevo Diario" para iniciar la creación; implementado formulario condicional que se muestra para crear o editar diarios.
- **Explicación del porqué se realiza el cambio:** Para mejorar la experiencia del usuario con una interfaz más visual y atractiva, facilitando la navegación y gestión de diarios anuales.
- **Resultado esperado:** Los usuarios ven los diarios en tarjetas con imágenes, pueden crear nuevos diarios fácilmente, y el formulario aparece condicionalmente para operaciones de creación o edición.

### 2025-11-18 - Ocultación de la Lista de Tarjetas en Modo Edición y Botón "Actualizar" Condicional Basado en Cambios
- **Archivos afectados:** frontend/src/pages/DiarioAnual.tsx
- **Cambios específicos realizados:** Implementada lógica para ocultar la lista de tarjetas cuando se está editando un diario; agregado estado para rastrear cambios en los campos del formulario; el botón "Actualizar" solo se muestra cuando hay cambios detectados.
- **Explicación del porqué se realiza el cambio:** Para mejorar la experiencia del usuario enfocando la atención en la edición sin distracciones visuales, y optimizando la interfaz al mostrar acciones solo cuando son necesarias.
- **Resultado esperado:** En modo edición, los usuarios ven únicamente el formulario de edición sin la lista de tarjetas; el botón "Actualizar" aparece solo cuando se detectan cambios en los campos, reduciendo confusión y mejorando la eficiencia.

### 2025-11-17 - Cambios en Sesión Actual
- **Actualización a Java 21**
  - Actualizado Java de versión 17 a 21
  - Actualizado Spring Boot de 3.0.0 a 3.2.0 para compatibilidad con Java 21
  - Actualizado Lombok a 1.18.30 para soporte completo de Java 21
  - Modificado Dockerfile para usar eclipse-temurin:21-jdk-alpine y eclipse-temurin:21-jre
  - Instalación manual de Maven y ffmpeg en el contenedor de build
  - Validado build exitoso con docker-compose

- **Correcciones en la Base de Datos**
  - Correcciones realizadas en el esquema y entidades de la base de datos

- **Correcciones en el Frontend**
  - Mejoras y correcciones en la interfaz de usuario del frontend

- **Correcciones en la Autenticación**
  - Actualizaciones y correcciones en el sistema de autenticación

- **Correcciones en el Menú**
  - Ajustes y mejoras en el componente de menú

- **Actualizaciones en API Docs**
  - Documentación actualizada de las APIs

### 2025-11-17 - Actualización a Java 21
- **Backend - Actualización de Java y Dependencias**
  - Actualizado Java de versión 17 a 21
  - Actualizado Spring Boot de 3.0.0 a 3.2.0 para compatibilidad con Java 21
  - Actualizado Lombok a 1.18.30 para soporte completo de Java 21
  - Modificado Dockerfile para usar eclipse-temurin:21-jdk-alpine y eclipse-temurin:21-jre
  - Instalación manual de Maven y ffmpeg en el contenedor de build
  - Validado build exitoso con docker-compose

### 2025-11-13 - Creación del Componente de Menú Compartido Menu.tsx
- **Frontend - Componente Menu**
  - Creado componente Menu.tsx compartido
  - Integrado en todas las páginas excepto Login

### 2025-11-13 - Adición de Campo Orden en CamposDiario
- **Backend - CamposDiario**
  - Agregado campo 'orden' a CamposDiario.java
  - Modificado CamposDiarioRepository.java para ordenar por 'orden' ascendente


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

### 2025-11-13 - Logs de Debugging y Corrección de Enum
- **Backend - Logs de Debugging**
  - Agregados logs en DailyEntryController.java para debugging de la petición del calendario

- **Frontend - Logs de Debugging**
  - Agregados logs en Calendario.tsx para debugging de la petición del calendario

- **Backend - Corrección de Enum**
  - Agregados 'APLICACION', 'ORACION' y 'PRIORIDADES' al enum TipoEntrada en CamposDiario.java para resolver errores de enum

- **Backend - Cambio de Enum a String**
  - Cambiado campo tipoEntrada en CamposDiario de enum a String para permitir valores dinámicos

### 2025-11-13 - Corrección en DB/init.sql para INSERT de Campos_Diario
- **Base de Datos - Corrección de INSERT**
  - Agregado el valor faltante 'PRIORIDADES' en el campo tipo_entrada de la última fila del INSERT de Campos_Diario en init.sql
  
  ### 2025-11-13 - Actualización de ApiDocs.tsx con Documentación Completa de Endpoints
  - **Frontend - ApiDocs.tsx**
    - Actualizada documentación completa de todos los endpoints del backend
    - Incluye detalles de autenticación, parámetros, respuestas y ejemplos
  
  ## Funcionalidades Implementadas
- **Backend - Modificación en saveEntry**
  - Actualizado método saveEntry en DailyEntryController.java para asignar diario y diaMaestro correctamente al guardar la entrada diaria
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

### 2025-11-21 - Mejoras Completas en Gestión de Usuarios: Botón Ver Contraseña, Validaciones, Aspecto Visual y Debugging de Autenticación
- **Archivos afectados:** frontend/src/pages/UserManagement.tsx, frontend/src/contexts/AuthContext.tsx, backend/src/main/java/com/diario_intimidad/config/JwtAuthenticationFilter.java, backend/src/main/java/com/diario_intimidad/controller/UsuarioController.java, backend/src/main/java/com/diario_intimidad/service/UsuarioService.java, backend/src/main/java/com/diario_intimidad/repository/UsuarioRepository.java, backend/src/main/java/com/diario_intimidad/entity/Usuario.java
- **Cambios específicos realizados:**
  - **UserManagement.tsx**: Agregado estado showPassword para toggle de visibilidad de contraseña con íconos 👁️/🙈; implementada función hasChanges() para detectar modificaciones comparando campos específicos; mejorado layout del formulario con <form>, márgenes consistentes, ancho fijo sin scrollbar horizontal, campo rol redimensionado a 150px; agregado botón "Actualizar" condicional solo si hay cambios y validaciones pasan; validaciones de email (formato regex y unicidad), contraseña mínima 6 caracteres; mensajes de error para email inválido/duplicado; redimensionado modal a 400px con overflow auto.
  - **AuthContext.tsx**: Corregido acceso a token decodificado de decoded.sub en lugar de decoded.email.
  - **JwtAuthenticationFilter.java**: Cambiado uso de rol del token JWT en lugar del de DB para authorities; agregado logs detallados para procesamiento de requests, autenticación y errores.
  - **UsuarioController.java**: Cambiada comparación de usuarios por ID en lugar de email para permitir actualizaciones; agregado logs en createUsuario para authorities y errores.
  - **UsuarioService.java**: Agregada validación de password no null/vacío en save(); agregado logs en save().
  - **UsuarioRepository.java**: Cambiado a findByEmailIgnoreCase para búsqueda case-insensitive.
  - **Usuario.java**: Cambiado @JsonIgnore a @JsonProperty(access = JsonProperty.Access.WRITE_ONLY) para permitir deserialización de password.
- **Explicación del porqué se realiza el cambio:** Para resolver errores 403 en operaciones de usuarios, mejorar la UX con validaciones en tiempo real, toggle de contraseña, aspecto visual moderno, y debugging completo de autenticación.
- **Resultado esperado:** Gestión de usuarios completamente funcional con validaciones robustas, interfaz intuitiva, operaciones CRUD seguras, logs para troubleshooting, y experiencia de usuario mejorada con feedback visual inmediato.