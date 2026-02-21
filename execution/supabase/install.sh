#!/bin/bash
# install.sh - Instalador principal Supabase Self-Hosted

set -euo pipefail

# Inclusão de bibliotecas
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/scripts/lib/utils.sh"
source "$BASE_DIR/scripts/lib/checks.sh"
source "$BASE_DIR/utils/generate_secrets.sh"

# Fix CRLF no início
fix_crlf "$0"

log "INFO" "Iniciando instalação do Supabase Self-Hosted..."

# 1. Pre-flight checks
check_dependencies
check_docker_compose

# 2. Definição Dinâmica de Portas
log "INFO" "Verificando disponibilidade de portas..."

# Postgres (Default 5432)
POSTGRES_PORT=$(find_free_port 5432)
if [ "$POSTGRES_PORT" != "5432" ]; then
    log "WARN" "Porta 5432 ocupada. Usando $POSTGRES_PORT para o Postgres."
fi

# API Gateway / Kong (Default 8000)
API_PORT=$(find_free_port 8000)
if [ "$API_PORT" != "8000" ]; then
    log "WARN" "Porta 8000 ocupada. Usando $API_PORT para API Gateway."
fi

# Studio (Default 3000)
STUDIO_PORT=$(find_free_port 3000)
if [ "$STUDIO_PORT" != "3000" ]; then
    log "WARN" "Porta 3000 ocupada. Usando $STUDIO_PORT para o Studio."
fi

# 3. Obter o código do Supabase
if [ -d "supabase" ]; then
    log "INFO" "Diretório 'supabase' já existe. Atualizando..."
    cd supabase && git pull && cd ..
else
    log "INFO" "Clonando repositório do Supabase..."
    git clone --depth 1 https://github.com/supabase/supabase
fi

# 4. Preparar diretório do projeto
PROJECT_DIR="supabase-instance"
mkdir -p "$PROJECT_DIR"
cp -rf supabase/docker/. "$PROJECT_DIR/"
cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"

# 5. Configurar .env com Secrets e Portas
cd "$PROJECT_DIR"
update_env_secrets ".env"
chmod 600 ".env"

# Criar docker-compose.override.yml para garantir exposição de portas
log "INFO" "Copiando docker-compose.override.yml do template..."
if [ -f "$BASE_DIR/scripts/docker-compose.override.yml" ]; then
    cp "$BASE_DIR/scripts/docker-compose.override.yml" "docker-compose.override.yml"
else
    log "WARN" "Template docker-compose.override.yml não encontrado em scripts/. Gerando padrão..."
    cat <<EOF > "docker-compose.override.yml"
services:
  studio:
    ports:
      - "\${STUDIO_PORT}:3000"
EOF
fi

# Atualizar Portas no .env
log "INFO" "Configurando portas no .env..."

# Garantir que as variáveis existam no .env para evitar avisos do Docker Compose
update_env_var "POSTGRES_PORT" "$POSTGRES_PORT" ".env"
update_env_var "KONG_HTTP_PORT" "$API_PORT" ".env"
update_env_var "STUDIO_PORT" "$STUDIO_PORT" ".env"

# Exportar para o ambiente atual para garantir que o Docker Compose veja
export POSTGRES_PORT KONG_HTTP_PORT STUDIO_PORT

# 6. Subir os containers
log "INFO" "Baixando imagens e iniciando containers..."
docker compose pull
docker compose up -d

# 7. Aguardar containers ficarem saudáveis
log "INFO" "Aguardando serviços iniciarem corretamente..."
MAX_RETRIES=30
COUNT=0
while [ $COUNT -lt $MAX_RETRIES ]; do
    UNHEALTHY=$(docker compose ps --format json | grep -v "healthy" | grep -v "running" || true)
    if [ -z "$UNHEALTHY" ]; then
        log "SUCCESS" "Todos os serviços estão saudáveis!"
        break
    fi
    COUNT=$((COUNT + 1))
    sleep 5
    echo -n "."
done

if [ $COUNT -eq $MAX_RETRIES ]; then
    log "WARN" "Alguns serviços demoraram muito para iniciar. Verifique com 'docker compose ps'."
fi

log "SUCCESS" "Supabase instalado e rodando!"
log "INFO" "API Gateway: http://localhost:$API_PORT"
log "INFO" "Supabase Studio: http://localhost:$STUDIO_PORT"
log "INFO" "Postgres Connection: localhost:$POSTGRES_PORT"
log "INFO" "Veja SUPABASE_SETUP.md para instruções de integração com n8n."
