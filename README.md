# Supabase Stack – Self-Hosted com Docker 🚀

Este repositório contém uma **stack completa para rodar Supabase self-hosted em uma VPS**, utilizando Docker e Docker Compose, com foco em **ambiente real de produção**.

A stack foi pensada para desenvolvedores, builders e empresas que querem:
- Controle total da infraestrutura
- Evitar custos de soluções gerenciadas
- Rodar Supabase em VPS (Hetzner, Hostinger, etc.)
- Padronizar ambientes de deploy

---

## 🧠 O que essa stack faz

Esta stack automatiza:

- Deploy completo do Supabase (self-hosted)
- Configuração via Docker Compose
- Geração e organização de secrets
- Estrutura pronta para evolução (proxy, SSL, etc.)

Tudo isso de forma **auditável e transparente**.

> ⚠️ Importante: este repositório **não é um fork oficial do Supabase**, e sim uma automação prática para self-hosting.

---

## 🏗️ Arquitetura (visão geral)

- Docker + Docker Compose
- Serviços do Supabase rodando em containers
- Estrutura organizada para facilitar manutenção e upgrades
- Scripts de instalação e remoção

A stack fica concentrada em:

```

execution/  
└─ supabase/  
├ install.sh  
├ uninstall.sh  
├ SUPABASE_SETUP.md  
├ scripts/  
└ utils/

````

---

## ✅ Pré-requisitos

Antes de rodar a stack, certifique-se de ter:

- VPS Linux (Ubuntu 20.04+ recomendado)
- Acesso root ou usuário com `sudo`
- Pelo menos:
  - **2 vCPU**
  - **4 GB de RAM** (mínimo recomendado)
- Portas liberadas no firewall (ex: 80, 443, 5432 – conforme uso)

> 💡 Para produção, recomenda-se uso de:
> - Firewall ativo (UFW / firewall da VPS)
> - Proxy reverso (Nginx / Traefik)
> - SSL (Cloudflare, Let’s Encrypt, etc.)

---

## ⚙️ Formas de instalação

### 🔹 Opção 1 – Instalação manual (modo técnico)

Você pode clonar este repositório e executar os scripts manualmente, entendendo cada etapa do processo:

```bash
git clone https://github.com/Growlinkoficial/supabase-stack.git
cd supabase-stack/execution/supabase
bash install.sh
````

👉 Essa abordagem é indicada se você:

- Quer estudar a stack
    
- Deseja customizar o processo
    
- Já tem experiência com Docker e VPS

---

### 🔹 Opção 2 – Instalação automatizada (recomendada)

Para quem quer **subir tudo rápido, com menos risco de erro**, foi criado um **script automatizado one-click**, que:

- Atualiza o sistema
    
- Instala Docker e Docker Compose
    
- Configura permissões corretamente
    
- Executa a stack no padrão usado em produção


👉 Para receber o comando de instalação automatizada:  
🔗 **[link do formulário aqui]**

Você recebe o comando por e-mail, pronto para rodar na VPS.

---

## 📄 Documentação adicional

- [Guia de Setup e Integração n8n](execution/supabase/SUPABASE_SETUP.md)
    

---

## 🧩 Quando usar Supabase self-hosted?

Essa abordagem faz sentido se você:

✔ Precisa de controle total  
✔ Quer reduzir custos em escala  
✔ Já trabalha com VPS e Docker  
✔ Quer liberdade para customizações

Se você busca **simplicidade máxima**, talvez o Supabase Cloud seja mais adequado.

---

## ⚠️ Avisos importantes

- Esta stack **não substitui boas práticas de segurança**
    
- Sempre revise variáveis de ambiente
    
- Faça backups
    
- Teste antes de usar em produção

## Documentação
- [Guia de Setup e Integração n8n](execution/supabase/SUPABASE_SETUP.md)