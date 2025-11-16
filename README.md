# Teste Técnico – Desenvolvedor Ruby on Rails (Pleno)

![output](https://github.com/user-attachments/assets/22f5c00d-ccd5-448f-a257-95cee5228127)


## Objetivo
O candidato deverá desenvolver uma aplicação **Ruby on Rails** para **processar arquivos `.eml` (e-mails)** e extrair informações estruturadas, salvando os resultados em banco de dados.  
O projeto deve contemplar **arquitetura limpa, background jobs, logs persistentes e interface web**.

---

## Descrição do desafio

Você deve criar um projeto no **GitHub** utilizando **Ruby on Rails** que atenda aos seguintes requisitos:

### 1. Estrutura de classes
O sistema deve conter pelo menos **4 classes principais**:
- **Classe de processamento**: responsável por receber o arquivo `.eml` e decidir qual parser deve lidar com o e-mail (baseado no remetente).  
- **Classe base de parser**: define a estrutura comum para os parsers.
- **Dois parsers específicos**: cada um capaz de extrair informações de diferentes formatos de e-mail (o candidato terá acesso aos arquivos de exemplo).

### OBS: as classes de processamento foram colocadas dentro do service, e fo criada mais 3 classes para cadastro e processamento de emails, logs e customes

```
src/
├── app/
│   ├── assets/            # imagens, css/js compilados
│   ├── channels/          # ActionCable (websockets)
│   ├── controllers/       # controllers HTTP (API / views)
│   │   ├── application_controller.rb
│   │   ├── customers_controller.rb
│   │   ├── email_logs_controller.rb
│   │   ├── logs_controller.rb
│   │   └── uploads_controller.rb
│   ├── helpers/           # view helpers
│   ├── javascript/        # assets JS / pack (webpack/webpacker/esbuild)
│   ├── jobs/              # ActiveJob / jobs (process_email_job.rb, process_upload_job.rb)
│   │   ├── application_job.rb ✅
│   │   ├── process_email_job.rb ✅
│   │   └── process_upload_job.rb ✅
│   ├── mailers/           # mailers
│   ├── models/            # ActiveRecord models
│   │   ├── application_record.rb
│   │   ├── concerns/
│   │   ├── customer.rb ✅
│   │   ├── email_log.rb ✅
│   │   └── upload.rb ✅
│   ├── services/          # lógica de domínio / serviços
│   │   ├── email_processor.rb ✅
│   │   └── parsers/
│   │       ├── fornecedor_a_parser.rb ✅
│   │       ├── parceiro_b_parser.rb ✅
│   │       └── parser_base.rb ✅
│   └── views/             # views e templates
├── bin/
├── config/                # routes, environments, initializers
├── config.ru
├── db/                    # migrate, schema, seeds
├── Dockerfile
├── docker-compose.yml
├── Gemfile
├── Gemfile.lock
├── lib/
├── log/
├── public/
├── procfile
├── Rakefile
├── README.md              # (este arquivo sugerido)
├── spec/ or test/         # testes (RSpec ou Minitest)
├── storage/
├── tmp/
└── vendor/

```
> **Importante:** a arquitetura deve permitir que seja **fácil adicionar novos parsers** no futuro, apenas criando uma nova classe, sem necessidade de modificar outras partes do sistema.

### 2. Extração de informações
Os parsers devem ser capazes de extrair do corpo do e-mail:
- Nome do cliente  
- E-mail do cliente  
- Telefone do cliente  
- Código do produto de interesse  
- Assunto do e-mail  

Caso não seja possível extrair **nenhuma informação de contato do cliente (e-mail ou telefone)**, o processamento deve ser considerado **falho**.

---

## Exemplos de e-mails fornecidos
Estamos fornecendo **6 arquivos `.eml` de exemplo**, provenientes de **2 remetentes diferentes** (Fornecedor A e Parceiro B).  
- Para cada remetente, existem **2 e-mails completos** (com todas as informações) e **1 e-mail com informações faltantes** (para simular falha).  
- Esses arquivos devem ser utilizados para validar o funcionamento do seu parser.  
- O candidato também pode se sentir **livre para criar exemplos próprios** e demonstrar maior robustez no processamento.  

> Sugestão: utilize uma pasta `spec/emails/` para organizar os exemplos.  

---

## Regras de negócio
- Com os dados extraídos, deve ser criado um registro na tabela **customers**.  
- Todos os processamentos (sucessos e falhas) devem ser **registrados em logs persistentes**, incluindo:
  - Arquivo processado  
  - Informações extraídas  
  - Erros (se houver)  
- O arquivo `.eml` deve ser armazenado para permitir reprocessamento.  
- Deve existir uma **limpeza periódica dos logs** (estratégia a critério do candidato).  

---

## Interface
O projeto deve ter uma interface web simples em Rails (HTML + Bootstrap), contendo:
1. **Área para upload de arquivos `.eml`** (ao enviar, deve disparar o processamento em background).  
2. **Tela com a listagem de customers criados**.  
3. **Tela com os resultados dos parsers (logs)** mostrando sucessos e falhas.  


---

## Instruções técnicas
- O processamento dos e-mails deve rodar em **background com Sidekiq + Redis**.  
- Tratar erros de forma adequada.  
- Utilizar **Docker e Docker Compose** para subir o projeto.  
- Criar um **README.md** com instruções de instalação, execução e uso do sistema.  
- Implementar **testes unitários com RSpec**.  

---

## Entregáveis
- Código hospedado em repositório público no GitHub.  
- `README.md` com:
  - Passos para rodar o projeto (via Docker).  
  - Como subir o ambiente (Redis, Sidekiq, Rails).  
  - Como enviar um e-mail `.eml` para processamento.  
  - Como visualizar os resultados (customers + logs).
- Video explicativo
  - Demonstrar o uso do sistema
  - Explicar principais pontos do código e decisõe técnicas.

---

## Diferenciais
- Organização do código (design patterns, boas práticas Rails).  
- Clareza e objetividade nos testes.  
- Documentação técnica bem estruturada.  
- Boas práticas de logs e monitoramento.  
- **Configuração de CI (Continuous Integration)** no repositório para rodar testes automaticamente.  

---

## O que será avaliado?
- **Testes automatizados**  
  - Iremos executar os testes localmente, tenha certeza que eles estão passando antes de entregar o projeto.  
  - Se o projeto não tiver testes ou estiverem em branco ou falhando, **não avaliaremos os demais requisitos**.
- **Aplicação correta das regras de negócio** 
- **Simplicidade, clareza e estilo do código**  
- **Arquitetura do código**  
- **Facilidade de adicionar novos parsers**  
- **UI e UX do aplicativo de exemplo**  
  - Iremos executar o app localmente e verificar se ele funciona como deveria e se é intuitivo.  

---

## ⏱️ Prazo
- **5 dias corridos** a partir do recebimento do desafio.  
