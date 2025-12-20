# 🚨 AÇÃO IMEDIATA - Proteção Contra Perda de Dados

## PROBLEMA IDENTIFICADO

O comando `prisma db push --accept-data-loss` no Evolution API está **EXCLUINDO TABELAS DO AGENDAONSELL** porque ambos os sistemas estão usando o mesmo schema PostgreSQL (`public`).

## SOLUÇÃO IMPLEMENTADA

✅ Scripts modificados com proteção automática
✅ Schema separado para isolamento total
✅ Validação obrigatória antes de cada deploy

---

## 📋 CHECKLIST URGENTE

Execute estes passos **NA ORDEM** para proteger seus dados:

### ☑️ PASSO 1: Backup Imediato
```bash
# No Render Dashboard do PostgreSQL:
# 1. Acesse: Dashboard → PostgreSQL → Backups
# 2. Clique em "Create Snapshot"
# 3. Aguarde confirmação
```

### ☑️ PASSO 2: Criar Schema Evolution

**Opção A: Via Render Dashboard**
1. Acesse: https://dashboard.render.com
2. Vá em seu PostgreSQL service
3. Clique em "Shell" (terminal)
4. Execute:
```sql
CREATE SCHEMA IF NOT EXISTS evolution;
GRANT ALL ON SCHEMA evolution TO sasconv_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA evolution GRANT ALL ON TABLES TO sasconv_user;
```

**Opção B: Via psql (Local)**
```bash
# Substitua com suas credenciais do Render
psql "postgresql://sasconv_user:SUA_SENHA@dpg-xxxxx.virginia-postgres.render.com:5432/agenda_db?sslmode=require" <<EOF
CREATE SCHEMA IF NOT EXISTS evolution;
GRANT ALL ON SCHEMA evolution TO sasconv_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA evolution GRANT ALL ON TABLES TO sasconv_user;
\dn
EOF
```

**Opção C: Executar arquivo SQL**
```bash
psql "postgresql://..." < setup-evolution-schema.sql
```

### ☑️ PASSO 3: Atualizar DATABASE_URL no Render

1. Acesse: https://dashboard.render.com
2. Vá no serviço **Evolution API**
3. Clique em "Environment"
4. Localize `DATABASE_URL`
5. **ADICIONE** `&schema=evolution` no final:

**ANTES:**
```
postgresql://sasconv_user:senha@host:5432/agenda_db?sslmode=require
```

**DEPOIS:**
```
postgresql://sasconv_user:senha@host:5432/agenda_db?sslmode=require&schema=evolution
```

6. Clique em "Save Changes"

### ☑️ PASSO 4: Commit e Push das Proteções

```bash
# Na pasta do projeto:
cd C:\dev\AgendaOnSell

# Verificar mudanças
git status

# Adicionar arquivos modificados
git add evolution-api/db-deploy.sh
git add evolution-api/README.md
git add evolution-api/SOLUCAO_CRITICA_PERDA_DADOS.md
git add evolution-api/ACAO_IMEDIATA.md
git add evolution-api/setup-evolution-schema.sql

# Commit
git commit -m "fix(evolution-api): Add critical protection against data loss

- Add schema validation in db-deploy.sh
- Require &schema=evolution in DATABASE_URL
- Prevent Prisma from dropping AgendaOnSell tables
- Add setup-evolution-schema.sql helper script"

# Push
git push origin main
```

### ☑️ PASSO 5: Fazer Deploy Manual (Teste)

1. No Render Dashboard da Evolution API
2. Clique em "Manual Deploy" → "Deploy latest commit"
3. **Monitore os logs em tempo real**
4. **PROCURE POR:**
   - ✅ "DATABASE_URL encontrada com schema isolado"
   - ✅ "Schema 'evolution': Evolution API (ISOLADO)"
   - ✅ "SUCESSO: Schema Evolution API sincronizado!"
   - ❌ Se aparecer "ERRO CRÍTICO: DATABASE_URL SEM SCHEMA ISOLADO!" → Volte ao Passo 3

### ☑️ PASSO 6: Validar Schema no Banco

Execute no PostgreSQL para confirmar que está correto:

```sql
-- Listar todos os schemas
SELECT schema_name FROM information_schema.schemata
WHERE schema_name IN ('public', 'evolution')
ORDER BY schema_name;

-- Resultado esperado:
--  schema_name
-- -------------
--  evolution   ← Evolution API (isolado)
--  public      ← AgendaOnSell (intacto)

-- Listar tabelas em cada schema
SELECT
  schemaname,
  COUNT(*) as total_tabelas
FROM pg_tables
WHERE schemaname IN ('public', 'evolution')
GROUP BY schemaname;

-- Resultado esperado:
--  schemaname | total_tabelas
-- ------------+---------------
--  public     | 12-15 (AgendaOnSell)
--  evolution  | 6-8 (Evolution API)
```

### ☑️ PASSO 7: Testar Integração WhatsApp

1. Acesse o AgendaOnSell
2. Vá em `/whatsapp`
3. Teste conexão com "Send Test Message"
4. Verifique se mensagem foi enviada

---

## ✅ VALIDAÇÃO FINAL

Execute este checklist para confirmar que está tudo OK:

- [ ] Backup do banco criado
- [ ] Schema `evolution` criado no PostgreSQL
- [ ] `DATABASE_URL` contém `&schema=evolution`
- [ ] Deploy bem-sucedido (logs mostram schema isolado)
- [ ] Tabelas do AgendaOnSell intactas (verificado via SQL)
- [ ] Evolution API funcionando (test message OK)
- [ ] Sem erros nos logs do Render

---

## 🛡️ PROTEÇÕES IMPLEMENTADAS

Após implementar esta solução, você terá:

✅ **Isolamento Total**: Evolution API e AgendaOnSell em schemas separados
✅ **Validação Automática**: Deploy falha se `&schema=evolution` não estiver presente
✅ **Mensagens Claras**: Logs indicam exatamente o que está acontecendo
✅ **Rollback Seguro**: Se algo der errado, só o schema `evolution` é afetado
✅ **Futuro Garantido**: Impossível haver perda de dados por acidente

---

## ⚠️ O QUE NÃO FAZER

❌ **NÃO** faça deploy sem criar o schema `evolution`
❌ **NÃO** remova `&schema=evolution` da DATABASE_URL
❌ **NÃO** modifique `db-deploy.sh` para pular a validação
❌ **NÃO** use `migrate deploy` no lugar de `db push`

---

## 🆘 EM CASO DE EMERGÊNCIA

Se o deploy falhar ou houver perda de dados:

1. **PARE TUDO** - Não faça mais deploys
2. **Restaure o backup** via Render Dashboard
3. **Recomece do Passo 1** deste guia
4. **Valide cada etapa** antes de prosseguir

---

## 📞 SUPORTE

Se tiver dúvidas:
1. Leia `SOLUCAO_CRITICA_PERDA_DADOS.md` (documentação completa)
2. Verifique logs do deploy no Render
3. Execute comandos SQL de validação

---

**Data de Criação**: 2025-12-20
**Prioridade**: 🔴 URGENTE
**Tempo Estimado**: 15-20 minutos
**Risco se não implementar**: PERDA TOTAL DE DADOS DO AGENDAONSELL
