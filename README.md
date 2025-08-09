# Hamburgueria XTudo

## Descrição do Projeto

O **Hamburgueria XTudo** é um sistema de controle para hamburgueria desenvolvido em Progress OpenEdge. O sistema oferece uma solução completa para gerenciamento de clientes, produtos, pedidos e controle financeiro, permitindo o controle total das operações de uma hamburgueria.

## O que o Sistema Faz

O sistema oferece as seguintes funcionalidades principais:

### 📋 Módulos de Cadastro
- **Cadastro de Cidades**: Gerenciamento das cidades onde os clientes residem
- **Cadastro de Clientes**: Controle completo dos dados dos clientes
- **Cadastro de Produtos**: Gerenciamento do cardápio e preços
- **Cadastro de Pedidos e Itens**: Controle de pedidos com seus respectivos itens

### 💼 Funcionalidades Principais
- **Controle de Clientes**: Cadastro completo com endereço e cidade
- **Controle Financeiro**: Acompanhamento de valores de pedidos e totais
- **Navegação Intuitiva**: Botões de navegação entre registros (primeiro, anterior, próximo, último)
- **Operações CRUD**: Adicionar, modificar, eliminar e consultar registros
- **Validações de Integridade**: Impede exclusão de registros em uso
- **Exportação de Dados**: Geração de arquivos JSON e CSV

### 📊 Relatórios
- **Relatório de Clientes**: Lista completa dos clientes cadastrados
- **Relatório de Pedidos**: Detalhamento dos pedidos por cliente com itens, quantidades e valores

### 🔄 Integração
- **Exportação JSON**: Arquivo de pedidos formatado para integração com sistema da franqueadora

## Estrutura do Banco de Dados

O sistema utiliza o banco de dados **xtudo2.db** localizado em `C:\dados\` com as seguintes tabelas:

### Tabelas Principais
- **Cidades**: Controle de cidades (código, nome, UF)
- **Clientes**: Dados dos clientes com referência à cidade
- **Produtos**: Cardápio com códigos, nomes e valores
- **Pedidos**: Cabeçalho dos pedidos com data e cliente
- **Itens**: Itens detalhados de cada pedido

### Relacionamentos
- Cliente → Cidade (chave estrangeira)
- Pedido → Cliente (chave estrangeira)
- Item → Pedido (chave estrangeira)
- Item → Produto (chave estrangeira)

## Como Executar o Projeto

### Pré-requisitos
- Progress OpenEdge instalado
- IDE Eclipse com plugin Progress Developer Studio
- Banco de dados xtudo2.db configurado em `C:\dados\`

### Configuração do Ambiente

1. **Preparação do Banco de Dados**
   ```
   Localize o arquivo: C:\dados\xtudo2.db
   Certifique-se de que o banco está acessível
   ```

2. **Configuração no Eclipse**
   - Abra o Eclipse IDE
   - Configure o workspace do Progress OpenEdge
   - Importe o projeto da Hamburgueria XTudo
   - Configure a conexão com o banco de dados xtudo2.db

3. **Execução do Sistema**
   - Execute o programa principal do menu
   - O sistema iniciará com o menu principal de acesso
   - Navegue pelas opções de cadastro conforme necessário

### Estrutura de Navegação

O sistema inicia com um **Menu Principal** que oferece acesso a:
- Cadastro de Cidades
- Cadastro de Produtos  
- Cadastro de Clientes
- Cadastro de Pedidos e Itens
- Relatórios

### Funcionalidades dos Botões

Cada tela do sistema possui botões padronizados:

#### Navegação
- `<<` - Primeiro Registro
- `<` - Registro Anterior
- `>` - Próximo Registro
- `>>` - Último Registro

#### Operações
- `Adicionar` - Criar novo registro
- `Modificar` - Editar registro atual
- `Eliminar` - Excluir registro
- `Salvar` - Confirmar inclusão/alteração
- `Cancelar` - Cancelar operação
- `Exportar` - Gerar arquivos JSON/CSV
- `Sair` - Fechar tela

## Regras de Negócio

### Validações Implementadas
- **Integridade Referencial**: Não permite exclusão de registros em uso
- **Códigos Automáticos**: Geração automática via sequences
- **Validação de Cidades**: Cliente só pode ser salvo com cidade válida
- **Validação de Produtos**: Item só pode ser salvo com produto válido
- **Cascata**: Exclusão de pedido remove automaticamente seus itens

### Controles de Interface
- Botões de navegação e operação habilitados conforme o estado da tela
- Campos de código habilitados apenas na inclusão
- Validações em tempo real durante as operações

## Arquivos de Saída

O sistema gera:
- **Arquivo JSON**: Dados dos pedidos para integração com franqueadora
- **Arquivo CSV**: Dados tabulares para análise externa
- **Relatórios**: Clientes e pedidos formatados para impressão

## Tecnologias Utilizadas

- **Progress OpenEdge**: Plataforma de desenvolvimento
- **Eclipse IDE**: Ambiente de desenvolvimento
- **Progress Database**: Sistema de banco de dados

---

**Projeto desenvolvido como Trabalho Final do Treinamento Progress OpenEdge**
