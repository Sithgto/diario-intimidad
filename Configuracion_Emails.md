# 📧 Configuración de Emails - Tienda de Diarios Anuales

## Descripción General

Este documento proporciona una guía completa para configurar, probar y documentar el sistema de envío de correos de validación en la tienda de diarios anuales del proyecto "Diario de Intimidad".

## 🚀 INICIO RÁPIDO

```bash
# 1. Copiar template de variables
cp .env.example .env

# 2. Configurar Mailjet (ya está activado por defecto)
# - Ve a https://www.mailjet.com/ y crea cuenta gratuita
# - Ve a Account > SMTP Settings
# - Copia API Key y Secret Key
# - Reemplaza en .env: MAIL_USERNAME=tu_api_key, MAIL_PASSWORD=tu_secret_key

# 3. Levantar aplicación
docker-compose up --build

# 4. Verificar configuración
docker-compose exec backend env | findstr MAIL

# 5. Probar envío de email (opción rápida)
./test_email.sh tu_email@ejemplo.com

# O manualmente:
curl -X POST "http://localhost:8085/api/pedidos" \
  -H "Content-Type: application/json" \
  -d '{"diarioId": 1, "email": "tu_email@ejemplo.com"}'

# 6. Verificar logs
docker-compose logs backend | findstr "Error sending email"
# Si no hay errores, el email se envió correctamente
```

## 📋 PASO A PASO: CONFIGURACIÓN, PRUEBA Y DOCUMENTACIÓN

### 1. **CONFIGURACIÓN DEL SERVIDOR DE EMAIL**

#### Opción A: Mailjet (Recomendado - envío real)
```bash
# 1. Ve a https://www.mailjet.com/ y crea cuenta gratuita
# 2. Ve a Account > SMTP Settings
# 3. Copia API Key y Secret Key
# 4. Configura en .env:
#    MAIL_USERNAME=tu_api_key
#    MAIL_PASSWORD=tu_secret_key
```

#### Opción B: Mailtrap (Para testing - emails no se envían realmente)
```bash
# 1. Ve a https://mailtrap.io y crea cuenta gratuita
# 2. Crea un inbox de prueba
# 3. Ve a Settings > SMTP Settings
# 4. Copia USERNAME y PASSWORD
```

#### Opción C: Gmail (Para producción)
```bash
# 1. Genera "Contraseña de aplicación" en Gmail
# 2. Configura MAIL_HOST=smtp.gmail.com
```

### 2. **CONFIGURACIÓN DE VARIABLES DE ENTORNO**

#### Archivo .env (Recomendado):
Ya está creado el archivo `.env` en la raíz del proyecto con toda la configuración:

```env
# Configuración de Email (desarrollo/producción con Mailjet)
MAIL_HOST=in-v3.mailjet.com
MAIL_PORT=587
MAIL_USERNAME=tu_api_key_mailjet
MAIL_PASSWORD=tu_secret_key_mailjet

# Para Gmail (descomenta y configura):
# MAIL_HOST=smtp.gmail.com
# MAIL_PORT=587
# MAIL_USERNAME=tu_email@gmail.com
# MAIL_PASSWORD=tu_app_password
```

#### Docker Compose:
El `docker-compose.yml` ya está configurado para usar las variables del `.env`:

```yaml
backend:
  environment:
    # ... otras variables ...
    MAIL_HOST: ${MAIL_HOST}
    MAIL_PORT: ${MAIL_PORT}
    MAIL_USERNAME: ${MAIL_USERNAME}
    MAIL_PASSWORD: ${MAIL_PASSWORD}
```

#### Para desarrollo local (sin Docker):
Si ejecutas el backend directamente con Maven/Gradle, crea `.env` en `backend/` o configura las variables del sistema.

### 3. **LEVANTAR LA APLICACIÓN**

```bash
# Reconstruir y levantar servicios
docker-compose down
docker-compose up --build

# Verificar que el backend inicie correctamente
# Deberías ver en logs: "Started BackendApplication"
```

### 4. **PRUEBA DEL SISTEMA DE EMAIL**

#### Prueba 1: Verificar configuración
```bash
# Ver logs del backend
docker-compose logs backend

# Verificar variables de entorno
docker-compose exec backend env | findstr MAIL

# Buscar errores de email en logs
docker-compose logs backend | findstr "mail\|email\|Error sending"
```

#### Prueba 2: Simular una compra
1. **Abrir la tienda:** Ve a `http://localhost:3005/tienda`
2. **Seleccionar un diario:** Haz clic en "Comprar" en cualquier diario
3. **Completar formulario:**
   - Email: `test@example.com`
   - Haz clic en "Confirmar Compra"

#### Prueba 3: Verificar envío de email
1. **Ir a Mailtrap:** Accede a tu inbox de Mailtrap
2. **Buscar email:** Deberías ver un email con asunto "Validación de compra - Diario de Intimidad"
3. **Contenido esperado:**
   ```
   Asunto: Validación de compra - Diario de Intimidad

   ¡Gracias por tu compra!

   Has comprado el diario: [Nombre del diario]

   Para completar tu compra y crear tu cuenta, por favor valida tu email haciendo clic en el siguiente enlace:

   http://localhost:3005/validar-pedido?token=[token-uuid]

   Si no solicitaste esta compra, ignora este email.

   Saludos,
   Equipo de Diario de Intimidad
   ```

#### Prueba 4: Validar el token
1. **Haz clic en el link del email**
2. **Verificar redirección:** Deberías ver la página de validación
3. **Mensaje esperado:** "Compra confirmada. Usuario creado con email: test@example.com"
4. **Redirección automática:** Después de 3 segundos, te lleva al login

#### Prueba 5: Verificar creación de usuario
1. **Ir al login:** `http://localhost:3005/login`
2. **Intentar login:**
   - Email: `test@example.com`
   - Password: El generado automáticamente (ver logs del backend)
3. **Verificar acceso:** Deberías poder acceder al diario comprado

### 5. **VERIFICACIÓN EN BASE DE DATOS**

```sql
-- Conectar a PostgreSQL
docker-compose exec postgres psql -U diario_user -d diario_intimidad

-- Ver pedidos
SELECT * FROM pedido;

-- Ver usuarios creados
SELECT * FROM usuario WHERE email = 'test@example.com';

-- Ver pedidos confirmados
SELECT p.*, u.email FROM pedido p
LEFT JOIN usuario u ON p.usuario_id = u.id
WHERE p.estado = 'CONFIRMADO';
```

### 6. **MANEJO DE ERRORES**

#### Si el email no llega:
```bash
# Ver logs del backend
docker-compose logs backend | grep -i "mail\|email"

# Posibles errores:
# - Credenciales incorrectas
# - Firewall bloqueando puerto SMTP
# - Configuración de DNS
```

#### Si la validación falla:
- Verificar que el token en la URL sea correcto
- Comprobar que el pedido existe en BD
- Revisar logs del backend por errores

### 7. **DOCUMENTACIÓN**

#### README.md - Sección Email
```markdown
## Configuración de Email

### Desarrollo (Mailtrap)
1. Crea cuenta en [Mailtrap.io](https://mailtrap.io)
2. Configura variables de entorno:
   ```env
   MAIL_HOST=smtp.mailtrap.io
   MAIL_PORT=2525
   MAIL_USERNAME=tu_usuario
   MAIL_PASSWORD=tu_password
   ```

### Producción (Gmail/Otro)
```env
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=tu_email@gmail.com
MAIL_PASSWORD=tu_app_password
```

### Plantilla de Email
Los emails de validación incluyen:
- Saludo personalizado
- Nombre del diario comprado
- Link de validación único
- Instrucciones de seguridad

### Testing
Para probar el envío de emails:
1. Ve a `/tienda`
2. Compra cualquier diario
3. Revisa tu inbox de Mailtrap
4. Haz clic en el link de validación
5. Verifica creación de usuario y acceso
```

#### Documentación técnica
```markdown
## API Email

### POST /api/pedidos
- Envía email de validación automáticamente
- Maneja errores de envío sin fallar la transacción

### GET /api/pedidos/validar/{token}
- Valida token y confirma compra
- Crea usuario con email verificado
- Asigna diario al usuario

### EmailService
- `enviarEmailValidacion(to, token, tituloDiario)`
- Usa JavaMailSender de Spring Boot
- Configurable vía application.properties
```

### 8. **DEPLOYMENT EN PRODUCCIÓN**

#### Variables de entorno requeridas:
```bash
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=produccion@tuapp.com
MAIL_PASSWORD=app_password_seguro
```

#### Consideraciones de seguridad:
- Usa contraseñas de aplicación, no la contraseña real
- Configura SPF/DKIM para el dominio
- Monitorea envío de emails
- Implementa rate limiting si es necesario

### 9. **MONITOREO Y LOGGING**

```bash
# Ver logs de email
docker-compose logs backend | grep -E "(mail|email|Mail)"

# Métricas importantes:
# - Tasa de envío exitoso
# - Tasa de validación
# - Errores de SMTP
# - Tiempo de respuesta
```

### 10. **TROUBLESHOOTING**

#### Problema: "Could not connect to SMTP host"
```bash
# Verificar conectividad
telnet smtp.mailtrap.io 2525

# Verificar variables de entorno
docker-compose exec backend env | grep MAIL
```

#### Problema: Error de dependencias Maven (mailjet-rest)
```bash
# Solución: Limpiar cache de Maven y reconstruir
./clean_maven_cache.sh
./rebuild_and_test.sh

# O manualmente:
docker-compose down
docker system prune -f
docker volume prune -f
docker-compose build --no-cache --pull
docker-compose up -d
```

#### Problema: "Authentication failed" con Mailjet
```bash
# Verificar credenciales:
# 1. Ve a https://app.mailjet.com/account/api_keys
# 2. Confirma que API Key y Secret Key son correctos
# 3. Verifica que la cuenta esté activada (no suspendida)
# 4. Revisa límites de envío (Mailjet tiene límites gratuitos)
```

#### Problema: "Authentication failed" con Gmail
```bash
# Solución para Gmail con 2FA:
# 1. Ve a https://myaccount.google.com/security
# 2. Activa "Verificación en 2 pasos"
# 3. Ve a "Contraseñas de aplicaciones"
# 4. Genera una contraseña para "Correo"
# 5. Usa esa contraseña (16 caracteres) en MAIL_PASSWORD

# Solución para Gmail sin 2FA:
# 1. Ve a https://myaccount.google.com/security
# 2. Activa "Acceso de aplicaciones menos seguras"
# 3. Usa tu contraseña normal de Gmail
```

#### Problema: Emails llegan a spam
- Configura SPF records
- Usa dominio personalizado
- Evita palabras como "compra", "validación" en asunto

#### Problema: Tokens expirados
- Actualmente no expiran (implementar si es necesario)
- Validar que pedido no esté ya confirmado

---

## 📁 Estructura de Archivos Modificados

.env                                # Variables de entorno (NO subir a git)
.env.example                        # Template de variables (sí subir a git)
docker-compose.yml                  # Configurado para usar variables de .env
```

backend/
├── pom.xml                           # Agregada dependencia spring-boot-starter-mail
├── src/main/resources/
│   └── application.properties        # Configuración SMTP
└── src/main/java/com/diario_intimidad/
    ├── controller/
    │   └── PedidoController.java     # Integración EmailService
    ├── service/
    │   └── EmailService.java         # Nuevo servicio de email
    ├── entity/
    │   └── Pedido.java               # Entidad para pedidos
    ├── repository/
    │   └── PedidoRepository.java     # Repository para pedidos
    └── dto/
        ├── PedidoRequest.java        # DTO para requests
        └── PedidoResponse.java       # DTO para responses

frontend/
└── src/
    ├── pages/
    │   └── ValidarPedido.tsx         # Nueva página de validación
    └── App.tsx                       # Ruta agregada

DB/
└── init.sql                         # Tabla pedido y campo precio

test_email.sh                        # Script para probar envío de emails
rebuild_and_test.sh                  # Script para reconstruir con Mailjet
clean_maven_cache.sh                 # Script para limpiar cache de Maven
Configuracion_Emails.md              # Este documento
```

## 🔧 Dependencias Técnicas

- **Spring Boot Mail:** `spring-boot-starter-mail`
- **JavaMail:** Incluido en spring-boot-starter-mail
- **Proveedor:** Mailjet SMTP
- **Protocolo:** SMTP con STARTTLS
- **Plantillas:** HTML profesional + texto plano
- **Características:** Envío real, deliverability alta, dashboard

## ✅ Checklist de Implementación

- [x] Configuración Mailjet SMTP implementada
- [x] Servicio de email actualizado con HTML profesional
- [x] Emails de validación con diseño responsive
- [x] Integración JavaMail con Mailjet
- [x] Variables de entorno configuradas
- [x] Página de validación frontend
- [x] Ruta de validación agregada
- [x] Scripts de testing y reconstrucción
- [x] Documentación completa actualizada
- [x] Guía de troubleshooting para Mailjet

---

**Nota:** Este sistema está diseñado para ser escalable y seguro. Para entornos de producción, considera implementar:
- Templates HTML para emails
- Sistema de colas (RabbitMQ/Redis)
- Rate limiting
- Monitoreo avanzado
- Backup de emails enviados