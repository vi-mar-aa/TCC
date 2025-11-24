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
	username VARCHAR(40) NOT NULL,
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
    ano_publicacao VARCHAR(100),
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
	status_midia VARCHAR(20) DEFAULT 'publica',
    codigo_exemplar INT NOT NULL,
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_tpmidia) REFERENCES TipoMidia(id_tpmidia),
    CONSTRAINT chk_disponibilidade CHECK (disponibilidade IN ('disponível', 'emprestado')),
    CONSTRAINT chk_status_midia CHECK (status_midia IN ('publica', 'privada'))
);
GO


CREATE TABLE Reserva (
    id_reserva INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
    id_midia INT NOT NULL,
    data_reserva DATETIME NOT NULL default GETDATE(), 
    data_limite DATETIME NOT NULL,
    status_reserva VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia),
    CONSTRAINT chk_status_reserva CHECK (status_reserva IN ('ativa', 'expirada', 'cancelada', 'concluida'))
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
    limite_renovacoes INT DEFAULT 2,
	status_emprestimo VARCHAR(20) NOT NULL DEFAULT 'emprestado',
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_midia) REFERENCES Midia(id_midia),
    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva),
	CONSTRAINT chk_status_emprestimo CHECK (status_emprestimo IN ('atrasado','emprestado','renovado','devolvido'))
);
GO

CREATE TABLE Mensagem (
    id_mensagem INT PRIMARY KEY IDENTITY,
    id_cliente INT NOT NULL,
	titulo NVARCHAR(60) NOT NULL,
    conteudo NVARCHAR(255) NOT NULL,
    data_postagem DATETIME NOT NULL,
    visibilidade BIT DEFAULT 1 NOT NULL, -- 1 = publica, 0 = privada
	curtidas INT DEFAULT 0,
	id_pai INT, 
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);
GO

CREATE TABLE Denuncia (
    id_denuncia INT PRIMARY KEY IDENTITY,
    id_funcionario INT,
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
    titulo NVARCHAR(200) NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME NOT NULL,
    local_evento NVARCHAR(200) NOT NULL,
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
	data_indicacao DATETIME NOT NULL DEFAULT GETDATE(),
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
	limite_emprestimos INT  NOT NULL
);
GO

CREATE TRIGGER trg_Midia_AssignCodigo
ON Midia
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Midia (
        id_funcionario, id_tpmidia, titulo, sinopse, autor, editora, ano_publicacao,
        edicao, local_publicacao, numero_paginas, isbn, duracao, estudio, roteirista,
        disponibilidade, genero, imagem, codigo_exemplar
    )
    SELECT 
        i.id_funcionario, i.id_tpmidia, i.titulo, i.sinopse, i.autor, i.editora, i.ano_publicacao,
        i.edicao, i.local_publicacao, i.numero_paginas, i.isbn, i.duracao, i.estudio, i.roteirista,
        i.disponibilidade, i.genero, i.imagem,
        ISNULL((
            SELECT MAX(m.codigo_exemplar)
            FROM Midia m
            WHERE
              (
                (i.isbn IS NOT NULL AND i.isbn <> '' AND m.isbn = i.isbn) -- com ISBN
              )
              OR
              (
                (i.isbn IS NULL OR i.isbn = '')                           -- sem ISBN
                AND (m.isbn IS NULL OR m.isbn = '')
                AND m.titulo = i.titulo
                AND m.id_tpmidia = i.id_tpmidia
              )
        ),0) + 1 AS novo_codigo
    FROM inserted i;
END
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

INSERT INTO Cliente (nome, username, cpf, email, telefone, senha, status_conta) VALUES 
('Gabriel Gonçalves', 'gabsfofinha', '666.666.666-66', 'gabriel.goncalves@email.com', '11999990006', 'abc123', 'banido'),
('Luiggi Alexandre', 'luiggiale', '777.777.777-77', 'luiggi.alexandre@email.com', '11999990007', 'senha456', 'ativo'),
('Pedro Dias', 'pedrodiass', '888.888.888-88', 'pedro.dias@email.com', '11999990008', 'senha789', 'ativo'),
('Rikelme Souza', 'rik1000grau', '999.999.999-99', 'rikelme.souza@email.com', '11999990009', '123senha', 'ativo'),
('Cauê Gonçalves', 'cauezinGon', '000.000.000-00', 'caue.goncalves@email.com', '11999990010', 'xyz987', 'ativo');

INSERT INTO TipoMidia (nome_tipo) VALUES ('livros'), ('filmes'), ('revistas'), ('e-book');
GO

INSERT INTO Midia (id_funcionario, id_tpmidia, titulo, sinopse, autor, editora, ano_publicacao, edicao, local_publicacao, numero_paginas, isbn, duracao, estudio, roteirista, disponibilidade, genero) VALUES
(1, 1, 'Mar Morto', '', 'Jorge Amado', 'Companhia das Letras', '1936', '1ª', 'Salvador', 250, '9788535902773', NULL, NULL, NULL, 'disponível', 'Romance'),
(2, 1, 'Vidas Secas', '', 'Graciliano Ramos', 'Record', '1938', '3ª', 'Maceió', 200, '9788501042329', NULL, NULL, NULL, 'disponível', 'Drama'),
(3, 2, 'O Auto da Compadecida', '', 'Ariano Suassuna', NULL, '2000', NULL, NULL, NULL, NULL, '1h40min', 'Globo Filmes', 'Guel Arraes', 'emprestado', 'Comédia'),
(4, 3, 'Revista Superinteressante - Edição 402', '', NULL, 'Abril', '2022', NULL, 'São Paulo', 80, NULL, NULL, NULL, NULL, 'disponível', 'Ciência'),
(5, 4, '1984', '', 'George Orwell', 'Penguin', '1949', '2ª', 'Londres', 328, '9780141036144', NULL, NULL, NULL, 'emprestado', 'Ficção Cientí­fica');
GO

INSERT INTO Reserva (id_cliente, id_midia, data_reserva, data_limite, status_reserva) VALUES 
(2, 1, '2025-06-14T14:00:00', '2025-06-17T14:00:00', 'ativa'),
(3, 2, '2025-06-15T14:00:00', '2025-06-18T14:00:00', 'ativa'),
(4, 3, '2025-06-13T14:00:00', '2025-06-16T14:00:00', 'expirada'),
(5, 4, '2025-06-16T14:00:00', '2025-06-19T14:00:00', 'ativa'),
(2, 5, '2025-06-17T14:00:00', '2025-06-20T14:00:00', 'cancelada');
GO

INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes) VALUES 
(2, 1, 1, 1, '2025-06-14', '2025-06-21', 1),
(3, 2, 2, 2, '2025-06-15', '2025-06-22', 0),
(4, 3, 3, 3, '2025-06-13', '2025-06-20', 2),
(5, 4, 5, 5, '2025-06-17', '2025-06-24', 0),
(3, 5, 4, 4, '2025-06-16', '2025-06-23', 1);
GO

INSERT INTO Mensagem (id_cliente, titulo, conteudo, data_postagem) VALUES 
(2, '', 'Seria útimo adicionarem "Dom Casmurro" à coleção.', '2025-06-14T10:00:00'),
(3, '', 'Auto da Compadecida é uma obra-prima!', '2025-06-15T11:30:00'),
(4, '', 'Sugiro incluir "O Quinze" da Rachel de Queiroz.', '2025-06-16T12:45:00'),
(5, '', '"1984" deveria estar disponÃ­vel também em áudio.', '2025-06-17T09:20:00'),
(3, '', 'A edição da Superinteressante de maio estava muito boa.', '2025-06-18T08:00:00');
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

INSERT INTO Evento (titulo, data_inicio, data_fim, local_evento, id_funcionario) VALUES
('Clube do Livro - Jorge Amado', '2025-09-10T19:00:00', '2025-09-10T21:00:00', 'Sala de leitura 1', 1),
('Exibição de Filme - O Auto da Compadecida', '2025-09-15T20:00:00', '2025-09-15T22:00:00', 'Auditório Principal', 2),
('Palestra: A Literatura Nordestina', '2025-09-20T18:00:00', '2025-09-20T20:00:00', 'Sala 2', 3),
('Semana de Ciência e Conhecimento', '2025-09-25T09:00:00', '2025-09-25T17:00:00', 'Auditório B', 4),
('Encontro de e-Books - Discussões Modernas', '2025-10-02T17:00:00', '2025-10-02T19:00:00', 'Online', 5);
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

INSERT INTO Parametros (multa_dia, prazo_devolucao_dias, limite_emprestimos) VALUES 
(2.00, 14, 3);
GO

UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\MarMorto-JorgeAmado.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 1;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\VidasSecas-GracilianoRamos.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 2;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\AutoDaCompadecida-ArianoSuassuna.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 3;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\\SuperInteressante_402.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 4;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\1984-GeorgeOrwell.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 5;
GO
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 1;
GO
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 2;
GO
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 3;
GO
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 4;
GO
UPDATE Cliente
SET imagem_perfil = (
    SELECT * FROM OPENROWSET(BULK N'C:\Users\vitor\OneDrive\Documentos\SQL Server Management Studio\imagensTCC\bressan.jpg', SINGLE_BLOB) AS img
)
WHERE id_cliente = 5;

GO
-- Midias
INSERT INTO Midia (id_funcionario, id_tpmidia, titulo, sinopse, autor, editora, ano_publicacao, disponibilidade, genero) VALUES
(1, 1, 'Dom Casmurro', 'Clássico romance psicológico.', 'Machado de Assis', 'Principis', '1899', 'disponível', 'Romance'),
(2, 1, 'Amor nos Tempos do Cólera', 'História de amor marcada pelo tempo.', 'Gabriel García Márquez', 'Record', '1985', 'disponível', 'Romance'),
(3, 1, 'Capitães da Areia', 'Romance social baiano.', 'Jorge Amado', 'Companhia das Letras', '1937', 'disponível', 'Romance'),
(4, 1, 'Orgulho e Preconceito', 'Obra de Jane Austen.', 'Jane Austen', 'Penguin', '1813', 'disponível', 'Romance'),
(5, 1, 'Grande Sertão: Veredas', 'Obra-prima de Guimarães Rosa.', 'Guimarães Rosa', 'Nova Fronteira', '1956', 'disponível', 'Romance'),
(1, 1, 'A Moreninha', 'Primeira novela romântica brasileira.', 'Joaquim Manuel de Macedo', 'Ática', '1844', 'disponível', 'Novela'),
(2, 1, 'Senhora', 'Clássico romântico.', 'José de Alencar', 'Principis', '1875', 'disponível', 'Novela'),
(3, 1, 'Iracema', 'Símbolo do romantismo indianista.', 'José de Alencar', 'Saraiva', '1865', 'disponível', 'Novela'),
(4, 1, 'Lucíola', 'Obra urbana do romantismo.', 'José de Alencar', 'Ática', '1862', 'disponível', 'Novela'),
(5, 1, 'O Mulato', 'Primeira obra naturalista brasileira.', 'Aluísio Azevedo', 'Principis', '1881', 'disponível', 'Novela'),
(1, 1, 'A Cartomante', 'Clássico conto realista.', 'Machado de Assis', 'L&PM', '1884', 'disponível', 'Conto'),
(2, 1, 'O Alienista', 'Sátira social.', 'Machado de Assis', 'Companhia das Letras', '1882', 'disponível', 'Conto'),
(3, 1, 'O Espelho', 'Reflexão sobre identidade.', 'Machado de Assis', 'Principis', '1882', 'disponível', 'Conto'),
(4, 1, 'O Capote', 'Clássico russo.', 'Nikolai Gógol', 'Penguin', '1842', 'disponível', 'Conto'),
(5, 1, 'O Gato Preto', 'Terror psicológico.', 'Edgar Allan Poe', 'Darkside', '1843', 'disponível', 'Conto'),
(1, 1, 'A Cigarra e a Formiga', 'Clássica fábula.', 'La Fontaine', 'Companhia das Letrinhas', '1668', 'disponível', 'Fábula'),
(2, 1, 'A Raposa e as Uvas', 'Fábula sobre desejo.', 'Esopo', 'Ática', '500', 'disponível', 'Fábula'),
(3, 1, 'O Leão e o Rato', 'Fábula sobre gratidão.', 'Esopo', 'Saraiva', '500', 'disponível', 'Fábula'),
(4, 1, 'A Lebre e a Tartaruga', 'Persistência vence.', 'Esopo', 'Ática', '500', 'disponível', 'Fábula'),
(5, 1, 'Fábulas de Esopo', 'Coletânea clássica.', 'Esopo', 'Domínio Público', '2001', 'disponível', 'Fábula'),
(1, 1, 'O Senhor dos Anéis', 'Trilogia épica de fantasia.', 'J.R.R. Tolkien', 'Martins Fontes', '1954', 'disponível', 'Fantasia'),
(2, 1, 'Harry Potter e a Pedra Filosofal', 'Primeiro livro da saga.', 'J.K. Rowling', 'Rocco', '1997', 'disponível', 'Fantasia'),
(3, 1, 'O Hobbit', 'Aventura fantástica.', 'J.R.R. Tolkien', 'HarperCollins', '1937', 'disponível', 'Fantasia'),
(4, 1, 'As Crônicas de Nárnia', 'Mundo mágico de Nárnia.', 'C.S. Lewis', 'HarperCollins', '1950', 'disponível', 'Fantasia'),
(5, 1, 'Eragon', 'Dragões e magia.', 'Christopher Paolini', 'Rocco', '2003', 'disponível', 'Fantasia'),
(1, 1, 'Fundação', 'Império galáctico em colapso.', 'Isaac Asimov', 'Aleph', '1951', 'disponível', 'Ficção Científica'),
(2, 1, 'Neuromancer', 'Cyberpunk clássico.', 'William Gibson', 'Aleph', '1984', 'disponível', 'Ficção Científica'),
(3, 1, 'Eu, Robô', 'Contos sobre robótica.', 'Isaac Asimov', 'Aleph', '1950', 'disponível', 'Ficção Científica'),
(4, 1, '2001: Uma Odisseia no Espaço', 'Clássico de Arthur C. Clarke.', 'Arthur C. Clarke', 'Aleph', '1968', 'disponível', 'Ficção Científica'),
(5, 1, 'Duna', 'Planeta deserto e intrigas políticas.', 'Frank Herbert', 'Aleph', '1965', 'disponível', 'Ficção Científica'),
(1, 1, '1984', 'Sociedade vigiada pelo Grande Irmão.', 'George Orwell', 'Companhia Editora Nacional', '1949', 'disponível', 'Distopia'),
(2, 1, 'Admirável Mundo Novo', 'Sociedade futurista controlada.', 'Aldous Huxley', 'Globo', '1932', 'disponível', 'Distopia'),
(3, 1, 'Fahrenheit 451', 'Livros proibidos.', 'Ray Bradbury', 'Biblioteca Azul', '1953', 'disponível', 'Distopia'),
(4, 1, 'Jogos Vorazes', 'Competição mortal televisiva.', 'Suzanne Collins', 'Rocco', '2008', 'disponível', 'Distopia'),
(5, 1, 'Laranja Mecânica', 'Juventude violenta e controle social.', 'Anthony Burgess', 'Aleph', '1962', 'disponível', 'Distopia'),
(1, 1, 'Utopia', 'Sociedade perfeita idealizada.', 'Thomas More', 'Principis', '1516', 'disponível', 'Utopia'),
(2, 1, 'A Cidade do Sol', 'Sociedade justa e ideal.', 'Tommaso Campanella', 'Martins Fontes', '1602', 'disponível', 'Utopia'),
(3, 1, 'Looking Backward', 'Visão utópica do futuro.', 'Edward Bellamy', 'Penguin', '1888', 'disponível', 'Utopia'),
(4, 1, 'Walden Two', 'Comunidade utópica behaviorista.', 'B.F. Skinner', 'Macmillan', '1948', 'disponível', 'Utopia'),
(5, 1, 'News from Nowhere', 'Visão utópica socialista.', 'William Morris', 'Routledge', '1890', 'disponível', 'Utopia'),
(1, 1, 'Drácula', 'Clássico de vampiro.', 'Bram Stoker', 'Principis', '1897', 'disponível', 'Terror'),
(2, 1, 'Frankenstein', 'Criação que ganha vida.', 'Mary Shelley', 'Penguin', '1818', 'disponível', 'Terror'),
(3, 1, 'O Iluminado', 'Hotel amaldiçoado.', 'Stephen King', 'Suma', '1977', 'disponível', 'Terror'),
(4, 1, 'It: A Coisa', 'Força maligna em Derry.', 'Stephen King', 'Suma', '1986', 'disponível', 'Terror'),
(5, 1, 'O Exorcista', 'Possessão demoníaca.', 'William Peter Blatty', 'Harper & Row', '1971', 'disponível', 'Terror'),
(1, 1, 'O Silêncio dos Inocentes', 'Serial killer Hannibal Lecter.', 'Thomas Harris', 'Record', '1988', 'disponível', 'Suspense'),
(2, 1, 'Garota Exemplar', 'Desaparecimento misterioso.', 'Gillian Flynn', 'Intrínseca', '2012', 'disponível', 'Suspense'),
(3, 1, 'A Garota no Trem', 'Suspense psicológico.', 'Paula Hawkins', 'Record', '2015', 'disponível', 'Suspense'),
(4, 1, 'O Colecionador', 'Homem sequestra jovem.', 'John Fowles', 'Companhia das Letras', '1963', 'disponível', 'Suspense'),
(5, 1, 'Antes de Dormir', 'Mulher sem memória diária.', 'S.J. Watson', 'Record', '2011', 'disponível', 'Suspense'),
(1, 1, 'Sherlock Holmes: Um Estudo em Vermelho', 'Primeira aventura de Holmes e Watson.', 'Arthur Conan Doyle', 'Principis', '1887', 'disponível', 'Policial'),
(2, 1, 'Assassinato no Expresso do Oriente', 'Mistério resolvido por Poirot.', 'Agatha Christie', 'HarperCollins', '1934', 'disponível', 'Policial'),
(3, 1, 'O Falcão Maltês', 'Caso noir clássico.', 'Dashiell Hammett', 'Companhia das Letras', '1930', 'disponível', 'Policial'),
(4, 1, 'Os Homens que Não Amavam as Mulheres', 'Investigação jornalística e policial.', 'Stieg Larsson', 'Companhia das Letras', '2005', 'disponível', 'Policial'),
(5, 1, 'A Sangue Frio', 'Investigação de assassinato real.', 'Truman Capote', 'Random House', '1966', 'disponível', 'Policial'),
(1, 1, 'A Ilha do Tesouro', 'Caça ao tesouro pirata.', 'Robert Louis Stevenson', 'Penguin', '1883', 'disponível', 'Aventura'),
(2, 1, 'As Aventuras de Tom Sawyer', 'Juventude travessa às margens do Mississippi.', 'Mark Twain', 'Penguin', '1876', 'disponível', 'Aventura'),
(3, 1, 'Robinson Crusoé', 'Náufrago em ilha deserta.', 'Daniel Defoe', 'Penguin', '1719', 'disponível', 'Aventura'),
(4, 1, 'Os Três Mosqueteiros', 'Clássico de capa e espada.', 'Alexandre Dumas', 'Martins Fontes', '1844', 'disponível', 'Aventura'),
(5, 1, 'Viagem ao Centro da Terra', 'Expedição subterrânea fantástica.', 'Júlio Verne', 'Principis', '1864', 'disponível', 'Aventura'),
(1, 1, 'A Última Lição', 'Reflexões de vida.', 'Randy Pausch', 'Editora Agir', '2008', 'disponível', 'Biografia'),
(2, 1, 'Longa Caminhada até a Liberdade', 'Autobiografia de Nelson Mandela.', 'Nelson Mandela', 'Companhia das Letras', '1994', 'disponível', 'Biografia'),
(3, 1, 'Minha Vida em Dois Mundos', 'Relato de Chico Xavier.', 'Chico Xavier', 'FEB', '1974', 'disponível', 'Biografia'),
(4, 1, 'Steve Jobs', 'Biografia autorizada.', 'Walter Isaacson', 'Companhia das Letras', '2011', 'disponível', 'Biografia'),
(5, 1, 'Eu Sou Malala', 'História de coragem e educação.', 'Malala Yousafzai', 'Companhia das Letras', '2013', 'disponível', 'Biografia'),
(1, 1, 'O Diário de Anne Frank', 'Relato do Holocausto.', 'Anne Frank', 'Record', '1947', 'disponível', 'Diário'),
(2, 1, 'Diário de um Banana', 'Crônicas de um jovem atrapalhado.', 'Jeff Kinney', 'V&R', '2007', 'disponível', 'Diário'),
(3, 1, 'Querido Diário Otário', 'Série infantojuvenil de humor.', 'Jim Benton', 'Fundamento', '2004', 'disponível', 'Diário'),
(4, 1, 'Diário de Zlata', 'Vivências da guerra na Bósnia.', 'Zlata Filipovic', 'Companhia das Letras', '1993', 'disponível', 'Diário'),
(5, 1, 'Diário Íntimo', 'Reflexões e angústias pessoais.', 'Lima Barreto', 'Penguin', '1903', 'disponível', 'Diário'),
(1, 1, 'A Interpretação dos Sonhos', 'Obra seminal de Freud.', 'Sigmund Freud', 'Imago', '1900', 'disponível', 'Ensaio'),
(2, 1, 'O Segundo Sexo', 'Fundamento do feminismo.', 'Simone de Beauvoir', 'Nova Fronteira', '1949', 'disponível', 'Ensaio'),
(3, 1, 'A República', 'Discussão sobre política e justiça.', 'Platão', 'Principis', '380 BC', 'disponível', 'Ensaio'),
(4, 1, 'A Desobediência Civil', 'Reflexão sobre resistência política.', 'Henry David Thoreau', 'Principis', '1849', 'disponível', 'Ensaio'),
(5, 1, 'Meditações', 'Pensamentos do imperador romano.', 'Marco Aurélio', 'Penguin', '180', 'disponível', 'Ensaio'),
(1, 1, 'A Origem das Espécies - Artigo Acadêmico', 'Resumo científico das ideias de Darwin.', 'Charles Darwin', 'Nature', '1859', 'disponível', 'Artigo'),
(2, 1, 'Computing Machinery and Intelligence', 'Artigo sobre inteligência artificial.', 'Alan Turing', 'Mind Journal', '1950', 'disponível', 'Artigo'),
(3, 1, 'A Teoria da Relatividade Restrita', 'Primeira formulação por Einstein.', 'Albert Einstein', 'Annalen der Physik', '1905', 'disponível', 'Artigo'),
(4, 1, 'O Que é Literatura?', 'Reflexão existencial.', 'Jean-Paul Sartre', 'Critique', '1947', 'disponível', 'Artigo'),
(5, 1, 'A Ética Protestante e o Espírito do Capitalismo', 'Artigo precursor de Weber.', 'Max Weber', 'Archiv für Sozialwissenschaft', '1904', 'disponível', 'Artigo'),
(1, 1, 'Para Gostar de Ler - Crônicas', 'Coletânea brasileira.', 'Luis Fernando Verissimo', 'Ática', '1981', 'disponível', 'Crônica'),
(2, 1, 'A Vida que Ninguém Vê', 'Crônicas cotidianas.', 'Eliane Brum', 'Arquipélago', '2006', 'disponível', 'Crônica'),
(3, 1, 'Comédias da Vida Privada', 'Humor e ironia do cotidiano.', 'Luis Fernando Verissimo', 'Objetiva', '1994', 'disponível', 'Crônica'),
(4, 1, 'Cem Crônicas Escolhidas', 'Coletânea de Rubem Braga.', 'Rubem Braga', 'Record', '1992', 'disponível', 'Crônica'),
(5, 1, 'Crônicas para Ler na Escola', 'Seleção de textos para jovens.', 'Carlos Drummond de Andrade', 'Record', '2000', 'disponível', 'Crônica'),
(1, 1, 'Rota 66', 'História da violência policial no Brasil.', 'Caco Barcellos', 'Companhia das Letras', '1992', 'disponível', 'Reportagem'),
(2, 1, 'Holocausto Brasileiro', 'Abusos em Barbacena.', 'Daniela Arbex', 'Geração Editorial', '2013', 'disponível', 'Reportagem'),
(3, 1, 'Abusado', 'História do tráfico no Rio.', 'Caco Barcellos', 'Companhia das Letras', '2003', 'disponível', 'Reportagem'),
(4, 1, 'A Ditadura Envergonhada', 'Investigação jornalística.', 'Elio Gaspari', 'Companhia das Letras', '2002', 'disponível', 'Reportagem'),
(5, 1, 'Os Sertões', 'Relato de Canudos.', 'Euclides da Cunha', 'Principis', '1902', 'disponível', 'Reportagem'),
(1, 1, 'Revista National Geographic - Edição Amazônia', 'Exploração científica e cultural.', 'Vários Autores', 'National Geographic Society', '2020', 'disponível', 'Revista'),
(2, 1, 'Revista Superinteressante - Inteligência Artificial', 'Especial sobre IA.', 'Editora Abril', 'Abril', '2019', 'disponível', 'Revista'),
(3, 1, 'Revista Piauí - Edição Política', 'Análises contemporâneas.', 'Vários Autores', 'Piauí', '2018', 'disponível', 'Revista'),
(4, 1, 'Revista Scientific American - Cosmologia', 'Avanços sobre o universo.', 'Vários Autores', 'Scientific American', '2021', 'disponível', 'Revista'),
(5, 1, 'Revista Quatro Rodas - Carros Elétricos', 'Tendências da indústria automotiva.', 'Editora Abril', 'Abril', '2022', 'disponível', 'Revista'),
(1, 1, 'Jornal Folha de S. Paulo - Edição de 1985', 'Diretas Já e política nacional.', 'Folha de S. Paulo', 'Folha', '1985', 'disponível', 'Periódico'),
(2, 1, 'The New York Times - 11/09/2001', 'Cobertura do atentado.', 'NYT', 'NYT', '2001', 'disponível', 'Periódico'),
(3, 1, 'Le Monde - Maio de 1968', 'Movimentos estudantis franceses.', 'Le Monde', 'Le Monde', '1968', 'disponível', 'Periódico'),
(4, 1, 'The Guardian - Brexit Referendum', 'Saída do Reino Unido da UE.', 'The Guardian', 'Guardian', '2016', 'disponível', 'Periódico'),
(5, 1, 'Estadão - Copa do Mundo 1970', 'Cobertura da seleção tricampeã.', 'O Estado de S. Paulo', 'Estadão', '1970', 'disponível', 'Periódico'),
(1, 1, 'Os Lusíadas', 'Poema épico sobre as navegações.', 'Luís de Camões', 'Principis', '1572', 'disponível', 'Poesia'),
(2, 1, 'Cantos', 'Obra poética simbolista.', 'Ezra Pound', 'Penguin', '1925', 'disponível', 'Poesia'),
(3, 1, 'A Rosa do Povo', 'Poesia engajada brasileira.', 'Carlos Drummond de Andrade', 'Record', '1945', 'disponível', 'Poesia'),
(4, 1, 'Folhas de Relva', 'Poemas de liberdade.', 'Walt Whitman', 'Penguin', '1855', 'disponível', 'Poesia'),
(5, 1, 'Alguma Poesia', 'Obra inicial de Drummond.', 'Carlos Drummond de Andrade', 'Companhia das Letras', '1930', 'disponível', 'Poesia'),
(1, 1, 'O Auto da Compadecida', 'Peça cômica popular.', 'Ariano Suassuna', 'Nova Fronteira', '1955', 'disponível', 'Comédia'),
(2, 1, 'As Rãs', 'Comédia grega clássica.', 'Aristófanes', 'Penguin', '405 BC', 'disponível', 'Comédia'),
(3, 1, 'A Megera Domada', 'Comédia romântica.', 'William Shakespeare', 'Principis', '1592', 'disponível', 'Comédia'),
(4, 1, 'As Alegres Comadres de Windsor', 'Humor popular shakespeariano.', 'William Shakespeare', 'Penguin', '1602', 'disponível', 'Comédia'),
(5, 1, 'O Doente Imaginário', 'Sátira social.', 'Molière', 'Penguin', '1673', 'disponível', 'Comédia'),
(1, 1, 'Uma Breve História do Tempo', 'Explicação do universo.', 'Stephen Hawking', 'Intrínseca', '1988', 'disponível', 'Ciência'),
(2, 1, 'O Gene Egoísta', 'Evolução sob nova ótica.', 'Richard Dawkins', 'Companhia das Letras', '1976', 'disponível', 'Ciência'),
(3, 1, 'Cosmos', 'Exploração do universo.', 'Carl Sagan', 'Companhia das Letras', '1980', 'disponível', 'Ciência'),
(4, 1, 'Princípios Matemáticos da Filosofia Natural', 'Obra de Newton.', 'Isaac Newton', 'Principis', '1687', 'disponível', 'Ciência'),
(5, 1, 'A Estrutura das Revoluções Científicas', 'Mudanças de paradigmas.', 'Thomas Kuhn', 'Perspectiva', '1962', 'disponível', 'Ciência'),
(1, 1, 'Hamlet', 'Tragédia shakespeariana.', 'William Shakespeare', 'Penguin', '1603', 'disponível', 'Drama'),
(2, 1, 'Romeu e Julieta', 'Drama romântico clássico.', 'William Shakespeare', 'Principis', '1597', 'disponível', 'Drama'),
(3, 1, 'Édipo Rei', 'Tragédia grega.', 'Sófocles', 'Penguin', '429 BC', 'disponível', 'Drama'),
(4, 1, 'Esperando Godot', 'Peça do absurdo.', 'Samuel Beckett', 'Companhia das Letras', '1952', 'disponível', 'Drama'),
(5, 1, 'Vestido de Noiva', 'Marco do teatro moderno brasileiro.', 'Nelson Rodrigues', 'Nova Fronteira', '1943', 'disponível', 'Drama'),
(1, 1, 'O Pequeno Príncipe', 'Fábula filosófica moderna.', 'Antoine de Saint-Exupéry', 'Agir', '1943', 'disponível', 'Outros'),
(2, 1, 'Sapiens: Uma Breve História da Humanidade', 'Análise da evolução humana.', 'Yuval Noah Harari', 'Companhia das Letras', '2011', 'disponível', 'Outros'),
(3, 1, '1984 - Edição Ilustrada', 'Nova edição do clássico.', 'George Orwell', 'Companhia das Letras', '2016', 'disponível', 'Outros'),
(4, 1, 'A Arte da Guerra', 'Estratégia e filosofia.', 'Sun Tzu', 'Principis', '500 BC', 'disponível', 'Outros'),
(5, 1, 'O Livro dos Espíritos', 'Obra básica do espiritismo.', 'Allan Kardec', 'FEB', '1857', 'disponível', 'Outros');
go

-- Reservas adicionais
INSERT INTO Reserva (id_cliente, id_midia, data_reserva, data_limite, status_reserva) VALUES
(2, 6, GETDATE(), DATEADD(DAY, 3, GETDATE()), 'ativa'),
(3, 7, GETDATE(), DATEADD(DAY, 3, GETDATE()), 'ativa'),
(4, 8, GETDATE(), DATEADD(DAY, 3, GETDATE()), 'ativa'),
(5, 9, GETDATE(), DATEADD(DAY, 3, GETDATE()), 'ativa'),
(2, 10, GETDATE(), DATEADD(DAY, 3, GETDATE()), 'ativa');
go
-- Emprestimos adicionais
INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, data_emprestimo, data_devolucao) VALUES
(2, 1, 6, GETDATE(), DATEADD(DAY, 7, GETDATE())),
(3, 2, 7, GETDATE(), DATEADD(DAY, 7, GETDATE())),
(4, 3, 8, GETDATE(), DATEADD(DAY, 7, GETDATE())),
(5, 4, 9, GETDATE(), DATEADD(DAY, 7, GETDATE())),
(3, 5, 10, GETDATE(), DATEADD(DAY, 7, GETDATE()));
go
-- Mensagens extras
INSERT INTO Mensagem (id_cliente, titulo, conteudo, data_postagem) VALUES
(2, 'Sugestão', 'Gostaria de ver mais títulos de fantasia.', GETDATE()),
(3, 'Comentário', 'Excelente seleção de revistas científicas!', GETDATE()),
(1, 'Comentário', 'Achei esse livro muito bom!', GETDATE()),
(2, 'Comentário', 'Prefiro a adaptação do filme.', GETDATE()),
(3, 'Dúvida', 'Alguém recomenda outra obra do mesmo autor?', GETDATE());
go
-- Denúncias extras
INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status_denuncia) VALUES
(1, 1, 2, '2025-09-01', 'Conteúdo inadequado', 'pendente'),
(2, 2, 3, '2025-09-02', 'Spam', 'resolvida'),
(3, 3, 4, '2025-09-03', 'Fora do tópico', 'pendente'),
(4, 4, 5, '2025-09-04', 'Duplicado', 'resolvida'),
(5, 5, 2, '2025-09-05', 'Linguagem ofensiva', 'pendente'),
(1, 2, 3, '2025-09-06', 'Conteúdo inadequado', 'resolvida'),
(2, 3, 4, '2025-09-07', 'Linguagem ofensiva', 'pendente'),
(3, 4, 5, '2025-09-08', 'Spam', 'resolvida'),
(4, 5, 2, '2025-09-09', 'Conteúdo inadequado', 'pendente'),
(5, 1, 3, '2025-09-10', 'Duplicado', 'resolvida');
go
-- Eventos extras
INSERT INTO Evento (titulo, data_inicio, data_fim, local_evento, id_funcionario) VALUES
('Clube do Livro - Fantasia', '2025-09-15T18:00:00', '2025-09-15T20:00:00', 'Sala 1', 1),
('Exibição de Filme - Terror', '2025-09-16T19:00:00', '2025-09-16T21:00:00', 'Auditório Principal', 2),
('Palestra - Literatura Contemporânea', '2025-09-17T17:00:00', '2025-09-17T19:00:00', 'Sala 2', 3),
('Workshop de Escrita Criativa', '2025-09-18T14:00:00', '2025-09-18T16:00:00', 'Sala 3', 4),
('Debate: Ficção Científica', '2025-09-19T18:00:00', '2025-09-19T20:00:00', 'Online', 5),
('Oficina de Poesia', '2025-09-20T10:00:00', '2025-09-20T12:00:00', 'Sala 4', 1),
('Encontro de Autores', '2025-09-21T15:00:00', '2025-09-21T17:00:00', 'Auditório B', 2),
('Seminário de História', '2025-09-22T09:00:00', '2025-09-22T11:00:00', 'Sala 5', 3),
('Mesa Redonda - Jornalismo', '2025-09-23T16:00:00', '2025-09-23T18:00:00', 'Online', 4),
('Clube de Leitura Infantil', '2025-09-24T10:00:00', '2025-09-24T12:00:00', 'Sala 6', 5);
go
-- Indicações extras
INSERT INTO Indicacao (id_cliente, titulo_ind, autor_ind) VALUES
(2, 'O Pequeno Príncipe', 'Antoine de Saint-Exupéry'),
(3, '1984', 'George Orwell'),
(4, 'Dom Casmurro', 'Machado de Assis'),
(5, 'Vidas Secas', 'Graciliano Ramos'),
(2, 'A Revolução dos Bichos', 'George Orwell'),
(3, 'O Auto da Compadecida', 'Ariano Suassuna'),
(4, 'Capitães da Areia', 'Jorge Amado'),
(5, 'Memórias Póstumas de Brás Cubas', 'Machado de Assis'),
(2, 'Grande Sertão: Veredas', 'João Guimarães Rosa'),
(3, 'O Quinze', 'Rachel de Queiroz');
go
-- Notificações extras
INSERT INTO Notificacao (id_cliente, titulo, mensagem) VALUES
(2, 'Lembrete de Devolução', 'Você tem um livro para devolver até 25/09.'),
(3, 'Reserva Ativa', 'Sua reserva de "1984" está disponível até 26/09.'),
(4, 'Evento Hoje', 'Não esqueça: Palestra de Literatura às 17h.'),
(5, 'Nova Denúncia', 'Uma denúncia foi atribuída para sua análise.'),
(2, 'Indicação Aceita', 'Sua indicação de "O Pequeno Príncipe" foi aprovada.'),
(3, 'Renovação', 'Seu empréstimo de "1984" foi renovado por mais 7 dias.'),
(4, 'Reserva Expirada', 'Sua reserva de "Dom Casmurro" expirou.'),
(5, 'Mensagem Recebida', 'Você recebeu uma nova mensagem no fórum.'),
(2, 'Evento Cancelado', 'O evento "Clube do Livro" foi cancelado.'),
(3, 'Notificação Especial', 'Confira as novidades da semana na biblioteca.');
go
-- Funcionarios extras
INSERT INTO Funcionario (id_cargo, nome, cpf, email, telefone, senha, status_conta) VALUES
(1, 'Carlos Henrique', '666.666.666-66', 'carlos.henrique@email.com', '11999990011', 'senha123', 'ativo'),
(2, 'Fernanda Lima', '777.777.777-77', 'fernanda.lima@email.com', '11999990012', 'senha123', 'ativo'),
(1, 'Roberto Soares', '888.888.888-88', 'roberto.soares@email.com', '11999990013', 'senha123', 'ativo'),
(2, 'Patricia Gomes', '999.999.999-99', 'patricia.gomes@email.com', '11999990014', 'senha123', 'ativo'),
(1, 'Thiago Almeida', '000.000.000-01', 'thiago.almeida@email.com', '11999990015', 'senha123', 'ativo');
go
-- Funcionarios extras
INSERT INTO Cliente (nome, username, cpf, email, telefone, senha, status_conta) VALUES
('Ana Clara', 'anaclara12', '111.111.111-12', 'ana.clara@email.com', '11999990016', 'senha123', 'ativo'),
('Bruno Santos', 'brunos', '222.222.222-23', 'bruno.santos@email.com', '11999990017', 'senha123', 'ativo'),
('Camila Ribeiro', 'camilar', '333.333.333-34', 'camila.ribeiro@email.com', '11999990018', 'senha123', 'ativo'),
('Diego Martins', 'diegom', '444.444.444-45', 'diego.martins@email.com', '11999990019', 'senha123', 'ativo'),
('Elisa Fernandes', 'elisaf', '555.555.555-56', 'elisa.fernandes@email.com', '11999990020', 'senha123', 'ativo');



/*
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\MarMorto-JorgeAmado.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 1;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\VidasSecas-GracilianoRamos.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 2;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\AutoDaCompadecida-ArianoSuassuna.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 3;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\SuperInteressante_402.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 4;
GO
UPDATE Midia
SET imagem = (
    SELECT * FROM OPENROWSET(BULK N'F:\tcc\imagens\1984-GeorgeOrwell.jpg', SINGLE_BLOB) AS img
)
WHERE id_midia = 5;
*/

/*Select * from Midia

SELECT id_midia, DATALENGTH(imagem) AS tamanho_em_bytes
FROM Midia
WHERE id_midia = 2;

SELECT imagem FROM Midia WHERE id_midia = 1

select * from Funcionario --ADICIONAR
select * from Cliente --ADICIONAR
select * from Midia
select * from Reserva
select * from Emprestimo
select * from Mensagem
select * from Denuncia
select * from Evento
select * from Indicacao 
select * from Notificacao
*/
