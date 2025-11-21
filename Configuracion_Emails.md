# 📧 Configuración de Emails - Tienda de Diarios Anuales

## Descripción General

Este documento proporciona una guía completa para configurar, probar y documentar el sistema de envío de correos de validación en la tienda de diarios anuales del proyecto "Diario de Intimidad".

## 📋 PASO A PASO: CONFIGURACIÓN, PRUEBA Y DOCUMENTACIÓN

### 1. **CONFIGURACIÓN DEL SERVIDOR DE EMAIL**

#### Opción A: Mailtrap (Recomendado para desarrollo)
```bash
# 1. Ve a https://mailtrap.io y crea cuenta gratuita
# 2. Crea un inbox de prueba
# 3. Ve a Settings > SMTP Settings
# 4. Copia las credenciales
```

#### Opción B: Gmail (Para producción)
```bash
# 1. Habilita "Acceso de aplicaciones menos seguras" en Gmail
# 2. O usa "Contraseñas de aplicación" si tienes 2FA
```

### 2. **CONFIGURACIÓN DE VARIABLES DE ENTORNO**

#### Para Docker Compose:
Edita tu `docker-compose.yml` y agrega las variables:

```yaml
services:
  backend:
    environment:
      - MAIL_HOST=smtp.mailtrap.io
      - MAIL_PORT=2525
      - MAIL_USERNAME=tu_usuario_mailtrap
      - MAIL_PASSWORD=tu_password_mailtrap
      # O para Gmail:
      # - MAIL_HOST=smtp.gmail.com
      # - MAIL_PORT=587
      # - MAIL_USERNAME=tu_email@gmail.com
      # - MAIL_PASSWORD=tu_password_o_app_password
```

#### Para desarrollo local:
Crea un archivo `.env` en la raíz del proyecto backend:

```env
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=tu_usuario
MAIL_PASSWORD=tu_password
```

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

# Busca líneas como:
# "JavaMail version 1.6.2"
# "Mail server connection successful"
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

#### Problema: Emails llegan a spam
- Configura SPF records
- Usa dominio personalizado
- Evita palabras como "compra", "validación" en asunto

#### Problema: Tokens expirados
- Actualmente no expiran (implementar si es necesario)
- Validar que pedido no esté ya confirmado

---

## 📁 Estructura de Archivos Modificados

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

Configuracion_Emails.md              # Este documento
```

## 🔧 Dependencias Técnicas

- **Spring Boot Mail:** `spring-boot-starter-mail`
- **JavaMail:** Incluido en spring-boot-starter-mail
- **Protocolo:** SMTP con STARTTLS
- **Plantillas:** Texto plano (se puede mejorar a HTML)

## ✅ Checklist de Implementación

- [x] Dependencia de email agregada
- [x] Configuración SMTP implementada
- [x] Servicio de email creado
- [x] Integración en controlador de pedidos
- [x] Página de validación frontend
- [x] Ruta de validación agregada
- [x] Documentación completa
- [x] Guía de testing detallada
- [x] Troubleshooting incluido

---

**Nota:** Este sistema está diseñado para ser escalable y seguro. Para entornos de producción, considera implementar:
- Templates HTML para emails
- Sistema de colas (RabbitMQ/Redis)
- Rate limiting
- Monitoreo avanzado
- Backup de emails enviados