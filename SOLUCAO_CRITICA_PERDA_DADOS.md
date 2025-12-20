# 🚨 SOLUÇÃO CRÍTICA: Perda de Dados no Deploy Evolution API

## PROBLEMA IDENTIFICADO

**CAUSA RAIZ**: A flag `--accept-data-loss` no comando `prisma db push` está permitindo que o Prisma **EXCLUA TABELAS** do AgendaOnSell durante a sincronização do schema.

### Como está acontecendo:

1. Evolution API tem arquivo `prisma/postgresql-schema.prisma` que define APENAS suas tabelas
2. Comando `prisma db push --accept-data-loss` tenta sincronizar banco com esse schema
3. Prisma vê tabelas "extras" (AgendaOnSell) no banco
4. Com `--accept-data-loss`, Prisma EXCLUI essas tabelas para "limpar" o banco
5. **RESULTADO: Perda total dos dados do AgendaOnSell**

### Linha problemática em `db-deploy.sh`:
```bash
DATABASE_URL="$DATABASE_URL" npx prisma db push \
  --accept-data-loss \    # ⚠️ AUTORIZA EXCLUSÃO DE DADOS!
  --schema ./prisma/postgresql-schema.prisma
```

---

## ✅ SOLUÇÃO DEFINITIVA: PostgreSQL Schemas Separados

PostgreSQL permite criar **schemas** (namespaces) dentro do mesmo banco. Isso garante **ISOLAMENTO TOTAL** entre Evolution API e AgendaOnSell.

### Arquitetura:

```
PostgreSQL: agenda_db
├── Schema: public (AgendaOnSell)
│   ├── empresas
│   ├── estabelecimentos
│   ├── users
│   ├── clientes
│   ├── servicos
│   ├── agendamentos
│   └── ...
│
└── Schema: evolution (Evolution API) ← ISOLADO!
    ├── Instance
    ├── Message
    ├── Contact
    ├── Chat
    └── ...
```

---

## 🔧 IMPLEMENTAÇÃO URGENTE

### PASSO 1: Criar Schema `evolution` no PostgreSQL

Execute no banco de dados (via Render Dashboard ou cliente SQL):

```sql
-- Criar schema separado para Evolution API
CREATE SCHEMA IF NOT EXISTS evolution;

-- Garantir permissões para o usuário do banco
GRANT ALL ON SCHEMA evolution TO sasconv_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA evolution TO sasconv_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA evolution GRANT ALL ON TABLES TO sasconv_user;
```

### PASSO 2: Modificar DATABASE_URL no Render

No Render Dashboard da Evolution API, modifique a variável `DATABASE_URL` para incluir o schema:

**ANTES:**
```
postgresql://sasconv_user:password@host:5432/agenda_db?sslmode=require
```

**DEPOIS:**
```
postgresql://sasconv_user:password@host:5432/agenda_db?sslmode=require&schema=evolution
```

**IMPORTANTE**: Adicione `&schema=evolution` no final da URL!

### PASSO 3: Modificar `db-deploy.sh`

Adicione validação de schema antes do deploy:

```bash
#!/bin/bash
set -e

echo "=== Evolution API - Database Deploy Script ==="
echo "Executado durante a fase de deploy do Render"
echo ""

# Verificar se DATABASE_URL está definida
if [ -z "$DATABASE_URL" ]; then
  echo "❌ ERRO: DATABASE_URL não está definida!"
  exit 1
fi

# CRÍTICO: Verificar se schema=evolution está na URL
if [[ ! "$DATABASE_URL" =~ "schema=evolution" ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🚨 ERRO CRÍTICO: DATABASE_URL SEM SCHEMA ISOLADO!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "A DATABASE_URL DEVE incluir '&schema=evolution' no final!"
  echo ""
  echo "Exemplo correto:"
  echo "postgresql://user:pass@host:5432/db?sslmode=require&schema=evolution"
  echo ""
  echo "Isso garante que Evolution API use schema separado"
  echo "e NÃO afete as tabelas do AgendaOnSell (schema public)"
  echo ""
  echo "Configure no Render Dashboard: Environment → DATABASE_URL"
  echo ""
  exit 1
fi

echo "✅ DATABASE_URL encontrada com schema isolado"
echo "📊 Banco: $(echo $DATABASE_URL | cut -d '@' -f 2 | cut -d '/' -f 1)"
echo "🔒 Schema: evolution (isolado do AgendaOnSell)"
echo ""

# BANCO COMPARTILHADO COM SCHEMA SEPARADO
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 BANCO COMPARTILHADO - SCHEMAS SEPARADOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Schema 'evolution': Evolution API (ISOLADO)"
echo "✅ Schema 'public': AgendaOnSell (PROTEGIDO)"
echo ""

cd /evolution

# db push agora é SEGURO porque está isolado no schema 'evolution'
DATABASE_URL="$DATABASE_URL" npx prisma db push \
  --skip-generate \
  --accept-data-loss \
  --schema ./prisma/postgresql-schema.prisma 2>&1 || {
  echo ""
  echo "❌ ERRO: Falha ao aplicar schema da Evolution API"
  exit 1
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SUCESSO: Schema da Evolution API sincronizado!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Schema 'evolution' (Evolution API):"
echo "   • Instance, Message, Contact, Chat, etc."
echo ""
echo "✅ Schema 'public' (AgendaOnSell) INTACTO:"
echo "   • empresas, estabelecimentos, users, clientes, etc."
echo ""
exit 0
```

### PASSO 4: Testar Schema Separado Localmente

Antes de fazer deploy, teste localmente:

```bash
# 1. Criar schema evolution no banco Render
psql "postgresql://sasconv_user:password@host:5432/agenda_db?sslmode=require" \
  -c "CREATE SCHEMA IF NOT EXISTS evolution;"

# 2. Testar conexão com schema evolution
export DATABASE_URL="postgresql://sasconv_user:password@host:5432/agenda_db?sslmode=require&schema=evolution"

# 3. Verificar que o schema está correto
psql "$DATABASE_URL" -c "\dn"  # Lista schemas
```

---

## 🛡️ GARANTIAS DE SEGURANÇA

Com schemas separados:

✅ **Isolamento Total**: Evolution API só vê tabelas do schema `evolution`
✅ **Prisma Seguro**: `db push --accept-data-loss` só afeta schema `evolution`
✅ **AgendaOnSell Protegido**: Schema `public` fica 100% intocado
✅ **Zero Conflito**: Mesmo que haja tabelas com nomes iguais, estão em schemas diferentes
✅ **Rollback Seguro**: Se algo der errado, basta dropar schema `evolution` e recriar

---

## 📋 CHECKLIST PRÉ-DEPLOY

Antes de fazer novo deploy da Evolution API, CONFIRME:

- [ ] Schema `evolution` criado no PostgreSQL
- [ ] Permissões concedidas para `sasconv_user` no schema `evolution`
- [ ] DATABASE_URL modificada no Render incluindo `&schema=evolution`
- [ ] Arquivo `db-deploy.sh` atualizado com validação de schema
- [ ] Backup completo do banco antes do deploy
- [ ] Teste local bem-sucedido

---

## 🔄 RECUPERAÇÃO DE DADOS (Se já perdeu)

Se você já perdeu dados do AgendaOnSell:

### Opção 1: Restaurar Backup
```bash
# Render.com mantém backups automáticos
# Acesse: Render Dashboard → PostgreSQL → Backups → Restore
```

### Opção 2: Recriar Estrutura
```bash
cd backend
alembic upgrade head  # Recria todas as tabelas do AgendaOnSell
```

**ATENÇÃO**: Opção 2 recria estrutura mas perde dados. Use backup se possível!

---

## 📊 MONITORAMENTO PÓS-DEPLOY

Após deploy, verifique:

```sql
-- Listar todos os schemas
\dn

-- Listar tabelas no schema evolution
\dt evolution.*

-- Listar tabelas no schema public (AgendaOnSell)
\dt public.*

-- Contar registros críticos do AgendaOnSell
SELECT
  (SELECT COUNT(*) FROM public.empresas) as empresas,
  (SELECT COUNT(*) FROM public.estabelecimentos) as estabelecimentos,
  (SELECT COUNT(*) FROM public.users) as users,
  (SELECT COUNT(*) FROM public.clientes) as clientes,
  (SELECT COUNT(*) FROM public.agendamentos) as agendamentos;
```

---

## 🚨 NÃO FAÇA DEPLOY ATÉ IMPLEMENTAR ESTA SOLUÇÃO!

**CRÍTICO**: Cada deploy sem schema separado pode causar perda total de dados!

---

**Data**: 2025-12-20
**Prioridade**: 🔴 CRÍTICA
**Status**: ⚠️ AGUARDANDO IMPLEMENTAÇÃO
