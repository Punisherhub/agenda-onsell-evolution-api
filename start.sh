#!/bin/bash
set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Iniciando Evolution API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📂 Workdir: $(pwd)"

# Remover qualquer arquivo .env que possa interferir
echo "🗑️  Removendo arquivos .env locais..."
rm -f .env .env.local .env.production .env.* 2>/dev/null || true

# Verificar se DATABASE_URL está definida
if [ -z "$DATABASE_URL" ]; then
  echo ""
  echo "❌ ERRO: DATABASE_URL não está definida!"
  echo "Configure no Render Dashboard: Environment → DATABASE_URL"
  exit 1
fi

# Verificar se DATABASE_CONNECTION_URI está definida
if [ -z "$DATABASE_CONNECTION_URI" ]; then
  echo ""
  echo "❌ ERRO: DATABASE_CONNECTION_URI não está definida!"
  echo "Configure no Render Dashboard: Environment → DATABASE_CONNECTION_URI"
  exit 1
fi

echo "✅ DATABASE_URL encontrada"
echo "✅ DATABASE_CONNECTION_URI encontrada"
echo "📊 Banco: $(echo $DATABASE_URL | cut -d '@' -f 2 | cut -d '/' -f 1)"
echo ""

# Exportar variáveis de ambiente
export DATABASE_CONNECTION_URI="$DATABASE_CONNECTION_URI"
export DATABASE_URL="$DATABASE_URL"
export DATABASE_PROVIDER="${DATABASE_PROVIDER:-postgresql}"
export DATABASE_ENABLED="${DATABASE_ENABLED:-true}"
export SERVER_PORT="${SERVER_PORT:-8080}"

echo "📋 Variáveis de ambiente:"
echo "   • DATABASE_PROVIDER: $DATABASE_PROVIDER"
echo "   • DATABASE_ENABLED: $DATABASE_ENABLED"
echo "   • SERVER_PORT: $SERVER_PORT"
echo ""

# Migrations já foram executadas pelo db-deploy.sh durante o deploy
# Apenas iniciar o servidor

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Iniciando servidor Evolution API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Porta: $SERVER_PORT"
echo "📡 Aguardando conexões..."
echo ""

exec node ./dist/src/main.js
