# Guia de Configuração Supabase + n8n

Este guia explica como conectar sua instância Supabase Self-Hosted ao n8n.

## 1. Conexão via Postgres Node

### ✅ n8n na mesma VPS que o Supabase (ÚNICA SOLUÇÃO QUE FUNCIONA)

Se ambos estão na mesma máquina, você DEVE conectá-los via **rede Docker**:

#### Passo 1: Conectar n8n à rede do Supabase

```bash
# Execute na sua VPS (ajuste os nomes se necessário):
docker network connect supabase_default <nome-do-container-n8n>
```

**Como descobrir o nome do seu container n8n:**
```bash
docker ps | grep n8n
# Procure o container principal (geralmente "n8n-main", "n8n", ou "n8n_n8n-main")
```

**Como descobrir o nome da rede do Supabase:**
```bash
cd /caminho/para/supabase-stack/supabase-instance
docker compose ps | grep db
# A rede geralmente é "supabase_default" ou "supabase-instance_default"
```

**Exemplo real:**
```bash
# Se seu container n8n se chama "n8n-main":
docker network connect supabase_default n8n-main
```

#### Passo 2: Configurar credencial no n8n

No n8n, crie uma credencial **PostgreSQL** com:

| Campo | Valor |
|-------|-------|
| **Host** | `supabase-db` |
| **Port** | `5432` |
| **Database** | `postgres` |
| **User** | `postgres` |
| **Password** | Veja abaixo ⬇️ |
| **SSL** | `Disable` |

**Como obter a senha:**
```bash
cd /caminho/para/supabase-stack/supabase-instance
cat .env | grep "^POSTGRES_PASSWORD="
```

Copie o valor completo que aparece depois de `POSTGRES_PASSWORD=` e cole no campo **Password** do n8n.

---

### ❌ n8n em outra VPS (NÃO na mesma máquina)

Se o n8n está em outra máquina, **NÃO use Postgres Node**. Use a **API do Supabase** (seção 2 abaixo) que é mais segura e funciona remotamente.

> [!WARNING]
> **Por que localhost/IP público não funciona?**
> 
> O Supabase usa **Supavisor** (connection pooler) que intercepta a porta 5432. Conexões externas ao container requerem autenticação multi-tenant que não existe no self-hosted. A única forma confiável é via rede Docker interna.

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
