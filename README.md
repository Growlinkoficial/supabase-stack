# Supabase Self-Hosted Stack Automation

Esta automação provisiona uma instância completa do Supabase Self-Hosted usando Docker, projetada para ser resiliente e segura.

## Estrutura do Projeto

```
.
├── execution/
│   └── supabase/
│       ├── install.sh          # Script Principal de Instalação
│       ├── uninstall.sh        # Script de Remoção
│       ├── SUPABASE_SETUP.md   # Guia de Uso e Integração
│       ├── scripts/            # Bibliotecas
│       └── utils/              # Utilitários de Secrets
├── directives/                 # Protocolos Operacionais (Layer 1)
└── ...
```

## Como Usar

### Instalação Rápida
Execute o script de instalação localizado na camada de **Execução**.

```bash
cd execution/supabase
chmod +x install.sh
./install.sh
```

### Funcionalidades
- **Portas Dinâmicas**: Detecta e resolve conflitos de porta (8000/5432) automaticamente.
- **Segurança**: Gera segredos fortes (`JWT_SECRET`, etc.) automaticamente.
- **Resiliência**: Verifica pré-requisitos antes de executar.

## Documentação
- [Guia de Setup e Integração n8n](execution/supabase/SUPABASE_SETUP.md)
- [Diretiva de Deploy](directives/deploy_supabase.md)
