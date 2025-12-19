#!/bin/bash
set -e

echo "=== Evolution API - Database Deploy Script ==="
echo "Executado durante a fase de deploy do Render"
echo ""

# Verificar se DATABASE_CONNECTION_URI está definida
if [ -z "$DATABASE_CONNECTION_URI" ]; then
  echo "❌ ERRO: DATABASE_CONNECTION_URI não está definida!"
  echo "Configure no Render Dashboard: Environment → DATABASE_CONNECTION_URI"
  exit 1
fi

echo "✅ DATABASE_CONNECTION_URI encontrada"
echo "📊 Banco: $(echo $DATABASE_CONNECTION_URI | cut -d '@' -f 2 | cut -d '/' -f 1)"
echo ""

# Tentar rodar migrations normalmente primeiro
echo "Tentando rodar migrations do Prisma..."
node runWithProvider.js "rm -rf ./prisma/migrations && cp -r ./prisma/DATABASE_PROVIDER-migrations ./prisma/migrations && npx prisma migrate deploy --schema ./prisma/DATABASE_PROVIDER-schema.prisma" 2>&1 | tee /tmp/migration.log

# Verificar se falhou com P3005 (banco não vazio)
if grep -q "P3005" /tmp/migration.log; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  BANCO COMPARTILHADO DETECTADO (Erro P3005)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "📊 O banco 'agenda_db' já contém tabelas do AgendaOnSell"
  echo "✅ Aplicando schema da Evolution API sem afetar tabelas existentes..."
  echo ""

  # Usar db push para criar apenas as tabelas da Evolution API
  cd /evolution
  DATABASE_CONNECTION_URI="$DATABASE_CONNECTION_URI" npx prisma db push \
    --skip-generate \
    --accept-data-loss \
    --schema ./prisma/postgresql-schema.prisma 2>&1 || {
    echo ""
    echo "❌ ERRO: Falha ao aplicar schema da Evolution API"
    echo ""
    echo "Possíveis causas:"
    echo "  1. DATABASE_CONNECTION_URI incorreta"
    echo "  2. Usuário do banco sem permissão CREATE TABLE"
    echo "  3. Conflito de nomes de tabelas"
    echo ""
    echo "Verifique as variáveis de ambiente no Render Dashboard"
    exit 1
  }

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ SUCESSO: Schema da Evolution API aplicado!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "📋 Tabelas da Evolution API criadas:"
  echo "   • Instance (conexões WhatsApp)"
  echo "   • Message (mensagens)"
  echo "   • Contact (contatos)"
  echo "   • Chat (conversas)"
  echo "   • Webhook (webhooks)"
  echo "   • Session (sessões)"
  echo ""
  echo "✅ Tabelas do AgendaOnSell mantidas intactas:"
  echo "   • empresas, estabelecimentos, users, clientes"
  echo "   • servicos, agendamentos, materiais, etc."
  echo ""
  exit 0

elif grep -q "error" /tmp/migration.log || grep -q "Error" /tmp/migration.log; then
  echo ""
  echo "❌ ERRO ao executar migrations do Prisma"
  echo ""
  echo "Verifique os logs acima para detalhes"
  echo "Certifique-se de que DATABASE_CONNECTION_URI está correta"
  exit 1
fi

# Se chegou aqui, migrations rodaram com sucesso
echo ""
echo "✅ Migrations do Prisma executadas com sucesso!"
echo ""
exit 0
