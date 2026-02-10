#!/bin/bash
# checks.sh - Pré-requisitos e checagem de ambiente

# Verifica se a porta está em uso (Retorna 0 se em uso, 1 se livre)
is_port_in_use() {
    local port=$1
    if lsof -i :$port >/dev/null 2>&1 || nc -z localhost $port >/dev/null 2>&1; then
        return 0 # Em uso
    fi
    return 1 # Livre
}

# Encontra uma porta livre a partir de uma porta base
find_free_port() {
    local base_port=$1
    local port=$base_port
    while is_port_in_use "$port"; do
        ((port++))
    done
    echo "$port"
}

check_dependencies() {
    local deps=("docker" "git" "openssl" "curl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "ERROR" "Dependência não encontrada: $dep. Por favor, instale-a antes de continuar."
            exit 1
        fi
    done
    log "SUCCESS" "Todas as dependências encontradas."
}

check_docker_compose() {
    if ! docker compose version &> /dev/null; then
        log "ERROR" "Docker Compose (V2) não encontrado. O Supabase requer Docker Compose V2."
        exit 1
    fi
}
