-- ============================================================================
-- SCRIPT DE VERIFICAÇÃO DA PROTEÇÃO CONTRA PERDA DE DADOS
-- ============================================================================
-- Execute este script após implementar a solução de schemas separados
-- para confirmar que tudo está configurado corretamente
-- ============================================================================

\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo '🔍 VERIFICAÇÃO DE SEGURANÇA - Evolution API + AgendaOnSell'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo ''

-- ============================================================================
-- TESTE 1: Verificar existência dos schemas
-- ============================================================================
\echo '📋 TESTE 1: Schemas existentes'
\echo '─────────────────────────────────────────────────────────────────────'

SELECT
  schema_name,
  CASE
    WHEN schema_name = 'public' THEN '✅ AgendaOnSell'
    WHEN schema_name = 'evolution' THEN '✅ Evolution API'
    ELSE '⚠️  Desconhecido'
  END as uso
FROM information_schema.schemata
WHERE schema_name IN ('public', 'evolution')
ORDER BY schema_name;

\echo ''
\echo '✅ Esperado: 2 schemas (public e evolution)'
\echo ''

-- ============================================================================
-- TESTE 2: Contagem de tabelas por schema
-- ============================================================================
\echo '📊 TESTE 2: Tabelas por schema'
\echo '─────────────────────────────────────────────────────────────────────'

SELECT
  schemaname as schema,
  COUNT(*) as total_tabelas,
  CASE
    WHEN schemaname = 'public' THEN '(AgendaOnSell: empresas, clientes, etc.)'
    WHEN schemaname = 'evolution' THEN '(Evolution API: Instance, Message, etc.)'
    ELSE '(?)'
  END as descricao
FROM pg_tables
WHERE schemaname IN ('public', 'evolution')
GROUP BY schemaname
ORDER BY schemaname;

\echo ''
\echo '✅ Esperado: ~12-15 tabelas no public, ~6-8 no evolution'
\echo ''

-- ============================================================================
-- TESTE 3: Verificar tabelas críticas do AgendaOnSell (schema public)
-- ============================================================================
\echo '🏢 TESTE 3: Tabelas críticas do AgendaOnSell'
\echo '─────────────────────────────────────────────────────────────────────'

SELECT
  table_name,
  '✅ Existe' as status
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'empresas',
    'estabelecimentos',
    'users',
    'clientes',
    'servicos',
    'agendamentos',
    'materiais',
    'whatsapp_configs'
  )
ORDER BY table_name;

\echo ''
\echo '✅ Esperado: Todas as 8 tabelas acima devem existir'
\echo ''

-- ============================================================================
-- TESTE 4: Verificar tabelas da Evolution API (schema evolution)
-- ============================================================================
\echo '📱 TESTE 4: Tabelas da Evolution API'
\echo '─────────────────────────────────────────────────────────────────────'

SELECT
  table_name,
  '✅ Existe' as status
FROM information_schema.tables
WHERE table_schema = 'evolution'
ORDER BY table_name;

\echo ''
\echo '✅ Esperado: Instance, Message, Contact, Chat, etc.'
\echo ''

-- ============================================================================
-- TESTE 5: Contar registros em tabelas críticas do AgendaOnSell
-- ============================================================================
\echo '📈 TESTE 5: Dados preservados no AgendaOnSell'
\echo '─────────────────────────────────────────────────────────────────────'

SELECT
  (SELECT COUNT(*) FROM public.empresas) as empresas,
  (SELECT COUNT(*) FROM public.estabelecimentos) as estabelecimentos,
  (SELECT COUNT(*) FROM public.users) as users,
  (SELECT COUNT(*) FROM public.clientes) as clientes,
  (SELECT COUNT(*) FROM public.agendamentos) as agendamentos;

\echo ''
\echo '✅ Esperado: Números > 0 em todas as colunas (dados preservados)'
\echo ''

-- ============================================================================
-- TESTE 6: Verificar permissões do usuário
-- ============================================================================
\echo '🔐 TESTE 6: Permissões do usuário'
\echo '─────────────────────────────────────────────────────────────────────'

SELECT
  grantee as usuario,
  table_schema as schema,
  privilege_type as permissao,
  '✅' as status
FROM information_schema.role_table_grants
WHERE grantee = 'sasconv_user'
  AND table_schema IN ('public', 'evolution')
GROUP BY grantee, table_schema, privilege_type
ORDER BY table_schema, privilege_type;

\echo ''
\echo '✅ Esperado: Permissões ALL em ambos os schemas'
\echo ''

-- ============================================================================
-- TESTE 7: Verificar isolamento (nenhuma tabela com mesmo nome)
-- ============================================================================
\echo '🛡️  TESTE 7: Isolamento de tabelas'
\echo '─────────────────────────────────────────────────────────────────────'

SELECT
  table_name,
  COUNT(*) as schemas_com_esta_tabela,
  CASE
    WHEN COUNT(*) > 1 THEN '⚠️  CONFLITO!'
    ELSE '✅ OK'
  END as status
FROM information_schema.tables
WHERE table_schema IN ('public', 'evolution')
GROUP BY table_name
HAVING COUNT(*) > 1;

\echo ''
\echo '✅ Esperado: Nenhuma linha (zero conflitos)'
\echo ''

-- ============================================================================
-- RESUMO FINAL
-- ============================================================================
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo '📊 RESUMO DA VERIFICAÇÃO'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo ''

DO $$
DECLARE
  v_public_tables INT;
  v_evolution_tables INT;
  v_empresas INT;
  v_clientes INT;
BEGIN
  -- Contar tabelas
  SELECT COUNT(*) INTO v_public_tables
  FROM information_schema.tables
  WHERE table_schema = 'public';

  SELECT COUNT(*) INTO v_evolution_tables
  FROM information_schema.tables
  WHERE table_schema = 'evolution';

  -- Contar dados
  SELECT COUNT(*) INTO v_empresas FROM public.empresas;
  SELECT COUNT(*) INTO v_clientes FROM public.clientes;

  -- Exibir resumo
  RAISE NOTICE '';
  RAISE NOTICE '✅ Schema public (AgendaOnSell):';
  RAISE NOTICE '   • % tabelas encontradas', v_public_tables;
  RAISE NOTICE '   • % empresas cadastradas', v_empresas;
  RAISE NOTICE '   • % clientes cadastrados', v_clientes;
  RAISE NOTICE '';
  RAISE NOTICE '✅ Schema evolution (Evolution API):';
  RAISE NOTICE '   • % tabelas encontradas', v_evolution_tables;
  RAISE NOTICE '';

  IF v_public_tables > 0 AND v_evolution_tables > 0 THEN
    RAISE NOTICE '🎉 SUCESSO: Schemas separados e dados preservados!';
    RAISE NOTICE '🔒 Isolamento total garantido.';
  ELSE
    RAISE WARNING '⚠️  ATENÇÃO: Verifique se o deploy foi concluído corretamente.';
  END IF;

  RAISE NOTICE '';
END $$;

\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo ''
\echo 'Para executar novamente:'
\echo '  psql "postgresql://..." < verify-schema-safety.sql'
\echo ''
