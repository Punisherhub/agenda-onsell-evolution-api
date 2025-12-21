# 🔧 FIX: Evolution API - Render Deploy

## 🔴 Problema Identificado

### Sintoma:
- ✅ Servidor inicia
- ❌ Crash com erro: `Cannot read properties of undefined (reading 'listen')`
- ❌ **TABELAS NÃO FORAM CRIADAS** no schema `evolution`

### Causa Raiz:
O script `db-deploy.sh` (que cria as tabelas) **NÃO estava sendo executado** antes de iniciar o servidor.

O arquivo `start.sh` tinha este comentário:
```bash
# Migrations já foram executadas pelo db-deploy.sh durante o deploy
# Apenas iniciar o servidor
```

**Mas isso estava ERRADO!** No Render com Docker, não há fase de build separada - tudo acontece no runtime.

---

## ✅ Correção Aplicada

**Arquivo modificado**: `evolution-api/start.sh`

Agora o `start.sh`:
1. ✅ Valida variáveis de ambiente
2. ✅ **EXECUTA `db-deploy.sh`** (NOVO!)
3. ✅ Cria as tabelas no schema `evolution`
4. ✅ Inicia o servidor

---

## 🚀 Como Fazer o Deploy Agora

### Passo 1: Verificar Variáveis de Ambiente no Render

Acesse Render Dashboard → **Environment** e confira se TODAS estas variáveis estão configuradas:

#### ⚠️ OBRIGATÓRIAS (você deve preencher):

```bash
DATABASE_URL=postgresql://sasconv_user:SENHA@dpg-xxxxx.virginia-postgres.render.com:5432/agenda_db?sslmode=require&schema=evolution
#                                                                                                                              ^^^^^^^^^^^^^^^^
# IMPORTANTE: Deve ter "&schema=evolution" no final!

AUTHENTICATION_API_KEY=SuaChaveForteAqui123
# Gere uma chave forte (ex: openssl rand -base64 32)

SERVER_URL=https://seu-servico.onrender.com
# URL do serviço (você receberá após deploy)
# Se ainda não tiver, deixe vazio agora e preencha depois
```

#### ✅ AUTOMÁTICAS (já configuradas no render.yaml):

```bash
SERVER_PORT=8080
DATABASE_ENABLED=true
DATABASE_PROVIDER=postgresql
DATABASE_SAVE_DATA_INSTANCE=true
DATABASE_SAVE_DATA_NEW_MESSAGE=true
DATABASE_SAVE_MESSAGE_UPDATE=true
DATABASE_SAVE_DATA_CONTACTS=true
DATABASE_SAVE_DATA_CHATS=true
CORS_ORIGIN=*
CORS_METHODS=GET,POST,PUT,DELETE
CORS_CREDENTIALS=true
QRCODE_LIMIT=30
QRCODE_COLOR=#198754
WEBSOCKET_ENABLED=false
LOG_LEVEL=ERROR,WARN,DEBUG,INFO,LOG,VERBOSE,DARK,WEBHOOKS
LOG_COLOR=true
LOG_BAILEYS=error
STORE_MESSAGES=true
STORE_MESSAGE_UP=true
STORE_CONTACTS=true
STORE_CHATS=true
PROVIDER_ENABLED=false
```

---

### Passo 2: Fazer Commit e Push

```bash
cd C:\dev\AgendaOnSell

# Adicionar arquivos modificados
git add evolution-api/start.sh evolution-api/FIX_RENDER_DEPLOY.md

# Commit
git commit -m "fix(evolution-api): Execute db-deploy.sh before starting server"

# Push
git push
```

---

### Passo 3: Fazer Deploy no Render

#### Opção A: Se o serviço já existe (Manual Deploy)

1. Acesse: https://dashboard.render.com
2. Clique no serviço **agenda-onsell-evolution-api**
3. Clique em **Manual Deploy** → **Deploy latest commit**
4. Monitore os logs (próximo passo)

#### Opção B: Se ainda não criou o serviço

1. Acesse: https://dashboard.render.com
2. Clique em **New** → **Blueprint**
3. Conecte ao repositório **AgendaOnSell**
4. Selecione o branch `main`
5. O Render detectará `evolution-api/render.yaml`
6. Clique em **Apply**

---

### Passo 4: Monitorar os Logs (CRÍTICO)

Acesse Render Dashboard → **Logs** → **Deploy Logs**

#### ✅ LOGS ESPERADOS (SUCESSO):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Iniciando Evolution API
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Workdir: /evolution
🗑️  Removendo arquivos .env locais...
✅ DATABASE_URL encontrada
📊 Banco: dpg-d2195c6uk2gs7380vemg-a.virginia-postgres.render.com

📝 Mapeando DATABASE_URL → DATABASE_CONNECTION_URI
✅ DATABASE_CONNECTION_URI já definida

📋 Variáveis de ambiente:
   • DATABASE_PROVIDER: postgresql
   • DATABASE_ENABLED: true
   • SERVER_PORT: 8080

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔨 Aplicando Migrations do Prisma
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

=== Evolution API - Database Deploy Script ===
✅ DATABASE_URL encontrada com schema isolado
📊 Banco: dpg-d2195c6uk2gs7380vemg-a.virginia-postgres.render.com
🔒 Schema: evolution (isolado do AgendaOnSell)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 BANCO COMPARTILHADO - SCHEMAS SEPARADOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔒 Schema 'evolution': Evolution API (ISOLADO)
✅ Schema 'public': AgendaOnSell (PROTEGIDO)

Usando 'db push' para sincronizar schema evolution

Prisma schema loaded from ./prisma/postgresql-schema.prisma
Datasource "db": PostgreSQL database "agenda_db", schema "evolution" at "dpg-xxx..."

🚀  Your database is now in sync with your Prisma schema. Done in 2.5s

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ SUCESSO: Schema Evolution API sincronizado!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Schema 'evolution' (Evolution API):
   • Instance, Message, Contact, Chat
   • Webhook, Session, MessageUpdate
   • _prisma_migrations

✅ Schema 'public' (AgendaOnSell) - 100% INTACTO:
   • empresas, estabelecimentos, users
   • clientes, servicos, agendamentos
   • materiais, consumos_materiais
   • configuracao_fidelidade, premios, resgates_premios
   • whatsapp_configs

🔒 ISOLAMENTO TOTAL GARANTIDO!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Iniciando servidor Evolution API
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 Porta: 8080
📡 Aguardando conexões...

[Evolution API] Server started on port 8080
[Prisma] Connected to database
```

**SE VOCÊ VER ISSO = SUCESSO TOTAL! 🎉**

---

#### ❌ LOGS DE ERRO (se aparecer):

##### Erro 1: `DATABASE_URL SEM SCHEMA ISOLADO`

```
🚨 ERRO CRÍTICO: DATABASE_URL SEM SCHEMA ISOLADO!
⚠️  A DATABASE_URL DEVE incluir '&schema=evolution' no final!
```

**Solução:**
1. Vá em Render Dashboard → Environment
2. Edite `DATABASE_URL`
3. Adicione `&schema=evolution` no final
4. Save Changes → Manual Deploy

##### Erro 2: `Cannot read properties of undefined`

```
TypeError: Cannot read properties of undefined (reading 'listen')
```

**Solução:**
- Verifique se `AUTHENTICATION_API_KEY` está definido
- Verifique se todas as variáveis DATABASE_* estão corretas

##### Erro 3: `Permission denied for schema evolution`

```
ERROR: permission denied for schema evolution
```

**Solução:**
Execute no banco de dados:
```sql
GRANT ALL ON SCHEMA evolution TO sasconv_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA evolution GRANT ALL ON TABLES TO sasconv_user;
```

---

### Passo 5: Validar que as Tabelas Foram Criadas

Execute este script SQL no banco de dados:

```sql
-- Verificar tabelas no schema evolution
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname = 'evolution'
ORDER BY tablename;
```

**Resultado esperado (6-8 tabelas):**
```
schemaname | tablename
-----------+--------------------
evolution  | Chat
evolution  | Contact
evolution  | Instance
evolution  | Message
evolution  | MessageUpdate
evolution  | Session
evolution  | Webhook
evolution  | _prisma_migrations
```

---

### Passo 6: Testar o Servidor

```bash
# Health check
curl https://seu-servico.onrender.com

# Deve retornar:
# {"status":"ok","version":"latest"}
```

Se retornar isso = **Evolution API funcionando! 🎉**

---

## 📋 Checklist Final

Antes de considerar resolvido, verifique:

- [ ] `start.sh` modificado (commit feito)
- [ ] `DATABASE_URL` tem `&schema=evolution` no final
- [ ] `AUTHENTICATION_API_KEY` está definido
- [ ] Deploy completou com sucesso
- [ ] Logs mostram "✅ SUCESSO: Schema Evolution API sincronizado!"
- [ ] Logs mostram "Schema 'evolution' (Evolution API):"
- [ ] Logs mostram "Server started on port 8080"
- [ ] **Tabelas criadas no schema evolution** (6-8 tabelas)
- [ ] Teste curl retorna `{"status":"ok"}`
- [ ] Servidor NÃO crashou (sem erro "Cannot read properties")

---

## 🎯 Próximos Passos (Após Deploy Funcionar)

### 1. Atualizar SERVER_URL (se deixou vazio antes)

1. Copie a URL gerada (ex: `https://agenda-onsell-evolution-api.onrender.com`)
2. Vá em Environment
3. Edite `SERVER_URL` e cole a URL
4. Save Changes (vai reimplantar automaticamente)

### 2. Criar Instância WhatsApp

```bash
curl -X POST https://seu-servico.onrender.com/instance/create \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"instanceName": "agenda_onsell", "qrcode": true}'
```

### 3. Conectar via QR Code

Acesse no browser:
```
https://seu-servico.onrender.com/instance/connect/agenda_onsell?apikey=SUA_API_KEY
```

Leia o QR Code com WhatsApp no celular.

### 4. Configurar no AgendaOnSell

1. Acesse `/whatsapp` no sistema
2. Preencha:
   - URL: `https://seu-servico.onrender.com`
   - API Key: Sua chave
   - Instance: `agenda_onsell`
3. Teste o envio

---

## 📚 Resumo das Mudanças

| Arquivo | Mudança | Por quê |
|---------|---------|---------|
| `start.sh` | Adicionado `bash /evolution/db-deploy.sh` antes de iniciar servidor | Para criar as tabelas ANTES do servidor tentar usá-las |
| `FIX_RENDER_DEPLOY.md` | Criado (este arquivo) | Documentação da solução |

---

**Última Atualização:** 2025-12-20
**Status:** ✅ Solução Implementada - Aguardando Deploy
