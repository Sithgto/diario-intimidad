#!/bin/bash

# Script para reconstruir y probar la aplicación con Mailjet SMTP
echo "🔄 Reconstruyendo aplicación con configuración Mailjet..."

# Limpiar completamente
docker-compose down
docker system prune -f
docker volume prune -f
docker image prune -f

# Forzar reconstrucción desde cero (limpia cache de Maven)
docker-compose build --no-cache --pull

# Levantar aplicación
docker-compose up -d

echo "⏳ Esperando que la aplicación inicie..."
sleep 45

# Verificar estado
echo "📋 Verificando estado de contenedores..."
docker-compose ps

# Verificar logs de compilación
echo "📋 Verificando logs de compilación..."
docker-compose logs backend | grep -E "(ERROR|BUILD|Compilation)" | tail -10

# Verificar logs de aplicación
echo "📋 Verificando logs de aplicación..."
docker-compose logs backend | tail -20

# Probar envío de email
echo "🧪 Probando envío de email..."
curl -s -X POST "http://localhost:8080/api/pedidos" \
  -H "Content-Type: application/json" \
  -d '{"diarioId": 1, "email": "test@example.com"}' || echo "❌ Error en la petición"

echo ""
echo "✅ Reconstrucción completada!"
echo "📧 Si usas Mailjet, revisa tu dashboard: https://app.mailjet.com/"
echo "🔍 Revisa logs completos: docker-compose logs backend"