#!/bin/bash
# uninstall.sh - Desinstalador Clean

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/scripts/lib/utils.sh"

log "WARN" "VOCÊ ESTÁ PRESTES A REMOVER O SUPABASE E TODOS OS DADOS!"
read -p "Tem certeza que deseja continuar? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "INFO" "Operação cancelada."
    exit 0
fi

if [ -d "supabase-instance" ]; then
    cd supabase-instance
    log "INFO" "Removendo containers e volumes..."
    docker compose down -v
    cd ..
    rm -rf supabase-instance
    log "SUCCESS" "Supabase desacoplado e arquivos removidos."
else
    log "ERROR" "Pasta 'supabase-instance' não encontrada. Nada para desinstalar."
fi
