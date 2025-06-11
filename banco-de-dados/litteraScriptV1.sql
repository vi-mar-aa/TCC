CREATE DATABASE Littera;
GO

USE Littera;
GO

-- Cargos dos Funcionários
CREATE TABLE CargoFuncionario (
    id_cargo INT PRIMARY KEY IDENTITY,
    nome_cargo VARCHAR(100) NOT NULL
);

-- Funcionários
CREATE TABLE Funcionario (
    id_funcionario INT PRIMARY KEY IDENTITY,
    id_cargo INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    senha VARCHAR(255) NOT NULL,
    status_conta VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cargo) REFERENCES CargoFuncionario(id_cargo)
);

-- Clientes
CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY IDENTITY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    senha VARCHAR(255) NOT NULL,
    status_conta VARCHAR(20) NOT NULL
);

-- Tipos de Mídia (Livro, Filme, etc.)
CREATE TABLE TipoMidia (
    id_tpmidia INT PRIMARY KEY IDENTITY,
    nome_tipo VARCHAR(50) NOT NULL
);

-- Mídias (ex: livros, filmes)
CREATE TABLE Midia (
    id_midia INT PRIMARY KEY IDENTITY,
    id_funcionario INT NOT NULL,
    id_tpmidia INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(100),
    editora VARCHAR(100),
    ano_publicacao INT,
    edicao VARCHAR(50),
    local_publicacao VARCHAR(100),
    numero_paginas INT,
    isbn VARCHAR(20),
    duracao VARCHAR(20),
    estudio VARCHAR(100),
    roteirista VARCHAR(100),
    disponibilidade VARCHAR(20) NOT NULL,
    -- Para uso futuro:
    -- imagem VARBINARY(MAX),
    -- trailer_link VARCHAR(255),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_tpmidia) REFERENCES TipoMidia(id_tpmidia)
);

-- Reservas de mídias
CREATE TABLE Reserva (
    id_reserva INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    id_midia INT NOT NULL,
    data_reserva DATE NOT NULL,
    data_limite DATE NOT NULL,
    status_reserva VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia)
);

-- Empréstimos
CREATE TABLE Emprestimo (
    id_emprestimo INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_midia INT NOT NULL,
    id_reserva INT,
    data_emprestimo DATE NOT NULL,
    data_devolucao DATE NOT NULL,
    limite_renovacoes INT DEFAULT 0,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia),
    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva)
);

-- Fórum
CREATE TABLE Forum (
    id_forum INT PRIMARY KEY IDENTITY,
    titulo VARCHAR(255) NOT NULL
);

-- Mensagens no fórum
CREATE TABLE Mensagem (
    id_mensagem INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    id_forum INT NOT NULL,
    conteudo TEXT NOT NULL,
    data_postagem DATETIME NOT NULL,
    visibilidade VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_forum) REFERENCES Forum(id_forum)
);

-- Denúncias
CREATE TABLE Denuncia (
    id_denuncia INT PRIMARY KEY IDENTITY,
    id_funcionario INT NOT NULL,
    id_mensagem INT NOT NULL,
    id_cliente INT NOT NULL,
    data_denuncia DATETIME NOT NULL,
    motivo VARCHAR(255),
    status VARCHAR(20) NOT NULL,
    acao_tomada VARCHAR(255),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_mensagem) REFERENCES Mensagem(id_mensagem),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

-- Lista de Desejos
CREATE TABLE ListaDeDesejos (
    id_cliente INT NOT NULL,
    id_midia INT NOT NULL,
    data_adicionada DATE NOT NULL,
    PRIMARY KEY (id_cliente, id_midia),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia)
);


-- =========================== FUNCIONÁRIOS ===========================
-- Retorna todas as informações de um funcionário (bibliotecário ou administrador) pelo ID
CREATE PROCEDURE sp_InfoFuncionario
    @id_funcionario INT
AS
BEGIN
    SELECT * FROM Funcionario WHERE id_funcionario = @id_funcionario;
END;

-- Retorna o ID do funcionário baseado no nome de usuário (email)
CREATE PROCEDURE sp_GetFuncionarioID
    @username VARCHAR(100)
AS
BEGIN
    SELECT id_funcionario FROM Funcionario WHERE email = @username;
END;

-- =========================== EMPRÉSTIMOS ===========================
-- Quantidade de empréstimos por mês (mês e ano)
CREATE PROCEDURE sp_QtdEmprestimosPorMes
    @mes INT,
    @ano INT
AS
BEGIN
    SELECT COUNT(*) AS qtd_emprestimos
    FROM Emprestimo
    WHERE MONTH(data_emprestimo) = @mes AND YEAR(data_emprestimo) = @ano;
END;

-- Quantidade de reservas por mês (mês e ano)
CREATE PROCEDURE sp_QtdReservasPorMes
    @mes INT,
    @ano INT
AS
BEGIN
    SELECT COUNT(*) AS qtd_reservas
    FROM Reserva
    WHERE MONTH(data_reserva) = @mes AND YEAR(data_reserva) = @ano;
END;

-- Quantidade total de empréstimos
CREATE PROCEDURE sp_QtdTotalEmprestimos
AS
BEGIN
    SELECT COUNT(*) AS total_emprestimos FROM Emprestimo;
END;

-- Quantidade de empréstimos atrasados (data_devolucao anterior a hoje)
CREATE PROCEDURE sp_QtdEmprestimosAtrasados
AS
BEGIN
    SELECT COUNT(*) AS emprestimos_atrasados
    FROM Emprestimo
    WHERE data_devolucao < CAST(GETDATE() AS DATE);
END;

-- Atualiza a devolução de um empréstimo
CREATE PROCEDURE sp_DevolverMidia
    @id_emprestimo INT,
    @data_devolucao DATE
AS
BEGIN
    UPDATE Emprestimo
    SET data_devolucao = @data_devolucao
    WHERE id_emprestimo = @id_emprestimo;
END;

-- =========================== EVENTOS ===========================
-- Seleciona as informações do evento mais próximo pelo ID
CREATE PROCEDURE sp_InfoEvento
    @id_evento INT
AS
BEGIN
    SELECT * FROM Evento WHERE id_evento = @id_evento;
END;

-- =========================== LIVROS ===========================
-- Retorna todas as informações de um livro
CREATE PROCEDURE sp_InfoLivro
    @id_midia INT
AS
BEGIN
    SELECT * FROM Midia WHERE id_midia = @id_midia;
END;

-- Retorna o ID do livro com mais indicações baseado em ranking
-- (requer que a tabela tenha coluna "qtd_indicacoes")
CREATE PROCEDURE sp_TopLivrosPorIndicacao
    @posicao INT
AS
BEGIN
    SELECT id_midia
    FROM (
        SELECT id_midia, RANK() OVER (ORDER BY qtd_indicacoes DESC) AS posicao
        FROM Midia
    ) AS ranked
    WHERE posicao = @posicao;
END;

-- =========================== PROCEDURES PARA ANDROID ===========================
-- Login
CREATE PROCEDURE sp_LoginCliente
    @email VARCHAR(100),
    @senha VARCHAR(255)
AS
BEGIN
    SELECT * FROM Cliente WHERE email = @email AND senha = @senha;
END;

-- Cadastro
CREATE PROCEDURE sp_CadastrarCliente
    @nome VARCHAR(100),
    @cpf VARCHAR(14),
    @email VARCHAR(100),
    @telefone VARCHAR(20),
    @senha VARCHAR(255),
    @status_conta VARCHAR(20)
AS
BEGIN
    INSERT INTO Cliente (nome, cpf, email, telefone, senha, status_conta)
    VALUES (@nome, @cpf, @email, @telefone, @senha, @status_conta);
END;

-- Livros populares (baseado em número de empréstimos)
CREATE PROCEDURE sp_LivrosPopulares
AS
BEGIN
    SELECT m.id_midia, m.titulo, COUNT(e.id_emprestimo) AS total
    FROM Midia m
    JOIN Emprestimo e ON m.id_midia = e.id_midia
    GROUP BY m.id_midia, m.titulo
    ORDER BY total DESC;
END;

-- Livros por gênero ou ano
CREATE PROCEDURE sp_FiltrarMidia
    @genero VARCHAR(100) = NULL,
    @ano INT = NULL
AS
BEGIN
    SELECT * FROM Midia
    WHERE (@genero IS NULL OR autor = @genero) -- Ajustar para campo de gênero se existir
      AND (@ano IS NULL OR ano_publicacao = @ano);
END;

-- Informações da mídia (detalhes)
CREATE PROCEDURE sp_InfoMidiaDetalhada
    @id_midia INT
AS
BEGIN
    SELECT titulo, autor, ano_publicacao, editora, isbn, edicao, numero_paginas
    FROM Midia
    WHERE id_midia = @id_midia;
END;

-- Sinopse (assumindo que existe campo sinopse)
CREATE PROCEDURE sp_SinopseMidia
    @id_midia INT
AS
BEGIN
    SELECT sinopse FROM Midia WHERE id_midia = @id_midia;
END;

-- Títulos similares (por gênero - genérico)
CREATE PROCEDURE sp_MidiasSimilares
    @id_tpmidia INT
AS
BEGIN
    SELECT * FROM Midia WHERE id_tpmidia = @id_tpmidia;
END;

-- Chave do trailer (audiovisual)
CREATE PROCEDURE sp_ChaveTrailer
    @id_midia INT
AS
BEGIN
    SELECT trailer_link FROM Midia WHERE id_midia = @id_midia;
END;

-- Empréstimos atuais (cliente)
CREATE PROCEDURE sp_EmprestimosAtuais
    @id_cliente INT
AS
BEGIN
    SELECT * FROM Emprestimo
    WHERE id_cliente = @id_cliente AND data_devolucao >= GETDATE();
END;

-- Empréstimos históricos
CREATE PROCEDURE sp_HistoricoEmprestimos
    @id_cliente INT
AS
BEGIN
    SELECT * FROM Emprestimo
    WHERE id_cliente = @id_cliente AND data_devolucao < GETDATE();
END;

-- Verificação de renovação (se limite foi atingido)
CREATE PROCEDURE sp_PodeRenovar
    @id_emprestimo INT
AS
BEGIN
    SELECT limite_renovacoes FROM Emprestimo WHERE id_emprestimo = @id_emprestimo;
END;

-- Reservas do cliente
CREATE PROCEDURE sp_ReservasCliente
    @id_cliente INT
AS
BEGIN
    SELECT * FROM Reserva WHERE id_cliente = @id_cliente;
END;

-- Lista de desejos do cliente
CREATE PROCEDURE sp_ListaDesejos
    @id_cliente INT
AS
BEGIN
    SELECT * FROM ListaDeDesejos WHERE id_cliente = @id_cliente;
END;

-- Atualização de dados do perfil do cliente
CREATE PROCEDURE sp_AtualizarPerfilCliente
    @id_cliente INT,
    @email VARCHAR(100),
    @senha VARCHAR(255),
    @telefone VARCHAR(20)
AS
BEGIN
    UPDATE Cliente
    SET email = @email, senha = @senha, telefone = @telefone
    WHERE id_cliente = @id_cliente;
END;

-- Notificações (3 dias antes ou atraso)
CREATE PROCEDURE sp_NotificacoesEmprestimos
AS
BEGIN
    SELECT id_emprestimo, id_cliente, data_devolucao
    FROM Emprestimo
    WHERE data_devolucao = CAST(GETDATE() + 3 AS DATE)
       OR data_devolucao < CAST(GETDATE() AS DATE);
END;
