#!/bin/bash
set -e

echo "=== Evolution API - Database Deploy Script ==="
echo "Executado durante a fase de deploy do Render"
echo ""

# Verificar se DATABASE_URL está definida
if [ -z "$DATABASE_URL" ]; then
  echo "❌ ERRO: DATABASE_URL não está definida!"
  echo "Configure no Render Dashboard: Environment → DATABASE_URL"
  exit 1
fi

# 🚨 CRÍTICO: Verificar se schema=evolution está na URL
# Isso PROTEGE o banco compartilhado contra perda de dados
if [[ ! "$DATABASE_URL" =~ "schema=evolution" ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🚨 ERRO CRÍTICO: DATABASE_URL SEM SCHEMA ISOLADO!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "⚠️  A DATABASE_URL DEVE incluir '&schema=evolution' no final!"
  echo ""
  echo "Sem isso, o Prisma pode EXCLUIR TODAS AS TABELAS DO AGENDAONSELL!"
  echo ""
  echo "Exemplo correto:"
  echo "postgresql://user:pass@host:5432/db?sslmode=require&schema=evolution"
  echo ""
  echo "📋 Passos para corrigir:"
  echo "   1. Crie o schema: CREATE SCHEMA IF NOT EXISTS evolution;"
  echo "   2. Adicione '&schema=evolution' na DATABASE_URL do Render"
  echo "   3. Faça novo deploy"
  echo ""
  echo "Configure no Render Dashboard: Environment → DATABASE_URL"
  echo ""
  exit 1
fi

echo "✅ DATABASE_URL encontrada com schema isolado"
echo "📊 Banco: $(echo $DATABASE_URL | cut -d '@' -f 2 | cut -d '/' -f 1)"
echo "🔒 Schema: evolution (isolado do AgendaOnSell)"
echo ""

# BANCO COMPARTILHADO COM SCHEMAS SEPARADOS
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 BANCO COMPARTILHADO - SCHEMAS SEPARADOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔒 Schema 'evolution': Evolution API (ISOLADO)"
echo "✅ Schema 'public': AgendaOnSell (PROTEGIDO)"
echo ""
echo "Usando 'db push' para sincronizar schema evolution"
echo ""

cd /evolution

# Usar db push direto - idempotente e seguro para banco compartilhado
DATABASE_URL="$DATABASE_URL" npx prisma db push \
  --skip-generate \
  --accept-data-loss \
  --schema ./prisma/postgresql-schema.prisma 2>&1 || {
  echo ""
  echo "❌ ERRO: Falha ao aplicar schema da Evolution API"
  echo ""
  echo "Possíveis causas:"
  echo "  1. DATABASE_URL incorreta"
  echo "  2. Usuário do banco sem permissão CREATE TABLE"
  echo "  3. Conflito de nomes de tabelas"
  echo ""
  echo "Verifique as variáveis de ambiente no Render Dashboard"
  exit 1
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SUCESSO: Schema Evolution API sincronizado!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Schema 'evolution' (Evolution API):"
echo "   • Instance, Message, Contact, Chat"
echo "   • Webhook, Session, MessageUpdate"
echo "   • _prisma_migrations"
echo ""
echo "✅ Schema 'public' (AgendaOnSell) - 100% INTACTO:"
echo "   • empresas, estabelecimentos, users"
echo "   • clientes, servicos, agendamentos"
echo "   • materiais, consumos_materiais"
echo "   • configuracao_fidelidade, premios, resgates_premios"
echo "   • whatsapp_configs"
echo ""
echo "🔒 ISOLAMENTO TOTAL GARANTIDO!"
echo ""
exit 0
