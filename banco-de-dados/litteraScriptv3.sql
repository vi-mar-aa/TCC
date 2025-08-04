USE master;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Littera') 
    DROP DATABASE Littera;

CREATE DATABASE Littera;
GO

USE Littera;
GO

CREATE TABLE CargoFuncionario (
    id_cargo INT PRIMARY KEY IDENTITY,
    nome_cargo VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Funcionario (
    id_funcionario INT PRIMARY KEY IDENTITY,
    id_cargo INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    senha VARCHAR(255) NOT NULL,
    status_conta VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cargo) REFERENCES CargoFuncionario(id_cargo),
    CONSTRAINT chk_func_status CHECK (status_conta IN ('ativo', 'banido'))
);
GO

CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY IDENTITY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    senha VARCHAR(255) NOT NULL,
    status_conta VARCHAR(20) NOT NULL,
    CONSTRAINT chk_cli_status CHECK (status_conta IN ('ativo', 'banido'))
);
GO

CREATE TABLE TipoMidia (
    id_tpmidia INT PRIMARY KEY IDENTITY,
    nome_tipo VARCHAR(50) NOT NULL
);
GO

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
    genero VARCHAR(100),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_tpmidia) REFERENCES TipoMidia(id_tpmidia),
    CONSTRAINT chk_disponibilidade CHECK (disponibilidade IN ('disponível', 'emprestado'))
);
GO

CREATE TABLE Reserva (
    id_reserva INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    id_midia INT NOT NULL,
    data_reserva DATE NOT NULL,
    data_limite DATE NOT NULL,
    status_reserva VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia),
    CONSTRAINT chk_status_reserva CHECK (status_reserva IN ('ativa', 'expirada', 'cancelada'))
);
GO

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
GO

CREATE TABLE Forum (
    id_forum INT PRIMARY KEY IDENTITY,
    titulo VARCHAR(255) NOT NULL
);
GO

CREATE TABLE Mensagem (
    id_mensagem INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    id_forum INT NOT NULL,
    conteudo TEXT NOT NULL,
    data_postagem DATETIME NOT NULL,
    visibilidade VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_forum) REFERENCES Forum(id_forum),
    CONSTRAINT chk_visibilidade CHECK (visibilidade IN ('publica', 'privada'))
);
GO

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
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT chk_denuncia_status CHECK (status IN ('pendente', 'resolvida'))
);
GO

CREATE TABLE ListaDeDesejos (
    id_cliente INT NOT NULL,
    id_midia INT NOT NULL,
    data_adicionada DATE NOT NULL,
    PRIMARY KEY (id_cliente, id_midia),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia)
);
GO
-- INSERTS COMPLETOS

INSERT INTO CargoFuncionario (nome_cargo) VALUES ('bibliotecario'), ('adm');
GO

INSERT INTO Funcionario (id_cargo, nome, cpf, email, telefone, senha, status_conta) VALUES
(1, 'Luiz Ricardo', '111.111.111-11', 'luiz.ricardo@email.com', '11999990001', 'senha123', 'ativo'),
(1, 'Henrique Bressan', '222.222.222-22', 'henrique.bressan@email.com', '11999990002', 'senha123', 'ativo'),
(2, 'Maria Vitoria', '333.333.333-33', 'maria.vitoria@email.com', '11999990003', 'senha123', 'ativo'),
(2, 'Luiz Pinheiro', '444.444.444-44', 'luiz.pinheiro@email.com', '11999990004', 'senha123', 'ativo'),
(1, 'Marcia X', '555.555.555-55', 'marcia.x@email.com', '11999990005', 'senha123', 'ativo');
GO

INSERT INTO Cliente (nome, cpf, email, telefone, senha, status_conta) VALUES 
('Gabriel Gonçalves', '666.666.666-66', 'gabriel.goncalves@email.com', '11999990006', 'abc123', 'banido'),
('Juliana Ramos', '777.777.777-77', 'juliana.ramos@email.com', '11999990007', 'senha456', 'ativo'),
('Carlos Nunes', '888.888.888-88', 'carlos.nunes@email.com', '11999990008', 'senha789', 'ativo'),
('Fernanda Dias', '999.999.999-99', 'fernanda.dias@email.com', '11999990009', '123senha', 'ativo'),
('Roberto Lima', '000.000.000-00', 'roberto.lima@email.com', '11999990010', 'xyz987', 'ativo');
GO

INSERT INTO TipoMidia (nome_tipo) VALUES ('livros'), ('filmes'), ('revistas'), ('e-book');
GO

INSERT INTO Midia (id_funcionario, id_tpmidia, titulo, autor, editora, ano_publicacao, edicao, local_publicacao, numero_paginas, isbn, duracao, estudio, roteirista, disponibilidade, genero) VALUES 
(1, 1, 'Mar Morto', 'Jorge Amado', 'Companhia das Letras', 1936, '1ª', 'Salvador', 250, '9788535902773', NULL, NULL, NULL, 'disponível', 'Romance'),
(2, 1, 'Vidas Secas', 'Graciliano Ramos', 'Record', 1938, '3ª', 'Maceió', 200, '9788501042329', NULL, NULL, NULL, 'disponível', 'Drama'),
(3, 2, 'O Auto da Compadecida', 'Ariano Suassuna', NULL, 2000, NULL, NULL, NULL, NULL, '1h40min', 'Globo Filmes', 'Guel Arraes', 'emprestado', 'Comédia'),
(4, 3, 'Revista Superinteressante - Edição 402', NULL, 'Abril', 2022, NULL, 'São Paulo', 80, NULL, NULL, NULL, NULL, 'disponível', 'Ciência'),
(5, 4, '1984', 'George Orwell', 'Penguin', 1949, '2ª', 'Londres', 328, '9780141036144', NULL, NULL, NULL, 'emprestado', 'Ficção Científica');
GO

INSERT INTO Reserva (id_cliente, id_midia, data_reserva, data_limite, status_reserva) VALUES 
(2, 1, '2025-06-14', '2025-06-17', 'ativa'),
(3, 2, '2025-06-15', '2025-06-18', 'ativa'),
(4, 3, '2025-06-13', '2025-06-16', 'expirada'),
(5, 4, '2025-06-16', '2025-06-19', 'ativa'),
(2, 5, '2025-06-17', '2025-06-20', 'cancelada');
GO

INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes) VALUES 
(2, 1, 1, 1, '2025-06-14', '2025-06-21', 1),
(3, 2, 2, 2, '2025-06-15', '2025-06-22', 0),
(4, 3, 3, 3, '2025-06-13', '2025-06-20', 2),
(5, 4, 5, 5, '2025-06-17', '2025-06-24', 0),
(3, 5, 4, 4, '2025-06-16', '2025-06-23', 1);
GO

INSERT INTO Forum (titulo) VALUES 
('Sugestão de novos livros'),
('Filmes que marcaram época'),
('Literatura nordestina'),
('Melhores e-books do mês'),
('Discussões sobre revistas científicas');
GO

INSERT INTO Mensagem (id_cliente, id_forum, conteudo, data_postagem, visibilidade) VALUES 
(2, 1, 'Seria ótimo adicionarem "Dom Casmurro" à coleção.', '2025-06-14 10:00:00', 'publica'),
(3, 2, 'Auto da Compadecida é uma obra-prima!', '2025-06-15 11:30:00', 'publica'),
(4, 3, 'Sugiro incluir "O Quinze" da Rachel de Queiroz.', '2025-06-16 12:45:00', 'publica'),
(5, 4, '"1984" deveria estar disponível também em áudio.', '2025-06-17 09:20:00', 'publica'),
(3, 5, 'A edição da Superinteressante de maio estava muito boa.', '2025-06-18 08:00:00', 'privada');
GO

INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status, acao_tomada) VALUES 
(1, 5, 2, '2025-06-18 14:00:00', 'Conteúdo inadequado', 'resolvida', 'Mensagem ocultada'),
(2, 4, 3, '2025-06-17 13:00:00', 'Spam', 'pendente', NULL),
(3, 3, 4, '2025-06-16 11:00:00', 'Fora do tópico', 'resolvida', 'Advertência ao usuário'),
(4, 2, 5, '2025-06-15 10:30:00', 'Linguagem ofensiva', 'pendente', NULL),
(5, 1, 3, '2025-06-14 09:45:00', 'Duplicado', 'resolvida', 'Mensagem removida');
GO

INSERT INTO ListaDeDesejos (id_cliente, id_midia, data_adicionada) VALUES 
(2, 1, '2025-06-18'),
(3, 2, '2025-06-17'),
(4, 3, '2025-06-16'),
(5, 4, '2025-06-15'),
(3, 5, '2025-06-14');
GO
-- PROCEDURES PARTE 1

-- Retorna todas as informações de um funcionário pelo ID
CREATE PROCEDURE sp_InfoFuncionario
    @id_funcionario INT
AS
BEGIN
    SELECT * FROM Funcionario WHERE id_funcionario = @id_funcionario;
END;
GO

-- Retorna o ID do funcionário com base no e-mail (login)
CREATE PROCEDURE sp_GetFuncionarioID
    @email VARCHAR(100)
AS
BEGIN
    SELECT id_funcionario FROM Funcionario WHERE email = @email;
END;
GO

-- Verifica login de cliente por email e senha
CREATE PROCEDURE sp_LoginCliente
    @email VARCHAR(100),
    @senha VARCHAR(255)
AS
BEGIN
    SELECT * FROM Cliente WHERE email = @email AND senha = @senha;
END;
GO

-- Cadastra um novo cliente
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
GO

-- Recupera senha de cliente via e-mail
CREATE PROCEDURE sp_RecuperarSenhaCliente
    @email VARCHAR(100)
AS
BEGIN
    SELECT senha FROM Cliente WHERE email = @email;
END;
GO

-- Atualiza perfil do cliente (email, senha e telefone)
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
GO

-- Retorna quantidade de empréstimos feitos em um mês/ano específico
CREATE PROCEDURE sp_QtdEmprestimosPorMes
    @mes INT,
    @ano INT
AS
BEGIN
    SELECT COUNT(*) AS qtd_emprestimos
    FROM Emprestimo
    WHERE MONTH(data_emprestimo) = @mes AND YEAR(data_emprestimo) = @ano;
END;
GO

-- Retorna quantidade de reservas feitas em um mês/ano específico
CREATE PROCEDURE sp_QtdReservasPorMes
    @mes INT,
    @ano INT
AS
BEGIN
    SELECT COUNT(*) AS qtd_reservas
    FROM Reserva
    WHERE MONTH(data_reserva) = @mes AND YEAR(data_reserva) = @ano;
END;
GO

-- Retorna total de empréstimos no sistema
CREATE PROCEDURE sp_QtdTotalEmprestimos
AS
BEGIN
    SELECT COUNT(*) AS total_emprestimos FROM Emprestimo;
END;
GO

-- Retorna empréstimos atrasados
CREATE PROCEDURE sp_QtdEmprestimosAtrasados
AS
BEGIN
    SELECT COUNT(*) AS emprestimos_atrasados
    FROM Emprestimo
    WHERE data_devolucao < CAST(GETDATE() AS DATE);
END;
GO

-- Atualiza data de devolução de um empréstimo
CREATE PROCEDURE sp_DevolverMidia
    @id_emprestimo INT,
    @data_devolucao DATE
AS
BEGIN
    UPDATE Emprestimo
    SET data_devolucao = @data_devolucao
    WHERE id_emprestimo = @id_emprestimo;
END;
GO
-- PROCEDURES PARTE 2

-- Retorna empréstimos ativos de um cliente
CREATE PROCEDURE sp_EmprestimosAtuais
    @id_cliente INT
AS
BEGIN
    SELECT * FROM Emprestimo
    WHERE id_cliente = @id_cliente AND data_devolucao >= GETDATE();
END;
GO

-- Retorna histórico de empréstimos de um cliente
CREATE PROCEDURE sp_HistoricoEmprestimos
    @id_cliente INT
AS
BEGIN
    SELECT * FROM Emprestimo
    WHERE id_cliente = @id_cliente AND data_devolucao < GETDATE();
END;
GO

-- Verifica limite de renovações de um empréstimo
CREATE PROCEDURE sp_PodeRenovar
    @id_emprestimo INT
AS
BEGIN
    SELECT limite_renovacoes FROM Emprestimo WHERE id_emprestimo = @id_emprestimo;
END;
GO

-- Retorna empréstimos vencidos ou que vencerão em 3 dias
CREATE PROCEDURE sp_NotificacoesEmprestimos
AS
BEGIN
    SELECT id_emprestimo, id_cliente, data_devolucao
    FROM Emprestimo
    WHERE data_devolucao = CAST(GETDATE() + 3 AS DATE)
       OR data_devolucao < CAST(GETDATE() AS DATE);
END;
GO

-- Filtra mídias por gênero e/ou ano de publicação
CREATE PROCEDURE sp_FiltrarMidia
    @genero VARCHAR(100) = NULL,
    @ano INT = NULL
AS
BEGIN
    SELECT * FROM Midia
    WHERE (@genero IS NULL OR genero = @genero)
      AND (@ano IS NULL OR ano_publicacao = @ano);
END;
GO

-- Busca mídias por título
CREATE PROCEDURE sp_BuscarPorTitulo
    @titulo VARCHAR(255)
AS
BEGIN
    SELECT * FROM Midia
    WHERE titulo LIKE '%' + @titulo + '%';
END;
GO

-- Detalhes de um livro específico
CREATE PROCEDURE sp_PaginaLivroDetalhada
    @id_midia INT
AS
BEGIN
    SELECT titulo, autor, ano_publicacao, editora, isbn, edicao, numero_paginas, genero, disponibilidade
    FROM Midia
    WHERE id_midia = @id_midia AND id_tpmidia = 1;
END;
GO

-- Detalhes de uma mídia audiovisual
CREATE PROCEDURE sp_PaginaAudiovisualDetalhada
    @id_midia INT
AS
BEGIN
    SELECT titulo, duracao, ano_publicacao, estudio, roteirista, genero, disponibilidade
    FROM Midia
    WHERE id_midia = @id_midia AND id_tpmidia <> 1;
END;
GO

-- Retorna mídias do mesmo gênero
CREATE PROCEDURE sp_MidiasSimilares
    @genero VARCHAR(100)
AS
BEGIN
    SELECT * FROM Midia WHERE genero = @genero;
END;
GO

-- Retorna livros mais populares por empréstimo
CREATE PROCEDURE sp_LivrosPopulares
AS
BEGIN
    SELECT m.id_midia, m.titulo, COUNT(e.id_emprestimo) AS total
    FROM Midia m
    JOIN Emprestimo e ON m.id_midia = e.id_midia
    WHERE m.id_tpmidia = 1
    GROUP BY m.id_midia, m.titulo
    ORDER BY total DESC;
END;
GO

-- Retorna reservas de um cliente
CREATE PROCEDURE sp_ReservasCliente
    @id_cliente INT
AS
BEGIN
    SELECT * FROM Reserva WHERE id_cliente = @id_cliente;
END;
GO

-- Retorna lista de desejos de um cliente
CREATE PROCEDURE sp_ListaDesejos
    @id_cliente INT
AS
BEGIN
    SELECT * FROM ListaDeDesejos WHERE id_cliente = @id_cliente;
END;
GO

-- Posts públicos de um fórum
CREATE PROCEDURE sp_ObterPostsForum
    @id_forum INT
AS
BEGIN
    SELECT conteudo, data_postagem
    FROM Mensagem
    WHERE id_forum = @id_forum AND visibilidade = 'publica'
    ORDER BY data_postagem DESC;
END;
GO

-- Filtra posts do fórum por ordem
CREATE PROCEDURE sp_FiltrarPostsForum
    @id_forum INT,
    @modo VARCHAR(20)
AS
BEGIN
    IF @modo = 'recentes'
    BEGIN
        SELECT conteudo, data_postagem
        FROM Mensagem
        WHERE id_forum = @id_forum AND visibilidade = 'publica'
        ORDER BY data_postagem DESC;
    END
    ELSE IF @modo = 'antigos'
    BEGIN
        SELECT conteudo, data_postagem
        FROM Mensagem
        WHERE id_forum = @id_forum AND visibilidade = 'publica'
        ORDER BY data_postagem ASC;
    END
    ELSE
    BEGIN
        SELECT conteudo, data_postagem
        FROM Mensagem
        WHERE id_forum = @id_forum AND visibilidade = 'publica';
    END
END;
GO

-- Cria denúncia sobre mensagem
CREATE PROCEDURE sp_CriarDenuncia
    @id_funcionario INT,
    @id_mensagem INT,
    @id_cliente INT,
    @motivo VARCHAR(255)
AS
BEGIN
    INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status, acao_tomada)
    VALUES (@id_funcionario, @id_mensagem, @id_cliente, GETDATE(), @motivo, 'pendente', NULL);
END;
GO

-- Pesquisa postagens por palavra-chave
CREATE PROCEDURE sp_PesquisarPost
    @busca VARCHAR(255)
AS
BEGIN
    SELECT conteudo, data_postagem
    FROM Mensagem
    WHERE conteudo LIKE '%' + @busca + '%';
END;
