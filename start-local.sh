#!/bin/bash

echo "========================================"
echo " Evolution API - Teste Local (Docker)"
echo "========================================"
echo ""

# Verifica se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "[ERRO] Docker não está instalado!"
    echo "Por favor, instale Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verifica se .env existe
if [ ! -f .env ]; then
    echo "[AVISO] Arquivo .env não encontrado!"
    echo "Criando .env a partir de .env.example..."
    cp .env.example .env
    echo ""
    echo "IMPORTANTE: Edite o arquivo .env e adicione suas configurações!"
    read -p "Pressione Enter após editar o .env..."
fi

echo "[INFO] Iniciando Evolution API via Docker Compose..."
echo ""

docker-compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo " Evolution API iniciada com sucesso!"
    echo "========================================"
    echo ""
    echo "Acesse: http://localhost:8080"
    echo ""
    echo "Para ver logs:    docker-compose logs -f evolution-api"
    echo "Para parar:       docker-compose down"
    echo ""
else
    echo "[ERRO] Falha ao iniciar Evolution API!"
fi
