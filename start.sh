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

echo "✅ DATABASE_URL encontrada"
echo "📊 Banco: $(echo $DATABASE_URL | cut -d '@' -f 2 | cut -d '/' -f 1)"

# Evolution API usa DATABASE_CONNECTION_URI internamente
# Se não estiver definida, mapear de DATABASE_URL
if [ -z "$DATABASE_CONNECTION_URI" ]; then
  echo "📝 Mapeando DATABASE_URL → DATABASE_CONNECTION_URI"
  export DATABASE_CONNECTION_URI="$DATABASE_URL"
else
  echo "✅ DATABASE_CONNECTION_URI já definida"
fi
echo ""

# Exportar variáveis de ambiente
export DATABASE_URL="$DATABASE_URL"
export DATABASE_PROVIDER="${DATABASE_PROVIDER:-postgresql}"
export DATABASE_ENABLED="${DATABASE_ENABLED:-true}"
export SERVER_PORT="${SERVER_PORT:-8080}"

echo "📋 Variáveis de ambiente:"
echo "   • DATABASE_PROVIDER: $DATABASE_PROVIDER"
echo "   • DATABASE_ENABLED: $DATABASE_ENABLED"
echo "   • SERVER_PORT: $SERVER_PORT"
echo ""

# CRÍTICO: Executar migrations ANTES de iniciar o servidor
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔨 Aplicando Migrations do Prisma"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Executar script de migrations
bash /evolution/db-deploy.sh || {
  echo ""
  echo "❌ ERRO: Falha ao executar migrations!"
  echo "Verifique os logs acima para detalhes."
  exit 1
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Iniciando servidor Evolution API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Porta: $SERVER_PORT"
echo "📡 Aguardando conexões..."
echo ""

exec node ./dist/main.js
