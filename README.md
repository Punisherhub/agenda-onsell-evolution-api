# Evolution API - Serviço WhatsApp

Este diretório contém a configuração do Evolution API, um serviço separado para gerenciar conexões WhatsApp.

---

## 🚨 ALERTA CRÍTICO: PERDA DE DADOS

**ANTES DE FAZER QUALQUER DEPLOY**, você DEVE:

1. **Criar schema separado no PostgreSQL** (protege contra perda de dados):
   ```bash
   # Execute este comando NO BANCO DE DADOS (Render Dashboard ou psql):
   psql "postgresql://sasconv_user:senha@host:5432/agenda_db?sslmode=require"
   ```
   ```sql
   CREATE SCHEMA IF NOT EXISTS evolution;
   GRANT ALL ON SCHEMA evolution TO sasconv_user;
   ALTER DEFAULT PRIVILEGES IN SCHEMA evolution GRANT ALL ON TABLES TO sasconv_user;
   ```
   **OU execute o arquivo:** `setup-evolution-schema.sql`

2. **Modificar DATABASE_URL** para incluir `&schema=evolution`:
   ```
   postgresql://user:pass@host:5432/agenda_db?sslmode=require&schema=evolution
   ```

   ⚠️ **SEM O `&schema=evolution`, O DEPLOY VAI EXCLUIR TODAS AS TABELAS DO AGENDAONSELL!**

3. **Validação automática**: O script `db-deploy.sh` agora valida se o schema está correto e BLOQUEIA o deploy se não estiver.

📖 **Documentação completa**: `SOLUCAO_CRITICA_PERDA_DADOS.md`

---

## 🚀 Deploy no Render

### Opção 1: Deploy Automático (Recomendado)

**A pasta `evolution-api/` contém um arquivo `render.yaml` que configura tudo automaticamente!**

1. **Commite os arquivos**:
   ```bash
   git add evolution-api/
   git commit -m "Add Evolution API service"
   git push
   ```

2. **Acesse o Render**:
   - Vá para https://dashboard.render.com
   - Clique em **New** → **Blueprint**
   - Conecte ao seu repositório Git
   - Selecione o repositório `AgendaOnSell`
   - O Render detectará automaticamente o `render.yaml`
   - Clique em **Apply**

3. **Configure as variáveis de ambiente obrigatórias**:
   - `SERVER_URL`: `https://seu-servico.onrender.com` (você receberá essa URL após criar)
   - `DATABASE_URL`: Cole a mesma URL do PostgreSQL do backend (Render)
   - `AUTHENTICATION_API_KEY`: Gere uma chave forte (veja abaixo)

### Opção 2: Deploy Manual

1. **Acesse https://dashboard.render.com**
2. Clique em **New** → **Web Service**
3. Conecte ao seu repositório Git
4. **IMPORTANTE - Configure exatamente assim**:
   - **Name**: `agenda-onsell-evolution-api`
   - **Region**: `Virginia (US East)` (mesma do banco)
   - **Branch**: `main`
   - **Root Directory**: `./evolution-api` ⚠️ **ATENÇÃO: com "./"**
   - **Runtime**: `Docker`
   - **Dockerfile Path**: `./evolution-api/Dockerfile`
   - **Docker Context**: `./evolution-api`
   - **Instance Type**: `Free` ou `Starter` ($7/mês)

### 2. Configurar Variáveis de Ambiente

No Render, adicione as seguintes **Environment Variables**:

```bash
# Server
SERVER_URL=https://seu-servico.onrender.com
SERVER_PORT=8080

# Database (use a mesma URL do backend principal)
DATABASE_URL=postgresql://user:password@host:5432/agenda_db?sslmode=require
DATABASE_ENABLED=true
DATABASE_PROVIDER=postgresql
DATABASE_SAVE_DATA_INSTANCE=true
DATABASE_SAVE_DATA_NEW_MESSAGE=true
DATABASE_SAVE_MESSAGE_UPDATE=true
DATABASE_SAVE_DATA_CONTACTS=true
DATABASE_SAVE_DATA_CHATS=true

# Authentication (GERE UMA CHAVE FORTE!)
AUTHENTICATION_API_KEY=sua_api_key_super_secreta_aqui

# CORS (ajuste para seu domínio)
CORS_ORIGIN=*
CORS_METHODS=GET,POST,PUT,DELETE
CORS_CREDENTIALS=true

# QR Code
QRCODE_LIMIT=30
QRCODE_COLOR=#198754

# Websocket
WEBSOCKET_ENABLED=false

# Logs
LOG_LEVEL=ERROR,WARN,DEBUG,INFO,LOG,VERBOSE,DARK,WEBHOOKS
LOG_COLOR=true
LOG_BAILEYS=error

# Storage
STORE_MESSAGES=true
STORE_MESSAGE_UP=true
STORE_CONTACTS=true
STORE_CHATS=true

# Provider
PROVIDER_ENABLED=false
```

### 3. Deploy

- Clique em **Create Web Service**
- Aguarde o build e deploy (5-10 minutos)
- A URL do serviço será algo como: `https://agenda-onsell-evolution-api.onrender.com`

### 4. Gerar API Key Forte

```bash
# No terminal (Linux/Mac):
openssl rand -base64 32

# Ou use um gerador online:
# https://www.uuidgenerator.net/api/guid
```

### 5. Testar Conexão

```bash
# Health check
curl https://seu-servico.onrender.com

# Listar instâncias (deve retornar array vazio no início)
curl -X GET https://seu-servico.onrender.com/instance/fetchInstances \
  -H "apikey: SUA_API_KEY_AQUI"
```

---

## 🧪 Teste Local (Desenvolvimento)

### Pré-requisitos
- Docker instalado
- Docker Compose instalado

### Passos:

1. **Copie o arquivo de ambiente**:
   ```bash
   cp .env.example .env
   ```

2. **Edite o `.env`**:
   - Adicione a URL do PostgreSQL (mesmo do backend)
   - Gere e adicione uma API Key forte
   - Ajuste outras configurações se necessário

3. **Inicie o serviço**:
   ```bash
   docker-compose up -d
   ```

4. **Verifique os logs**:
   ```bash
   docker-compose logs -f evolution-api
   ```

5. **Acesse**:
   - API: http://localhost:8080
   - Swagger/Docs: http://localhost:8080/manager (se habilitado)

6. **Parar o serviço**:
   ```bash
   docker-compose down
   ```

---

## 📡 Endpoints Principais

### Gerenciar Instâncias

**Criar instância**:
```bash
POST /instance/create
Headers:
  apikey: SUA_API_KEY
Body:
{
  "instanceName": "agenda_onsell",
  "qrcode": true
}
```

**Listar instâncias**:
```bash
GET /instance/fetchInstances
Headers:
  apikey: SUA_API_KEY
```

**Conectar (gerar QR Code)**:
```bash
GET /instance/connect/{instanceName}
Headers:
  apikey: SUA_API_KEY
```

**Status da conexão**:
```bash
GET /instance/connectionState/{instanceName}
Headers:
  apikey: SUA_API_KEY
```

### Enviar Mensagens

**Enviar texto**:
```bash
POST /message/sendText/{instanceName}
Headers:
  apikey: SUA_API_KEY
Body:
{
  "number": "5511999999999",
  "text": "Olá! Esta é uma mensagem de teste."
}
```

**Enviar com imagem**:
```bash
POST /message/sendMedia/{instanceName}
Headers:
  apikey: SUA_API_KEY
Body:
{
  "number": "5511999999999",
  "mediatype": "image",
  "media": "https://url-da-imagem.com/imagem.jpg",
  "caption": "Legenda da imagem"
}
```

---

## 🔧 Configuração no Backend Principal

Após deploy, adicione no **backend/.env** (ou nas variáveis de ambiente do Railway):

```bash
# Evolution API
EVOLUTION_API_URL=https://seu-servico.onrender.com
EVOLUTION_API_KEY=sua_api_key_aqui
```

---

## 📚 Documentação Oficial

- **Evolution API Docs**: https://doc.evolution-api.com
- **GitHub**: https://github.com/EvolutionAPI/evolution-api

---

## ⚠️ Importante

1. **Segurança**: A `AUTHENTICATION_API_KEY` deve ser uma chave **forte e única**. Nunca comite no Git!
2. **Database**: Use o **mesmo PostgreSQL** do backend principal (no Render)
3. **Instâncias**: Cada estabelecimento pode ter sua própria instância WhatsApp
4. **QR Code**: Após criar instância, conecte lendo o QR Code no endpoint `/instance/connect/{instanceName}`
5. **Persistência**: Os dados ficam salvos no PostgreSQL, então não se perdem no restart do Render

---

## 🐛 Troubleshooting

### ❌ Erro: "invalid local: resolve: lstat /opt/render/project/src/evolution-api: no such file or directory"

**Este é o erro mais comum!** Acontece quando o Render não consegue encontrar a pasta `evolution-api`. Soluções:

#### Solução 1: Use Blueprint (Mais Fácil)
1. Certifique-se de que o arquivo `render.yaml` está em `evolution-api/render.yaml`
2. Commite tudo: `git add . && git commit -m "Add evolution-api" && git push`
3. No Render, use **New → Blueprint** (não Web Service)
4. Selecione seu repositório
5. O Render detectará automaticamente o `render.yaml`

#### Solução 2: Configure Root Directory Corretamente
Se estiver usando **New → Web Service**:
1. Em **Root Directory**, coloque **exatamente**: `./evolution-api` (com `./` no início!)
2. Em **Dockerfile Path**, coloque: `./evolution-api/Dockerfile`
3. Em **Docker Context**, coloque: `./evolution-api`
4. **NÃO** use apenas `evolution-api` (sem `./`)

#### Solução 3: Mova para Repositório Separado (Mais Limpo)
```bash
# Crie um novo repositório só para Evolution API
mkdir evolution-api-deploy
cd evolution-api-deploy

# Copie os arquivos
cp -r ../AgendaOnSell/evolution-api/* .

# Inicialize git
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/seu-usuario/evolution-api-deploy.git
git push -u origin main

# No Render, conecte este novo repositório
# Root Directory: ./
# Dockerfile Path: ./Dockerfile
```

### Serviço não inicia
- Verifique os logs no Render Dashboard
- Confirme que `DATABASE_URL` está correto
- Verifique se a porta 8080 está configurada

### QR Code não aparece
- Acesse `/instance/connect/{instanceName}` via browser
- Verifique se `QRCODE_LIMIT=30` está configurado

### Mensagens não enviam
- Verifique se a instância está conectada: `/instance/connectionState/{instanceName}`
- Confirme formato do número: `5511999999999` (DDI + DDD + número)
- Veja os logs para erros específicos

### Conexão WhatsApp cai constantemente
- Verifique se `DATABASE_URL` está configurado (para persistência)
- Certifique-se de estar usando PostgreSQL (não SQLite)
- Verifique se o plano Free do Render não está hibernando (upgrade para Starter se necessário)

---

**Última Atualização**: 2025-12-18
**Versão Evolution API**: latest (atendai/evolution-api)
