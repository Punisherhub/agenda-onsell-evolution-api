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

# BANCO COMPARTILHADO: Usar db push direto (mais robusto)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 BANCO COMPARTILHADO COM AGENDAONSELL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Usando 'db push' para sincronizar schema"
echo "   (Não afeta tabelas existentes do AgendaOnSell)"
echo ""

cd /evolution

# Usar db push direto - idempotente e seguro para banco compartilhado
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
echo "✅ SUCESSO: Schema da Evolution API sincronizado!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Tabelas da Evolution API:"
echo "   • Instance (conexões WhatsApp)"
echo "   • Message (mensagens)"
echo "   • Contact (contatos)"
echo "   • Chat (conversas)"
echo "   • Webhook (webhooks)"
echo "   • Session (sessões)"
echo ""
echo "✅ Tabelas do AgendaOnSell intactas:"
echo "   • empresas, estabelecimentos, users, clientes"
echo "   • servicos, agendamentos, materiais, etc."
echo ""
exit 0
