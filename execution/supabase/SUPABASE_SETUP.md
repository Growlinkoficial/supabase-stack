# Guia de Configuração Supabase + n8n

Este guia explica como conectar sua instância Supabase Self-Hosted ao n8n.

## 1. Conexão via Postgres Node
Use o nó do Postgres no n8n para manipulação direta de dados.

- **Host**: IP da sua VPS (ou `host.docker.internal` se o n8n estiver na mesma rede Docker do Host).
- **Port**: `5432` (Padrão) ou a porta dinâmica alocada pelo instalador (verifique o output ao final da instalação).
- **Database**: `postgres`
- **User**: `postgres`
- **Password**: A senha gerada durante o `install.sh`.
- **SSL**: Desativado por padrão no self-hosted.

## 2. Conexão via Supabase Node (API) ⭐ Recomendado

Use o nó nativo do Supabase no n8n para tirar proveito da API REST.

### Passo 1: Obter as Credenciais

Todas as chaves necessárias estão no arquivo `.env` gerado durante a instalação:

```bash
# Na sua VPS, navegue até a pasta da instância
cd /caminho/para/supabase-stack/supabase-instance

# Visualize as chaves
cat .env | grep -E "(SERVICE_ROLE_KEY|ANON_KEY)"
```

Você verá algo como:
```
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Passo 2: Configurar Credencial no n8n

No n8n, ao criar uma credencial do tipo **Supabase API**, preencha:

| Campo | Valor | Onde Encontrar |
|-------|-------|----------------|
| **Host** | `http://<IP-DA-VPS>:8001` | Use o IP da sua VPS + porta API (padrão 8001, veja output do `install.sh`) |
| **Service Role Secret** | `SERVICE_ROLE_KEY` do `.env` | Cole o valor completo da chave `SERVICE_ROLE_KEY` |

> [!IMPORTANT]
> **Service Role Secret** = `SERVICE_ROLE_KEY` (não confunda com `ANON_KEY`)
> 
> - **`SERVICE_ROLE_KEY`**: Acesso administrativo total, ignora RLS (Row Level Security). Use para operações de backend/automação.
> - **`ANON_KEY`**: Acesso público limitado, respeita RLS. Use apenas em aplicações frontend.

### Passo 3: Testar Conexão

1. Salve a credencial no n8n
2. Adicione um nó Supabase ao workflow
3. Selecione a credencial criada
4. Teste uma operação simples (ex: listar tabelas)

Se houver erro de conexão:
- Verifique se a porta 8001 está liberada no firewall da VPS: `ufw allow 8001/tcp`
- Confirme que o container Kong está rodando: `docker compose ps` (deve mostrar `supabase-kong` como `Up`)

## 3. Webhooks
Os Webhooks do Supabase (Edge Functions) podem disparar Webhooks no n8n.
- No Supabase, configure o destino do Webhook para a URL de produção do seu n8n.

## Dicas de Coexistência (VPS)
- Se você tiver múltiplos apps pedindo a porta `5432`, edite o arquivo `supabase-instance/.env` e altere `POSTGRES_PORT` para `5434`, por exemplo.
- Sempre verifique o status com `docker compose ps` dentro da pasta `supabase-instance`.
