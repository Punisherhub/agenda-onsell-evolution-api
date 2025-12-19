# 🔧 Troubleshooting - Deploy Evolution API no Render

## ❌ Erro: "Can't reach database server at localhost:5432"

### Causa do Problema
O Prisma está tentando conectar em `localhost:5432` porque a variável `DATABASE_URL` **NÃO está configurada** no Render Dashboard.

### ✅ Solução Completa - Passo a Passo

#### 1. Acesse o Render Dashboard
- URL: https://dashboard.render.com
- Encontre seu serviço (ex: `agenda-onsell-evolution-api`)
- Clique no nome do serviço

#### 2. Configure TODAS as Variáveis de Ambiente

Vá em **Environment** → **Add Environment Variable** e adicione:

##### Variáveis OBRIGATÓRIAS (Critical):

```bash
# ⚠️ DEIXE EM BRANCO AGORA - Preencha depois do primeiro deploy
SERVER_URL=

# Database do AgendaOnSell (mesmo PostgreSQL do backend)
DATABASE_URL=postgresql://sasconv_user:d5DezoH9fkvGQvAldNebbIAU0FWcm4Fe@dpg-d2195c6uk2gs7380vemg-a.virginia-postgres.render.com:5432/agenda_db?sslmode=require

# Gere uma chave forte (veja abaixo como gerar)
AUTHENTICATION_API_KEY=SuaChaveForteAqui
```

##### Variáveis de Configuração do Prisma:

```bash
DATABASE_PROVIDER=postgresql
DATABASE_ENABLED=true
DATABASE_SAVE_DATA_INSTANCE=true
DATABASE_SAVE_DATA_NEW_MESSAGE=true
DATABASE_SAVE_MESSAGE_UPDATE=true
DATABASE_SAVE_DATA_CONTACTS=true
DATABASE_SAVE_DATA_CHATS=true
```

##### Variáveis de CORS e Servidor:

```bash
SERVER_PORT=8080
CORS_ORIGIN=*
CORS_METHODS=GET,POST,PUT,DELETE
CORS_CREDENTIALS=true
```

##### Variáveis de Logging:

```bash
LOG_LEVEL=ERROR,WARN,DEBUG,INFO,LOG,VERBOSE,DARK,WEBHOOKS
LOG_COLOR=true
LOG_BAILEYS=error
```

##### Variáveis de Storage:

```bash
STORE_MESSAGES=true
STORE_MESSAGE_UP=true
STORE_CONTACTS=true
STORE_CHATS=true
```

##### Variáveis de QR Code:

```bash
QRCODE_LIMIT=30
QRCODE_COLOR=#198754
```

##### Outras Configurações:

```bash
WEBSOCKET_ENABLED=false
PROVIDER_ENABLED=false
```

#### 3. Gerar API Key Forte

**Opção A - Git Bash / Linux / Mac:**
```bash
openssl rand -base64 32
```

**Opção B - PowerShell (Windows):**
```powershell
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})
```

**Opção C - Online:**
- Acesse: https://www.uuidgenerator.net/api/guid
- Copie o UUID gerado

#### 4. Salvar e Aguardar Deploy

1. Clique em **Save Changes**
2. O Render vai **automaticamente reimplantar**
3. Aguarde ~5-10 minutos
4. Monitore os logs em **Logs** → **Deploy Logs**

#### 5. Após Deploy Completar

1. Copie a URL gerada (ex: `https://agenda-onsell-evolution-api.onrender.com`)
2. Volte em **Environment**
3. **Edite** a variável `SERVER_URL`
4. Cole a URL gerada: `https://agenda-onsell-evolution-api.onrender.com`
5. Salve (vai reimplantar novamente)

#### 6. Testar a API

```bash
# Teste básico (deve retornar status ok)
curl https://sua-url.onrender.com

# Resposta esperada:
# {"status":"ok","version":"2.1.1"}
```

---

## 📋 Checklist de Variáveis Configuradas

Antes de fazer o deploy, verifique se configurou:

- [ ] `DATABASE_URL` - **URL completa do PostgreSQL**
- [ ] `AUTHENTICATION_API_KEY` - **Chave forte gerada**
- [ ] `DATABASE_PROVIDER=postgresql`
- [ ] `DATABASE_ENABLED=true`
- [ ] `SERVER_PORT=8080`
- [ ] `CORS_ORIGIN=*`
- [ ] Todas as variáveis de `DATABASE_SAVE_*`
- [ ] Todas as variáveis de `STORE_*`

---

## 🔍 Como Verificar se Funcionou

### 1. Verificar Logs de Deploy

No Render Dashboard → **Logs** → **Deploy Logs**

**Procure por:**
```
✅ Prisma schema loaded
✅ Prisma migrate deploy succeeded
✅ Server listening on port 8080
```

**NÃO deve aparecer:**
```
❌ Error: P1001: Can't reach database server at localhost:5432
❌ Migration failed
```

### 2. Testar Conexão com Database

```bash
curl https://sua-url.onrender.com/instance/fetchInstances \
  -H "apikey: SUA_API_KEY"
```

Se retornar `[]` (array vazio) = **Conexão OK!**

Se retornar erro 401 = **API Key incorreta**

Se retornar erro 500 = **Database não conectou**

---

## 🐛 Outros Erros Comuns

### Erro: "Migration failed"

**Solução:** Certifique-se que:
1. `DATABASE_URL` está **EXATAMENTE** correta (copie do backend)
2. Tem `?sslmode=require` no final da URL
3. O database `agenda_db` existe no Render

### Erro: "P1001: Can't reach database server"

**Solução:**
1. Verifique se `DATABASE_URL` está configurada no Render
2. Teste a conexão do database manualmente
3. Certifique-se que o IP do Render está autorizado (Render → Render = sempre autorizado)

### Erro: "Dockerfile not found"

**Solução:**
1. Certifique-se que `Dockerfile` está na **raiz** do repositório
2. No Render, configure: `Dockerfile Path = ./Dockerfile`

### Erro: "Environment variable not set"

**Solução:**
1. Vá em **Environment** no Render Dashboard
2. Adicione manualmente as variáveis que estão faltando
3. Salve e aguarde reimplantar

---

## ✅ Configuração Completa (Copiar e Colar)

Para facilitar, aqui está a lista completa de variáveis:

```
SERVER_URL=https://sua-url.onrender.com
SERVER_PORT=8080
DATABASE_URL=postgresql://sasconv_user:d5DezoH9fkvGQvAldNebbIAU0FWcm4Fe@dpg-d2195c6uk2gs7380vemg-a.virginia-postgres.render.com:5432/agenda_db?sslmode=require
DATABASE_PROVIDER=postgresql
DATABASE_ENABLED=true
DATABASE_SAVE_DATA_INSTANCE=true
DATABASE_SAVE_DATA_NEW_MESSAGE=true
DATABASE_SAVE_MESSAGE_UPDATE=true
DATABASE_SAVE_DATA_CONTACTS=true
DATABASE_SAVE_DATA_CHATS=true
AUTHENTICATION_API_KEY=SuaChaveForteAqui123456789
CORS_ORIGIN=*
CORS_METHODS=GET,POST,PUT,DELETE
CORS_CREDENTIALS=true
LOG_LEVEL=ERROR,WARN,DEBUG,INFO,LOG,VERBOSE,DARK,WEBHOOKS
LOG_COLOR=true
LOG_BAILEYS=error
STORE_MESSAGES=true
STORE_MESSAGE_UP=true
STORE_CONTACTS=true
STORE_CHATS=true
QRCODE_LIMIT=30
QRCODE_COLOR=#198754
WEBSOCKET_ENABLED=false
PROVIDER_ENABLED=false
```

**⚠️ IMPORTANTE:**
1. Substitua `SuaChaveForteAqui123456789` por uma chave real (gere com comandos acima)
2. Deixe `SERVER_URL` vazio no primeiro deploy
3. Após deploy, edite `SERVER_URL` com a URL gerada pelo Render

---

## 📞 Ainda com Problemas?

1. **Verifique os logs detalhados:** Render Dashboard → Logs → Deploy Logs
2. **Copie o erro completo** e busque na documentação da Evolution API
3. **Teste a conexão do database manualmente** usando o mesmo `DATABASE_URL`

---

**Última Atualização:** 2025-12-19
**Versão:** 1.0
