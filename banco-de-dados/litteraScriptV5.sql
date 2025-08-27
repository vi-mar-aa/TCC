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
	imagem_perfil VARBINARY(MAX),
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
	sinopse VARCHAR(255) NOT NULL, 
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
    conteudo NVARCHAR(255) NOT NULL,
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
    data_adicionada DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (id_cliente, id_midia),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia)
);
GO

CREATE TABLE Evento (
    id_evento INT PRIMARY KEY IDENTITY,
    titulo VARCHAR(200) NOT NULL,
    horario VARCHAR(50) NOT NULL,
    local_evento VARCHAR(200) NOT NULL,
    data_evento DATE NOT NULL,
	status_evento VARCHAR(20) NOT NULL DEFAULT 'ativo',
    id_funcionario INT NOT NULL,
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
);
GO

CREATE TABLE Indicacao (
    id_indicacao INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    titulo_ind VARCHAR(255) NOT NULL,
    autor_ind VARCHAR(120),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);
GO

CREATE TABLE Notificacao (
    id_notificacao INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensagem VARCHAR(MAX) NOT NULL,
    data_criacao DATETIME NOT NULL DEFAULT GETDATE(),
    lida BIT DEFAULT 0,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);
GO

CREATE TABLE Parametros(
	id_parametros INT IDENTITY PRIMARY KEY,
	multa_dia DECIMAL(10,2)  NOT NULL, 
	prazo_devolucao_dias INT  NOT NULL, 
	limite_emprestimos INT  NOT NULL, 
	data_atualizada DATETIME NOT NULL,
/*	id_midia INT NOT NULL,
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia)*/
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

INSERT INTO Midia (id_funcionario, id_tpmidia, titulo, sinopse, autor, editora, ano_publicacao, edicao, local_publicacao, numero_paginas, isbn, duracao, estudio, roteirista, disponibilidade, genero) VALUES 
(1, 1, 'Mar Morto', '', 'Jorge Amado', 'Companhia das Letras', 1936, '1ª', 'Salvador', 250, '9788535902773', NULL, NULL, NULL, 'disponível', 'Romance'),
(2, 1, 'Vidas Secas', '', 'Graciliano Ramos', 'Record', 1938, '3ª', 'Maceió', 200, '9788501042329', NULL, NULL, NULL, 'disponível', 'Drama'),
(3, 2, 'O Auto da Compadecida', '', 'Ariano Suassuna', NULL, 2000, NULL, NULL, NULL, NULL, '1h40min', 'Globo Filmes', 'Guel Arraes', 'emprestado', 'Comédia'),
(4, 3, 'Revista Superinteressante - Edição 402', '', NULL, 'Abril', 2022, NULL, 'São Paulo', 80, NULL, NULL, NULL, NULL, 'disponível', 'Ciência'),
(5, 4, '1984', '', 'George Orwell', 'Penguin', 1949, '2ª', 'Londres', 328, '9780141036144', NULL, NULL, NULL, 'emprestado', 'Ficção Cientí­fica');
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

INSERT INTO ListaDeDesejos (id_cliente, id_midia) VALUES 
(2, 1),
(3, 2),
(4, 3),
(5, 4),
(3, 5);
GO

INSERT INTO Evento (titulo, horario, local_evento, data_evento, id_funcionario) VALUES
('Clube do Livro - Jorge Amado', '19h', 'Sala de leitura 1', '2025-09-10', 1),
('Exibição de Filme - O Auto da Compadecida', '20h', 'Auditório Principal', '2025-09-15', 2),
('Palestra: A Literatura Nordestina', '18h', 'Sala 2', '2025-09-20', 3),
('Semana de Ciência e Conhecimento', '09h', 'Auditório B', '2025-09-25', 4),
('Encontro de e-Books - Discussões Modernas', '17h', 'Online', '2025-10-02', 5);
GO

INSERT INTO Indicacao (id_cliente, titulo_ind, autor_ind) VALUES
(2, 'Dom Casmurro', 'Machado de Assis'),
(3, 'O Quinze', 'Rachel de Queiroz'),
(4, 'Grande Sertão: Veredas', 'João Guimarães Rosa'),
(5, 'Memórias Póstumas de Brás Cubas', 'Machado de Assis'),
(2, 'Capitães da Areia', 'Jorge Amado');
GO

INSERT INTO Notificacao (id_cliente, titulo, mensagem) VALUES
(2, 'Lembrete de Devolução', 'Você tem um livro para devolver até 21/06.'),
(3, 'Reserva Ativa', 'Sua reserva do livro "Vidas Secas" está disponível até 18/06.'),
(1, 'Nova Denúncia', 'Uma denúncia foi atribuída para sua análise.'),
(4, 'Evento Hoje', 'Não esqueça: Palestra sobre Literatura Nordestina às 18h.'),
(5, 'Indicação Recebida', 'Sua indicação de "O Quinze" está em análise.');
GO

INSERT INTO Parametros (multa_dia, prazo_devolucao_dias, limite_emprestimos, data_atualizada) VALUES 
(2.00, 14, 3, GETDATE());
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



-- !!!!!!!!!!!!!!!! ANDROID !!!!!!!!!!!!!!!!!!!!!!!



-- !!!MAIN!!!


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


	CREATE PROCEDURE sp_MainListar
  @genero_ref VARCHAR(100) = NULL,
  @top_genero INT = 10
AS
BEGIN
  EXEC sp_MidiasPopulares @tipo='livros', @genero=NULL;

  IF @genero_ref IS NOT NULL
    SELECT TOP (@top_genero)
           m.id_midia, m.titulo, m.autor, m.ano_publicacao, m.genero
    FROM Midia m
    JOIN TipoMidia tm ON tm.id_tpmidia=m.id_tpmidia
    WHERE tm.nome_tipo='livros' AND m.genero=@genero_ref
    ORDER BY m.ano_publicacao DESC, m.titulo;
END
GO

	
	

-- !!! RESERVAS/EMPRESTIMO!!!


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


CREATE PROCEDURE sp_HistoricoEmprestimosCliente
  @id_cliente INT
AS
BEGIN
  SELECT 
    e.id_emprestimo,
    e.data_emprestimo,
    e.data_devolucao,
    m.id_midia,
    m.titulo,
    m.autor,
    m.ano_publicacao
  FROM Emprestimo e
  JOIN Midia m ON m.id_midia = e.id_midia
  WHERE e.id_cliente = @id_cliente
    AND e.data_devolucao < GETDATE()
  ORDER BY e.data_devolucao DESC;
END
GO


-- !!!NOTIFICAÇÕES/ALERTAS !!!

	CREATE PROCEDURE sp_NotificacoesEmprestimos
AS
BEGIN
  SELECT id_emprestimo,
         id_cliente,
         data_devolucao
  FROM Emprestimo
  WHERE data_devolucao = DATEADD(DAY, 3, CAST(GETDATE() AS DATE))
     OR data_devolucao < CAST(GETDATE() AS DATE)
  ORDER BY data_devolucao;
END
GO

CREATE PROCEDURE sp_NotificacaoMarcarLida
  @id_notificacao INT
AS
BEGIN
  UPDATE Notificacao
  SET lida = 1
  WHERE id_notificacao = @id_notificacao;

  SELECT 'OK' AS msg;
END
GO

	

-- !!! LISTA DE DESEJOS !!!



	CREATE PROCEDURE sp_ListaDesejosCliente
  @id_cliente INT
AS
BEGIN
  SELECT 
    ld.id_midia,
    ld.data_adicionada,
    m.titulo,
    m.autor,
    m.ano_publicacao
  FROM ListaDeDesejos ld
  JOIN Midia m ON m.id_midia = ld.id_midia
  WHERE ld.id_cliente = @id_cliente
  ORDER BY ld.data_adicionada DESC;
END
GO

CREATE PROCEDURE sp_ListaDesejosExcluir
  @id_cliente INT,
  @id_midia   INT
AS
BEGIN
  DELETE FROM ListaDeDesejos
  WHERE id_cliente=@id_cliente AND id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO
	
	

-- !!! ACERVO/MIDIA !!!

CREATE PROCEDURE sp_AcervoPrincipal
AS
BEGIN
  SELECT 
    m.id_midia,
    m.imagem,
    m.titulo,
    m.autor,
    m.roteirista,
    m.ano_publicacao
  FROM Midia m
  ORDER BY m.titulo;
END
GO

CREATE PROCEDURE sp_MidiaComExemplares
  @isbn   VARCHAR(20) = NULL,
  @titulo VARCHAR(255) = NULL
AS
BEGIN
  IF (@isbn IS NOT NULL)
  BEGIN
    SELECT * FROM Midia WHERE isbn = @isbn;

    SELECT @isbn AS chave, COUNT(*) AS total_exemplares
    FROM Midia
    WHERE isbn = @isbn;
  END
  ELSE
  BEGIN
    SELECT * FROM Midia WHERE titulo = @titulo;

    SELECT @titulo AS chave, COUNT(*) AS total_exemplares
    FROM Midia
    WHERE titulo = @titulo;
  END
END
GO

	

-- !!! LOGIN/CADASTRO CLIENTE !!!


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
  @telefone VARCHAR(20),
  @senha VARCHAR(255),
  @status_conta VARCHAR(20)
AS
BEGIN
  IF @status_conta NOT IN ('ativo','banido')
  BEGIN
    SELECT 'Status inválido' AS msg;
    RETURN;
  END

  IF EXISTS (SELECT 1 FROM Cliente WHERE cpf=@cpf)
  BEGIN
    SELECT 'CPF já cadastrado' AS msg;
    RETURN;
  END

  IF EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN
    SELECT 'E-mail já cadastrado' AS msg;
    RETURN;
  END

  INSERT INTO Cliente (nome, cpf, email, telefone, senha, status_conta)
  VALUES (@nome, @cpf, @email, @telefone, @senha, @status_conta);

  SELECT 'OK' AS msg;
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
  @email VARCHAR(100),
  @senha VARCHAR(255),
  @telefone VARCHAR(20)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente=@id_cliente)
  BEGIN
    SELECT 'Cliente não encontrado' AS msg;
    RETURN;
  END

  IF EXISTS (SELECT 1 FROM Cliente WHERE email=@email AND id_cliente<>@id_cliente)
  BEGIN
    SELECT 'E-mail já em uso' AS msg;
    RETURN;
  END

  UPDATE Cliente
  SET email=@email,
      senha=@senha,
      telefone=@telefone
  WHERE id_cliente=@id_cliente;

  SELECT 'OK' AS msg;
END
GO


-- !!!!!!!!!!!!!!! DESKTOP !!!!!!!!!!!!!!!!!!!!!!!


CREATE PROCEDURE sp_ConfigurarParametros
  @multa_dia DECIMAL(10,2),
  @prazo_devolucao_dias INT,
  @limite_emprestimos INT
AS
BEGIN
  UPDATE Parametros
    SET multa_dia=@multa_dia,
        prazo_devolucao_dias=@prazo_devolucao_dias,
        limite_emprestimos=@limite_emprestimos,
        data_atualizada=GETDATE();
  SELECT 'OK' AS msg;
END
GO


--!!!FUNCIONARIO!!!

CREATE PROCEDURE sp_TodosFuncionarios --lista todos os funcionarios
AS
BEGIN
  SELECT id_funcionario, id_cargo, nome, cpf, email, telefone, status_conta
  FROM Funcionario
  ORDER BY nome;
END
GO


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
  @telefone VARCHAR(20),
  @senha VARCHAR(255),
  @status_conta VARCHAR(20)
AS
BEGIN
  IF @status_conta NOT IN ('ativo','banido')
  BEGIN
    SELECT 'Status inválido' AS msg;
    RETURN;
  END

  IF NOT EXISTS (SELECT 1 FROM CargoFuncionario WHERE id_cargo=@id_cargo)
  BEGIN
    SELECT 'Cargo inexistente' AS msg;
    RETURN;
  END

  IF EXISTS (SELECT 1 FROM Funcionario WHERE cpf=@cpf)
  BEGIN
    SELECT 'CPF já cadastrado' AS msg;
    RETURN;
  END

  IF EXISTS (SELECT 1 FROM Funcionario WHERE email=@email)
  BEGIN
    SELECT 'E-mail já cadastrado' AS msg;
    RETURN;
  END

  INSERT INTO Funcionario (id_cargo, nome, cpf, email, telefone, senha, status_conta)
  VALUES (@id_cargo, @nome, @cpf, @email, @telefone, @senha, @status_conta);

  SELECT 'OK' AS msg;
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

-- Alterar funcionário
CREATE PROCEDURE sp_FuncionarioAlterar
  @id_funcionario INT,
  @nome VARCHAR(100),
  @email VARCHAR(100),
  @telefone VARCHAR(20),
  @status_conta VARCHAR(20)
AS
BEGIN
  UPDATE Funcionario
  SET nome = @nome,
      email = @email,
      telefone = @telefone,
      status_conta = @status_conta
  WHERE id_funcionario = @id_funcionario;

  SELECT 'OK' AS msg;
END
GO


-- !!!INFO SOBRE O CLIENTE!!!

CREATE PROCEDURE sp_LeitorBuscarPorNome
  @nome VARCHAR(100)
AS
BEGIN
  SELECT id_cliente, nome, email, telefone, status_conta
  FROM Cliente
  WHERE nome LIKE '%' + @nome + '%'
  ORDER BY nome;
END
GO
	
-- Mídias não devolvidas pelo cliente (em atraso)
CREATE PROCEDURE sp_NaoDevolveuMidia
  @id_cliente INT
AS
BEGIN
  SELECT 
    e.id_emprestimo,
    m.id_midia,
    m.titulo,
    e.data_devolucao,
    DATEDIFF(DAY, e.data_devolucao, GETDATE()) AS dias_atraso
  FROM Emprestimo e
  JOIN Midia m ON m.id_midia=e.id_midia
  WHERE e.id_cliente=@id_cliente
    AND e.data_devolucao < GETDATE()
  ORDER BY e.data_devolucao;
END
GO

	

-- !!!EVENTOS!!!

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

-- Criar
CREATE PROCEDURE sp_EventoCriar
  @titulo NVARCHAR(200),
  @horario VARCHAR(50),
  @local_evento NVARCHAR(200),
  @data_evento DATE,
  @id_funcionario INT
AS
BEGIN
  INSERT INTO Evento (titulo, horario, local_evento, data_evento, id_funcionario, status_evento)
  VALUES (@titulo, @horario, @local_evento, @data_evento, @id_funcionario, 'ativo');
  SELECT 'OK' AS msg;
END
GO

-- Editar
CREATE PROCEDURE sp_EventoEditar
  @id_evento INT,
  @titulo NVARCHAR(200),
  @horario VARCHAR(50),
  @local_evento NVARCHAR(200),
  @data_evento DATE
AS
BEGIN
  UPDATE Evento
  SET titulo=@titulo,
      horario=@horario,
      local_evento=@local_evento,
      data_evento=@data_evento
  WHERE id_evento=@id_evento;
  SELECT 'OK' AS msg;
END
GO

-- Histórico (já aconteceram)
CREATE PROCEDURE sp_EventosHistorico
AS
BEGIN
  SELECT *
  FROM Evento
  WHERE data_evento < CAST(GETDATE() AS DATE)
  ORDER BY data_evento DESC;
END
GO

-- Em andamento ou futuros (ativos)
CREATE PROCEDURE sp_EventosAtivos
AS
BEGIN
  SELECT *
  FROM Evento
  WHERE data_evento >= CAST(GETDATE() AS DATE)
    AND status_evento = 'ativo'
  ORDER BY data_evento ASC;
END
GO

	

-- !!!FÓRUM/DENUNCIAS!!!


-- Listar denúncias
CREATE PROCEDURE sp_DenunciasListar
AS
BEGIN
  SELECT id_denuncia, id_mensagem, id_cliente, id_funcionario, data_denuncia, motivo, status_denuncia, acao_tomada
  FROM Denuncia
  ORDER BY data_denuncia DESC;
END
GO

-- Ver denúncia por id
CREATE PROCEDURE sp_DenunciaVer
  @id_denuncia INT
AS
BEGIN
  SELECT * FROM Denuncia WHERE id_denuncia=@id_denuncia;
END
GO

-- Suspender leitor
CREATE PROCEDURE sp_LeitorSuspender
  @id_cliente INT
AS
BEGIN
  UPDATE Cliente SET status_conta='banido' WHERE id_cliente=@id_cliente;
  SELECT 'OK' AS msg;
END
GO

-- Histórico de posts do leitor
CREATE PROCEDURE sp_LeitorPostsHistorico
  @id_cliente INT
AS
BEGIN
  SELECT id_mensagem, id_forum, conteudo, data_postagem, visibilidade
  FROM Mensagem
  WHERE id_cliente=@id_cliente
  ORDER BY data_postagem DESC;
END
GO

	

-- !!!EMPRESTIMOS/RESERVA/DEVOLUÇÃO!!!
	

-- Adicionar empréstimo e marcar mídia como emprestada
CREATE PROCEDURE sp_EmprestimoAdicionar
  @id_cliente INT,
  @id_funcionario INT,
  @id_midia INT,
  @data_emprestimo DATETIME,
  @data_devolucao DATETIME
AS
BEGIN
  INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes)
  VALUES (@id_cliente, @id_funcionario, @id_midia, NULL, @data_emprestimo, @data_devolucao, 0);

  UPDATE Midia SET disponibilidade='emprestado' WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

-- Select reservas (código exemplar, título, tempo restante, usuário)
CREATE PROCEDURE sp_ReservasSelect -- Qual a diferença
AS
BEGIN
  SELECT 
    r.id_reserva,
    r.id_midia AS codigo_exemplar,
    m.titulo,
    DATEDIFF(DAY, GETDATE(), r.data_limite) AS dias_restantes,
    c.id_cliente,
    c.nome AS usuario
  FROM Reserva r
  JOIN Midia m ON m.id_midia=r.id_midia
  JOIN Cliente c ON c.id_cliente=r.id_cliente
  WHERE r.status_reserva='ativa'
  ORDER BY r.data_limite ASC;
END
GO

-- Transformar reserva em empréstimo
CREATE PROCEDURE sp_ReservaTransformarEmEmprestimo
  @id_reserva INT,
  @id_funcionario INT,
  @data_emprestimo DATETIME,
  @data_devolucao DATETIME
AS
BEGIN
  DECLARE @id_cliente INT, @id_midia INT;

  SELECT @id_cliente = id_cliente, @id_midia = id_midia
  FROM Reserva
  WHERE id_reserva=@id_reserva;

  INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes)
  VALUES (@id_cliente, @id_funcionario, @id_midia, @id_reserva, @data_emprestimo, @data_devolucao, 0);

  UPDATE Reserva SET status_reserva='cancelada' WHERE id_reserva=@id_reserva;
  UPDATE Midia   SET disponibilidade='emprestado' WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO


CREATE PROCEDURE sp_TodosEmprestimosComAtraso
AS
BEGIN
  SELECT 
    e.id_emprestimo,
    e.id_cliente,
    c.nome AS cliente,
    e.id_midia,
    m.titulo,
    e.data_emprestimo,
    e.data_devolucao,
    DATEDIFF(DAY, e.data_devolucao, GETDATE()) AS dias_atraso
  FROM Emprestimo e
  JOIN Cliente c ON c.id_cliente = e.id_cliente
  JOIN Midia m   ON m.id_midia   = e.id_midia
  ORDER BY e.data_devolucao ASC;
END
GO

CREATE PROCEDURE sp_TodasReservas -- qual a diferença?
AS
BEGIN
  SELECT 
    r.id_reserva,
    r.id_cliente,
    c.nome AS cliente,
    r.id_midia,
    m.titulo,
    r.data_reserva,
    r.data_limite,
    r.status_reserva
  FROM Reserva r
  JOIN Cliente c ON c.id_cliente = r.id_cliente
  JOIN Midia m   ON m.id_midia   = r.id_midia
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


-- Informações do exemplar + leitor que está com ele (se tiver)
CREATE PROCEDURE sp_ExemplarInfoComLeitor
  @id_midia INT
AS
BEGIN
  SELECT 
    m.id_midia,
    m.titulo,
    e.id_emprestimo,
    c.id_cliente,
    c.nome AS cliente,
    e.data_devolucao
  FROM Midia m
  JOIN Emprestimo e ON e.id_midia = m.id_midia
  JOIN Cliente c    ON c.id_cliente = e.id_cliente
  WHERE m.id_midia = @id_midia
    AND e.data_devolucao >= GETDATE();

  -- Se não voltar nada, significa que está livre (sem empréstimo atual).
END
GO





--!!!MIDIA/MANUTENCAO ACERVO!!!


	CREATE PROCEDURE sp_MidiaAdicionar
  @id_funcionario INT,
  @id_tpmidia INT,
  @titulo VARCHAR(255),
  @sinopse VARCHAR(255),
  @autor VARCHAR(100),
  @editora VARCHAR(100),
  @ano_publicacao INT,
  @isbn VARCHAR(20),
  @disponibilidade VARCHAR(20),
  @genero VARCHAR(100)
AS
BEGIN
  INSERT INTO Midia (
    id_funcionario, id_tpmidia, titulo, sinopse, autor, editora,
    ano_publicacao, isbn, disponibilidade, genero
  )
  VALUES (
    @id_funcionario, @id_tpmidia, @titulo, @sinopse, @autor, @editora,
    @ano_publicacao, @isbn, @disponibilidade, @genero
  );
  SELECT 'OK' AS msg;
END
GO


CREATE PROCEDURE sp_MidiaAlterar
  @id_midia INT,
  @titulo VARCHAR(255),
  @autor VARCHAR(100),
  @editora VARCHAR(100),
  @ano_publicacao INT,
  @isbn VARCHAR(20),
  @disponibilidade VARCHAR(20),
  @genero VARCHAR(100)
AS
BEGIN
  UPDATE Midia
  SET titulo = @titulo,
      autor = @autor,
      editora = @editora,
      ano_publicacao = @ano_publicacao,
      isbn = @isbn,
      disponibilidade = @disponibilidade,
      genero = @genero
  WHERE id_midia = @id_midia;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaExcluir
  @id_midia INT
AS
BEGIN
  DELETE FROM Midia WHERE id_midia=@id_midia;
  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAddSinopse
  @id_midia INT,
  @sinopse VARCHAR(255)
AS
BEGIN
  UPDATE Midia SET sinopse=@sinopse WHERE id_midia=@id_midia;
  SELECT 'OK' AS msg;
END
GO

-- !!!INDICACOES!!

CREATE PROCEDURE sp_IndicacoesResumo
AS
BEGIN
  SELECT 
    titulo_ind AS titulo,
    autor_ind  AS autor,
    COUNT(*)   AS qtd_indicacoes
  FROM Indicacao
  GROUP BY titulo_ind, autor_ind
  ORDER BY titulo_ind;
END
GO	




-- !!!!!!!!!!!!!!!!!COMUM!!!!!!!!!!!!!!!!!!!!!!!!!


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



--!!!!!!!!!!!!NÃO ENTENDI/REVER!!!!!!!!!!!!!
	

-- quantidade de empréstimos por mês/ano
CREATE PROCEDURE sp_QtdEmprestimosPorMes
  @mes INT,
  @ano INT
AS
BEGIN
  SELECT COUNT(*) AS qtd_emprestimos
  FROM Emprestimo
  WHERE MONTH(data_emprestimo) = @mes
    AND YEAR(data_emprestimo) = @ano;
END
GO

-- quantidade de reservas por mês/ano
CREATE PROCEDURE sp_QtdReservasPorMes
  @mes INT,
  @ano INT
AS
BEGIN
  SELECT COUNT(*) AS qtd_reservas
  FROM Reserva
  WHERE MONTH(data_reserva) = @mes
    AND YEAR(data_reserva) = @ano;
END
GO

-- quantidade total de empréstimos
CREATE PROCEDURE sp_QtdTotalEmprestimos
AS
BEGIN
  SELECT COUNT(*) AS total_emprestimos
  FROM Emprestimo;
END
GO

-- quantidade de empréstimos atrasados
CREATE PROCEDURE sp_QtdEmprestimosAtrasados
AS
BEGIN
  SELECT COUNT(*) AS emprestimos_atrasados
  FROM Emprestimo
  WHERE data_devolucao < CAST(GETDATE() AS DATE);
END
GO

CREATE PROCEDURE sp_MidiaAlterarImagem -- fazer junto com o alter, precisa de um separado pro perfil do cliente no android
  @id_midia INT,
  @imagem VARBINARY(MAX)
AS
BEGIN
  UPDATE Midia SET imagem = @imagem WHERE id_midia = @id_midia;
  SELECT 'OK' AS msg;
END
GO


-- Exemplares ??????????????
CREATE PROCEDURE sp_Exemplares
AS
BEGIN
  SELECT id_midia, titulo, autor, isbn, disponibilidade, genero, ano_publicacao
  FROM Midia
  ORDER BY titulo;
END
GO




--------------------------------------
-- EVENTOS (FÓRUM) / POSTS / DENÚNCIA
--------------------------------------



CREATE PROCEDURE sp_PostCriar
  @id_cliente INT,
  @id_forum   INT,
  @conteudo   VARCHAR(255)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente=@id_cliente AND status_conta='ativo')
  BEGIN SELECT 'Cliente inativo/ausente' AS msg; RETURN; END

  IF NOT EXISTS (SELECT 1 FROM Forum WHERE id_forum=@id_forum)
  BEGIN SELECT 'Fórum não encontrado' AS msg; RETURN; END

  INSERT INTO Mensagem (id_cliente, id_forum, conteudo, data_postagem, visibilidade)
  VALUES (@id_cliente, @id_forum, @conteudo, GETDATE(), 'publica');

  SELECT 'OK' AS msg;
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
  @motivo VARCHAR(255)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE id_funcionario=@id_funcionario AND status_conta='ativo')
  BEGIN
    SELECT 'Funcionario inválido' AS msg;
    RETURN;
  END

  IF NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem=@id_mensagem)
  BEGIN
    SELECT 'Mensagem não encontrada' AS msg;
    RETURN;
  END

  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente=@id_cliente)
  BEGIN
    SELECT 'Cliente não encontrado' AS msg;
    RETURN;
  END

  INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status_denuncia, acao_tomada)
  VALUES (@id_funcionario, @id_mensagem, @id_cliente, GETDATE(), @motivo, 'pendente', NULL);

  SELECT 'OK' AS msg;
END
GO
