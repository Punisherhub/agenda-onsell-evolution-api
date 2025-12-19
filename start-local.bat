@echo off
echo ========================================
echo  Evolution API - Teste Local (Docker)
echo ========================================
echo.

REM Verifica se Docker está instalado
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Docker nao esta instalado!
    echo Por favor, instale Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Verifica se .env existe
if not exist .env (
    echo [AVISO] Arquivo .env nao encontrado!
    echo Criando .env a partir de .env.example...
    copy .env.example .env
    echo.
    echo IMPORTANTE: Edite o arquivo .env e adicione suas configuracoes!
    echo Pressione qualquer tecla apos editar o .env...
    pause
)

echo [INFO] Iniciando Evolution API via Docker Compose...
echo.

docker-compose up -d

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo  Evolution API iniciada com sucesso!
    echo ========================================
    echo.
    echo Acesse: http://localhost:8080
    echo.
    echo Para ver logs:    docker-compose logs -f evolution-api
    echo Para parar:       docker-compose down
    echo.
) else (
    echo [ERRO] Falha ao iniciar Evolution API!
)

pause
