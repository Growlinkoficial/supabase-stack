#!/bin/bash
# uninstall.sh - Remove completamente a instância Supabase

set -e

# Detectar diretório base do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Carregar utils
source "$SCRIPT_DIR/scripts/lib/utils.sh" 2>/dev/null || {
    # Fallback se utils.sh não existir
    log() { echo "[$1] $(date '+%Y-%m-%d %H:%M:%S') - $2"; }
}

# Procurar pasta supabase-instance
PROJECT_DIR=""
if [ -d "$BASE_DIR/supabase-instance" ]; then
    PROJECT_DIR="$BASE_DIR/supabase-instance"
elif [ -d "./supabase-instance" ]; then
    PROJECT_DIR="./supabase-instance"
elif [ -d "../supabase-instance" ]; then
    PROJECT_DIR="../supabase-instance"
else
    log "ERROR" "Pasta 'supabase-instance' não encontrada. Nada para desinstalar."
    exit 1
fi

log "WARN" "VOCÊ ESTÁ PRESTES A REMOVER O SUPABASE E TODOS OS DADOS!"
read -p "Tem certeza que deseja continuar? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "INFO" "Operação cancelada."
    exit 0
fi

cd "$PROJECT_DIR"

log "INFO" "Removendo containers e volumes..."
docker compose down -v 2>/dev/null || docker-compose down -v 2>/dev/null || true

# Remover rede Docker se ainda existir
NETWORK_NAME=$(docker network ls --filter "name=supabase" --format "{{.Name}}" | head -n 1)
if [ -n "$NETWORK_NAME" ]; then
    log "INFO" "Removendo rede Docker: $NETWORK_NAME"
    docker network rm "$NETWORK_NAME" 2>/dev/null || log "WARN" "Rede ainda em uso por outros containers. Será removida automaticamente quando não estiver mais em uso."
fi

cd ..
rm -rf "$(basename "$PROJECT_DIR")"

log "SUCCESS" "Supabase desacoplado e arquivos removidos."
