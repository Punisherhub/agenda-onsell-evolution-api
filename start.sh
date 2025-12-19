#!/bin/bash
set -e

echo "=== Iniciando Evolution API ==="

# Verificar se DATABASE_URL está definida
if [ -z "$DATABASE_URL" ]; then
  echo "ERRO: DATABASE_URL não está definida!"
  echo "Configure no Render Dashboard: Environment → DATABASE_URL"
  exit 1
fi

echo "DATABASE_URL encontrada: postgresql://***:***@$(echo $DATABASE_URL | cut -d '@' -f 2)"

# Executar migrations do Prisma com DATABASE_URL disponível
echo "Executando migrations do Prisma..."
npm run db:deploy || {
  echo "ERRO: Falha nas migrations do Prisma"
  echo "Verifique se DATABASE_URL está correta e acessível"
  exit 1
}

# Iniciar servidor
echo "Iniciando servidor Evolution API na porta ${SERVER_PORT:-8080}..."
exec node ./dist/src/main.js
