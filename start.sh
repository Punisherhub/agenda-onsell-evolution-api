#!/bin/bash
set -e

echo "=== Iniciando Evolution API ==="
echo "Workdir: $(pwd)"

# Remover qualquer arquivo .env que possa interferir
echo "Removendo arquivos .env locais..."
rm -f .env .env.local .env.production .env.* 2>/dev/null || true

# Verificar se DATABASE_URL está definida
if [ -z "$DATABASE_URL" ]; then
  echo "ERRO: DATABASE_URL não está definida!"
  echo "Configure no Render Dashboard: Environment → DATABASE_URL"
  exit 1
fi

echo "DATABASE_URL encontrada: postgresql://***:***@$(echo $DATABASE_URL | cut -d '@' -f 2)"

# CRÍTICO: Exportar explicitamente as variáveis de ambiente
# para garantir que npm scripts as usem
export DATABASE_URL="$DATABASE_URL"
export DATABASE_PROVIDER="${DATABASE_PROVIDER:-postgresql}"
export DATABASE_ENABLED="${DATABASE_ENABLED:-true}"
export SERVER_PORT="${SERVER_PORT:-8080}"

echo "Variáveis exportadas:"
echo "  DATABASE_PROVIDER=$DATABASE_PROVIDER"
echo "  DATABASE_ENABLED=$DATABASE_ENABLED"
echo "  SERVER_PORT=$SERVER_PORT"

# Executar migrations do Prisma com DATABASE_URL forçada
echo "Executando migrations do Prisma..."
DATABASE_URL="$DATABASE_URL" npm run db:deploy || {
  echo "ERRO: Falha nas migrations do Prisma"
  echo "Verifique se DATABASE_URL está correta e acessível"
  exit 1
}

echo "✅ Migrations executadas com sucesso!"

# Iniciar servidor
echo "Iniciando servidor Evolution API na porta $SERVER_PORT..."
exec node ./dist/src/main.js
