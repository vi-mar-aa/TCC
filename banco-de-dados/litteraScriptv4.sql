USE master;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Littera') 
    DROP DATABASE Littera;

CREATE DATABASE Littera;
GO

EXEC sp_configure 'show advanced options', 1;
GO

RECONFIGURE;
GO

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
GO

RECONFIGURE;
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
	imagem VARBINARY(MAX),
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
    status_denuncia VARCHAR(20) NOT NULL,
    acao_tomada VARCHAR(255),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_mensagem) REFERENCES Mensagem(id_mensagem),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT chk_denuncia_status_denuncia CHECK (status_denuncia IN ('pendente', 'resolvida'))
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
('Luiggi Alexandre', '777.777.777-77', 'luiggi.alexandre@email.com', '11999990007', 'senha456', 'ativo'),
('Pedro Dias', '888.888.888-88', 'pedro.dias@email.com', '11999990008', 'senha789', 'ativo'),
('Rikelme Souza', '999.999.999-99', 'rikelme.souza@email.com', '11999990009', '123senha', 'ativo'),
('Cauê Gonçalves', '000.000.000-00', 'caue.goncalves@email.com', '11999990010', 'xyz987', 'ativo');
GO

INSERT INTO TipoMidia (nome_tipo) VALUES ('livros'), ('filmes'), ('revistas'), ('e-book');
GO

INSERT INTO Midia (id_funcionario, id_tpmidia, titulo, autor, editora, ano_publicacao, edicao, local_publicacao, numero_paginas, isbn, duracao, estudio, roteirista, disponibilidade, genero) VALUES 
(1, 1, 'Mar Morto', 'Jorge Amado', 'Companhia das Letras', 1936, '1ª', 'Salvador', 250, '9788535902773', NULL, NULL, NULL, 'disponível', 'Romance'),
(2, 1, 'Vidas Secas', 'Graciliano Ramos', 'Record', 1938, '3ª', 'Maceió', 200, '9788501042329', NULL, NULL, NULL, 'disponível', 'Drama'),
(3, 2, 'O Auto da Compadecida', 'Ariano Suassuna', NULL, 2000, NULL, NULL, NULL, NULL, '1h40min', 'Globo Filmes', 'Guel Arraes', 'emprestado', 'Comédia'),
(4, 3, 'Revista Superinteressante - Edição 402', NULL, 'Abril', 2022, NULL, 'São Paulo', 80, NULL, NULL, NULL, NULL, 'disponível', 'Ciência'),
(5, 4, '1984', 'George Orwell', 'Penguin', 1949, '2ª', 'Londres', 328, '9780141036144', NULL, NULL, NULL, 'emprestado', 'Ficção Cientí­fica');
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
('Discussões sobre revistas cientí­ficas');
GO

INSERT INTO Mensagem (id_cliente, id_forum, conteudo, data_postagem, visibilidade) VALUES 
(2, 1, 'Seria útimo adicionarem "Dom Casmurro" à coleção.', '2025-06-14T10:00:00', 'publica'),
(3, 2, 'Auto da Compadecida é uma obra-prima!', '2025-06-15T11:30:00', 'publica'),
(4, 3, 'Sugiro incluir "O Quinze" da Rachel de Queiroz.', '2025-06-16T12:45:00', 'publica'),
(5, 4, '"1984" deveria estar disponÃ­vel também em áudio.', '2025-06-17T09:20:00', 'publica'),
(3, 5, 'A edição da Superinteressante de maio estava muito boa.', '2025-06-18T08:00:00', 'privada');
GO

INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status_denuncia, acao_tomada) VALUES 
(1, 5, 2, '2025-06-18T14:00:00', 'Conteúdo inadequado', 'resolvida', 'Mensagem ocultada'),
(2, 4, 3, '2025-06-17T13:00:00', 'Spam', 'pendente', NULL),
(3, 3, 4, '2025-06-16T11:00:00', 'Fora do tópico', 'resolvida', 'Advertência ao usuário'),
(4, 2, 5, '2025-06-15T10:30:00', 'Linguagem ofensiva', 'pendente', NULL),
(5, 1, 3, '2025-06-14T09:45:00', 'Duplicado', 'resolvida', 'Mensagem removida');
GO

INSERT INTO ListaDeDesejos (id_cliente, id_midia, data_adicionada) VALUES 
(2, 1, '2025-06-18'),
(3, 2, '2025-06-17'),
(4, 3, '2025-06-16'),
(5, 4, '2025-06-15'),
(3, 5, '2025-06-14');
GO

/*
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\MarMorto-JorgeAmado.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 1;
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\VidasSecas-GracilianoRamos.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 2;
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\AutoDaCompadecida-ArianoSuassuna.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 3;
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\SuperInteressante_402.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 4;
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\1984-GeorgeOrwell.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 5;

Select * from Midia

SELECT id_midia, DATALENGTH(imagem) AS tamanho_em_bytes
FROM Midia
WHERE id_midia = 2;

SELECT imagem FROM Midia WHERE id_midia = 1
*/

-----------------------------------
--  AUTENTICAÇÃO / PERFIL (CLIENTE)
-----------------------------------

CREATE PROCEDURE sp_LoginCliente
    @email VARCHAR(100),
    @senha VARCHAR(255)
AS
BEGIN
    SELECT id_cliente, nome, email, telefone, status_conta
    FROM Cliente
    WHERE email = @email AND senha = @senha AND status_conta = 'ativo';
END
GO

CREATE PROCEDURE sp_CadastrarCliente
    @nome VARCHAR(100),
    @cpf VARCHAR(14),
    @email VARCHAR(100),
    @telefone VARCHAR(20) = NULL,
    @senha VARCHAR(255),
    @status_conta VARCHAR(20) = 'ativo'
AS
BEGIN
    IF @status_conta NOT IN ('ativo','banido')
    BEGIN
        SELECT 'Status inválido' AS msg; RETURN;
    END

    IF EXISTS (SELECT 1 FROM Cliente WHERE cpf = @cpf)
    BEGIN
        SELECT 'CPF já cadastrado' AS msg; RETURN;
    END

    IF EXISTS (SELECT 1 FROM Cliente WHERE email = @email)
    BEGIN
        SELECT 'E-mail já cadastrado' AS msg; RETURN;
    END

    INSERT INTO Cliente (nome, cpf, email, telefone, senha, status_conta)
    VALUES (@nome, @cpf, @email, @telefone, @senha, @status_conta);

    SELECT 'OK' AS msg, SCOPE_IDENTITY() AS id_cliente;
END
GO

CREATE PROCEDURE sp_ClienteResetarSenhaViaCpfEmail
    @email VARCHAR(100),
    @cpf   VARCHAR(14),
    @nova_senha VARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email AND cpf=@cpf)
    BEGIN
        SELECT 'Email/CPF não conferem' AS msg; RETURN;
    END

    UPDATE Cliente SET senha=@nova_senha WHERE email=@email AND cpf=@cpf;
    SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_AtualizarPerfilCliente
    @id_cliente INT,
    @email VARCHAR(100) = NULL,
    @senha VARCHAR(255) = NULL,
    @telefone VARCHAR(20) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente=@id_cliente)
    BEGIN
        SELECT 'Cliente não encontrado' AS msg; RETURN;
    END

    IF @email IS NOT NULL AND EXISTS (
        SELECT 1 FROM Cliente WHERE email=@email AND id_cliente<>@id_cliente
    )
    BEGIN
        SELECT 'E-mail já em uso' AS msg; RETURN;
    END

    UPDATE Cliente
       SET email    = COALESCE(@email, email),
           senha    = COALESCE(@senha, senha),
           telefone = COALESCE(@telefone, telefone)
     WHERE id_cliente=@id_cliente;

    SELECT 'OK' AS msg;
END
GO

----------------
-- FUNCIONÁRIO
----------------

CREATE PROCEDURE sp_InfoFuncionario
    @id_funcionario INT
AS
BEGIN
    SELECT id_funcionario, id_cargo, nome, cpf, email, telefone, status_conta
    FROM Funcionario
    WHERE id_funcionario = @id_funcionario;
END
GO

CREATE PROCEDURE sp_GetFuncionarioID
    @email VARCHAR(100)
AS
BEGIN
    SELECT id_funcionario
    FROM Funcionario
    WHERE email = @email AND status_conta = 'ativo';
END
GO

CREATE PROCEDURE sp_CadastrarFuncionario
    @id_cargo INT,
    @nome VARCHAR(100),
    @cpf VARCHAR(14),
    @email VARCHAR(100),
    @telefone VARCHAR(20) = NULL,
    @senha VARCHAR(255),
    @status_conta VARCHAR(20) = 'ativo'
AS
BEGIN
    IF @status_conta NOT IN ('ativo','banido')
    BEGIN
        SELECT 'Status inválido' AS msg; RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM CargoFuncionario WHERE id_cargo=@id_cargo)
    BEGIN
        SELECT 'Cargo inexistente' AS msg; RETURN;
    END

    IF EXISTS (SELECT 1 FROM Funcionario WHERE cpf=@cpf)
    BEGIN
        SELECT 'CPF já cadastrado' AS msg; RETURN;
    END

    IF EXISTS (SELECT 1 FROM Funcionario WHERE email=@email)
    BEGIN
        SELECT 'E-mail já cadastrado' AS msg; RETURN;
    END

    INSERT INTO Funcionario (id_cargo, nome, cpf, email, telefone, senha, status_conta)
    VALUES (@id_cargo, @nome, @cpf, @email, @telefone, @senha, @status_conta);

    SELECT 'OK' AS msg, SCOPE_IDENTITY() AS id_funcionario;
END
GO

CREATE PROCEDURE sp_LoginFuncionario
    @email VARCHAR(100),
    @senha VARCHAR(255)
AS
BEGIN
    SELECT id_funcionario, id_cargo, nome, email, telefone, status_conta
    FROM Funcionario
    WHERE email=@email AND senha=@senha AND status_conta='ativo';
END
GO

--------------------------------------
-- EVENTOS (FÓRUM) / POSTS / DENÚNCIA
--------------------------------------

CREATE PROCEDURE sp_EventosListar
AS
BEGIN
    SELECT f.id_forum, f.titulo,
           COUNT(m.id_mensagem) AS qtde_posts,
           MAX(m.data_postagem) AS ultima_atividade
    FROM Forum f
    LEFT JOIN Mensagem m ON m.id_forum=f.id_forum
    GROUP BY f.id_forum, f.titulo
    ORDER BY MAX(m.data_postagem) DESC;
END
GO

CREATE  PROCEDURE sp_PostCriar
    @id_cliente INT,
    @id_forum   INT,
    @conteudo   NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente=@id_cliente AND status_conta='ativo')
    BEGIN
        SELECT 'Cliente inativo/ausente' AS msg; RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Forum WHERE id_forum=@id_forum)
    BEGIN
        SELECT 'Fórum não encontrado' AS msg; RETURN;
    END

    INSERT INTO Mensagem (id_cliente, id_forum, conteudo, data_postagem, visibilidade)
    VALUES (@id_cliente, @id_forum, @conteudo, GETDATE(), 'publica');

    SELECT 'OK' AS msg, SCOPE_IDENTITY() AS id_mensagem;
END
GO

CREATE PROCEDURE sp_FiltrarPostsForum
    @id_forum INT,
    @modo VARCHAR(20) -- 'recentes' | 'antigos'
AS
BEGIN
    IF @modo = 'antigos'
    BEGIN
        SELECT m.conteudo, m.data_postagem, c.nome AS autor
        FROM Mensagem m
        JOIN Cliente c ON c.id_cliente=m.id_cliente
        WHERE m.id_forum=@id_forum AND m.visibilidade='publica'
        ORDER BY m.data_postagem ASC;
        RETURN;
    END

    -- padrão: recentes
    SELECT m.conteudo, m.data_postagem, c.nome AS autor
    FROM Mensagem m
    JOIN Cliente c ON c.id_cliente=m.id_cliente
    WHERE m.id_forum=@id_forum AND m.visibilidade='publica'
    ORDER BY m.data_postagem DESC;
END
GO

CREATE PROCEDURE sp_CriarDenuncia
    @id_funcionario INT,
    @id_mensagem INT,
    @id_cliente INT,
    @motivo VARCHAR(255) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE id_funcionario=@id_funcionario AND status_conta='ativo')
    BEGIN
        SELECT 'Funcionario inválido' AS msg; RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem=@id_mensagem)
    BEGIN
        SELECT 'Mensagem não encontrada' AS msg; RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente=@id_cliente)
    BEGIN
        SELECT 'Cliente não encontrado' AS msg; RETURN;
    END

    INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status_denuncia, acao_tomada)
    VALUES (@id_funcionario, @id_mensagem, @id_cliente, GETDATE(), @motivo, 'pendente', NULL);

    SELECT 'OK' AS msg, SCOPE_IDENTITY() AS id_denuncia;
END
GO

--------------------------------
-- ACERVO / DETALHE / POPULARES
--------------------------------

CREATE PROCEDURE sp_AcervoBuscar
    @tipo         VARCHAR(50) = NULL,
    @genero       VARCHAR(100) = NULL,
    @ano_min      INT = NULL,
    @ano_max      INT = NULL,
    @titulo_like  VARCHAR(255) = NULL
AS
BEGIN
    SELECT m.id_midia, m.titulo, m.autor, m.editora, m.ano_publicacao, m.genero,
           tm.nome_tipo, m.disponibilidade, m.isbn, m.estudio, m.roteirista
    FROM Midia m
    JOIN TipoMidia tm ON tm.id_tpmidia = m.id_tpmidia
    WHERE (@tipo IS NULL OR tm.nome_tipo = @tipo)
      AND (@genero IS NULL OR m.genero = @genero)
      AND (@ano_min IS NULL OR m.ano_publicacao >= @ano_min)
      AND (@ano_max IS NULL OR m.ano_publicacao <= @ano_max)
      AND (@titulo_like IS NULL OR m.titulo LIKE '%' + @titulo_like + '%')
    ORDER BY m.titulo;
END
GO

CREATE PROCEDURE sp_AcervoSearchTitulos
    @tipo   VARCHAR(50) = NULL,
    @q      VARCHAR(255)
AS
BEGIN
    SELECT m.id_midia, m.titulo, tm.nome_tipo, m.ano_publicacao, m.genero, m.autor, m.roteirista
    FROM Midia m
    JOIN TipoMidia tm ON tm.id_tpmidia=m.id_tpmidia
    WHERE (@tipo IS NULL OR tm.nome_tipo=@tipo)
      AND m.titulo LIKE '%' + @q + '%'
    ORDER BY m.titulo;
END
GO

CREATE PROCEDURE sp_MidiaDetalheComSimilares
    @id_midia INT
AS
BEGIN
    -- detalhe + contagem de exemplares disponíveis
    SELECT a.id_midia, a.titulo, a.autor, a.editora, a.ano_publicacao,
           a.edicao, a.local_publicacao, a.numero_paginas, a.isbn, a.duracao,
           a.estudio, a.roteirista, a.genero, tm.nome_tipo, a.disponibilidade,
           (SELECT COUNT(*) FROM Midia x
             WHERE (CASE WHEN a.isbn IS NOT NULL AND a.isbn<>'' THEN x.isbn ELSE x.titulo END) =
                   (CASE WHEN a.isbn IS NOT NULL AND a.isbn<>'' THEN a.isbn ELSE a.titulo END)
               AND x.disponibilidade='disponível') AS exemplares_disponiveis
    FROM Midia a
    JOIN TipoMidia tm ON tm.id_tpmidia=a.id_tpmidia
    WHERE a.id_midia=@id_midia;

    -- similares por gênero
    SELECT TOP 10 m.id_midia, m.titulo, m.autor, m.ano_publicacao, m.genero
    FROM Midia m
    WHERE m.genero = (SELECT genero FROM Midia WHERE id_midia=@id_midia)
      AND m.id_midia <> @id_midia
    ORDER BY m.ano_publicacao DESC, m.titulo;

    -- similares por “assunto” (mesmo autor ou mesmo roteirista)
    SELECT TOP 10 m.id_midia, m.titulo, m.autor, m.roteirista, m.ano_publicacao
    FROM Midia m
    WHERE m.id_midia <> @id_midia
      AND (
           (m.autor = (SELECT autor FROM Midia WHERE id_midia=@id_midia) AND (SELECT autor FROM Midia WHERE id_midia=@id_midia) IS NOT NULL)
        OR (m.roteirista = (SELECT roteirista FROM Midia WHERE id_midia=@id_midia) AND (SELECT roteirista FROM Midia WHERE id_midia=@id_midia) IS NOT NULL)
      )
    ORDER BY m.ano_publicacao DESC, m.titulo;
END
GO

CREATE PROCEDURE sp_MidiasPopulares
    @tipo   VARCHAR(50) = NULL,
    @genero VARCHAR(100) = NULL
AS
BEGIN
    SELECT TOP 50
           MIN(m.id_midia) AS id_midia_exemplo,
           CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END AS chave,
           MIN(m.titulo) AS titulo,
           MIN(tm.nome_tipo) AS nome_tipo,
           COUNT(e.id_emprestimo) AS qtde_emprestimos
    FROM Emprestimo e
    JOIN Midia m ON m.id_midia=e.id_midia
    JOIN TipoMidia tm ON tm.id_tpmidia=m.id_tpmidia
    WHERE (@tipo IS NULL OR tm.nome_tipo=@tipo)
      AND (@genero IS NULL OR m.genero=@genero)
    GROUP BY CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END
    ORDER BY qtde_emprestimos DESC, MIN(m.titulo);
END
GO

--------------------------------------------------
-- EMPRÉSTIMOS / RESERVAS (CONSULTAS E DEVOLUÇÃO)
--------------------------------------------------

CREATE PROCEDURE sp_EmprestimosClienteListar
    @id_cliente INT,
    @multa_dia DECIMAL(10,2) = 2.00
AS
BEGIN
    DECLARE @hoje DATE = CAST(GETDATE() AS DATE);

    SELECT e.id_emprestimo,
           e.data_emprestimo,
           e.data_devolucao,
           e.limite_renovacoes,
           m.id_midia, m.titulo, m.autor, m.ano_publicacao,
           CASE WHEN @hoje > e.data_devolucao THEN DATEDIFF(DAY, e.data_devolucao, @hoje) ELSE 0 END AS dias_atraso,
           CASE WHEN @hoje > e.data_devolucao THEN DATEDIFF(DAY, e.data_devolucao, @hoje) * @multa_dia ELSE 0 END AS multa,
           CASE WHEN @hoje <= e.data_devolucao AND e.limite_renovacoes > 0 THEN 1 ELSE 0 END AS pode_renovar
    FROM Emprestimo e
    JOIN Midia m ON m.id_midia=e.id_midia
    WHERE e.id_cliente=@id_cliente
    ORDER BY e.data_devolucao ASC;
END
GO

CREATE PROCEDURE sp_ReservasClienteListar
    @id_cliente INT
AS
BEGIN
    DECLARE @hoje DATE = CAST(GETDATE() AS DATE);

    SELECT r.id_reserva, r.data_reserva, r.data_limite, r.status_reserva,
           m.id_midia, m.titulo, m.autor, m.ano_publicacao,
           DATEDIFF(DAY, @hoje, r.data_limite) AS dias_restantes
    FROM Reserva r
    JOIN Midia m ON m.id_midia=r.id_midia
    WHERE r.id_cliente=@id_cliente
      AND r.status_reserva='ativa'
      AND r.data_limite >= @hoje
    ORDER BY r.data_limite ASC;
END
GO

CREATE PROCEDURE sp_DevolverMidia
    @id_emprestimo INT
AS
BEGIN
    DECLARE @id_midia INT;

    SELECT @id_midia = id_midia
    FROM Emprestimo
    WHERE id_emprestimo=@id_emprestimo;

    IF @id_midia IS NULL
    BEGIN
        SELECT 'Empréstimo não encontrado' AS msg; RETURN;
    END

    UPDATE Midia
       SET disponibilidade = 'disponível'
     WHERE id_midia=@id_midia;

    UPDATE Emprestimo
       SET limite_renovacoes = 0
     WHERE id_emprestimo=@id_emprestimo;

    SELECT 'OK' AS msg;
END
GO

--------------------------
-- ESTATÍSTICAS / ALERTAS
--------------------------

CREATE PROCEDURE sp_QtdEmprestimosPorMes
    @mes INT, @ano INT
AS
BEGIN
    SELECT COUNT(*) AS qtd_emprestimos
    FROM Emprestimo
    WHERE MONTH(data_emprestimo)=@mes AND YEAR(data_emprestimo)=@ano;
END
GO

CREATE PROCEDURE sp_QtdReservasPorMes
    @mes INT, @ano INT
AS
BEGIN
    SELECT COUNT(*) AS qtd_reservas
    FROM Reserva
    WHERE MONTH(data_reserva)=@mes AND YEAR(data_reserva)=@ano;
END
GO

CREATE PROCEDURE sp_QtdTotalEmprestimos
AS
BEGIN
    SELECT COUNT(*) AS total_emprestimos FROM Emprestimo;
END
GO

CREATE PROCEDURE sp_QtdEmprestimosAtrasados
AS
BEGIN
    SELECT COUNT(*) AS emprestimos_atrasados
    FROM Emprestimo
    WHERE data_devolucao < CAST(GETDATE() AS DATE);
END
GO

CREATE PROCEDURE sp_NotificacoesEmprestimos
AS
BEGIN
    SELECT id_emprestimo, id_cliente, data_devolucao
    FROM Emprestimo
    WHERE data_devolucao = DATEADD(DAY, 3, CAST(GETDATE() AS DATE))
       OR data_devolucao < CAST(GETDATE() AS DATE)
    ORDER BY data_devolucao;
END
GO

------------------
-- ANDROID (MAIN)
------------------

CREATE PROCEDURE sp_MainListar
    @genero_ref VARCHAR(100) = NULL,
    @top_genero INT = 10
AS
BEGIN
    -- populares (livros)
    EXEC sp_MidiasPopulares @tipo='Livro', @genero=NULL;

    -- mesmos gênero (se informado)
    IF @genero_ref IS NOT NULL
        SELECT TOP (@top_genero)
               m.id_midia, m.titulo, m.autor, m.ano_publicacao, m.genero
        FROM Midia m
        JOIN TipoMidia tm ON tm.id_tpmidia=m.id_tpmidia
        WHERE tm.nome_tipo='Livro' AND m.genero=@genero_ref
        ORDER BY m.ano_publicacao DESC, m.titulo;
END
GO
