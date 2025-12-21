#!/bin/bash
set -e  # Sair em qualquer erro

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Iniciando Evolution API (DEBUG MODE)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📂 Workdir: $(pwd)"
echo "📦 Node version: $(node --version)"
echo "📦 NPM version: $(npm --version)"
echo ""

# Remover qualquer arquivo .env que possa interferir
echo "🗑️  Removendo arquivos .env locais..."
rm -f .env .env.local .env.production .env.* 2>/dev/null || true
echo "✅ Arquivos .env removidos"
echo ""

# Verificar se DATABASE_URL está definida
echo "🔍 Verificando DATABASE_URL..."
if [ -z "$DATABASE_URL" ]; then
  echo ""
  echo "❌ ERRO: DATABASE_URL não está definida!"
  echo "Configure no Render Dashboard: Environment → DATABASE_URL"
  exit 1
fi

echo "✅ DATABASE_URL encontrada"
echo "📊 Banco: $(echo $DATABASE_URL | cut -d '@' -f 2 | cut -d '/' -f 1)"
echo ""

# Verificar se tem &schema=evolution
echo "🔍 Verificando &schema=evolution..."
if [[ ! "$DATABASE_URL" =~ "schema=evolution" ]]; then
  echo ""
  echo "⚠️  WARNING: DATABASE_URL não contém '&schema=evolution'!"
  echo "   Mas vou continuar mesmo assim para debug..."
  echo ""
fi

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

echo "📋 Variáveis de ambiente exportadas:"
echo "   • DATABASE_PROVIDER: $DATABASE_PROVIDER"
echo "   • DATABASE_ENABLED: $DATABASE_ENABLED"
echo "   • SERVER_PORT: $SERVER_PORT"
echo "   • AUTHENTICATION_API_KEY: ${AUTHENTICATION_API_KEY:0:10}... (truncated)"
echo ""

# Verificar se AUTHENTICATION_API_KEY está definida
if [ -z "$AUTHENTICATION_API_KEY" ]; then
  echo "⚠️  WARNING: AUTHENTICATION_API_KEY não está definida!"
  echo "   Mas vou continuar mesmo assim para debug..."
  echo ""
fi

# Listar arquivos importantes
echo "📋 Arquivos importantes:"
ls -lh /evolution/dist/main.js 2>&1 || echo "❌ main.js não encontrado!"
ls -lh /evolution/prisma/postgresql-schema.prisma 2>&1 || echo "❌ schema prisma não encontrado!"
echo ""

# CRÍTICO: Executar migrations ANTES de iniciar o servidor
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔨 Aplicando Migrations do Prisma"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Executar script de migrations COM LOGS DETALHADOS
bash -x /evolution/db-deploy.sh 2>&1 || {
  echo ""
  echo "❌ ERRO: Falha ao executar migrations!"
  echo "Verifique os logs acima para detalhes."
  exit 1
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Iniciando servidor Evolution API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Porta: $SERVER_PORT"
echo "📡 Comando: node ./dist/main.js"
echo "🔍 Capturando stdout e stderr..."
echo ""

# CRÍTICO: NÃO usar exec - queremos capturar erros
# Redirecionar stderr para stdout para ver TODOS os erros
node ./dist/main.js 2>&1 || {
  EXIT_CODE=$?
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ SERVIDOR CRASHOU!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Exit code: $EXIT_CODE"
  echo ""
  echo "Possíveis causas:"
  echo "  1. Falta variável de ambiente obrigatória"
  echo "  2. Erro no código do Evolution API"
  echo "  3. Problema com conexão do banco"
  echo "  4. Versão 'latest' está com bug"
  echo ""
  echo "🔧 Soluções:"
  echo "  1. Verifique todas as variáveis de ambiente"
  echo "  2. Tente usar versão específica: atendai/evolution-api:v2.0.10"
  echo "  3. Verifique logs acima para stack trace"
  echo ""
  exit $EXIT_CODE
}
