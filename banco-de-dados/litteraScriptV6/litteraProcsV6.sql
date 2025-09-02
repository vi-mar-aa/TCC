-- !!!!!!!!!!!!!!!! ANDROID !!!!!!!!!!!!!!!!!!!!!!!


-- !!!MAIN!!!

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
    ORDER BY qtde_emprestimos DESC, titulo;
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


CREATE PROCEDURE sp_HistoricoEmprestimosPagosCliente -- qual a diferença entre essa e sp_HistoricoEmprestimosCliente
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END

  SELECT
    e.id_emprestimo,
    e.id_midia,
    m.titulo,
    m.autor,
    m.ano_publicacao,
    e.data_emprestimo,
    e.data_devolucao,
    e.status_pagamento
  FROM Emprestimo e
  JOIN Midia m   ON m.id_midia = e.id_midia
  JOIN Cliente c ON c.id_cliente = e.id_cliente
  WHERE c.email = @email
    AND e.status_pagamento = 'pago'
  ORDER BY e.data_devolucao DESC, e.id_emprestimo DESC;
END
GO



CREATE PROCEDURE sp_EmprestimosClienteListar
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN 
    SELECT 'Cliente não encontrado' AS msg; 
    RETURN; 
  END

  DECLARE @hoje DATE = CAST(GETDATE() AS DATE);
  DECLARE @multa_dia DECIMAL(10,2);

  -- pega valor da tabela Parametros (assumindo que só tem 1 linha configurada)
  SELECT TOP 1 @multa_dia = multa_dia FROM Parametros ORDER BY id_parametros DESC;

  SELECT 
    e.id_emprestimo,
    e.data_emprestimo,
    e.data_devolucao,
    e.limite_renovacoes,
    m.id_midia, m.titulo, m.autor, m.ano_publicacao,
    CASE WHEN @hoje > e.data_devolucao 
         THEN DATEDIFF(DAY, e.data_devolucao, @hoje) ELSE 0 END AS dias_atraso,
    CASE WHEN @hoje > e.data_devolucao 
         THEN DATEDIFF(DAY, e.data_devolucao, @hoje) * @multa_dia ELSE 0 END AS multa,
    CASE WHEN @hoje <= e.data_devolucao AND e.limite_renovacoes > 0 
         THEN 1 ELSE 0 END AS pode_renovar
  FROM Emprestimo e
  JOIN Midia m   ON m.id_midia = e.id_midia
  JOIN Cliente c ON c.id_cliente = e.id_cliente
  WHERE c.email = @email
  ORDER BY e.data_devolucao ASC;
END
GO
--exec sp_EmprestimosClienteListar @email = 'luiggi.alexandre@email.com'

CREATE PROCEDURE sp_ReservasClienteListar
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END

  DECLARE @hoje DATE = CAST(GETDATE() AS DATE);

  SELECT 
    r.id_reserva, r.data_reserva, r.data_limite, r.status_reserva,
    m.id_midia, m.titulo, m.autor, m.ano_publicacao, m.imagem,
    DATEDIFF(DAY, @hoje, r.data_limite) AS dias_restantes
  FROM Reserva r
  JOIN Cliente c ON c.id_cliente = r.id_cliente
  JOIN Midia m   ON m.id_midia   = r.id_midia
  WHERE c.email = @email
    AND r.status_reserva = 'ativa'
    AND r.data_limite >= @hoje
  ORDER BY r.data_limite ASC;
END
GO
--exec sp_ReservasClienteListar @email = 'pedro.dias@email.com'
--select * from Reserva


CREATE PROCEDURE sp_HistoricoEmprestimosCliente
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END

  SELECT 
    e.id_emprestimo,
    e.data_emprestimo,
    e.data_devolucao,
    m.id_midia,
    m.titulo,
    m.autor,
    m.ano_publicacao,
    m.imagem
  FROM Emprestimo e
  JOIN Midia m   ON m.id_midia = e.id_midia
  JOIN Cliente c ON c.id_cliente = e.id_cliente
  WHERE c.email=@email
    AND e.data_devolucao < CAST(GETDATE() AS DATE)
  ORDER BY e.data_devolucao DESC;
END
GO

-- !!!NOTIFICAÇÕES/ALERTAS !!!

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
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END

  SELECT 
    ld.id_midia,
    ld.data_adicionada,
    m.titulo,
    m.autor,
    m.ano_publicacao,
    m.imagem
  FROM ListaDeDesejos ld
  JOIN Cliente c ON c.id_cliente = ld.id_cliente
  JOIN Midia   m ON m.id_midia   = ld.id_midia
  WHERE c.email = @email
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

CREATE PROCEDURE sp_ListaDesejosAdicionar -- colocar email como parametro, depois procurar o id cliente desse email e ai sim usar o id para colocar p regi
  @id_cliente INT,
  @id_midia   INT
AS
BEGIN
  IF EXISTS (
    SELECT 1 FROM ListaDeDesejos
    WHERE id_cliente = @id_cliente AND id_midia = @id_midia
  )
  BEGIN
    SELECT 'Já existe na lista' AS msg;
    RETURN;
  END

  INSERT INTO ListaDeDesejos (id_cliente, id_midia)
  VALUES (@id_cliente, @id_midia);

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

CREATE PROCEDURE sp_AcervoMidiasTodasInfosComExemplares
AS
BEGIN
  SELECT
    m.id_midia,
    m.id_funcionario,
    m.id_tpmidia,
    m.titulo,
    m.sinopse,
    m.autor,
    m.editora,
    m.ano_publicacao,
    m.edicao,
    m.local_publicacao,
    m.numero_paginas,
    m.isbn,
    m.duracao,
    m.estudio,
    m.roteirista,
    m.disponibilidade,
    m.genero,
    m.imagem,
    tm.nome_tipo,
    (
      SELECT COUNT(*)
      FROM Midia x
      WHERE (CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN x.isbn ELSE x.titulo END) =
            (CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END)
    ) AS total_exemplares
  FROM Midia m
  JOIN TipoMidia tm ON tm.id_tpmidia = m.id_tpmidia
  ORDER BY m.titulo;
END
GO
exec sp_AcervoMidiasTodasInfosComExemplares
CREATE PROCEDURE sp_MidiaComExemplares -- TIRAR
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

CREATE PROCEDURE sp_ClienteAlterarImagemPorEmail
  @email  VARCHAR(100),
  @imagem VARBINARY(MAX)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN
    SELECT 'Cliente não encontrado' AS msg; RETURN;
  END;

  UPDATE Cliente
    SET imagem_perfil = @imagem
  WHERE email = @email;

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
        limite_emprestimos=@limite_emprestimos;
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
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END

  SELECT 
    e.id_emprestimo,
    m.id_midia,
    m.titulo,
    e.data_devolucao,
    DATEDIFF(DAY, e.data_devolucao, CAST(GETDATE() AS DATE)) AS dias_atraso
  FROM Emprestimo e
  JOIN Midia m   ON m.id_midia = e.id_midia
  JOIN Cliente c ON c.id_cliente = e.id_cliente
  WHERE c.email=@email
    AND e.data_devolucao < CAST(GETDATE() AS DATE)
  ORDER BY e.data_devolucao;
END
GO

	

-- !!!EVENTOS!!!
/*
CREATE PROCEDURE sp_PostListar
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
*/
-- Criar
CREATE PROCEDURE sp_EventoCriar
  @titulo NVARCHAR(200),
  @data_inicio DATETIME,
  @data_fim DATETIME,
  @local_evento NVARCHAR(200),
  @id_funcionario INT
AS
BEGIN
  INSERT INTO Evento (titulo, data_inicio, data_fim, local_evento, id_funcionario, status_evento)
  VALUES (@titulo, @data_inicio, @data_fim, @local_evento, @id_funcionario, 'ativo');

  SELECT 'OK' AS msg;
END
GO

-- Editar
CREATE PROCEDURE sp_EventoEditar
  @id_evento INT,
  @titulo NVARCHAR(200),
  @data_inicio DATETIME,
  @data_fim DATETIME,
  @local_evento NVARCHAR(200)
AS
BEGIN
  UPDATE Evento
  SET titulo=@titulo,
      data_inicio=@data_inicio,
      data_fim=@data_fim,
      local_evento=@local_evento
  WHERE id_evento=@id_evento;

  SELECT 'OK' AS msg;
END
GO

-- Inativar
CREATE PROCEDURE sp_EventoInativar
  @id_evento INT
AS
BEGIN
  UPDATE Evento SET status_evento='inativo'
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
  WHERE data_fim < GETDATE()
  ORDER BY data_fim DESC;
END
GO

-- Em andamento ou futuros (ativos)

CREATE PROCEDURE sp_EventosAtivos
AS
BEGIN
  SELECT *
  FROM Evento
  WHERE data_fim >= GETDATE()
    AND status_evento='ativo'
  ORDER BY data_inicio ASC;
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
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END

  UPDATE Cliente SET status_conta='banido' WHERE email=@email;
  SELECT 'OK' AS msg;
END
GO

-- Histórico de posts do leitor
CREATE PROCEDURE sp_LeitorPostsHistorico
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END

  SELECT m.id_mensagem, m.conteudo, m.data_postagem, m.visibilidade
  FROM Mensagem m
  JOIN Cliente c ON c.id_cliente = m.id_cliente
  WHERE c.email=@email
  ORDER BY m.data_postagem DESC;
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
  IF EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia AND disponibilidade='emprestado')
  BEGIN
     SELECT 'Mídia já emprestada' AS msg; 
     RETURN;
  END

  INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes)
  VALUES (@id_cliente, @id_funcionario, @id_midia, NULL, @data_emprestimo, @data_devolucao, 0);

  UPDATE Midia SET disponibilidade='emprestado' WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

/*
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
*/ -- ver redundancia?

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
    DATEDIFF(DAY, e.data_devolucao, CAST(GETDATE() AS DATE)) AS dias_atraso
  FROM Emprestimo e
  JOIN Cliente c ON c.id_cliente = e.id_cliente
  JOIN Midia m   ON m.id_midia   = e.id_midia
  WHERE e.data_devolucao < CAST(GETDATE() AS DATE)
  ORDER BY e.data_devolucao ASC;
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





--------------------------------------
-- EVENTOS (FÓRUM) / POSTS / DENÚNCIA
--------------------------------------


/*
CREATE PROCEDURE sp_PostCriar
  @id_cliente INT,
  @conteudo   VARCHAR(255)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente=@id_cliente AND status_conta='ativo')
  BEGIN SELECT 'Cliente inativo/ausente' AS msg; RETURN; END


  INSERT INTO Mensagem (id_cliente, conteudo, data_postagem, visibilidade)
  VALUES (@id_cliente, @conteudo, GETDATE(), 'publica');

  SELECT 'OK' AS msg;
END
GO

    -- padrão: recentes
    SELECT m.conteudo, m.data_postagem, c.nome AS autor
    FROM Mensagem m
    JOIN Cliente c ON c.id_cliente=m.id_cliente
    WHERE m.id_forum=@id_forum AND m.visibilidade='publica'
    ORDER BY m.data_postagem DESC;
END*/
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





/*

CREATE PROCEDURE sp_AtualizarPerfilCliente
  @id_cliente INT,
  @senha VARCHAR(255),
  @telefone VARCHAR(20)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente=@id_cliente)
  BEGIN
    SELECT 'Cliente não encontrado' AS msg; RETURN;
  END

  UPDATE Cliente
  SET senha=@senha,
      telefone=@telefone
  WHERE id_cliente=@id_cliente;

  SELECT 'OK' AS msg;
END
GO






CREATE PROCEDURE sp_EmprestimoRenovar
  @id_emprestimo INT,
  @novadata DATE
AS
BEGIN
  DECLARE @limite INT;

  SELECT @limite = limite_renovacoes
  FROM Emprestimo
  WHERE id_emprestimo=@id_emprestimo;

  IF @limite <= 0
  BEGIN
    SELECT 'Não pode renovar' AS msg; RETURN;
  END

  UPDATE Emprestimo
  SET data_devolucao=@novadata,
      limite_renovacoes=@limite-1
  WHERE id_emprestimo=@id_emprestimo;

  SELECT 'OK' AS msg;
END
GO




-- Adicionar Mídia
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


-- Alterar Mídia
CREATE PROCEDURE sp_MidiaAlterar
  @id_midia INT,
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
  UPDATE Midia
  SET titulo = @titulo,
      sinopse = @sinopse,
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


-- Excluir Mídia (sem alteração, só mantive padrão)
CREATE PROCEDURE sp_MidiaExcluir
  @id_midia INT
AS
BEGIN
  DELETE FROM Midia WHERE id_midia=@id_midia;
  SELECT 'OK' AS msg;
END
GO
*/