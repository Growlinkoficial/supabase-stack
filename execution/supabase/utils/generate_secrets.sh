#!/bin/bash
# generate_secrets.sh - Gera chaves JWT e senhas aleatórias

# Carregar utils para cores se disponível
[[ -f "./scripts/lib/utils.sh" ]] && source "./scripts/lib/utils.sh"

generate_jwt_secret() {
    openssl rand -base64 32
}

generate_password() {
    openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 20
}

# Função para gerar JWT tokens usando o JWT_SECRET
generate_jwt_token() {
    local role=$1
    local secret=$2
    
    # Header
    local header='{"alg":"HS256","typ":"JWT"}'
    local header_b64=$(echo -n "$header" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    
    # Payload - expira em 10 anos (315360000 segundos)
    local exp=$(($(date +%s) + 315360000))
    local payload="{\"role\":\"$role\",\"iss\":\"supabase\",\"iat\":$(date +%s),\"exp\":$exp}"
    local payload_b64=$(echo -n "$payload" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    
    # Signature
    local signature=$(echo -n "${header_b64}.${payload_b64}" | openssl dgst -sha256 -hmac "$secret" -binary | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    
    echo "${header_b64}.${payload_b64}.${signature}"
}

update_env_secrets() {
    local env_file=$1
    
    log "INFO" "Gerando novos segredos para $env_file..."

    POSTGRES_PASSWORD=$(generate_password)
    JWT_SECRET=$(generate_jwt_secret)
    
    # Gerar JWT tokens usando o JWT_SECRET
    ANON_KEY=$(generate_jwt_token "anon" "$JWT_SECRET")
    SERVICE_ROLE_KEY=$(generate_jwt_token "service_role" "$JWT_SECRET")
    
    # Dashboard/Studio Auth
    DASHBOARD_USERNAME="supabase"
    DASHBOARD_PASSWORD=$(generate_password)

    # Substituições no .env
    sed -i "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$POSTGRES_PASSWORD|" "$env_file"
    sed -i "s|JWT_SECRET=.*|JWT_SECRET=$JWT_SECRET|" "$env_file"
    sed -i "s|ANON_KEY=.*|ANON_KEY=$ANON_KEY|" "$env_file"
    sed -i "s|SERVICE_ROLE_KEY=.*|SERVICE_ROLE_KEY=$SERVICE_ROLE_KEY|" "$env_file"
    
    # Studio login
    sed -i "s|DASHBOARD_USERNAME=.*|DASHBOARD_USERNAME=$DASHBOARD_USERNAME|" "$env_file"
    sed -i "s|DASHBOARD_PASSWORD=.*|DASHBOARD_PASSWORD=$DASHBOARD_PASSWORD|" "$env_file"

    log "SUCCESS" "Segredos atualizados com sucesso."
    echo "--------------------------------------------------"
    echo -e "${YELLOW}GUARDE ESTAS CREDENCIAIS EM LOCAL SEGURO:${NC}"
    echo "Postgres Password: $POSTGRES_PASSWORD"
    echo "JWT Secret: $JWT_SECRET"
    echo "Studio User: $DASHBOARD_USERNAME"
    echo "Studio Pass: $DASHBOARD_PASSWORD"
    echo "--------------------------------------------------"
}
