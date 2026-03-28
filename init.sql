-- Habilita a extensão pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- Tabela 1: Os Nós (Agentes/Deputados)
CREATE TABLE deputies (
  id INT PRIMARY KEY,
  -- ID real da API da Câmara
  name VARCHAR(255) NOT NULL,
  party VARCHAR(50) NOT NULL,
  state VARCHAR(2) NOT NULL,
  -- Atributos do Agente (Multi-Agent System)
  role VARCHAR(50) DEFAULT 'Follower',
  -- Leader, Broker, Follower, Ideologue
  alpha DECIMAL(4, 3) DEFAULT 0.5,
  -- Nível de persuasão/flexibilidade (0.0 a 1.0)
  political_capital INT DEFAULT 1,
  -- Quantas mensagens pode enviar por rodada
  -- O 'Cérebro' do Agente
  ideology_embedding vector(1536) -- Vetor gerado a partir de discursos passados
);

-- Tabela 2: As Arestas (Topologia do Grafo)
CREATE TABLE historical_alignments (
  source_deputy_id INT REFERENCES deputies(id),
  target_deputy_id INT REFERENCES deputies(id),
  weight DECIMAL(4, 3) NOT NULL,
  -- W_ij: Similaridade de Jaccard (0.0 a 1.0)
  PRIMARY KEY (source_deputy_id, target_deputy_id)
);

-- Tabela 3: A Camada de Interação (Log do LLM)
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  simulation_round INT NOT NULL,
  source_deputy_id INT REFERENCES deputies(id),
  target_deputy_id INT REFERENCES deputies(id),
  content TEXT NOT NULL,
  -- O argumento persuasivo gerado pelo LLM
  message_embedding vector(1536),
  -- E(Message)
  semantic_similarity DECIMAL(4, 3),
  -- S_ij calculado dinamicamente na rodada
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela 4: Estado da Simulação (Para rastrear a convergência)
CREATE TABLE simulation_states (
  simulation_round INT NOT NULL,
  deputy_id INT REFERENCES deputies(id),
  probability_yes DECIMAL(4, 3) NOT NULL,
  -- P_i(t)
  PRIMARY KEY (simulation_round, deputy_id)
);