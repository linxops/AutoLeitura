-- ============================================================================
-- AutoLeitura - Schema do banco de dados
-- Padrões: comandos SQL em CAIXA ALTA | banco com prefixo db_ | tabelas tb_
-- Charset: utf8mb4 (suporte a acentos pt-BR) | Engine: InnoDB (FKs)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS db_autoleitura
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE db_autoleitura;

-- ----------------------------------------------------------------------------
-- tb_usuarios: usuários do sistema (comum e admin). Login por código + senha.
--   senha: hash bcrypt (password_hash/PASSWORD_DEFAULT no PHP)
--   role:  papel do usuário ('usuario' | 'admin')
--   UNIQUE em celular e email impedem usuários duplicados.
--   local NÃO é único: mais de um morador pode compartilhar a mesma casa.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_usuarios (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    local CHAR(1) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    celular VARCHAR(11) NOT NULL,
    email VARCHAR(100) NULL,
    senha VARCHAR(255) NOT NULL,
    role ENUM('usuario', 'admin') NOT NULL DEFAULT 'usuario',
    UNIQUE KEY uq_usuarios_celular (celular),
    UNIQUE KEY uq_usuarios_email (email)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- tb_leituras: leitura mensal por usuário.
--   UNIQUE (codigo, mes): no máximo 1 leitura por usuário/mês (o cálculo de
--   consumo depende de exatamente uma leitura atual e uma anterior).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_leituras (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    mes VARCHAR(12) NOT NULL,
    leitura INTEGER NOT NULL,
    data DATE NOT NULL,
    codigo INT NOT NULL,
    UNIQUE KEY uq_leituras_codigo_mes (codigo, mes),
    CONSTRAINT fk_leituras_usuario
        FOREIGN KEY (codigo) REFERENCES tb_usuarios (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- tb_valor: histórico do valor do metro cúbico (append-only).
--   O valor vigente é o registro mais recente (ORDER BY id DESC LIMIT 1).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_valor (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    valor NUMERIC(6,2) NOT NULL,
    data DATE NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- tb_contas: conta mensal por usuário.
--   UNIQUE (codigouser, mesreferencia): impede contas duplicadas por usuário/mês
--   (o endpoint de cálculo insere uma linha a cada execução).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tb_contas (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    mesreferencia VARCHAR(13) NOT NULL,
    dataemissao DATE NOT NULL,
    datavencimento DATE NOT NULL,
    valorconta NUMERIC(6,2) NOT NULL,
    valormetrocubico NUMERIC(4,2) NOT NULL,
    leituraatual INTEGER NOT NULL,
    leituraanterior INTEGER NOT NULL,
    mensagem VARCHAR(250) NULL,
    codigouser INT NOT NULL,
    UNIQUE KEY uq_contas_codigouser_mes (codigouser, mesreferencia),
    CONSTRAINT fk_contas_usuario
        FOREIGN KEY (codigouser) REFERENCES tb_usuarios (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ============================================================================
-- SEED - DADOS DE TESTE (simulados)
-- Senhas iniciais (hash bcrypt, PASSWORD_DEFAULT):
--   Administrador: admin@2026DB
--   demais usuários: <primeiro_nome>@2026 (ex.: joao@2026)
-- Troque as senhas pelo fluxo da API quando estiver em produção.
-- ============================================================================

INSERT INTO tb_usuarios (local, nome, celular, email, senha, role) VALUES
    ('A', 'Administrador', '11999990000', 'admin@autoleitura.local',
     '$2y$12$CEoEuEkSKv/0IQpaWATWrutLz/NbrBc6ZA6t2DWOwMYmtOExMKZj6', 'admin'),
    ('B', 'João Carlos',    '11988881111', 'joao.carlos@exemplo.com',
     '$2y$12$mjG.ZKfMEw0nMBo0JT48nu5eYs5q/OtJkAbkcF8PhZPhHQA9W0Mry', 'usuario'),
    ('B', 'Maria Silva',    '11977772222', 'maria.silva@exemplo.com',
     '$2y$12$/FygykLUedfrlFrRz2ZySesk7ffmGGhSAtE0UYVwuAOio8aZOVdbm', 'usuario'),
    ('C', 'Carlos Pereira', '11966663333', 'carlos.pereira@exemplo.com',
     '$2y$12$dKAQoLfQZe1mUZkuBOQFuOI0x5TCMZDXATA5t2dsn9XyQ.mFLHefq', 'usuario'),
    ('D', 'Ana Souza',      '11955554444', 'ana.souza@exemplo.com',
     '$2y$12$DKMvmcu67gZMnZm.sSNfLuZF2m6LVx52ygp5z1BpsWBt5zfvIfIry', 'usuario'),
    ('E', 'Pedro Lima',     '11944445555', 'pedro.lima@exemplo.com',
     '$2y$12$xDMvwA4nM288H0secSh0aeZhqOGc9zIcoi6/mObgUXaojxi6OfIn.', 'usuario');

INSERT INTO tb_valor (valor, data) VALUES (1.15, '2026-08-17');

-- Leitura do mês anterior (Julho) e mês atual (Agosto) por usuário (id 1..6).
INSERT INTO tb_leituras (mes, leitura, data, codigo) VALUES
    ('Julho',  50,  '2026-07-15', 1),
    ('Agosto', 62,  '2026-08-15', 1),
    ('Julho',  100, '2026-07-15', 2),
    ('Agosto', 115, '2026-08-15', 2),
    ('Julho',  80,  '2026-07-15', 3),
    ('Agosto', 95,  '2026-08-15', 3),
    ('Julho',  120, '2026-07-15', 4),
    ('Agosto', 138, '2026-08-15', 4),
    ('Julho',  60,  '2026-07-15', 5),
    ('Agosto', 72,  '2026-08-15', 5),
    ('Julho',  200, '2026-07-15', 6),
    ('Agosto', 230, '2026-08-15', 6);

-- Contas de Agosto por usuário (valorconta = consumo * valormetrocubico 1.15).
INSERT INTO tb_contas
    (mesreferencia, dataemissao, datavencimento, valorconta, valormetrocubico,
     leituraatual, leituraanterior, mensagem, codigouser) VALUES
    ('Agosto', '2026-08-17', '2026-08-27', 13.80, 1.15, 62, 50,
     'Seu consumo foi de 12 metros cubicos', 1),
    ('Agosto', '2026-08-17', '2026-08-27', 17.25, 1.15, 115, 100,
     'Seu consumo foi de 15 metros cubicos', 2),
    ('Agosto', '2026-08-17', '2026-08-27', 17.25, 1.15, 95, 80,
     'Seu consumo foi de 15 metros cubicos', 3),
    ('Agosto', '2026-08-17', '2026-08-27', 20.70, 1.15, 138, 120,
     'Seu consumo foi de 18 metros cubicos', 4),
    ('Agosto', '2026-08-17', '2026-08-27', 13.80, 1.15, 72, 60,
     'Seu consumo foi de 12 metros cubicos', 5),
    ('Agosto', '2026-08-17', '2026-08-27', 34.50, 1.15, 230, 200,
     'Seu consumo foi de 30 metros cubicos', 6);