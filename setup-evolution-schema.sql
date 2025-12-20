-- ============================================================================
-- SCRIPT DE CONFIGURAÇÃO DO SCHEMA EVOLUTION
-- ============================================================================
-- Este script cria um schema PostgreSQL separado para a Evolution API
-- garantindo ISOLAMENTO TOTAL das tabelas do AgendaOnSell
--
-- EXECUTE ESTE SCRIPT UMA VEZ no banco PostgreSQL antes do primeiro deploy
-- ============================================================================

-- 1. Criar schema 'evolution' (se não existir)
CREATE SCHEMA IF NOT EXISTS evolution;

-- 2. Conceder TODAS as permissões para o usuário do banco
-- IMPORTANTE: Substitua 'sasconv_user' pelo usuário real do seu banco
GRANT ALL ON SCHEMA evolution TO sasconv_user;

-- 3. Garantir permissões em tabelas existentes e futuras
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA evolution TO sasconv_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA evolution TO sasconv_user;

-- 4. Definir permissões padrão para objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA evolution GRANT ALL ON TABLES TO sasconv_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA evolution GRANT ALL ON SEQUENCES TO sasconv_user;

-- 5. Verificar schemas criados
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('public', 'evolution')
ORDER BY schema_name;

-- ============================================================================
-- RESULTADO ESPERADO:
--
--  schema_name
-- -------------
--  evolution
--  public
--
-- ✅ Schema 'evolution' criado e configurado com sucesso!
-- ✅ Schema 'public' permanece com tabelas do AgendaOnSell
-- ============================================================================

-- 6. PRÓXIMOS PASSOS:
--
-- 1. Execute este script no banco PostgreSQL (Render Dashboard ou psql)
--
-- 2. Modifique a DATABASE_URL no Render para incluir o schema:
--    ANTES: postgresql://user:pass@host:5432/agenda_db?sslmode=require
--    DEPOIS: postgresql://user:pass@host:5432/agenda_db?sslmode=require&schema=evolution
--
-- 3. Faça deploy da Evolution API - o script db-deploy.sh vai validar
--    que o schema está correto antes de prosseguir
--
-- ============================================================================
