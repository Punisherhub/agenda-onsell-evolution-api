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

# CRÍTICO: O schema do Prisma procura por DATABASE_CONNECTION_URI, não DATABASE_URL
# Criar alias para compatibilidade
export DATABASE_CONNECTION_URI="$DATABASE_URL"
export DATABASE_URL="$DATABASE_URL"
export DATABASE_PROVIDER="${DATABASE_PROVIDER:-postgresql}"
export DATABASE_ENABLED="${DATABASE_ENABLED:-true}"
export SERVER_PORT="${SERVER_PORT:-8080}"

echo "Variáveis exportadas:"
echo "  DATABASE_CONNECTION_URI=$DATABASE_CONNECTION_URI (alias de DATABASE_URL)"
echo "  DATABASE_PROVIDER=$DATABASE_PROVIDER"
echo "  DATABASE_ENABLED=$DATABASE_ENABLED"
echo "  SERVER_PORT=$SERVER_PORT"

# Executar migrations do Prisma com DATABASE_CONNECTION_URI forçada
echo "Executando migrations do Prisma..."
DATABASE_CONNECTION_URI="$DATABASE_URL" npm run db:deploy 2>&1 | tee /tmp/migration.log

# Verificar se falhou com erro P3005 (banco não vazio)
if grep -q "P3005" /tmp/migration.log; then
  echo ""
  echo "⚠️ Banco compartilhado detectado (P3005)"
  echo "📊 Aplicando schema da Evolution API ao banco existente agenda_db..."
  echo "✅ As tabelas do AgendaOnSell não serão afetadas"
  echo ""

  # Usar db push para criar apenas as tabelas da Evolution API que não existem
  # --accept-data-loss é seguro aqui porque estamos apenas criando tabelas novas
  # --skip-generate pula a geração do Prisma Client (já está no build)
  cd /evolution
  DATABASE_CONNECTION_URI="$DATABASE_URL" npx prisma db push \
    --skip-generate \
    --accept-data-loss \
    --schema ./prisma/postgresql-schema.prisma || {
    echo ""
    echo "❌ ERRO: Falha ao aplicar schema da Evolution API"
    echo "Verifique se:"
    echo "  1. DATABASE_URL está correta"
    echo "  2. Usuário do banco tem permissões de CREATE TABLE"
    echo "  3. Não há conflitos de nomes de tabelas"
    exit 1
  }

  echo ""
  echo "✅ Schema da Evolution API aplicado com sucesso!"
  echo "📋 Tabelas criadas: Instance, Message, Webhook, Chat, Contact, etc."
  echo ""
elif grep -q "error" /tmp/migration.log; then
  echo ""
  echo "❌ ERRO nas migrations do Prisma"
  echo "Verifique os logs acima para detalhes"
  exit 1
fi

echo "✅ Migrations executadas com sucesso!"

# Iniciar servidor
echo "Iniciando servidor Evolution API na porta $SERVER_PORT..."
exec node ./dist/src/main.js
