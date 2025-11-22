#!/bin/bash

# Script para limpiar completamente el cache de Maven en Docker
echo "🧹 Limpiando cache de Maven..."

# Crear un contenedor temporal para limpiar el cache
docker run --rm \
  -v maven-cache:/root/.m2 \
  maven:3.9.4-openjdk-21 \
  mvn dependency:purge-local-repository -DreResolve=false || true

echo "✅ Cache de Maven limpiado"
echo "🔄 Ahora ejecuta: ./rebuild_and_test.sh"