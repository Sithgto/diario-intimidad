#!/bin/bash

# Script para probar el envío de emails
# Uso: ./test_email.sh [email]

EMAIL=${1:-"test@example.com"}

echo "🧪 Probando envío de email a: $EMAIL"
echo "📧 Enviando petición de compra..."

# Enviar petición de compra
RESPONSE=$(curl -s -X POST "http://localhost:8085/api/pedidos" \
  -H "Content-Type: application/json" \
  -d "{\"diarioId\": 1, \"email\": \"$EMAIL\"}")

echo "📦 Respuesta del servidor:"
echo "$RESPONSE"
echo ""

# Verificar logs de error
echo "🔍 Verificando logs de error..."
docker-compose logs backend --tail 10 | grep -i "error sending email" || echo "✅ No se encontraron errores de email"

echo ""
echo "📬 Si usas Mailjet, revisa tu email real en la bandeja de entrada"
echo "🎯 Si el email no llega, configura tus credenciales de Mailjet en .env"