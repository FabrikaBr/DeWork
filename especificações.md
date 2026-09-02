

Especificação Técnica — DeWork4Us

Versão: 0.1 (rascunho para estudo)
Autor: FabrikaBR
Data: 2025
Status: Em elaboração

---

1. Introdução

O DeWork4Us é uma plataforma descentralizada para conectar profissionais autônomos a contratantes, com foco em microprojetos e tarefas do mundo real. Utiliza blockchain (Polygon) para garantir transações seguras e transparentes, contratos inteligentes para automatizar acordos e um sistema de curadoria com garantias bilaterais para reduzir riscos.

Este documento apresenta a especificação técnica do produto, cobrindo:

· Arquitetura geral;
· Contratos inteligentes (token, tarefas, curadoria, reputação);
· Modelo de dados off-chain;
· Fluxo de telas do aplicativo;
· Segurança e privacidade.

O objetivo é servir como base para desenvolvimento, auditoria e futuras iterações.

---

2. Visão Geral do Produto

2.1 Problema

Pessoas e empresas precisam realizar tarefas remotas ou em locais onde não possuem rede de confiança. Plataformas tradicionais dependem de avaliações superficiais, intermediários custosos e oferecem pouca garantia de execução ou pagamento.

2.2 Solução

O DeWork4Us cria um protocolo de confiança descentralizada baseado em:

· Curadores verificados que depositam garantia (calção) e supervisionam a execução;
· Contratos inteligentes que bloqueiam valores e liberam pagamentos mediante prestação de contas;
· Anonimato inicial no painel público, com revelação de identidade apenas após manifestação de interesse;
· Token utilitário ($FBK) para pagamentos e garantias;
· Integração com TeamScope (gestão de projetos) e BioGermina (verificação georreferenciada de entregas).

2.3 Público-alvo

· Contratantes que precisam de serviços remotos ou locais sem conhecer prestadores;
· Profissionais autônomos que buscam trabalho sem capital inicial;
· Investidores/curadores que desejam financiar microprojetos e receber taxas;
· Pessoas com propriedades em outras cidades/países;
· Pequenas empresas e produtores que precisam de serviços pontuais.

---

3. Arquitetura do Sistema

A plataforma é dividida em quatro camadas:

1. Interface do Usuário: aplicativo web/mobile com login tradicional ou Web3.
2. Serviços Off-chain: backend com autenticação, KYC, criptografia LGPD, integração TeamScope/BioGermina.
3. Blockchain: contratos inteligentes na Polygon.
4. Armazenamento: banco de dados relacional e IPFS/Arweave para mídias.

```
┌─────────────────────────────────────────────┐
│              USUÁRIOS                       │
└───────────────────────┬─────────────────────┘
                        ▼
┌─────────────────────────────────────────────┐
│         CAMADA DE INTERFACE                 │
│  Web App (React/Next.js)  Mobile (React Native) │
│  Login: Google, E-mail, Web3                 │
│  Painel de tarefas anônimas                  │
│  Formulários TeamScope                       │
│  Integração BioGermina                       │
└───────────────────────┬─────────────────────┘
                        ▼
┌─────────────────────────────────────────────┐
│       SERVIÇOS OFF-CHAIN (Backend)          │
│  API REST/GraphQL (Node.js/Python)          │
│  Autenticação (JWT, OAuth, SIWE)            │
│  KYC e entrevista                           │
│  Criptografia de dados pessoais             │
│  Armazenamento de mídia (IPFS/Arweave)      │
│  Integração TeamScope/BioGermina            │
└───────────────────────┬─────────────────────┘
                        ▼
┌─────────────────────────────────────────────┐
│         BLOCKCHAIN (Polygon)                │
│  Contrato FBK (token ERC20)                 │
│  Contrato DeWork (tarefas)                  │
│  Contrato de Curadoria (calção/frações)     │
│  Contrato de Reputação (score)              │
└───────────────────────┬─────────────────────┘
                        ▼
┌─────────────────────────────────────────────┐
│         ARMAZENAMENTO                       │
│  PostgreSQL (dados relacionais)             │
│  IPFS/Arweave (mídias, recibos)             │
│  Blockchain (registro imutável)             │
└─────────────────────────────────────────────┘
```

---

4. Especificação dos Contratos Inteligentes

4.1 Token FBK (FBK.sol)

Padrão: ERC20 (OpenZeppelin)

Funções principais:

· mint(address to, uint256 amount) — apenas controladoria (multisig).
· burn(uint256 amount) — queima de tokens pelo próprio usuário.
· transfer, approve, transferFrom, allowance, balanceOf, totalSupply.

Controle:

· 4 cold wallets (controladoria) com poder de mint/burn.
· Inicialmente sem governança on-chain; futura migração para DAO.

Observações:

· O token será vendido via Pix no site; backend emite tokens para carteira interna do usuário.
· Para usuários avançados, é possível sacar para carteira Web3.

---

4.2 Contrato DeWork (DeWork.sol)

Objetivo: gerenciar tarefas, depósitos, liberações e execução.

Struct Tarefa:

```solidity
struct Tarefa {
    uint256 id;
    string objetivoHash;        // Hash da descrição completa (off-chain)
    address contratante;        // Owner
    address fornecedor;         // Executor (pode ser address(0))
    uint256 valorTotal;
    uint256 valorDepositado;
    uint256 valorLiberado;
    uint256 prazo;              // Timestamp de expiração
    uint256 createdAt;
    EstadoTarefa estado;        // 0=Criada, 1=Financiada, 2=EmExecucao, 3=Concluida, 4=Disputa, 5=Expirada
    address[] curadores;        // até 4
    mapping(address => uint256) fracaoCurador;    // fração percentual de cada curador
    mapping(address => uint256) depositoCurador;  // calção depositado por cada curador
    mapping(address => bool) aprovacoes;          // aprovação individual
    uint256 totalAprovacoesNecessarias;
}
```

Funções principais:

Função Descrição Acesso
criarTarefa(string objetivoHash, uint256 valorTotal, uint256 prazo) Cria nova tarefa em estado Criada Qualquer usuário verificado
designarFornecedor(uint256 id, address fornecedor) Define o executor da tarefa Contratante
adicionarCurador(uint256 id, address curador, uint256 fracao) Adiciona curador com fração Contratante ou Fornecedor
depositar(uint256 id) Contratante deposita tokens (parcial ou total) Contratante (pagável)
depositarCalcao(uint256 id, address curador) Curador deposita calção conforme fração Curador
liberarPagamento(uint256 id, uint256 valorParcial) Libera parte do valor ao fornecedor após aprovação de marco Contratante ou Curador (se autorizado)
aprovarEntrega(uint256 id) Curador aprova entrega Curador
concluirTarefa(uint256 id) Distribui valores finais e atualiza reputação Automático quando aprovações suficientes
abrirDisputa(uint256 id) Qualquer parte abre disputa Participante
resolverDisputa(uint256 id, uint256 decisao) Supervisor humano decide (1=concluir, 2=reembolsar, 3=parcial) Supervisor
cancelarTarefa(uint256 id) Devolve valores e calções se tarefa expirar Contratante ou Supervisor

Distribuição na conclusão:

· Fornecedor recebe valorTotal - taxasCuradores - taxaProtocolo.
· Curadores recebem taxa fixa (ex.: 5% do valor total, dividido proporcionalmente à fração).
· Protocolo recebe 2% do valor total.
· Calções devolvidos integralmente aos curadores.

Eventos:

· TarefaCriada(uint256 id, address contratante, uint256 valorTotal)
· CuradorAdicionado(uint256 id, address curador, uint256 fracao)
· DepositoRealizado(uint256 id, address de, uint256 valor)
· PagamentoLiberado(uint256 id, address para, uint256 valor)
· EntregaAprovada(uint256 id, address curador)
· TarefaConcluida(uint256 id, address fornecedor, uint256 valorPago)
· DisputaAberta(uint256 id, address abertaPor)
· DisputaResolvida(uint256 id, uint256 decisao)
· TarefaCancelada(uint256 id)

---

4.3 Contrato de Curadoria (pode ser integrado ao DeWork)

Para simplificar, a curadoria pode ser incorporada ao contrato DeWork. Entretanto, se a complexidade crescer, um contrato separado pode gerenciar:

· Registro de curadores verificados.
· Depósitos de calção.
· Frações e distribuição de taxas.
· Histórico de atuação.

Funções adicionais:

· registrarCurador(address curador, uint256 limiteGarantia)
· adicionarCalcao(uint256 tarefaId, address curador, uint256 valor)
· liberarCalcao(uint256 tarefaId, address curador)

---

4.4 Contrato de Reputação (Reputacao.sol)

Objetivo: armazenar score de cada participante on-chain.

Struct Reputacao:

```solidity
struct Reputacao {
    uint256 score;               // 0 a 1000
    uint256 contratosConcluidos;
    uint256 contratosAtrasados;
    uint256 somaAvaliacoes;
    uint256 numAvaliacoes;
    uint256 kycLevel;            // 0, 1, 2
}
```

Funções:

· atualizarReputacao(address participante, uint256 nota, bool concluidoNoPrazo)
· obterScore(address participante) view returns (uint256)

A fórmula inicial de score:

score = \frac{contratosConcluidos \times mediaAvaliacoes}{contratosConcluidos + contratosAtrasados + 1}

---

5. Modelo de Dados Off-Chain

5.1 Banco de Dados (PostgreSQL)

Tabelas principais:

users

Campo Tipo Descrição
id UUID Identificador único
email varchar E-mail (criptografado)
nome_hash varchar Hash do nome (para anonimato)
kyc_level int Nível de verificação
wallet_address varchar Endereço da carteira Web3 (opcional)
internal_wallet_id UUID Referência à carteira interna
created_at timestamp Data de criação
updated_at timestamp Data de atualização

tasks

Campo Tipo Descrição
id UUID Identificador off-chain
contract_id bigint ID na blockchain
objective_encrypted text Descrição criptografada
objective_hash varchar Hash da descrição
region varchar Região (ex.: "Campinas - SP")
category varchar Categoria (jardinagem, transporte, etc.)
status enum created, funded, in_progress, completed, dispute, expired
created_by UUID FK para users.id
executor_id UUID FK para users.id (pode ser nulo)
total_value numeric Valor total em tokens
currency varchar 'FBK'
deadline timestamp Prazo
created_at timestamp Data de criação

curations

Campo Tipo Descrição
id UUID Identificador
task_id UUID FK para tasks.id
curator_id UUID FK para users.id
fraction_percent numeric Fração percentual (0-100)
deposit_amount numeric Valor do calção depositado
status enum pending, deposited, released, slashed
created_at timestamp Data de criação

transactions

Campo Tipo Descrição
id UUID Identificador
task_id UUID FK para tasks.id
from_user_id UUID FK para users.id
to_user_id UUID FK para users.id
amount numeric Valor transferido
type enum deposit, payment, curation_fee, protocol_fee, refund
tx_hash varchar Hash da transação na blockchain
created_at timestamp Data

media_evidences

Campo Tipo Descrição
id UUID Identificador
task_id UUID FK para tasks.id
media_type enum photo, video, document
ipfs_hash varchar Hash do arquivo no IPFS
metadata_json text Metadados georreferenciados (lat, long, timestamp, user_id)
uploaded_by UUID FK para users.id
created_at timestamp Data

kyc_requests

Campo Tipo Descrição
id UUID Identificador
user_id UUID FK para users.id
status enum pending, approved, rejected
documents_hash varchar Hash dos documentos armazenados
interview_notes text Anotações da entrevista
reviewed_by UUID FK para supervisor
created_at timestamp Data

5.2 Criptografia e LGPD

· Dados pessoais (nome, e-mail, documentos) são criptografados com chave simétrica gerenciada pelo backend.
· O hash dos dados criptografados é registrado na blockchain para integridade.
· O usuário pode solicitar a exclusão da chave para tornar seus dados inacessíveis (direito ao esquecimento).
· A blockchain guarda apenas hashes, nunca dados pessoais diretamente.

---

6. Fluxo de Telas do Aplicativo

6.1 Tela Inicial / Onboarding

· Logo DeWork4Us e FabrikaBR.
· Opções: "Entrar" e "Criar conta".
· Login: Google, E-mail, ou Carteira Web3.
· Breve explicação do que é a plataforma.

6.2 Painel Principal (Home)

· Barra superior: logo, busca, notificações, perfil.
· Filtros: categoria, região, faixa de valor, prazo.
· Lista de tarefas anônimas em cards:
  · Título genérico (ex.: "Serviço de roçada em terreno")
  · Região
  · Valor estimado
  · Prazo
  · Número de curadores já participantes (se houver)
· Botão "Manifestar interesse" em cada card.

6.3 Criação de Tarefa (Integração TeamScope)

· Formulário com etapas:
  1. Tipo de serviço (categoria)
  2. Descrição detalhada (objetivo)
  3. Localização (apenas região)
  4. Valor estimado e prazo
  5. Revisão da proposta padronizada
· O TeamScope ajuda a formatar e sugerir valor médio com base em tarefas similares.
· Confirmação de depósito inicial (se houver).

6.4 Detalhes da Tarefa (após interesse)

· Identidade das partes revelada somente após verificação.
· Informações completas do serviço.
· Curadores designados e suas frações.
· Status da tarefa (financiada, em execução, etc.).
· Botões para upload de evidências (foto, vídeo, recibo).
· Chat seguro entre as partes (off-chain).

6.5 Carteira Interna

· Saldo de tokens FBK.
· Histórico de transações.
· Comprar tokens (Pix, boleto, cartão).
· Sacar para carteira Web3 (se avançado).

6.6 Perfil do Usuário

· Nome (apelido/anônimo para o público)
· Nível KYC
· Score de reputação
· Tarefas concluídas como contratante, fornecedor, curador
· Configurações de privacidade (chave de descriptografia, exclusão)

6.7 Painel do Curador

· Tarefas disponíveis para curadoria.
· Saldo de calções depositados.
· Ganhos com taxas.
· Histórico de atuação.

6.8 Disputa

· Tela para abrir disputa com motivo.
· Evidências anexadas.
· Status da mediação.
· Decisão do supervisor registrada.

---

7. Segurança e Privacidade

· KYC e entrevista: todos os usuários passam por verificação antes de interagir com tarefas.
· Cold wallets: controladoria (4 carteiras) protege emissão de tokens e funções administrativas.
· Criptografia de dados: dados pessoais nunca vão para a blockchain; apenas hashes.
· Direito ao esquecimento: usuário pode descartar chave para tornar dados inacessíveis.
· Proteção contra ataques: contratos seguem padrões OpenZeppelin, com verificação de reentrância e controle de acesso.
· Supervisão humana: disputas são resolvidas por equipe treinada, não por código arbitrário.

---

8. Roadmap (próximas etapas)

1. MVP: tarefas simples, um curador, depósito e liberação.
2. Curadoria múltipla e fracionada.
3. Integração BioGermina para georreferenciamento.
4. Reputação on-chain com score.
5. Suporte a múltiplos tokens (USDC, DAI).
6. Governança comunitária (DAO) no futuro.

---

9. Referências

· OpenZeppelin Contracts: https://docs.openzeppelin.com/contracts
· Polygon Documentation: https://docs.polygon.technology/
· LGPD (Lei Geral de Proteção de Dados): https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm
· IPFS: https://ipfs.tech/

---