-- !!!!!!!!!!!!!!!! ANDROID !!!!!!!!!!!!!!!!!!!!!!!

-- !!!MAIN!!!
USE Littera
GO
IF OBJECT_ID('dbo.fn_DecodeBase64','FN') IS NOT NULL
  DROP FUNCTION dbo.fn_DecodeBase64;
GO
CREATE FUNCTION dbo.fn_DecodeBase64 (@b64 NVARCHAR(MAX))
RETURNS VARBINARY(MAX)
AS
BEGIN
  IF @b64 IS NULL OR LTRIM(RTRIM(@b64)) = '' RETURN NULL;
  RETURN CAST(N'' as xml).value('xs:base64Binary(sql:variable("@b64"))','varbinary(max)');
END
GO

-- Detalhe + similares por gênero (garante @id_midia válido)
CREATE PROCEDURE sp_MidiaDetalheComSimilares
  @id_midia INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia = @id_midia AND status_midia='publica')
    RETURN;

  DECLARE @obra_key_ref VARCHAR(600);
  SELECT @obra_key_ref =
         CASE WHEN (isbn IS NOT NULL AND isbn <> '')
              THEN 'ISBN:' + isbn
              ELSE 'TIT:' + titulo + '|TP:' + CONVERT(varchar(10), id_tpmidia)
         END
  FROM Midia
  WHERE id_midia = @id_midia;

  DECLARE @genero_ref VARCHAR(100);
  SELECT @genero_ref = genero FROM Midia WHERE id_midia = @id_midia;
  IF @genero_ref IS NULL OR LTRIM(RTRIM(@genero_ref)) = '' RETURN;

  ;WITH Obras AS (
    SELECT
      CASE WHEN (m.isbn IS NOT NULL AND m.isbn <> '')
           THEN 'ISBN:' + m.isbn
           ELSE 'TIT:' + m.titulo + '|TP:' + CONVERT(varchar(10), m.id_tpmidia)
      END AS obra_key,
      MIN(m.id_midia)       AS id_midia_exemplo,
      MIN(m.titulo)         AS titulo,
      MIN(m.autor)          AS autor,
      MIN(m.genero)         AS genero,
      MAX(m.ano_publicacao) AS ano_recente,
      MIN(m.imagem)         AS imagem,
      COUNT(*)              AS total_exemplares
    FROM Midia m
    WHERE m.genero = @genero_ref
      AND m.status_midia = 'publica'
    GROUP BY CASE WHEN (m.isbn IS NOT NULL AND m.isbn <> '')
                  THEN 'ISBN:' + m.isbn
                  ELSE 'TIT:' + m.titulo + '|TP:' + CONVERT(varchar(10), m.id_tpmidia)
             END
  )
  SELECT TOP (10)
         id_midia_exemplo    AS id_midia,
         titulo, autor, genero,
         ano_recente         AS ano_publicacao,
         imagem,
         total_exemplares
  FROM Obras
  WHERE obra_key <> @obra_key_ref
  ORDER BY ano_recente DESC, titulo;
END
GO


-- Mais populares (por obra: ISBN ou Título). Filtros opcionais de tipo/gênero.
CREATE PROCEDURE sp_MidiasPopulares
  @tipo   VARCHAR(50)  = NULL,
  @genero VARCHAR(100) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP (50)
         MIN(m.id_midia) AS id_midia_exemplo,
         CASE WHEN m.isbn IS NOT NULL AND m.isbn <> '' THEN m.isbn ELSE m.titulo END AS chave,
         MIN(m.titulo)          AS titulo,
         MIN(tm.nome_tipo)      AS nome_tipo,
         MIN(m.genero)          AS genero,
         COUNT(e.id_emprestimo) AS qtde_emprestimos
  FROM Midia m
  JOIN TipoMidia tm ON tm.id_tpmidia = m.id_tpmidia
  LEFT JOIN Emprestimo e ON e.id_midia = m.id_midia
  WHERE m.status_midia='publica'
    AND (@tipo   IS NULL OR tm.nome_tipo = @tipo)
    AND (@genero IS NULL OR m.genero     = @genero)
  GROUP BY CASE WHEN m.isbn IS NOT NULL AND m.isbn <> '' THEN m.isbn ELSE m.titulo END
  ORDER BY qtde_emprestimos DESC, titulo;
END
GO


-- “Main” lista: primeiro resultset = populares (livros),
CREATE PROCEDURE sp_MainListar
  @genero_ref VARCHAR(100) = NULL,
  @top_genero INT = 10,
  @tipo_midia VARCHAR(100)
AS
BEGIN

  SET NOCOUNT ON;
  ;WITH Base AS (
    SELECT
      CASE WHEN (m.isbn IS NOT NULL AND m.isbn <> '')
           THEN 'ISBN:' + m.isbn
           ELSE 'TIT:' + m.titulo + '|TP:' + CONVERT(varchar(10), m.id_tpmidia)
      END AS obra_key,
      m.id_midia, m.titulo, m.autor, m.genero, m.imagem, m.ano_publicacao
    FROM Midia m
    JOIN TipoMidia tm ON tm.id_tpmidia = m.id_tpmidia
    WHERE tm.nome_tipo = @tipo_midia AND m.status_midia='publica'
  ),
  Populares AS (
    SELECT MIN(b.id_midia) AS id_midia, MIN(b.titulo) AS titulo, MIN(b.autor) AS autor,
           MIN(b.genero) AS genero, MAX(b.ano_publicacao) AS ano_publicacao, MIN(b.imagem) AS imagem,
           COUNT(e.id_emprestimo) AS qtde_emprestimos
    FROM Base b
    LEFT JOIN Emprestimo e ON e.id_midia = b.id_midia
    GROUP BY b.obra_key
  ),
  ObrasGenero AS (
    SELECT
      CASE WHEN (m.isbn IS NOT NULL AND m.isbn <> '')
           THEN 'ISBN:' + m.isbn
           ELSE 'TIT:' + m.titulo + '|TP:' + CONVERT(varchar(10), m.id_tpmidia)
      END AS obra_key,
      MIN(m.id_midia) AS id_midia, MIN(m.titulo) AS titulo, MIN(m.autor) AS autor,
      MAX(m.ano_publicacao) AS ano_publicacao, MIN(m.imagem) AS imagem
    FROM Midia m
    JOIN TipoMidia tm ON tm.id_tpmidia = m.id_tpmidia
    WHERE tm.nome_tipo = @tipo_midia AND m.status_midia='publica'
      AND (@genero_ref IS NOT NULL AND LTRIM(RTRIM(@genero_ref)) <> '' AND m.genero = @genero_ref)
    GROUP BY CASE WHEN (m.isbn IS NOT NULL AND m.isbn <> '')
                  THEN 'ISBN:' + m.isbn
                  ELSE 'TIT:' + m.titulo + '|TP:' + CONVERT(varchar(10), m.id_tpmidia)
             END
  ),
  TopGenero AS (
    SELECT TOP (@top_genero) og.id_midia, og.titulo, og.autor, og.ano_publicacao, @genero_ref AS genero, og.imagem
    FROM ObrasGenero og
    ORDER BY og.ano_publicacao DESC, og.titulo
  )
  SELECT p.id_midia,p.titulo,p.autor,p.ano_publicacao,p.genero,p.imagem,
         'populares' AS grupo,
         ROW_NUMBER() OVER (ORDER BY p.qtde_emprestimos DESC, p.titulo) AS ordem
  FROM Populares p
  UNION ALL
  SELECT tg.id_midia,tg.titulo,tg.autor,tg.ano_publicacao,tg.genero,tg.imagem,
         CONCAT('genero:', @genero_ref) AS grupo,
         ROW_NUMBER() OVER (ORDER BY tg.ano_publicacao DESC, tg.titulo) AS ordem
  FROM TopGenero tg
  ORDER BY grupo, ordem;
END
GO
/*
-- similares por gênero (passa um id existente de livro/filme etc.)
EXEC sp_MidiaDetalheComSimilares @id_midia = 1;

-- populares (geral)
EXEC sp_MidiasPopulares;

-- populares só de livros
EXEC sp_MidiasPopulares @tipo = 'livros';

-- populares de livros do gênero Romance
EXEC sp_MidiasPopulares @tipo = 'livros', @genero = 'Romance';

-- main romance livros
EXEC sp_MainListar @genero_ref = 'romance', @top_genero = 10, @tipo_midia = 'livros'
*/
-- !!! RESERVAS/EMPRESTIMO!!!

CREATE PROCEDURE sp_EmprestimoRenovar -- funcionando
  @id_emprestimo INT,
  @novadata DATE
AS
BEGIN
  DECLARE @limite INT, @data_atual DATE;

  SELECT @limite = limite_renovacoes, @data_atual = data_devolucao
  FROM Emprestimo
  WHERE id_emprestimo=@id_emprestimo;

  IF @limite IS NULL RETURN;
  IF @limite <= 0 RETURN;

  IF @novadata <= CAST(GETDATE() AS DATE)
  RETURN;

  IF @novadata <= @data_atual
  RETURN;

  UPDATE Emprestimo
  SET data_devolucao=@novadata,
      limite_renovacoes=@limite-1
  WHERE id_emprestimo=@id_emprestimo;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_HistoricoEmprestimosPagosCliente -- funcionando
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  RETURN;

  SELECT
	m.imagem,
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

 -- atuais e atrasados
CREATE PROCEDURE sp_EmprestimosClienteListar -- funcionando
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
    RETURN;

  DECLARE @hoje DATE = CAST(GETDATE() AS DATE);
  DECLARE @multa_dia DECIMAL(10,2);

  -- pega valor da tabela Parametros (assumindo que só tem 1 linha configurada)
  SELECT TOP 1 @multa_dia = multa_dia FROM Parametros ORDER BY id_parametros DESC;

  SELECT 
	m.imagem,
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

CREATE PROCEDURE sp_ReservasClienteListar --FUNCIONANDO	
  @email  VARCHAR(100),
  @status VARCHAR(20) = NULL -- 'ativa' | 'expirada' | 'cancelada' | 'concluida' | NULL=todas
AS
BEGIN
  -- valida cliente
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
    RETURN;

  DECLARE @hoje DATE = CAST(GETDATE() AS DATE);

  -- 1) normaliza: reservas vencidas viram 'expirada'
  UPDATE r
     SET r.status_reserva = 'expirada'
  FROM Reserva r
  JOIN Cliente c ON c.id_cliente = r.id_cliente
  WHERE c.email = @email
    AND r.status_reserva = 'ativa'
    AND r.data_limite   < @hoje;

  -- 2) retorna (com filtro opcional de status)
  SELECT
    c.imagem_perfil AS imagem_cliente,
    r.id_reserva, r.data_reserva, r.data_limite, r.status_reserva,
    m.id_midia, m.titulo, m.autor, m.ano_publicacao, m.imagem,
    DATEDIFF(DAY, @hoje, r.data_limite) AS dias_restantes  -- pode ser negativo se expirada
  FROM Reserva r
  JOIN Cliente c ON c.id_cliente = r.id_cliente
  JOIN Midia   m ON m.id_midia   = r.id_midia
  WHERE c.email = @email
    AND (@status IS NULL OR r.status_reserva = @status)
  ORDER BY r.data_limite DESC;  -- mais recente primeiro
END
GO

CREATE PROCEDURE sp_HistoricoEmprestimosCliente -- funcionando
  @email VARCHAR(100)
AS
BEGIN
  -- Verificar se o cliente existe
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email = @email)
  RETURN; 

  -- Selecionar apenas empréstimos já pagos
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
  WHERE c.email = @email
    AND e.status_pagamento = 'pago'  -- Apenas os pagos
  ORDER BY e.data_devolucao DESC;
END
GO

-- !!!NOTIFICAÇÕES/ALERTAS !!!

-- ========== 1) GERAR NOTIFICAÇÕES ==========
CREATE PROCEDURE sp_NotificacoesGerarPendenciasCliente -- funcionando
  @email       VARCHAR(100),
  @dias_aviso  INT = 2      -- janela para "em breve"
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @id_cliente INT, @hoje DATE = CAST(GETDATE() AS DATE);
  SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email;
  IF @id_cliente IS NULL RETURN;

  ---------------------------
  -- 1) DEVOLUÇÃO EM BREVE --
  ---------------------------
  INSERT INTO Notificacao (id_cliente, titulo, mensagem)
  SELECT 
    @id_cliente,
    'Devolução em breve',
    'O livro ' + m.titulo + ' deve ser devolvido em breve (faltam ' 
      + CAST(DATEDIFF(DAY, @hoje, e.data_devolucao) AS VARCHAR(10)) + ' dia(s)).'
  FROM Emprestimo e
  JOIN Midia m ON m.id_midia = e.id_midia
  WHERE e.id_cliente = @id_cliente
    AND e.status_pagamento = 'pendente'
    AND e.data_devolucao BETWEEN @hoje AND DATEADD(DAY, @dias_aviso, @hoje)
    AND NOT EXISTS (
      SELECT 1 
      FROM Notificacao n
      WHERE n.id_cliente = @id_cliente
        AND n.titulo = 'Devolução em breve'
        AND n.mensagem LIKE '%' + m.titulo + '%'
        AND DATEDIFF(DAY, n.data_criacao, GETDATE()) <= 1
    );

  -------------- 
  -- 2) ATRASO --
  --------------
  INSERT INTO Notificacao (id_cliente, titulo, mensagem)
  SELECT 
    @id_cliente,
    'Empréstimo atrasado',
    'O livro ' + m.titulo + ' está atrasado em seu prazo de devolução em ' 
      + CAST(DATEDIFF(DAY, e.data_devolucao, @hoje) AS VARCHAR(10)) + ' dia(s).'
  FROM Emprestimo e
  JOIN Midia m ON m.id_midia = e.id_midia
  WHERE e.id_cliente = @id_cliente
    AND e.status_pagamento = 'pendente'
    AND e.data_devolucao < @hoje
    AND NOT EXISTS (
      SELECT 1 
      FROM Notificacao n
      WHERE n.id_cliente = @id_cliente
        AND n.titulo = 'Empréstimo atrasado'
        AND n.mensagem LIKE '%' + m.titulo + '%'
        AND DATEDIFF(DAY, n.data_criacao, GETDATE()) <= 1
    );

  SELECT 'OK' AS msg;
END
GO

-- ========== 2) LISTAR (SEM GRAVAR) ==========
CREATE PROCEDURE sp_NotificacoesListarPendenciasCliente -- funcionando
  @email       VARCHAR(100),
  @dias_aviso  INT = 2
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @id_cliente INT, @hoje DATE = CAST(GETDATE() AS DATE);
  SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email;
  IF @id_cliente IS NULL RETURN;

  SELECT *
  FROM (
      -- Em breve
      SELECT 
        'Devolução em breve' AS tipo,
        m.titulo,
        'O livro ' + m.titulo + ' deve ser devolvido em breve (faltam ' 
          + CAST(DATEDIFF(DAY, @hoje, e.data_devolucao) AS VARCHAR(10)) + ' dia(s)).' AS mensagem
      FROM Emprestimo e
      JOIN Midia m ON m.id_midia = e.id_midia
      WHERE e.id_cliente = @id_cliente
        AND e.status_pagamento = 'pendente'
        AND e.data_devolucao BETWEEN @hoje AND DATEADD(DAY, @dias_aviso, @hoje)

      UNION ALL

      -- Atrasado
      SELECT 
        'Empréstimo atrasado' AS tipo,
        m.titulo,
        'O livro ' + m.titulo + ' está atrasado em seu prazo de devolução em ' 
          + CAST(DATEDIFF(DAY, e.data_devolucao, @hoje) AS VARCHAR(10)) + ' dia(s).' AS mensagem
      FROM Emprestimo e
      JOIN Midia m ON m.id_midia = e.id_midia
      WHERE e.id_cliente = @id_cliente
        AND e.status_pagamento = 'pendente'
        AND e.data_devolucao < @hoje
  ) X
  ORDER BY tipo, titulo;
END
GO

CREATE PROCEDURE sp_ReservasExpirarENotificar -- funcionando
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @hoje DATE = CAST(GETDATE() AS DATE);

  -- guarda as reservas que foram efetivamente expiradas nesta execução
  DECLARE @afetadas TABLE (
    id_reserva  INT,
    id_cliente  INT,
    titulo      VARCHAR(255),
    data_limite DATE
  );

  -- expira e coleta info das reservas
  UPDATE r
     SET r.status_reserva = 'expirada'
  OUTPUT inserted.id_reserva, inserted.id_cliente, m.titulo, inserted.data_limite
    INTO @afetadas (id_reserva, id_cliente, titulo, data_limite)
  FROM Reserva r
  JOIN Midia   m ON m.id_midia = r.id_midia
  WHERE r.status_reserva = 'ativa'
    AND r.data_limite   < @hoje;

  -- notifica clientes (evita duplicatas nas últimas 24h para o mesmo id_reserva)
  INSERT INTO Notificacao (id_cliente, titulo, mensagem)
  SELECT 
      a.id_cliente,
      'Reserva expirada',
      CONCAT(
        'Sua reserva #', a.id_reserva, ' do título "', a.titulo,
        '" expirou em ', CONVERT(VARCHAR(10), a.data_limite, 120), '.'
      )
  FROM @afetadas a
  WHERE NOT EXISTS (
    SELECT 1
    FROM Notificacao n
    WHERE n.id_cliente = a.id_cliente
      AND n.titulo = 'Reserva expirada'
      AND n.mensagem LIKE CONCAT('%#', CAST(a.id_reserva AS VARCHAR(20)), '%')
      AND DATEDIFF(DAY, n.data_criacao, GETDATE()) <= 1
  );

  -- resumo
  SELECT COUNT(*) AS reservas_expiradas_hoje FROM @afetadas;
END
GO

-- !!! LISTA DE DESEJOS !!!

CREATE PROCEDURE sp_ListaDesejosCliente -- funcionando
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  RETURN;

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

CREATE PROCEDURE sp_ListaDesejosExcluir -- funcionando
    @email_cliente VARCHAR(100),
    @id_midia INT
AS
BEGIN
    DECLARE @id_cliente INT;

    -- Pegar id do cliente pelo email
    SELECT @id_cliente = id_cliente 
    FROM Cliente 
    WHERE email = @email_cliente;

    IF @id_cliente IS NULL
        RETURN;

    -- Verificar se a mídia existe
    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia = @id_midia)
        RETURN;

    -- Deletar da lista de desejos
    DELETE FROM ListaDeDesejos
    WHERE id_cliente = @id_cliente AND id_midia = @id_midia;

    SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_ListaDesejosAdicionar -- funcionando
    @email_cliente VARCHAR(100),
    @id_midia INT
AS
BEGIN
    DECLARE @id_cliente INT;

    -- Pegar id do cliente pelo email
    SELECT @id_cliente = id_cliente 
    FROM Cliente 
    WHERE email = @email_cliente;

    IF @id_cliente IS NULL
        RETURN;

    -- Verificar se a mídia existe
    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia = @id_midia)
        RETURN;

    -- Checar se já existe na lista
    IF EXISTS (
        SELECT 1 
        FROM ListaDeDesejos
        WHERE id_cliente = @id_cliente AND id_midia = @id_midia
    )
        RETURN;

    -- Inserir na lista
    INSERT INTO ListaDeDesejos (id_cliente, id_midia)
    VALUES (@id_cliente, @id_midia);

    SELECT 'OK' AS msg;
END
GO

-- !!! ACERVO/MIDIA !!!
CREATE PROCEDURE sp_AcervoPrincipal -- funcionando
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
  WHERE status_midia = 'publica'	
  ORDER BY m.titulo;
END
GO

CREATE PROCEDURE sp_AcervoMidiasTodasInfosComExemplares -- funcionando
AS
BEGIN
  SELECT *,
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

CREATE PROCEDURE sp_MidiaDetalhes -- FUNCIONANDO
    @id_midia INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia = @id_midia)
        RETURN;

    SELECT 
        *,
        -- Quantidade de exemplares
        (SELECT COUNT(*) 
         FROM Midia x
         WHERE (x.isbn IS NOT NULL AND x.isbn = m.isbn)
            OR (x.isbn IS NULL AND x.titulo = m.titulo)
        ) AS quantidade_exemplares
    FROM Midia m
    WHERE m.id_midia = @id_midia;
END;
GO

-- !!! LOGIN/CADASTRO CLIENTE !!!

CREATE PROCEDURE sp_LoginCliente -- funcionando
    @email VARCHAR(100),
    @senha VARCHAR(255)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
    RETURN;
    SELECT id_cliente, nome, email, telefone, status_conta
    FROM Cliente
    WHERE email = @email AND senha = @senha AND status_conta = 'ativo';
END
GO

CREATE PROCEDURE sp_CadastrarCliente -- funcionando
  @nome VARCHAR(100),
  @username VARCHAR(40),
  @cpf VARCHAR(14),
  @email VARCHAR(100),
  @telefone VARCHAR(20),
  @senha VARCHAR(255),
  @status_conta VARCHAR(20)
AS
BEGIN
  IF @status_conta NOT IN ('ativo','banido')
    RETURN;

  IF EXISTS (SELECT 1 FROM Cliente WHERE cpf=@cpf)
    RETURN;

  IF EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
    RETURN;

  INSERT INTO Cliente (nome, username, cpf, email, telefone, senha, status_conta)
  VALUES (@nome, @username, @cpf, @email, @telefone, @senha, @status_conta);

  SELECT 'OK' AS msg;
END
GO

 CREATE PROCEDURE sp_ClienteResetarSenhaViaCpfEmail -- funcionando
    @email      VARCHAR(100) = NULL,
    @cpf        VARCHAR(14)  = NULL,
    @nova_senha VARCHAR(255)
AS
BEGIN
    -- normaliza vazios para NULL
    IF @email IS NOT NULL AND LTRIM(RTRIM(@email)) = '' SET @email = NULL;
    IF @cpf   IS NOT NULL AND LTRIM(RTRIM(@cpf))   = '' SET @cpf   = NULL;

    IF @email IS NULL AND @cpf IS NULL
        RETURN;

    DECLARE @id_cliente INT;

    -- se vieram os dois, precisam pertencer ao MESMO cliente
    IF @email IS NOT NULL AND @cpf IS NOT NULL
    BEGIN
        SELECT @id_cliente = id_cliente
        FROM Cliente
        WHERE email = @email AND cpf = @cpf;

        IF @id_cliente IS NULL
            RETURN;
    END
    ELSE IF @email IS NOT NULL
    BEGIN
        SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email;
        IF @id_cliente IS NULL
            RETURN;
    END
    ELSE  -- só CPF
    BEGIN
        SELECT @id_cliente = id_cliente FROM Cliente WHERE cpf = @cpf;
        IF @id_cliente IS NULL
            RETURN;
    END

    UPDATE Cliente
    SET senha = @nova_senha
    WHERE id_cliente = @id_cliente;

    SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_AtualizarPerfilCliente -- funcionando
  @nome VARCHAR(50),
  @username VARCHAR(40),
  @email VARCHAR(100),
  @senha VARCHAR(255),
  @telefone VARCHAR(20)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
	RETURN;

  UPDATE Cliente
  SET senha=@senha,
	  nome=@nome,
	  username=@username,
      telefone=@telefone
  WHERE email=@email;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_ClienteAlterarImagemPorEmail
  @email         VARCHAR(100),
  @imagem_base64 NVARCHAR(MAX)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
    RETURN;

  UPDATE Cliente
    SET imagem_perfil = dbo.fn_DecodeBase64(@imagem_base64)
  WHERE email = @email;

  SELECT 'OK' AS msg;
END
GO

-- !!!!!!!!!!!!!!! DESKTOP !!!!!!!!!!!!!!!!!!!!!!!


CREATE PROCEDURE sp_ConfigurarParametros -- funcionando
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

 --lista todos os funcionarios
CREATE PROCEDURE sp_TodosFuncionarios -- funcionando
AS
BEGIN
  SELECT id_funcionario, id_cargo, nome, cpf, email, telefone, status_conta
  FROM Funcionario
  ORDER BY nome;
END
GO

CREATE PROCEDURE sp_InfoFuncionario -- funcionando
    @email VARCHAR(100)
AS
BEGIN
    SELECT id_funcionario, id_cargo, nome, cpf, email, telefone, status_conta
    FROM Funcionario
    WHERE email = @email;
END
GO

CREATE PROCEDURE sp_GetFuncionarioID -- funcionando
    @email VARCHAR(100)
AS
BEGIN
    SELECT id_funcionario
    FROM Funcionario
    WHERE email = @email AND status_conta = 'ativo';
END
GO

CREATE PROCEDURE sp_CadastrarFuncionario -- funcionando
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
    RETURN;

  IF NOT EXISTS (SELECT 1 FROM CargoFuncionario WHERE id_cargo=@id_cargo)
    RETURN;

  IF EXISTS (SELECT 1 FROM Funcionario WHERE cpf=@cpf)
    RETURN;

  IF EXISTS (SELECT 1 FROM Funcionario WHERE email=@email)
    RETURN;

  INSERT INTO Funcionario (id_cargo, nome, cpf, email, telefone, senha, status_conta)
  VALUES (@id_cargo, @nome, @cpf, @email, @telefone, @senha, @status_conta);

  SELECT 'OK' AS msg;
END
GO


CREATE PROCEDURE sp_LoginFuncionario -- funcionando
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
CREATE PROCEDURE sp_FuncionarioAlterar -- funcionando
  @id_funcionario INT,
  @nome VARCHAR(100),
  @telefone VARCHAR(20),
  @status_conta VARCHAR(20)
AS
BEGIN
  UPDATE Funcionario
  SET nome = @nome,
      telefone = @telefone,
      status_conta = @status_conta
  WHERE id_funcionario = @id_funcionario;

  SELECT 'OK' AS msg;
END
GO

-- !!!INFO SOBRE O CLIENTE!!!

CREATE PROCEDURE sp_LeitorBuscarPorNome -- funcionando
  @nome VARCHAR(100)
AS
BEGIN
  SELECT id_cliente, nome, username, imagem_perfil, email, telefone, status_conta
  FROM Cliente
  WHERE nome LIKE '%' + @nome + '%'
  ORDER BY nome;
END
GO

CREATE PROCEDURE sp_LeitorBuscarPorUsername -- funcionando
  @username VARCHAR(100)
AS
BEGIN
  SELECT id_cliente, nome, username, imagem_perfil, email, telefone, status_conta
  FROM Cliente
  WHERE username LIKE '%' + @username + '%'
  ORDER BY username;
END
GO

-- Mídias não devolvidas pelo cliente (em atraso)
CREATE PROCEDURE sp_NaoDevolveuMidia  -- funcionando
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  RETURN;

  SELECT 
    e.id_emprestimo,
    m.id_midia,
    m.titulo,
    e.data_devolucao,
    DATEDIFF(DAY, e.data_devolucao, CAST(GETDATE() AS DATE)) AS dias_atraso
  FROM Emprestimo e
  JOIN Midia   m ON m.id_midia = e.id_midia
  JOIN Cliente c ON c.id_cliente = e.id_cliente
  WHERE c.email = @email
    AND e.data_devolucao < CAST(GETDATE() AS DATE)
    AND e.status_pagamento = 'pendente'
  ORDER BY e.data_devolucao;
END
GO
	

-- !!!EVENTOS!!!

-- Criar
CREATE PROCEDURE sp_EventoCriar
  @titulo NVARCHAR(200),
  @data_inicio DATETIME,
  @data_fim DATETIME,
  @local_evento NVARCHAR(200),
  @email NVARCHAR(200)
AS
BEGIN
  IF @data_fim < @data_inicio RETURN;

  INSERT INTO Evento (titulo, data_inicio, data_fim, local_evento, id_funcionario, status_evento)
  VALUES (@titulo, @data_inicio, @data_fim, @local_evento, (SELECT id_funcionario FROM Funcionario WHERE email = @email), 'ativo');

  SELECT 'OK' AS msg;
END
GO

-- Editar
CREATE PROCEDURE sp_EventoEditar
  @id_evento INT,
  @titulo NVARCHAR(200),
  @data_inicio DATETIME,
  @data_fim DATETIME,
  @local_evento NVARCHAR(200),
  @email NVARCHAR(100)
AS
BEGIN
  IF @data_fim < @data_inicio RETURN;

  UPDATE Evento
     SET titulo=@titulo,
         data_inicio=@data_inicio,
         data_fim=@data_fim,
         local_evento=@local_evento,
         id_funcionario = (SELECT id_funcionario FROM Funcionario WHERE email = @email)
   WHERE id_evento=@id_evento;

  SELECT 'OK' AS msg;
END
GO

-- Inativar
CREATE PROCEDURE sp_EventoInativar -- funcionando
  @id_evento INT
AS
BEGIN
  UPDATE Evento SET status_evento='inativo'
  WHERE id_evento=@id_evento;

  SELECT 'OK' AS msg;
END
GO

-- Histórico (já aconteceram)

CREATE PROCEDURE sp_EventosHistorico -- funcionando
AS
BEGIN
  SELECT *
  FROM Evento
  WHERE data_fim < GETDATE()
  ORDER BY data_fim DESC;
END
GO

-- Em andamento ou futuros (ativos)

CREATE PROCEDURE sp_EventosAtivos -- funcionando
AS
BEGIN
  SELECT *
  FROM Evento
  WHERE data_fim >= GETDATE()
    AND status_evento='ativo'
  ORDER BY data_inicio ASC;
END
GO	

CREATE PROCEDURE sp_TodosEventos -- FUNCIONANDO
AS
BEGIN
  SELECT *
  FROM Evento
  ORDER BY data_inicio ASC;
END
GO

-- !!!FÓRUM/DENUNCIAS!!!

CREATE PROCEDURE sp_MensagemAdicionar -- funcionando
	@titulo VARCHAR(60),
    @email_cliente VARCHAR(100),
    @conteudo NVARCHAR(255),
    @id_pai INT = NULL -- opcional, se vier nulo vira post principal
AS
BEGIN
    DECLARE @id_cliente INT;

    -- 1. Pega o id_cliente pelo email
    SELECT @id_cliente = id_cliente 
    FROM Cliente 
    WHERE email = @email_cliente;

    IF @id_cliente IS NULL
        RETURN;

    -- 2. Se for comentário, verifica se o id_pai existe
    IF @id_pai IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem = @id_pai)
        RETURN;

	-- 3. Se cliente estiver banido, nao pode fazer post
    IF (SELECT status_conta FROM Cliente WHERE email = @email_cliente) = 'banido'
        RETURN;

    -- 4. Faz o insert
    INSERT INTO Mensagem (id_cliente, titulo, conteudo, data_postagem, id_pai)
    VALUES (@id_cliente, @titulo, @conteudo, GETDATE(), @id_pai);

    SELECT 'OK' AS msg;
END;
GO

CREATE PROCEDURE sp_PostsListar -- funcionando
    @ordenar_por VARCHAR(20) = 'recentes' -- recentes, antigos, populares
AS
BEGIN
    SELECT 
		m.titulo,
        m.id_mensagem,
        c.nome AS autor,
		c.username,
		c.imagem_perfil,
        m.conteudo,
        m.data_postagem,
        m.visibilidade,
        m.curtidas,
		(SELECT COUNT(1) FROM Mensagem cm WHERE cm.id_pai = m.id_mensagem) AS qtd_comentarios
    FROM Mensagem m
    JOIN Cliente c ON c.id_cliente = m.id_cliente
    WHERE m.id_pai IS NULL
    ORDER BY
        CASE WHEN @ordenar_por = 'recentes' THEN m.data_postagem END DESC,
        CASE WHEN @ordenar_por = 'antigos'  THEN m.data_postagem END ASC,
        CASE WHEN @ordenar_por = 'populares' THEN m.curtidas END DESC;
END;
GO

CREATE PROCEDURE sp_PostsListar_Publicos -- funcionando
    @ordenar_por VARCHAR(20) = 'recentes'
AS
BEGIN
    SELECT 
		m.titulo,
        m.id_mensagem,
        c.nome AS autor,
		c.username,
		c.imagem_perfil,
        m.conteudo,
        m.data_postagem,
        m.curtidas,
		(SELECT COUNT(1) FROM Mensagem cm WHERE cm.id_pai = m.id_mensagem) AS qtd_comentarios
    FROM Mensagem m
    JOIN Cliente c ON c.id_cliente = m.id_cliente
    WHERE m.id_pai IS NULL
      AND m.visibilidade = 1
    ORDER BY
        CASE WHEN @ordenar_por = 'recentes' THEN m.data_postagem END DESC,
        CASE WHEN @ordenar_por = 'antigos'  THEN m.data_postagem END ASC,
        CASE WHEN @ordenar_por = 'populares' THEN m.curtidas END DESC;
END;
GO

CREATE PROCEDURE sp_ComentariosListar -- funcionando
    @id_post INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem = @id_post AND id_pai IS NULL)
        RETURN;

    SELECT 
		m.titulo,
        m.id_mensagem,
        c.nome AS autor,
		c.username,
		c.imagem_perfil,
        m.conteudo,
        m.data_postagem,
		m.curtidas
    FROM Mensagem m
    JOIN Cliente c ON c.id_cliente = m.id_cliente
    WHERE m.id_pai = @id_post
    ORDER BY m.curtidas DESC;
END;
GO

CREATE PROCEDURE sp_ComentariosListar_Publicos -- funcionando
    @id_post INT
AS
BEGIN
    -- Confere se o post existe (independente da visibilidade)
    IF NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem = @id_post AND id_pai IS NULL)
        RETURN;

    -- Retorna apenas os comentários públicos
    SELECT 
		m.titulo,
        m.id_mensagem,
        c.nome AS autor,
		c.username,
		c.imagem_perfil,
        m.conteudo,
        m.data_postagem,
		m.curtidas
    FROM Mensagem m
    JOIN Cliente c ON c.id_cliente = m.id_cliente
    WHERE m.id_pai = @id_post
      AND m.visibilidade = 1
    ORDER BY m.curtidas DESC;
END;
GO

CREATE PROCEDURE sp_PostCompleto -- funcionando
    @id_post INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem = @id_post AND id_pai IS NULL)
        RETURN;

    ;WITH Hierarquia AS (
        -- 1. Post principal
        SELECT m.titulo, m.id_mensagem, m.id_pai, m.conteudo, m.data_postagem, m.curtidas, c.nome AS autor, c.username, c.imagem_perfil, 0 AS nivel
        FROM Mensagem m
        JOIN Cliente c ON c.id_cliente = m.id_cliente
        WHERE m.id_mensagem = @id_post

        UNION ALL

        -- 2. Comentários recursivos
        SELECT m.titulo, m.id_mensagem, m.id_pai, m.conteudo, m.data_postagem, m.curtidas, c.nome AS autor, c.username, c.imagem_perfil, h.nivel + 1
        FROM Mensagem m
        JOIN Cliente c ON c.id_cliente = m.id_cliente
        JOIN Hierarquia h ON m.id_pai = h.id_mensagem
    )
    SELECT *
    FROM Hierarquia
    ORDER BY nivel, curtidas;
END;
GO

CREATE PROCEDURE sp_PostCompleto_Publico -- funcionando
   @id_post INT
AS
BEGIN
    -- Verifica se o post público existe
    IF NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem = @id_post AND id_pai IS NULL AND visibilidade = 1)
        RETURN;

    ;WITH Hierarquia AS (
        -- 1. Post principal (somente público)
        SELECT m.titulo, m.id_mensagem, m.id_pai, m.conteudo, m.data_postagem, m.curtidas, c.nome AS autor, c.username, c.imagem_perfil, 0 AS nivel
        FROM Mensagem m
        JOIN Cliente c ON c.id_cliente = m.id_cliente
        WHERE m.id_mensagem = @id_post AND m.visibilidade = 1

        UNION ALL

        -- 2. Comentários recursivos (somente públicos)
        SELECT m.titulo, m.id_mensagem, m.id_pai, m.conteudo, m.data_postagem, m.curtidas, c.nome AS autor, c.username, c.imagem_perfil, h.nivel + 1
        FROM Mensagem m
        JOIN Cliente c ON c.id_cliente = m.id_cliente
        JOIN Hierarquia h ON m.id_pai = h.id_mensagem
        WHERE m.visibilidade = 1
    )
    SELECT *
    FROM Hierarquia
    ORDER BY nivel, data_postagem; -- mantém a ordem de hierarquia e cronológica
END;
GO

CREATE PROCEDURE sp_MensagemExcluir -- funcionando
    @id_mensagem INT
AS
BEGIN
    -- 1. Verifica se a mensagem existe e está publica
    IF NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem = @id_mensagem AND visibilidade = 1)
        RETURN;

    -- 2. Atualiza visibilidade para privada
    UPDATE Mensagem
    SET visibilidade = 0
    WHERE id_mensagem = @id_mensagem;

    SELECT 'OK' AS msg;
END;
GO

-- Listar denúncias
CREATE PROCEDURE sp_DenunciasListar -- funcionando
AS
BEGIN
  SELECT id_denuncia, id_mensagem, id_cliente, id_funcionario, data_denuncia, motivo, status_denuncia, acao_tomada
  FROM Denuncia
  ORDER BY data_denuncia DESC;
END
GO

-- Ver denúncia por id
CREATE PROCEDURE sp_DenunciaVer -- funcionando
  @id_denuncia INT
AS
BEGIN
  SELECT * FROM Denuncia WHERE id_denuncia=@id_denuncia;
END
GO

-- Suspender leitor
CREATE PROCEDURE sp_LeitorSuspender -- funcionando
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  RETURN;

  IF EXISTS (SELECT 1 FROM Cliente WHERE email=@email AND status_conta='banido')
  RETURN;

  UPDATE Cliente SET status_conta='banido' WHERE email=@email;
  SELECT 'OK' AS msg;
END
GO

-- Histórico de posts do leitor
CREATE PROCEDURE sp_LeitorPostsHistorico -- funcionando
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  RETURN;

  SELECT m.id_mensagem, m.conteudo, m.data_postagem, m.visibilidade, c.imagem_perfil, c.nome, c.username
  FROM Mensagem m
  JOIN Cliente c ON c.id_cliente = m.id_cliente
  WHERE c.email=@email
  ORDER BY m.data_postagem DESC;
END
GO

-- !!!EMPRESTIMOS/RESERVA/DEVOLUÇÃO!!!
	

-- Adicionar empréstimo e marcar mídia como emprestada 
CREATE PROCEDURE sp_EmprestimoAdicionar
  @email_cliente      VARCHAR(100),
  @email_funcionario  VARCHAR(100),
  @id_midia           INT,
  @data_emprestimo    DATETIME,
  @data_devolucao     DATETIME
AS
BEGIN
  DECLARE @id_cliente INT, @id_funcionario INT;

  SELECT @id_cliente = id_cliente FROM Cliente WHERE email=@email_cliente AND status_conta='ativo';
  IF @id_cliente IS NULL RETURN;

  SELECT @id_funcionario = id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL RETURN;

  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia AND status_midia='publica') RETURN;
  IF EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia AND disponibilidade='emprestado') RETURN;

  INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes, status_pagamento)
  VALUES (@id_cliente, @id_funcionario, @id_midia, NULL, @data_emprestimo, @data_devolucao, 0, 'pendente');

  UPDATE Midia SET disponibilidade='emprestado' WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_ReservaCriar -- funcionando
  @email       VARCHAR(100),
  @id_midia    INT        = NULL,
  @isbn        VARCHAR(20)= NULL,
  @titulo      VARCHAR(255)= NULL,
  @id_tpmidia  INT        = NULL
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @id_cliente INT, @hoje DATE = CAST(GETDATE() AS DATE), @dias_reserva INT = 3;
  DECLARE @id_midia_escolhida INT;

  -- cliente
  SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email AND status_conta = 'ativo';
  IF @id_cliente IS NULL RETURN;

  -- achar exemplar disponível
  IF @id_midia IS NOT NULL
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia AND disponibilidade='disponível' AND status_midia = 'publica')
    RETURN;
    SET @id_midia_escolhida = @id_midia;
  END
  ELSE IF @isbn IS NOT NULL AND @isbn <> ''
  BEGIN
    SELECT TOP 1 @id_midia_escolhida = id_midia
    FROM Midia
    WHERE isbn = @isbn AND disponibilidade = 'disponível' AND status_midia = 'publica'
    ORDER BY codigo_exemplar;  -- menor primeiro
    IF @id_midia_escolhida IS NULL
    RETURN;
  END
  ELSE
  BEGIN
    -- por título + tipo
    IF @titulo IS NULL OR @id_tpmidia IS NULL
    RETURN;

    SELECT TOP 1 @id_midia_escolhida = id_midia
    FROM Midia
    WHERE titulo=@titulo AND id_tpmidia=@id_tpmidia AND disponibilidade='disponível' AND status_midia = 'publica'
    ORDER BY codigo_exemplar;
    IF @id_midia_escolhida IS NULL
    RETURN;
  END

  -- evitar duplicidade de reserva ativa para a MESMA OBRA
  IF EXISTS (
    SELECT 1
    FROM Reserva r
    JOIN Midia  m1 ON m1.id_midia = r.id_midia
    JOIN Midia  m2 ON m2.id_midia = @id_midia_escolhida
    WHERE r.id_cliente = @id_cliente
      AND r.status_reserva = 'ativa'
      AND (
            (m1.isbn IS NOT NULL AND m2.isbn IS NOT NULL AND m1.isbn = m2.isbn)
         OR ( (m1.isbn IS NULL OR m1.isbn='') AND (m2.isbn IS NULL OR m2.isbn='') 
              AND m1.titulo = m2.titulo AND m1.id_tpmidia = m2.id_tpmidia )
          )
  )
  BEGIN
	RETURN;
  END

  -- cria reserva
  INSERT INTO Reserva (id_cliente, id_midia, data_reserva, data_limite, status_reserva)
  VALUES (@id_cliente, @id_midia_escolhida, @hoje, DATEADD(DAY, @dias_reserva, @hoje), 'ativa');

  SELECT 'OK' AS msg;
END
GO

-- Transformar reserva em empréstimo
CREATE PROCEDURE sp_ReservaTransformarEmEmprestimo -- funcionando
  @id_reserva INT,
  @email_funcionario VARCHAR(100),
  @data_emprestimo DATETIME,
  @data_devolucao  DATETIME
AS
BEGIN
  DECLARE @id_cliente INT, @id_midia INT, @status_reserva VARCHAR(20), @id_funcionario INT;

  SELECT @id_cliente=id_cliente, @id_midia=id_midia, @status_reserva=status_reserva
  FROM Reserva
  WHERE id_reserva=@id_reserva;

  IF @id_cliente IS NULL RETURN;
  IF @status_reserva <> 'ativa' RETURN;

  SELECT @id_funcionario = id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL RETURN;

  IF EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia AND disponibilidade='emprestado')
  RETURN;

  INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes, status_pagamento)
  VALUES (@id_cliente, @id_funcionario, @id_midia, @id_reserva, @data_emprestimo, @data_devolucao, 0, 'pendente');

  UPDATE Reserva SET status_reserva='concluida' WHERE id_reserva=@id_reserva;
  UPDATE Midia   SET disponibilidade='emprestado' WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_TodosEmprestimosComAtraso -- funcionando
AS
BEGIN
  SELECT 
    e.id_emprestimo,
    e.id_cliente,
    c.nome AS cliente,
	c.username,
	c.imagem_perfil,
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

CREATE PROCEDURE sp_TodosEmprestimos
AS
BEGIN
  SELECT *
  FROM Emprestimo
  ORDER BY id_emprestimo ASC;
END
GO

CREATE PROCEDURE sp_DevolverMidia -- funcionando
  @id_emprestimo INT
AS
BEGIN
  DECLARE @id_midia INT;

  SELECT @id_midia = id_midia
  FROM Emprestimo
  WHERE id_emprestimo=@id_emprestimo;

  IF @id_midia IS NULL
  RETURN;

  UPDATE Midia
     SET disponibilidade = 'disponível'
   WHERE id_midia=@id_midia;

  UPDATE Emprestimo
     SET limite_renovacoes = 0,
         status_pagamento = 'pago'
   WHERE id_emprestimo=@id_emprestimo;

  SELECT 'OK' AS msg;
END
GO

-- Informações do exemplar + leitor que está com ele (se tiver)
CREATE PROCEDURE sp_ExemplarInfoComLeitor -- FUNCIONANDO
  @id_midia INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE 
      @isbn        VARCHAR(20),
      @titulo      VARCHAR(255),
      @id_tpmidia  INT,
      @hoje        DATE = CAST(GETDATE() AS DATE),
      @prazo_padrao INT;

  -- mídia de referência
  SELECT @isbn = isbn, @titulo = titulo, @id_tpmidia = id_tpmidia
  FROM Midia
  WHERE id_midia = @id_midia;

  IF @titulo IS NULL RETURN;

  -- prazo padrão para detectar "renovada"
  SELECT TOP 1 @prazo_padrao = prazo_devolucao_dias
  FROM Parametros
  ORDER BY id_parametros DESC;

  ;WITH Exemplares AS (
    SELECT m.*
    FROM Midia m
    WHERE
      (
        @isbn IS NOT NULL AND @isbn <> '' 
        AND m.isbn = @isbn                            -- mesma obra (com ISBN)
      )
      OR
      (
        (@isbn IS NULL OR @isbn = '')                 -- obra sem ISBN...
        AND (m.isbn IS NULL OR m.isbn = '')           -- ...só entra quem tbm não tem ISBN
        AND m.titulo = @titulo
        AND m.id_tpmidia = @id_tpmidia                -- mesma obra (sem ISBN): título+tipo
      )
  )
  SELECT 
      m.isbn,
      m.codigo_exemplar,
      m.id_midia,
      m.titulo,
      m.disponibilidade,
      e.id_emprestimo,
      c.id_cliente,
      c.nome           AS cliente,
      c.username,
      c.imagem_perfil,
      e.data_devolucao,
      CASE 
        WHEN e.id_emprestimo IS NOT NULL 
             AND e.status_pagamento = 'pendente'
             AND @hoje > e.data_devolucao
          THEN 'atrasada'
        WHEN e.id_emprestimo IS NOT NULL 
             AND e.status_pagamento = 'pendente'
             AND @prazo_padrao IS NOT NULL
             AND e.data_devolucao > DATEADD(DAY, @prazo_padrao, e.data_emprestimo)
          THEN 'renovada'
        WHEN e.id_emprestimo IS NOT NULL 
             AND e.status_pagamento = 'pendente'
          THEN 'emprestada'
        WHEN r.id_reserva IS NOT NULL 
          THEN 'reservada'
        ELSE 'livre'
      END AS status
  FROM Exemplares m
  LEFT JOIN Emprestimo e 
         ON e.id_midia = m.id_midia
        AND e.status_pagamento = 'pendente'   -- só o empréstimo “aberto”
  LEFT JOIN Cliente c    
         ON c.id_cliente = e.id_cliente
  LEFT JOIN Reserva r
         ON r.id_midia = m.id_midia
        AND r.status_reserva = 'ativa'
        AND r.data_limite >= @hoje
  ORDER BY m.codigo_exemplar;
END
GO
--!!!MIDIA/MANUTENCAO ACERVO!!!

CREATE PROCEDURE sp_MidiaAdicionar_Livro
  @email_funcionario VARCHAR(100),
  @titulo VARCHAR(255),
  @sinopse VARCHAR(255),
  @autor VARCHAR(100),
  @editora VARCHAR(100),
  @ano_publicacao INT,
  @edicao VARCHAR(50) = NULL,
  @local_publicacao VARCHAR(100) = NULL,
  @numero_paginas INT = NULL,
  @isbn VARCHAR(20),
  @genero VARCHAR(100),
  @disponibilidade VARCHAR(20) = 'disponível',
  @imagem_base64 NVARCHAR(MAX) = NULL
AS
BEGIN
  DECLARE @id_funcionario INT, @id_tpmidia INT, @img VARBINARY(MAX);
  SELECT @id_funcionario=id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL RETURN;

  SELECT @id_tpmidia = id_tpmidia FROM TipoMidia WHERE nome_tipo='livros';
  IF @id_tpmidia IS NULL RETURN;

  SET @img = dbo.fn_DecodeBase64(@imagem_base64);

  INSERT INTO Midia (id_funcionario,id_tpmidia,titulo,sinopse,autor,editora,ano_publicacao,edicao,local_publicacao,numero_paginas,isbn,disponibilidade,genero,imagem)
  VALUES (@id_funcionario,@id_tpmidia,@titulo,@sinopse,@autor,@editora,@ano_publicacao,@edicao,@local_publicacao,@numero_paginas,@isbn,@disponibilidade,@genero,@img);

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAdicionar_Filme
  @email_funcionario VARCHAR(100),
  @titulo VARCHAR(255),
  @sinopse VARCHAR(255),
  @roteirista VARCHAR(100),
  @estudio VARCHAR(100),
  @duracao VARCHAR(20),
  @ano_publicacao INT = NULL,
  @genero VARCHAR(100),
  @disponibilidade VARCHAR(20) = 'disponível',
  @imagem_base64 NVARCHAR(MAX) = NULL
AS
BEGIN
  DECLARE @id_funcionario INT, @id_tpmidia INT, @img VARBINARY(MAX);
  SELECT @id_funcionario=id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL RETURN;

  SELECT @id_tpmidia = id_tpmidia FROM TipoMidia WHERE nome_tipo='filmes';
  IF @id_tpmidia IS NULL RETURN;

  SET @img = dbo.fn_DecodeBase64(@imagem_base64);

  INSERT INTO Midia (id_funcionario,id_tpmidia,titulo,sinopse,roteirista,estudio,duracao,ano_publicacao,disponibilidade,genero,imagem)
  VALUES (@id_funcionario,@id_tpmidia,@titulo,@sinopse,@roteirista,@estudio,@duracao,@ano_publicacao,@disponibilidade,@genero,@img);

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAdicionar_Revista
  @email_funcionario VARCHAR(100),
  @titulo VARCHAR(255),
  @sinopse VARCHAR(255),
  @editora VARCHAR(100),
  @ano_publicacao INT,
  @local_publicacao VARCHAR(100) = NULL,
  @numero_paginas INT = NULL,
  @genero VARCHAR(100),
  @disponibilidade VARCHAR(20) = 'disponível',
  @imagem_base64 NVARCHAR(MAX) = NULL
AS
BEGIN
  DECLARE @id_funcionario INT, @id_tpmidia INT, @img VARBINARY(MAX);
  SELECT @id_funcionario=id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL RETURN;

  SELECT @id_tpmidia = id_tpmidia FROM TipoMidia WHERE nome_tipo='revistas';
  IF @id_tpmidia IS NULL RETURN;

  SET @img = dbo.fn_DecodeBase64(@imagem_base64);

  INSERT INTO Midia (id_funcionario,id_tpmidia,titulo,sinopse,editora,ano_publicacao,local_publicacao,numero_paginas,disponibilidade,genero,imagem)
  VALUES (@id_funcionario,@id_tpmidia,@titulo,@sinopse,@editora,@ano_publicacao,@local_publicacao,@numero_paginas,@disponibilidade,@genero,@img);

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAlterar_Livro
  @id_midia INT,
  @titulo VARCHAR(255) = NULL,
  @sinopse VARCHAR(255) = NULL,
  @autor VARCHAR(100) = NULL,
  @editora VARCHAR(100) = NULL,
  @ano_publicacao INT = NULL,
  @edicao VARCHAR(50) = NULL,
  @local_publicacao VARCHAR(100) = NULL,
  @numero_paginas INT = NULL,
  @isbn VARCHAR(20) = NULL,
  @disponibilidade VARCHAR(20) = NULL,
  @genero VARCHAR(100) = NULL,
  @imagem_base64 NVARCHAR(MAX) = NULL
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia) RETURN;

  DECLARE @img VARBINARY(MAX) = dbo.fn_DecodeBase64(@imagem_base64);

  UPDATE Midia
  SET titulo           = COALESCE(@titulo, titulo),
      sinopse          = COALESCE(@sinopse, sinopse),
      autor            = COALESCE(@autor, autor),
      editora          = COALESCE(@editora, editora),
      ano_publicacao   = COALESCE(@ano_publicacao, ano_publicacao),
      edicao           = COALESCE(@edicao, edicao),
      local_publicacao = COALESCE(@local_publicacao, local_publicacao),
      numero_paginas   = COALESCE(@numero_paginas, numero_paginas),
      isbn             = COALESCE(@isbn, isbn),
      disponibilidade  = COALESCE(@disponibilidade, disponibilidade),
      genero           = COALESCE(@genero, genero),
      imagem           = COALESCE(@img, imagem)
  WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAlterar_Filme
  @id_midia INT,
  @titulo VARCHAR(255) = NULL,
  @sinopse VARCHAR(255) = NULL,
  @roteirista VARCHAR(100) = NULL,
  @estudio VARCHAR(100) = NULL,
  @duracao VARCHAR(20) = NULL,
  @ano_publicacao INT = NULL,
  @disponibilidade VARCHAR(20) = NULL,
  @genero VARCHAR(100) = NULL,
  @imagem_base64 NVARCHAR(MAX) = NULL
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia) RETURN;

  DECLARE @img VARBINARY(MAX) = dbo.fn_DecodeBase64(@imagem_base64);

  UPDATE Midia
  SET titulo          = COALESCE(@titulo, titulo),
      sinopse         = COALESCE(@sinopse, sinopse),
      roteirista      = COALESCE(@roteirista, roteirista),
      estudio         = COALESCE(@estudio, estudio),
      duracao         = COALESCE(@duracao, duracao),
      ano_publicacao  = COALESCE(@ano_publicacao, ano_publicacao),
      disponibilidade = COALESCE(@disponibilidade, disponibilidade),
      genero          = COALESCE(@genero, genero),
      imagem          = COALESCE(@img, imagem)
  WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAlterar_Revista
  @id_midia INT,
  @titulo VARCHAR(255) = NULL,
  @sinopse VARCHAR(255) = NULL,
  @editora VARCHAR(100) = NULL,
  @ano_publicacao INT = NULL,
  @local_publicacao VARCHAR(100) = NULL,
  @numero_paginas INT = NULL,
  @disponibilidade VARCHAR(20) = NULL,
  @genero VARCHAR(100) = NULL,
  @imagem_base64 NVARCHAR(MAX) = NULL
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia) RETURN;

  DECLARE @img VARBINARY(MAX) = dbo.fn_DecodeBase64(@imagem_base64);

  UPDATE Midia
  SET titulo           = COALESCE(@titulo, titulo),
      sinopse          = COALESCE(@sinopse, sinopse),
      editora          = COALESCE(@editora, editora),
      ano_publicacao   = COALESCE(@ano_publicacao, ano_publicacao),
      local_publicacao = COALESCE(@local_publicacao, local_publicacao),
      numero_paginas   = COALESCE(@numero_paginas, numero_paginas),
      disponibilidade  = COALESCE(@disponibilidade, disponibilidade),
      genero           = COALESCE(@genero, genero),
      imagem           = COALESCE(@img, imagem)
  WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO


CREATE PROCEDURE sp_MidiaInativar -- FUNCIONANDO
  @id_midia INT
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia)
  RETURN;

  UPDATE Midia
     SET status_midia='privada'
   WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

-- !!!INDICACOES!!

CREATE PROCEDURE sp_IndicacoesResumo -- funcionando
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

CREATE PROCEDURE sp_IndicacoesTop5 -- funcionando
AS
BEGIN
  SELECT TOP 5
    titulo_ind AS titulo,
    autor_ind  AS autor,
    COUNT(*)   AS qtd_indicacoes
  FROM Indicacao
  GROUP BY titulo_ind, autor_ind
  ORDER BY qtd_indicacoes DESC;
END
GO

CREATE PROCEDURE sp_ListarIndicacoes -- funcionando
AS
BEGIN
  SELECT 
    titulo_ind AS titulo,
    autor_ind  AS autor,
	(SELECT username FROM Cliente where id_cliente = i.id_cliente) username,
	(SELECT imagem_perfil FROM Cliente WHERE id_cliente = i.id_cliente) imagem_cliente
  FROM Indicacao i
  ORDER BY data_indicacao DESC;
END
GO

-- !!!!!!!!!!!!!!!!!COMUM!!!!!!!!!!!!!!!!!!!!!!!!!


CREATE PROCEDURE sp_AcervoBuscar -- funcionando
  @q            VARCHAR(255) = NULL,
  @tipo         VARCHAR(50)  = NULL,   -- 'livros','filmes','revistas','e-book'
  @genero       VARCHAR(100) = NULL,
  @ano_min      INT = NULL,
  @ano_max      INT = NULL,
  @so_publica   BIT = 1,               -- 1 = só status_midia = 'publica'
  @so_disponiveis BIT = NULL           -- 1 = apenas disponibilidade='disponível'; 0 = apenas 'emprestado'; NULL = ambos
AS
BEGIN
  SELECT 
    m.id_midia, m.titulo, m.autor, m.editora, m.ano_publicacao, m.genero,
    tm.nome_tipo, m.disponibilidade, m.isbn, m.estudio, m.roteirista, m.status_midia
  FROM Midia m
  JOIN TipoMidia tm ON tm.id_tpmidia = m.id_tpmidia
  WHERE (@q IS NULL OR (
           m.titulo      LIKE '%'+@q+'%' OR
           m.autor       LIKE '%'+@q+'%' OR
           m.roteirista  LIKE '%'+@q+'%' OR
           m.editora     LIKE '%'+@q+'%' OR
           m.isbn        LIKE '%'+@q+'%'
        ))
    AND (@tipo   IS NULL OR tm.nome_tipo = @tipo)
    AND (@genero IS NULL OR m.genero     = @genero)
    AND (@ano_min IS NULL OR m.ano_publicacao >= @ano_min)
    AND (@ano_max IS NULL OR m.ano_publicacao <= @ano_max)
    AND (@so_publica = 0 OR m.status_midia='publica')
    AND (
          @so_disponiveis IS NULL
          OR (@so_disponiveis=1 AND m.disponibilidade='disponível')
          OR (@so_disponiveis=0 AND m.disponibilidade='emprestado')
        )
  ORDER BY m.titulo;
END
GO

--------------------------------------
-- EVENTOS (FÓRUM) / POSTS / DENÚNCIA
--------------------------------------

CREATE PROCEDURE sp_CriarDenuncia -- funcionando
  @email_cliente VARCHAR(100),
  @id_mensagem   INT,
  @motivo        VARCHAR(255)
AS
BEGIN
  DECLARE @id_cliente INT;

  SELECT @id_cliente = id_cliente FROM Cliente WHERE email=@email_cliente;
  IF @id_cliente IS NULL RETURN;

  IF NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem=@id_mensagem)
  RETURN;

  INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status_denuncia, acao_tomada)
  VALUES (NULL, @id_mensagem, @id_cliente, GETDATE(), @motivo, 'pendente', NULL);

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_DenunciaAnalisar -- funcionando
    @id_denuncia INT,
    @email_funcionario VARCHAR(100),
    @motivo VARCHAR(255) = NULL
AS
BEGIN
    DECLARE @id_funcionario INT;
	IF NOT EXISTS (SELECT 1 FROM Denuncia WHERE id_denuncia = @id_denuncia)
    RETURN;

	SELECT top 1 @id_funcionario = id_funcionario FROM Funcionario WHERE email = @email_funcionario AND status_conta = 'ativo';
    IF @id_funcionario IS NULL RETURN;

    DECLARE @id_cliente INT;  
    SELECT top 1 @id_cliente = id_cliente FROM Denuncia WHERE id_denuncia = @id_denuncia;

    UPDATE Denuncia
    SET id_funcionario = @id_funcionario,
        status_denuncia = 'resolvida',
		acao_tomada = 'banido'
    WHERE id_denuncia = @id_denuncia;

	UPDATE Cliente
	SET status_conta = 'banido'
	WHERE id_cliente = @id_cliente

    INSERT INTO Notificacao (id_cliente, titulo, mensagem)
        VALUES (
            @id_cliente,
            'Conta Banida',
            'Sua conta foi banida pelo seguinte motivo: ' + @motivo
        );
    SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_TopLivrosPopularesGeral
AS
BEGIN
  SET NOCOUNT ON;

  SELECT TOP (15)
         MIN(m.id_midia) AS id_midia_exemplo,
         CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END AS chave,
         MIN(m.titulo)          AS titulo,
         MIN(m.autor)           AS autor,
         MIN(m.genero)          AS genero,
         MIN(m.imagem)          AS imagem,
         MIN(m.ano_publicacao)  AS ano_publicacao,
         COUNT(e.id_emprestimo) AS qtde_emprestimos
  FROM Emprestimo e
  JOIN Midia      m  ON m.id_midia   = e.id_midia
  JOIN TipoMidia  tm ON tm.id_tpmidia= m.id_tpmidia
  WHERE tm.nome_tipo = 'livros'
    AND m.status_midia = 'publica'
  GROUP BY CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END
  ORDER BY qtde_emprestimos DESC, titulo;
END
GO

CREATE PROCEDURE sp_Top15LivrosPorGenero
  @genero VARCHAR(100)
AS
BEGIN
  SET NOCOUNT ON;
  IF @genero IS NULL OR LTRIM(RTRIM(@genero)) = '' RETURN;

  ;WITH ObrasDoGenero AS (
    SELECT
      CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END AS chave,
      MIN(m.id_midia)       AS id_midia_exemplo,
      MIN(m.titulo)         AS titulo,
      MIN(m.autor)          AS autor,
      MAX(m.ano_publicacao) AS ano_recente,
      MAX(m.imagem)         AS imagem
    FROM Midia m
    JOIN TipoMidia tm ON tm.id_tpmidia = m.id_tpmidia
    WHERE tm.nome_tipo   = 'livros'
      AND m.status_midia = 'publica'
      AND m.genero       = @genero
    GROUP BY CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END
  )
  SELECT TOP (15)
         id_midia_exemplo, chave, titulo, autor, ano_recente AS ano_publicacao, imagem
  FROM ObrasDoGenero
  ORDER BY ano_recente DESC, titulo;
END
GO

CREATE PROCEDURE sp_MidiasMesmoGeneroPorId
  @id_midia INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @genero_ref VARCHAR(100);
  SELECT @genero_ref = genero
  FROM Midia
  WHERE id_midia = @id_midia AND status_midia='publica';

  IF @genero_ref IS NULL RETURN;

  SELECT TOP (15)
         m.id_midia,
         m.titulo,
         m.autor,
         m.ano_publicacao,
         m.genero,
         m.imagem
  FROM Midia m
  WHERE m.genero = @genero_ref
    AND m.id_midia <> @id_midia
    AND m.status_midia = 'publica'
  ORDER BY m.ano_publicacao DESC, m.titulo;
END
GO



/*
EXEC sp_MidiasMesmoGeneroPorId @id_midia = 5;

INSERT INTO Midia (id_funcionario, id_tpmidia, titulo, sinopse, autor, editora, ano_publicacao, edicao, local_publicacao, numero_paginas, isbn, disponibilidade, genero)
VALUES
(1, 1, 'Capitães da Areia', 'Clássico sobre infância marginalizada em Salvador.', 'Jorge Amado', 'Companhia das Letras', 1937, '1ª', 'Salvador', 280, '9788520920017', 'disponível', 'Romance'),
(2, 1, 'Dom Casmurro', 'Polêmica sobre ciúmes e traição.', 'Machado de Assis', 'Globo', 1899, '2ª', 'Rio de Janeiro', 320, '9788520920116', 'disponível', 'Romance'),
(3, 1, 'Memórias Póstumas de Brás Cubas', 'Narrativa do além-túmulo.', 'Machado de Assis', 'Companhia das Letras', 1881, '1ª', 'Rio de Janeiro', 220, '9788520920215', 'disponível', 'Romance'),
(4, 1, 'O Quinze', 'Sobre a grande seca de 1915 no Ceará.', 'Rachel de Queiroz', 'José Olympio', 1930, '1ª', 'Fortaleza', 250, '9788520920314', 'disponível', 'Drama'),
(5, 1, 'Grande Sertão: Veredas', 'Obra-prima modernista.', 'João Guimarães Rosa', 'Nova Fronteira', 1956, '1ª', 'Belo Horizonte', 600, '9788520920413', 'disponível', 'Romance'),
(1, 1, 'A Hora da Estrela', 'Clássico de Clarice Lispector.', 'Clarice Lispector', 'Rocco', 1977, '1ª', 'Rio de Janeiro', 120, '9788520920512', 'disponível', 'Drama'),
(2, 1, 'O Alienista', 'Sátira sobre ciência e loucura.', 'Machado de Assis', 'Companhia Editora', 1882, '1ª', 'Rio de Janeiro', 90, '9788520920619', 'disponível', 'Comédia'),
(3, 1, 'Ensaio sobre a Cegueira', 'Crítica social de José Saramago.', 'José Saramago', 'Companhia das Letras', 1995, '1ª', 'Lisboa', 350, '9788520920715', 'disponível', 'Ficção Científica'),
(4, 1, 'O Alquimista', 'História de Santiago em busca de seu destino.', 'Paulo Coelho', 'HarperCollins', 1988, '1ª', 'Rio de Janeiro', 180, '9788520920811', 'disponível', 'Ficção'),
(5, 1, 'It: A Coisa', 'Terror clássico de Stephen King.', 'Stephen King', 'Scribner', 1986, '1ª', 'Nova York', 1138, '9788520920918', 'disponível', 'Terror'),
(1, 1, 'O Iluminado', 'Outro clássico de terror de Stephen King.', 'Stephen King', 'Doubleday', 1977, '1ª', 'Nova York', 688, '9788520921014', 'disponível', 'Terror'),
(2, 1, 'Admirável Mundo Novo', 'Distopia de Aldous Huxley.', 'Aldous Huxley', 'Chatto & Windus', 1932, '1ª', 'Londres', 311, '9788520921111', 'disponível', 'Ficção Científica'),
(3, 1, 'Neuromancer', 'Cyberpunk de William Gibson.', 'William Gibson', 'Ace Books', 1984, '1ª', 'Nova York', 271, '9788520921219', 'disponível', 'Ficção Científica'),
(4, 1, 'A Revolução dos Bichos', 'Fábula política.', 'George Orwell', 'Secker & Warburg', 1945, '1ª', 'Londres', 112, '9788520921317', 'disponível', 'Ficção Científica');
*/

/*
-- trigger com msdb
CREATE PROCEDURE dbo.sp_EventosInativarVencidos
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE Evento
     SET status_evento='inativo'
   WHERE status_evento='ativo'
     AND data_fim < GETDATE();
END
GO


USE msdb;
GO

DECLARE @job_name SYSNAME = N'Littera_InativarEventosVencidos';
DECLARE @schedule_name SYSNAME = N'Cadencia_30min_Littera'; -- nome exclusivo p/ evitar conflito
DECLARE @job_id UNIQUEIDENTIFIER;

-- 1) Se já existe, remove
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = @job_name)
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1;
END

IF EXISTS (SELECT 1 FROM msdb.dbo.sysschedules WHERE name = @schedule_name)
BEGIN
    EXEC msdb.dbo.sp_delete_schedule @schedule_name = @schedule_name;
END
GO

-- 2) Recria o JOB
DECLARE @job_id UNIQUEIDENTIFIER;
EXEC msdb.dbo.sp_add_job
    @job_name = N'Littera_InativarEventosVencidos',
    @enabled = 1,
    @description = N'Marca eventos com data_fim < GETDATE() como inativos',
    @owner_login_name = N'sa',
    @job_id = @job_id OUTPUT;

-- 3) Adiciona STEP
EXEC msdb.dbo.sp_add_jobstep
  @job_id = @job_id,
  @step_name = N'Executar sp_EventosInativarVencidos',
  @subsystem = N'TSQL',
  @database_name = N'Littera',
  @command = N'EXEC dbo.sp_EventosInativarVencidos;';

-- 4) Cria SCHEDULE (30 em 30 min)
DECLARE @schedule_id INT;
EXEC msdb.dbo.sp_add_schedule
  @schedule_name = N'Cadencia_30min_Littera',
  @freq_type = 4,            -- daily
  @freq_interval = 1,
  @freq_subday_type = 4,     -- minutes
  @freq_subday_interval = 30,
  @active_start_time = 000000,
  @schedule_id = @schedule_id OUTPUT;

-- 5) Anexa schedule ao job
EXEC msdb.dbo.sp_attach_schedule
  @job_id = @job_id,
  @schedule_id = @schedule_id;

-- 6) Direciona ao servidor
EXEC msdb.dbo.sp_add_jobserver
  @job_id = @job_id,
  @server_name = N'(LOCAL)'; -- ou nome do servidor, se preferir
GO
*/
