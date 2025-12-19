# 🚀 Guia Rápido de Deploy - Evolution API no Render

## Método Recomendado: Blueprint (Automático)

### Passo 1: Commitar arquivos
```bash
cd C:\dev\AgendaOnSell
git add evolution-api/
git commit -m "Add Evolution API service"
git push
```

### Passo 2: Criar Blueprint no Render

1. Acesse: https://dashboard.render.com
2. Clique em: **New** → **Blueprint**
3. Conecte ao repositório: **AgendaOnSell**
4. O Render detectará automaticamente o `render.yaml`
5. Clique em: **Apply**

### Passo 3: Configurar Variáveis de Ambiente

Após criar o serviço, configure estas 3 variáveis **OBRIGATÓRIAS**:

1. **SERVER_URL**
   - Valor: `https://seu-servico.onrender.com`
   - (Copie a URL que o Render gerou para você)

2. **DATABASE_URL**
   - Valor: `postgresql://user:password@host:5432/agenda_db?sslmode=require`
   - (Use a **MESMA** URL do PostgreSQL do backend Railway/Render)

3. **AUTHENTICATION_API_KEY**
   - Gere uma chave forte:
   ```bash
   # No terminal:
   openssl rand -base64 32
   ```
   - Ou use: https://www.uuidgenerator.net/api/guid

### Passo 4: Deploy Completo!

O Render fará o build e deploy automaticamente. Aguarde ~5-10 minutos.

---

## ✅ Após Deploy: Criar Instância WhatsApp

### 1. Criar Instância

```bash
curl -X POST https://seu-servico.onrender.com/instance/create \
  -H "apikey: SUA_API_KEY_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "instanceName": "agenda_onsell",
    "qrcode": true
  }'
```

### 2. Conectar via QR Code

Acesse no navegador:
```
https://seu-servico.onrender.com/instance/connect/agenda_onsell
```

**Importante**: Adicione o header `apikey: SUA_API_KEY` ou acesse via Postman/Insomnia

Abra WhatsApp no celular → **Dispositivos Conectados** → Leia o QR Code

### 3. Verificar Conexão

```bash
curl -X GET https://seu-servico.onrender.com/instance/connectionState/agenda_onsell \
  -H "apikey: SUA_API_KEY"
```

Resposta esperada:
```json
{
  "instance": {
    "instanceName": "agenda_onsell",
    "state": "open"
  }
}
```

---

## 🔧 Configurar no AgendaOnSell

1. Acesse: `http://localhost:3000/whatsapp` (ou sua URL de produção)
2. Preencha:
   - **URL da Evolution API**: `https://seu-servico.onrender.com`
   - **API Key**: Sua API Key gerada
   - **Nome da Instância**: `agenda_onsell`
3. Configure templates
4. Clique em **Enviar Teste** para validar

---

## ⚠️ Erros Comuns

### ❌ "invalid local: lstat /opt/render/project/src/evolution-api: no such file or directory"

**Solução**: Use **Blueprint** (New → Blueprint), não "Web Service"

### ❌ QR Code não aparece

**Solução**: Adicione o header `apikey` na requisição ou use Postman

### ❌ Conexão cai toda hora

**Soluções**:
1. Verifique se `DATABASE_URL` está configurado
2. Use PostgreSQL (não SQLite)
3. Considere upgrade para plano Starter (Free hiberna após 15min inativo)

---

## 📊 Checklist de Deploy

- [ ] Commitei `evolution-api/` no Git
- [ ] Criei Blueprint no Render
- [ ] Configurei `SERVER_URL`
- [ ] Configurei `DATABASE_URL` (mesma do backend)
- [ ] Configurei `AUTHENTICATION_API_KEY`
- [ ] Deploy finalizou sem erros
- [ ] Criei instância via API
- [ ] Li QR Code no WhatsApp
- [ ] Verifiquei conexão (state: "open")
- [ ] Configurei credenciais no AgendaOnSell
- [ ] Testei envio de mensagem

---

**🎉 Pronto! Seu Evolution API está funcionando!**

Para mais detalhes, veja `README.md`
