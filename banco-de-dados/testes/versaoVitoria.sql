-- !!!!!!!!!!!!!!!! ANDROID !!!!!!!!!!!!!!!!!!!!!!!


-- !!!MAIN!!!

USE Littera
GO

--Drop Procedure sp_AcervoBuscar, sp_AcervoMidiasTodasInfosComExemplares, sp_AcervoPrincipal, sp_AcervoSearchTitulos, sp_CadastrarCliente, sp_CadastrarFuncionario, sp_ClienteAlterarImagemPorEmail, sp_ClienteResetarSenhaViaCpfEmail, sp_ConfigurarParametros, sp_CriarDenuncia, sp_DenunciasListar, sp_DenunciaVer, sp_DevolverMidia, sp_EmprestimoAdicionar, sp_EmprestimosClienteListar, sp_EventoCriar, sp_EventoEditar, sp_EventoInativar, sp_EventosAtivos, sp_EventosHistorico, sp_ExemplarInfoComLeitor, sp_FuncionarioAlterar, sp_GetFuncionarioID, sp_HistoricoEmprestimosCliente, sp_HistoricoEmprestimosPagosCliente, sp_IndicacoesResumo, sp_InfoFuncionario, sp_AtualizarPerfilCliente, sp_LeitorBuscarPorNome, sp_LeitorPostsHistorico, sp_LeitorSuspender, sp_LoginCliente, sp_LoginFuncionario, sp_ListaDesejosAdicionar, sp_ListaDesejosCliente, sp_ListaDesejosExcluir, sp_MainListar, sp_MidiaAddSinopse, sp_MidiaAdicionar, sp_MidiaAlterar, sp_MidiaAlterarImagem, sp_MidiaComExemplares, sp_MidiaDetalheComSimilares, sp_MidiaExcluir, sp_MidiasPopulares, sp_NaoDevolveuMidia, sp_NotificacaoMarcarLida, sp_QtdEmprestimosAtrasados, sp_QtdEmprestimosPorMes, sp_QtdReservasPorMes, sp_QtdTotalEmprestimos, sp_ReservasClienteListar, sp_ReservaTransformarEmEmprestimo, sp_TodosEmprestimosComAtraso, sp_TodosFuncionarios, sp_EmprestimoRenovar
--GO

/*CREATE PROCEDURE sp_MidiaDetalheComSimilares -- popular banco pra testar dps e nn mandar mesmas midias
    @id_midia INT
AS
BEGIN
    -- similares por gênero
    SELECT TOP 10 m.id_midia, m.titulo, m.autor, m.ano_publicacao, m.genero
    FROM Midia m
    WHERE m.genero = (SELECT genero FROM Midia WHERE id_midia=@id_midia)
      AND m.id_midia <> @id_midia
    ORDER BY m.ano_publicacao DESC, m.titulo;
END
GO

CREATE PROCEDURE sp_MidiasPopulares -- Ignora testa dps
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

CREATE PROCEDURE sp_MainListar -- Ignora testa dps
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

*/

--exec sp_TopLivrosPopularesGeral
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
         COUNT(e.id_emprestimo) AS qtde_emprestimos
  FROM Emprestimo e
  JOIN Midia      m  ON m.id_midia   = e.id_midia
  JOIN TipoMidia  tm ON tm.id_tpmidia= m.id_tpmidia
  WHERE tm.nome_tipo = 'livros'
  GROUP BY CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END
  ORDER BY qtde_emprestimos DESC, titulo;
END
GO

--exec sp_Top15LivrosPorGenero @genero = 'romance'
--exec sp_MidiasMesmoGeneroPorId @id_midia = 1


CREATE PROCEDURE sp_Top15LivrosPorGenero
  @genero VARCHAR(100)
AS
BEGIN
  SET NOCOUNT ON;

  IF @genero IS NULL OR LTRIM(RTRIM(@genero)) = ''
  BEGIN
    SELECT 'Gênero inválido' AS msg; 
    RETURN;
  END

  ;WITH ObrasDoGenero AS (
    SELECT
      CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END AS chave,
      MIN(m.id_midia)       AS id_midia_exemplo,
      MIN(m.titulo)         AS titulo,
      MIN(m.autor)          AS autor,
      MAX(m.ano_publicacao) AS ano_recente
    FROM Midia m
    JOIN TipoMidia tm ON tm.id_tpmidia = m.id_tpmidia
    WHERE tm.nome_tipo = 'livros'
      AND m.genero = @genero
    GROUP BY CASE WHEN m.isbn IS NOT NULL AND m.isbn<>'' THEN m.isbn ELSE m.titulo END
  )
  SELECT TOP (15)
         id_midia_exemplo, chave, titulo, autor, ano_recente AS ano_publicacao
  FROM ObrasDoGenero
  ORDER BY ano_recente DESC, titulo;
END
GO
	

CREATE PROCEDURE sp_MidiasMesmoGeneroPorId
  @id_midia INT
AS
BEGIN
  SET NOCOUNT ON;

  -- pega o gênero da mídia de referência
  DECLARE @genero_ref VARCHAR(100);

  SELECT @genero_ref = genero
  FROM Midia
  WHERE id_midia = @id_midia;

  IF @genero_ref IS NULL
  BEGIN
    SELECT 'Mídia não encontrada ou sem gênero definido' AS msg;
    RETURN;
  END;

  -- retorna até 15 mídias do mesmo gênero (exceto a própria)
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
  ORDER BY m.ano_publicacao DESC, m.titulo;
END
GO
	

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

  IF @limite IS NULL BEGIN 
  --SELECT 'Empréstimo não encontrado' AS msg; 
  RETURN; 
  END;
  IF @limite <= 0 BEGIN 
  --SELECT 'Não pode renovar' AS msg; 
  RETURN; 
  END;

  IF @novadata <= CAST(GETDATE() AS DATE) BEGIN 
  --SELECT 'Data inválida: precisa ser após hoje' AS msg; 
  RETURN; 
  END;

  IF @novadata <= @data_atual BEGIN 
  --SELECT 'Data inválida: precisa ser após a data de devolução atual' AS msg; 
  RETURN; 
  END;

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
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END

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
  BEGIN 
    SELECT 'Cliente não encontrado' AS msg; 
    RETURN; 
  END

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

CREATE PROCEDURE sp_ReservasClienteListar --FUNCIONANDOOOOOO	
  @email  VARCHAR(100),
  @status VARCHAR(20) = NULL -- 'ativa' | 'expirada' | 'cancelada' | 'concluida' | NULL=todas
AS
BEGIN
  -- valida cliente
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN
    SELECT 'Cliente não encontrado' AS msg; 
    RETURN; 
  END;

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
  BEGIN 
      SELECT 'Cliente não encontrado' AS msg; 
      RETURN; 
  END

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
    AND e.status_pagamento = 'Pago'  -- Apenas os pagos
  ORDER BY e.data_devolucao DESC;
END
GO

-- !!!NOTIFICAÇÕES/ALERTAS !!!

CREATE PROCEDURE sp_NotificacaoMarcarLida -- funcionando
  @id_notificacao INT
AS
BEGIN
  UPDATE Notificacao
  SET lida = 1
  WHERE id_notificacao = @id_notificacao;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_NotificacoesGerarPendenciasCliente
  @email       VARCHAR(100),
  @dias_aviso  INT = 2  -- janela para "em breve"
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @id_cliente INT, @hoje DATE = CAST(GETDATE() AS DATE);
  SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email;
  IF @id_cliente IS NULL
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END;

  ---------------------------
  -- 1) DEVOLUÇÃO EM BREVE --
  ---------------------------
  ;WITH DevBreve AS (
    SELECT 
      e.id_emprestimo,
      m.titulo,
      DATEDIFF(DAY, @hoje, e.data_devolucao) AS dias_restantes
    FROM Emprestimo e
    JOIN Midia m ON m.id_midia = e.id_midia
    WHERE e.id_cliente = @id_cliente
      AND e.data_devolucao BETWEEN @hoje AND DATEADD(DAY, @dias_aviso, @hoje)
  )
  INSERT INTO Notificacao (id_cliente, titulo, mensagem)
  SELECT 
    @id_cliente,
    'Devolução em breve',
    CONCAT('O livro ', d.titulo, ' deve ser devolvido em breve (faltam ', d.dias_restantes, ' dia(s)).')
  FROM DevBreve d
  WHERE NOT EXISTS (
    SELECT 1 FROM Notificacao n
    WHERE n.id_cliente = @id_cliente
      AND n.titulo = 'Devolução em breve'
      AND n.mensagem LIKE CONCAT('%', d.titulo, '%')
      AND DATEDIFF(DAY, n.data_criacao, GETDATE()) <= 1
  );

  ----------------
  -- 2) ATRASO  --
  ----------------
  ;WITH Atrasos AS (
    SELECT 
      e.id_emprestimo,
      m.titulo,
      DATEDIFF(DAY, e.data_devolucao, @hoje) AS dias_atraso
    FROM Emprestimo e
    JOIN Midia m ON m.id_midia = e.id_midia
    WHERE e.id_cliente = @id_cliente
      AND e.data_devolucao < @hoje
  )
  INSERT INTO Notificacao (id_cliente, titulo, mensagem)
  SELECT 
    @id_cliente,
    'Empréstimo atrasado',
    CONCAT('O livro ', a.titulo, ' está atrasado em seu prazo de devolução em ', a.dias_atraso, ' dia(s).')
  FROM Atrasos a
  WHERE NOT EXISTS (
    SELECT 1 FROM Notificacao n
    WHERE n.id_cliente = @id_cliente
      AND n.titulo = 'Empréstimo atrasado'
      AND n.mensagem LIKE CONCAT('%', a.titulo, '%')
      AND DATEDIFF(DAY, n.data_criacao, GETDATE()) <= 1
  );

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_NotificacoesListarPendenciasCliente
  @email       VARCHAR(100),
  @dias_aviso  INT = 2
AS
BEGIN
  DECLARE @id_cliente INT, @hoje DATE = CAST(GETDATE() AS DATE);
  SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email;
  IF @id_cliente IS NULL
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END;

  -- Em breve
  SELECT 
    'Devolução em breve' AS tipo,
    m.titulo,
    CONCAT('O livro ', m.titulo, ' deve ser devolvido em breve (faltam ', DATEDIFF(DAY, @hoje, e.data_devolucao), ' dia(s)).') AS mensagem
  FROM Emprestimo e
  JOIN Midia m ON m.id_midia = e.id_midia
  WHERE e.id_cliente = @id_cliente
    AND e.data_devolucao BETWEEN @hoje AND DATEADD(DAY, @dias_aviso, @hoje)

  UNION ALL

  -- Atrasado
  SELECT 
    'Empréstimo atrasado' AS tipo,
    m.titulo,
    CONCAT('O livro ', m.titulo, ' está atrasado em seu prazo de devolução em ', DATEDIFF(DAY, e.data_devolucao, @hoje), ' dia(s).') AS mensagem
  FROM Emprestimo e
  JOIN Midia m ON m.id_midia = e.id_midia
  WHERE e.id_cliente = @id_cliente
    AND e.data_devolucao < @hoje
  ORDER BY tipo, titulo;
END
GO

	

-- !!! LISTA DE DESEJOS !!!

CREATE PROCEDURE sp_ListaDesejosCliente -- funcionando
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
    BEGIN
        SELECT 'Erro: Cliente não encontrado.' AS msg;
        RETURN;
    END

    -- Verificar se a mídia existe
    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia = @id_midia)
    BEGIN
        SELECT 'Erro: Mídia não encontrada.' AS msg;
        RETURN;
    END

    -- Deletar da lista de desejos
    DELETE FROM ListaDeDesejos
    WHERE id_cliente = @id_cliente AND id_midia = @id_midia;

    SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_ListaDesejosAdicionar
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
    BEGIN
        SELECT 'Erro: Cliente não encontrado.' AS msg;
        RETURN;
    END

    -- Verificar se a mídia existe
    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia = @id_midia)
    BEGIN
        SELECT 'Erro: Mídia não encontrada.' AS msg;
        RETURN;
    END

    -- Checar se já existe na lista
    IF EXISTS (
        SELECT 1 
        FROM ListaDeDesejos
        WHERE id_cliente = @id_cliente AND id_midia = @id_midia
    )
    BEGIN
        SELECT 'Já existe na lista' AS msg;
        RETURN;
    END

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

-- !!! LOGIN/CADASTRO CLIENTE !!!


CREATE PROCEDURE sp_LoginCliente -- funcionando
    @email VARCHAR(100),
    @senha VARCHAR(255)
AS
BEGIN
    SELECT id_cliente, nome, email, telefone, status_conta
    FROM Cliente
    WHERE email = @email AND senha = @senha AND status_conta = 'ativo';
END
GO

CREATE PROCEDURE sp_CadastrarCliente -- funcionando
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
    BEGIN
        SELECT 'Informe e-mail ou CPF' AS msg; 
        RETURN;
    END

    DECLARE @id_cliente INT;

    -- se vieram os dois, precisam pertencer ao MESMO cliente
    IF @email IS NOT NULL AND @cpf IS NOT NULL
    BEGIN
        SELECT @id_cliente = id_cliente
        FROM Cliente
        WHERE email = @email AND cpf = @cpf;

        IF @id_cliente IS NULL
        BEGIN
            SELECT 'Email/CPF não conferem' AS msg; 
            RETURN;
        END
    END
    ELSE IF @email IS NOT NULL
    BEGIN
        SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email;
        IF @id_cliente IS NULL
        BEGIN
            SELECT 'Email não encontrado' AS msg; 
            RETURN;
        END
    END
    ELSE  -- só CPF
    BEGIN
        SELECT @id_cliente = id_cliente FROM Cliente WHERE cpf = @cpf;
        IF @id_cliente IS NULL
        BEGIN
            SELECT 'CPF não encontrado' AS msg; 
            RETURN;
        END
    END

    UPDATE Cliente
    SET senha = @nova_senha
    WHERE id_cliente = @id_cliente;

    SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_AtualizarPerfilCliente -- funcionando
  @nome VARCHAR(50),
  @email VARCHAR(100),
  @senha VARCHAR(255),
  @telefone VARCHAR(20)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN
    SELECT 'Cliente não encontrado' AS msg; RETURN;
  END

  UPDATE Cliente
  SET senha=@senha,
	  nome=@nome,
      telefone=@telefone
  WHERE email=@email;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_ClienteAlterarImagemPorEmail -- funcionando
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
  SELECT id_cliente, nome, email, telefone, status_conta
  FROM Cliente
  WHERE nome LIKE '%' + @nome + '%'
  ORDER BY nome;
END
GO

-- Mídias não devolvidas pelo cliente (em atraso)
CREATE PROCEDURE sp_NaoDevolveuMidia  -- funcionando
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END;

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
CREATE PROCEDURE sp_EventoCriar -- funcionando
  @titulo NVARCHAR(200),
  @data_inicio DATETIME,
  @data_fim DATETIME,
  @local_evento NVARCHAR(200),
  @email NVARCHAR(200)
AS
BEGIN
  INSERT INTO Evento (titulo, data_inicio, data_fim, local_evento, id_funcionario, status_evento)
  VALUES (@titulo, @data_inicio, @data_fim, @local_evento, (select id_funcionario from Funcionario where email = @email), 'ativo');

  SELECT 'OK' AS msg;
END
GO

-- Editar
CREATE PROCEDURE sp_EventoEditar -- funcionando
  @id_evento INT,
  @titulo NVARCHAR(200),
  @data_inicio DATETIME,
  @data_fim DATETIME,
  @local_evento NVARCHAR(200),
  @email NVARCHAR(100)
AS
BEGIN
  UPDATE Evento
  SET titulo=@titulo,
      data_inicio=@data_inicio,
      data_fim=@data_fim,
      local_evento=@local_evento,
	  id_funcionario = (Select id_funcionario from Funcionario where email = @email)
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

-- !!!FÓRUM/DENUNCIAS!!!


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
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END;

  IF EXISTS (SELECT 1 FROM Cliente WHERE email=@email AND status_conta='banido')
  BEGIN SELECT 'Cliente já está banido' AS msg; RETURN; END;

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
CREATE PROCEDURE sp_EmprestimoAdicionar -- funcionando
  @email_cliente      VARCHAR(100),
  @email_funcionario  VARCHAR(100),
  @id_midia           INT,
  @data_emprestimo    DATETIME,
  @data_devolucao     DATETIME
AS
BEGIN
  DECLARE @id_cliente INT, @id_funcionario INT;

  SELECT @id_cliente = id_cliente FROM Cliente     WHERE email=@email_cliente;
  IF @id_cliente IS NULL BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END;

  SELECT @id_funcionario = id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL BEGIN SELECT 'Funcionário inválido' AS msg; RETURN; END;

  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia)
  BEGIN SELECT 'Mídia não encontrada' AS msg; RETURN; END;

  IF EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia AND disponibilidade='emprestado')
  BEGIN SELECT 'Mídia já emprestada' AS msg; RETURN; END;

  INSERT INTO Emprestimo (id_cliente, id_funcionario, id_midia, id_reserva, data_emprestimo, data_devolucao, limite_renovacoes, status_pagamento)
  VALUES (@id_cliente, @id_funcionario, @id_midia, NULL, @data_emprestimo, @data_devolucao, 0, 'pendente');

  UPDATE Midia SET disponibilidade='emprestado' WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_ReservaCriar
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
  SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email;
  IF @id_cliente IS NULL
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END;

  -- achar exemplar disponível
  IF @id_midia IS NOT NULL
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia AND disponibilidade='disponível')
    BEGIN SELECT 'Não há exemplar disponível desse id_midia' AS msg; RETURN; END;
    SET @id_midia_escolhida = @id_midia;
  END
  ELSE IF @isbn IS NOT NULL AND @isbn <> ''
  BEGIN
    SELECT TOP 1 @id_midia_escolhida = id_midia
    FROM Midia
    WHERE isbn = @isbn AND disponibilidade = 'disponível'
    ORDER BY codigo_exemplar;  -- menor primeiro
    IF @id_midia_escolhida IS NULL
    BEGIN SELECT 'Não há exemplar disponível desse ISBN' AS msg; RETURN; END;
  END
  ELSE
  BEGIN
    -- por título + tipo
    IF @titulo IS NULL OR @id_tpmidia IS NULL
    BEGIN SELECT 'Informe @id_midia, ou @isbn, ou (@titulo + @id_tpmidia)' AS msg; RETURN; END;

    SELECT TOP 1 @id_midia_escolhida = id_midia
    FROM Midia
    WHERE titulo=@titulo AND id_tpmidia=@id_tpmidia AND disponibilidade='disponível'
    ORDER BY codigo_exemplar;
    IF @id_midia_escolhida IS NULL
    BEGIN SELECT 'Não há exemplar disponível dessa obra' AS msg; RETURN; END;
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
    SELECT 'Já existe uma reserva ativa dessa obra para este cliente' AS msg; 
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

  IF @id_cliente IS NULL BEGIN SELECT 'Reserva não encontrada' AS msg; RETURN; END;
  IF @status_reserva <> 'ativa' BEGIN SELECT 'Reserva não está ativa' AS msg; RETURN; END;

  SELECT @id_funcionario = id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL BEGIN SELECT 'Funcionário inválido' AS msg; RETURN; END;

  IF EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia AND disponibilidade='emprestado')
  BEGIN SELECT 'Mídia já emprestada' AS msg; RETURN; END;

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


CREATE PROCEDURE sp_DevolverMidia -- funcionando
  @id_emprestimo INT
AS
BEGIN
  DECLARE @id_midia INT;

  SELECT @id_midia = id_midia
  FROM Emprestimo
  WHERE id_emprestimo=@id_emprestimo;

  IF @id_midia IS NULL
  BEGIN SELECT 'Empréstimo não encontrado' AS msg; RETURN; END;

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
CREATE PROCEDURE sp_ExemplarInfoComLeitor -- aparentemente funcionando mas verificar melhor dpois de popular o banco
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


CREATE PROCEDURE sp_MidiaAdicionar_Livro -- funcionando
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
  @disponibilidade VARCHAR(20) = 'disponível'
AS
BEGIN
  DECLARE @id_funcionario INT, @id_tpmidia INT;
  SELECT @id_funcionario=id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL BEGIN SELECT 'Funcionário inválido' AS msg; RETURN; END;

  SELECT @id_tpmidia = id_tpmidia FROM TipoMidia WHERE nome_tipo='livros';
  IF @id_tpmidia IS NULL BEGIN SELECT 'Tipo de mídia "livros" não cadastrado' AS msg; RETURN; END;

  INSERT INTO Midia (id_funcionario,id_tpmidia,titulo,sinopse,autor,editora,ano_publicacao,edicao,local_publicacao,numero_paginas,isbn,disponibilidade,genero)
  VALUES (@id_funcionario,@id_tpmidia,@titulo,@sinopse,@autor,@editora,@ano_publicacao,@edicao,@local_publicacao,@numero_paginas,@isbn,@disponibilidade,@genero);

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAdicionar_Filme -- funcionando
  @email_funcionario VARCHAR(100),
  @titulo VARCHAR(255),
  @sinopse VARCHAR(255),
  @roteirista VARCHAR(100),
  @estudio VARCHAR(100),
  @duracao VARCHAR(20),
  @ano_publicacao INT = NULL,
  @genero VARCHAR(100),
  @disponibilidade VARCHAR(20) = 'disponível'
AS
BEGIN
  DECLARE @id_funcionario INT, @id_tpmidia INT;
  SELECT @id_funcionario=id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL BEGIN SELECT 'Funcionário inválido' AS msg; RETURN; END;

  SELECT @id_tpmidia = id_tpmidia FROM TipoMidia WHERE nome_tipo='filmes';
  IF @id_tpmidia IS NULL BEGIN SELECT 'Tipo de mídia "filmes" não cadastrado' AS msg; RETURN; END;

  INSERT INTO Midia (id_funcionario,id_tpmidia,titulo,sinopse,roteirista,estudio,duracao,ano_publicacao,disponibilidade,genero)
  VALUES (@id_funcionario,@id_tpmidia,@titulo,@sinopse,@roteirista,@estudio,@duracao,@ano_publicacao,@disponibilidade,@genero);

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAdicionar_Revista -- funcionando
  @email_funcionario VARCHAR(100),
  @titulo VARCHAR(255),
  @sinopse VARCHAR(255),
  @editora VARCHAR(100),
  @ano_publicacao INT,
  @local_publicacao VARCHAR(100) = NULL,
  @numero_paginas INT = NULL,
  @genero VARCHAR(100),
  @disponibilidade VARCHAR(20) = 'disponível'
AS
BEGIN
  DECLARE @id_funcionario INT, @id_tpmidia INT;
  SELECT @id_funcionario=id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL BEGIN SELECT 'Funcionário inválido' AS msg; RETURN; END;

  SELECT @id_tpmidia = id_tpmidia FROM TipoMidia WHERE nome_tipo='revistas';
  IF @id_tpmidia IS NULL BEGIN SELECT 'Tipo de mídia "revistas" não cadastrado' AS msg; RETURN; END;

  INSERT INTO Midia (id_funcionario,id_tpmidia,titulo,sinopse,editora,ano_publicacao,local_publicacao,numero_paginas,disponibilidade,genero)
  VALUES (@id_funcionario,@id_tpmidia,@titulo,@sinopse,@editora,@ano_publicacao,@local_publicacao,@numero_paginas,@disponibilidade,@genero);

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAlterar_Livro -- funcionando
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
  @genero VARCHAR(100) = NULL
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia)
  BEGIN SELECT 'Mídia não encontrada' AS msg; RETURN; END;

  UPDATE Midia
  SET titulo           = CASE WHEN @titulo           IS NULL THEN titulo           ELSE @titulo           END,
      sinopse          = CASE WHEN @sinopse          IS NULL THEN sinopse          ELSE @sinopse          END,
      autor            = CASE WHEN @autor            IS NULL THEN autor            ELSE @autor            END,
      editora          = CASE WHEN @editora          IS NULL THEN editora          ELSE @editora          END,
      ano_publicacao   = CASE WHEN @ano_publicacao   IS NULL THEN ano_publicacao   ELSE @ano_publicacao   END,
      edicao           = CASE WHEN @edicao           IS NULL THEN edicao           ELSE @edicao           END,
      local_publicacao = CASE WHEN @local_publicacao IS NULL THEN local_publicacao ELSE @local_publicacao END,
      numero_paginas   = CASE WHEN @numero_paginas   IS NULL THEN numero_paginas   ELSE @numero_paginas   END,
      isbn             = CASE WHEN @isbn             IS NULL THEN isbn             ELSE @isbn             END,
      disponibilidade  = CASE WHEN @disponibilidade  IS NULL THEN disponibilidade  ELSE @disponibilidade  END,
      genero           = CASE WHEN @genero           IS NULL THEN genero           ELSE @genero           END
  WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAlterar_Filme -- funcionando
  @id_midia INT,
  @titulo VARCHAR(255) = NULL,
  @sinopse VARCHAR(255) = NULL,
  @roteirista VARCHAR(100) = NULL,
  @estudio VARCHAR(100) = NULL,
  @duracao VARCHAR(20) = NULL,
  @ano_publicacao INT = NULL,
  @disponibilidade VARCHAR(20) = NULL,
  @genero VARCHAR(100) = NULL
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia)
  BEGIN SELECT 'Mídia não encontrada' AS msg; RETURN; END;

  UPDATE Midia
  SET titulo          = CASE WHEN @titulo          IS NULL THEN titulo          ELSE @titulo          END,
      sinopse         = CASE WHEN @sinopse         IS NULL THEN sinopse         ELSE @sinopse         END,
      roteirista      = CASE WHEN @roteirista      IS NULL THEN roteirista      ELSE @roteirista      END,
      estudio         = CASE WHEN @estudio         IS NULL THEN estudio         ELSE @estudio         END,
      duracao         = CASE WHEN @duracao         IS NULL THEN duracao         ELSE @duracao         END,
      ano_publicacao  = CASE WHEN @ano_publicacao  IS NULL THEN ano_publicacao  ELSE @ano_publicacao  END,
      disponibilidade = CASE WHEN @disponibilidade IS NULL THEN disponibilidade ELSE @disponibilidade END,
      genero          = CASE WHEN @genero          IS NULL THEN genero          ELSE @genero          END
  WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_MidiaAlterar_Revista -- funcionando
  @id_midia INT,
  @titulo VARCHAR(255) = NULL,
  @sinopse VARCHAR(255) = NULL,
  @editora VARCHAR(100) = NULL,
  @ano_publicacao INT = NULL,
  @local_publicacao VARCHAR(100) = NULL,
  @numero_paginas INT = NULL,
  @disponibilidade VARCHAR(20) = NULL,
  @genero VARCHAR(100) = NULL
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia)
  BEGIN SELECT 'Mídia não encontrada' AS msg; RETURN; END;

  UPDATE Midia
  SET titulo           = CASE WHEN @titulo           IS NULL THEN titulo           ELSE @titulo           END,
      sinopse          = CASE WHEN @sinopse          IS NULL THEN sinopse          ELSE @sinopse          END,
      editora          = CASE WHEN @editora          IS NULL THEN editora          ELSE @editora          END,
      ano_publicacao   = CASE WHEN @ano_publicacao   IS NULL THEN ano_publicacao   ELSE @ano_publicacao   END,
      local_publicacao = CASE WHEN @local_publicacao IS NULL THEN local_publicacao ELSE @local_publicacao END,
      numero_paginas   = CASE WHEN @numero_paginas   IS NULL THEN numero_paginas   ELSE @numero_paginas   END,
      disponibilidade  = CASE WHEN @disponibilidade  IS NULL THEN disponibilidade  ELSE @disponibilidade  END,
      genero           = CASE WHEN @genero           IS NULL THEN genero           ELSE @genero           END
  WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO


CREATE PROCEDURE sp_MidiaInativar
  @id_midia INT
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia=@id_midia)
  BEGIN SELECT 'Mídia não encontrada' AS msg; RETURN; END;

  UPDATE Midia
     SET status_midia='privada'
   WHERE id_midia=@id_midia;

  SELECT 'OK' AS msg;
END
GO

--select * from Midia
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
  IF @id_cliente IS NULL BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END;

  IF NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem=@id_mensagem)
  BEGIN SELECT 'Mensagem não encontrada' AS msg; RETURN; END;

  INSERT INTO Denuncia (id_funcionario, id_mensagem, id_cliente, data_denuncia, motivo, status_denuncia, acao_tomada)
  VALUES (NULL, @id_mensagem, @id_cliente, GETDATE(), @motivo, 'pendente', NULL);

  SELECT 'OK' AS msg;
END
GO

CREATE PROCEDURE sp_DenunciaAnalisar -- funcionando
  @id_denuncia INT,
  @email_funcionario VARCHAR(100),
  @acao_tomada VARCHAR(255) = NULL
AS
BEGIN
  DECLARE @id_funcionario INT;
  IF NOT EXISTS (SELECT 1 FROM Denuncia WHERE id_denuncia=@id_denuncia)
  BEGIN SELECT 'Denúncia não encontrada' AS msg; RETURN; END;

  SELECT @id_funcionario = id_funcionario FROM Funcionario WHERE email=@email_funcionario AND status_conta='ativo';
  IF @id_funcionario IS NULL BEGIN SELECT 'Funcionário inválido' AS msg; RETURN; END;

  UPDATE Denuncia
     SET id_funcionario = @id_funcionario,
         status_denuncia = 'resolvida',
         acao_tomada = @acao_tomada
   WHERE id_denuncia=@id_denuncia;

  SELECT 'OK' AS msg;
END
GO

/* 
CREATE PROCEDURE sp_ListarEmprestimosCliente
    @email_cliente VARCHAR(100)
AS
BEGIN
    DECLARE @id_cliente INT;
    SET @id_cliente = (SELECT id_cliente FROM Cliente WHERE email = @email_cliente);

    IF @id_cliente IS NULL
    BEGIN
        SELECT 'Erro: Cliente não encontrado.' AS Resultado;
        RETURN;
    END

    SELECT 
        e.id_emprestimo,
        m.titulo,
        m.autor,
        m.ano,
        m.genero,
        m.imagem, -- CORRIGIDO: agora traz a imagem da mídia
        e.data_emprestimo,
        e.data_devolucao,
        e.data_devolvido
    FROM Emprestimo e
    INNER JOIN Midia m ON e.id_midia = m.id_midia
    WHERE e.id_cliente = @id_cliente
    ORDER BY e.data_emprestimo DESC;
END
GO

CREATE PROCEDURE sp_ListarEmprestimos
AS
BEGIN
    SELECT 
        e.id_emprestimo,
        c.nome AS cliente,
        c.email,
        m.titulo,
        m.autor,
        m.ano,
        m.genero,
        m.imagem, -- CORRIGIDO: agora traz a imagem da mídia
        e.data_emprestimo,
        e.data_devolucao,
        e.data_devolvido
    FROM Emprestimo e
    INNER JOIN Cliente c ON e.id_cliente = c.id_cliente
    INNER JOIN Midia m ON e.id_midia = m.id_midia
    ORDER BY e.data_emprestimo DESC;
END
GO

CREATE PROCEDURE sp_ListarAtrasados
AS
BEGIN
    SELECT 
        e.id_emprestimo,
        c.nome AS cliente,
        c.email,
        m.titulo,
        m.autor,
        m.imagem, -- CORRIGIDO: traz imagem do livro/filme atrasado
        e.data_emprestimo,
        e.data_devolucao
    FROM Emprestimo e
    INNER JOIN Cliente c ON e.id_cliente = c.id_cliente
    INNER JOIN Midia m ON e.id_midia = m.id_midia
    WHERE e.data_devolvido IS NULL
      AND e.data_devolucao < GETDATE()
    ORDER BY e.data_devolucao;
END
GO

-- =========================================================
-- CLIENTES
-- =========================================================

-- Atualizar Cliente (não altera CPF nem e-mail)
CREATE PROCEDURE sp_AtualizarCliente
    @email VARCHAR(100), -- chave de busca
    @nome VARCHAR(100) = NULL,
    @telefone VARCHAR(20) = NULL,
    @senha VARCHAR(100) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email = @email)
    BEGIN
        SELECT 'Erro: Cliente não encontrado.' AS Resultado;
        RETURN;
    END

    UPDATE Cliente
    SET nome = ISNULL(@nome, nome),
        telefone = ISNULL(@telefone, telefone),
        senha = ISNULL(@senha, senha)
    WHERE email = @email;

    SELECT 'Dados do cliente atualizados com sucesso!' AS Resultado;
END
GO


-- Excluir Cliente
CREATE PROCEDURE sp_ExcluirCliente
    @email VARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email = @email)
    BEGIN
        SELECT 'Erro: Cliente não encontrado.' AS Resultado;
        RETURN;
    END

    DELETE FROM Cliente WHERE email = @email;

    SELECT 'Cliente excluído com sucesso!' AS Resultado;
END
GO


-- Informações de um Cliente
CREATE PROCEDURE sp_InfoCliente
    @email VARCHAR(100)
AS
BEGIN
    SELECT id_cliente, nome, cpf, email, telefone
    FROM Cliente
    WHERE email = @email;
END
GO


-- Listar Clientes
CREATE PROCEDURE sp_ListarClientes
AS
BEGIN
    SELECT id_cliente, nome, cpf, email, telefone
    FROM Cliente
    ORDER BY nome;
END
GO

-- =========================================================
-- FUNCIONÁRIOS
-- =========================================================

-- Cadastrar Funcionário
CREATE PROCEDURE sp_CadastrarFuncionario
    @nome VARCHAR(100),
    @cpf CHAR(11),
    @email VARCHAR(100),
    @telefone VARCHAR(20),
    @senha VARCHAR(100),
    @id_cargo INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Funcionario WHERE email = @email)
    BEGIN
        SELECT 'Erro: Já existe funcionário com este e-mail.' AS Resultado;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Funcionario WHERE cpf = @cpf)
    BEGIN
        SELECT 'Erro: Já existe funcionário com este CPF.' AS Resultado;
        RETURN;
    END

    INSERT INTO Funcionario (nome, cpf, email, telefone, senha, id_cargo)
    VALUES (@nome, @cpf, @email, @telefone, @senha, @id_cargo);

    SELECT 'Funcionário cadastrado com sucesso!' AS Resultado;
END
GO


-- Atualizar Funcionário (não altera CPF nem e-mail)
CREATE PROCEDURE sp_AtualizarFuncionario
    @email VARCHAR(100),
    @nome VARCHAR(100) = NULL,
    @telefone VARCHAR(20) = NULL,
    @senha VARCHAR(100) = NULL,
    @id_cargo INT = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE email = @email)
    BEGIN
        SELECT 'Erro: Funcionário não encontrado.' AS Resultado;
        RETURN;
    END

    UPDATE Funcionario
    SET nome = ISNULL(@nome, nome),
        telefone = ISNULL(@telefone, telefone),
        senha = ISNULL(@senha, senha),
        id_cargo = ISNULL(@id_cargo, id_cargo)
    WHERE email = @email;

    SELECT 'Dados do funcionário atualizados com sucesso!' AS Resultado;
END
GO


-- Excluir Funcionário
CREATE PROCEDURE sp_ExcluirFuncionario
    @email VARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE email = @email)
    BEGIN
        SELECT 'Erro: Funcionário não encontrado.' AS Resultado;
        RETURN;
    END

    DELETE FROM Funcionario WHERE email = @email;

    SELECT 'Funcionário excluído com sucesso!' AS Resultado;
END
GO


-- Informações de um Funcionário
CREATE PROCEDURE sp_InfoFuncionario
    @email VARCHAR(100)
AS
BEGIN
    SELECT id_funcionario, nome, cpf, email, telefone, id_cargo
    FROM Funcionario
    WHERE email = @email;
END
GO


-- Listar Funcionários
CREATE PROCEDURE sp_ListarFuncionarios
AS
BEGIN
    SELECT id_funcionario, nome, cpf, email, telefone, id_cargo
    FROM Funcionario
    ORDER BY nome;
END
GO

-- =========================================================
-- MÍDIAS
-- =========================================================

-- Cadastrar Mídia



-- Atualizar Mídia
CREATE PROCEDURE sp_AtualizarMidia
    @id_midia INT,
    @titulo VARCHAR(200) = NULL,
    @autor VARCHAR(100) = NULL,
    @ano_publicacao INT = NULL,
    @editora VARCHAR(100) = NULL,
    @categoria VARCHAR(100) = NULL,
    @quantidade INT = NULL,
    @imagem VARBINARY(MAX) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia = @id_midia)
    BEGIN
        SELECT 'Erro: Mídia não encontrada.' AS Resultado;
        RETURN;
    END

    UPDATE Midia
    SET titulo = ISNULL(@titulo, titulo),
        autor = ISNULL(@autor, autor),
        ano_publicacao = ISNULL(@ano_publicacao, ano_publicacao),
        editora = ISNULL(@editora, editora),
        categoria = ISNULL(@categoria, categoria),
        quantidade = ISNULL(@quantidade, quantidade),
        imagem = ISNULL(@imagem, imagem)
    WHERE id_midia = @id_midia;

    SELECT 'Mídia atualizada com sucesso!' AS Resultado;
END
GO


-- Excluir Mídia
CREATE PROCEDURE sp_ExcluirMidia
    @id_midia INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia = @id_midia)
    BEGIN
        SELECT 'Erro: Mídia não encontrada.' AS Resultado;
        RETURN;
    END

    DELETE FROM Midia WHERE id_midia = @id_midia;

    SELECT 'Mídia excluída com sucesso!' AS Resultado;
END
GO


-- Informações de uma Mídia
CREATE PROCEDURE sp_InfoMidia
    @id_midia INT
AS
BEGIN
    SELECT id_midia, titulo, autor, ano_publicacao, editora, categoria, quantidade, imagem
    FROM Midia
    WHERE id_midia = @id_midia;
END
GO


-- Listar todas as Mídias
CREATE PROCEDURE sp_ListarMidias
AS
BEGIN
    SELECT id_midia, titulo, autor, ano_publicacao, editora, categoria, quantidade, imagem
    FROM Midia
    ORDER BY titulo;
END
GO

-- =========================================================
-- EMPRÉSTIMOS
-- =========================================================

-- Registrar Empréstimo
CREATE PROCEDURE sp_RegistrarEmprestimo
    @email_cliente VARCHAR(100),
    @id_midia INT,
    @data_devolucao DATE
AS
BEGIN
    DECLARE @id_cliente INT;

    SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email_cliente;

    IF @id_cliente IS NULL
    BEGIN
        SELECT 'Erro: Cliente não encontrado.' AS Resultado;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Midia WHERE id_midia = @id_midia)
    BEGIN
        SELECT 'Erro: Mídia não encontrada.' AS Resultado;
        RETURN;
    END

    INSERT INTO Emprestimo (id_cliente, id_midia, data_emprestimo, data_devolucao, status)
    VALUES (@id_cliente, @id_midia, GETDATE(), @data_devolucao, 'Ativo');

    SELECT 'Empréstimo registrado com sucesso!' AS Resultado;
END
GO


-- Finalizar Empréstimo
CREATE PROCEDURE sp_FinalizarEmprestimo
    @id_emprestimo INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Emprestimo WHERE id_emprestimo = @id_emprestimo)
    BEGIN
        SELECT 'Erro: Empréstimo não encontrado.' AS Resultado;
        RETURN;
    END

    UPDATE Emprestimo
    SET status = 'Finalizado'
    WHERE id_emprestimo = @id_emprestimo;

    SELECT 'Empréstimo finalizado com sucesso!' AS Resultado;
END
GO


-- Listar Empréstimos de um Cliente (com imagens)
CREATE PROCEDURE sp_ListarEmprestimosCliente
    @email_cliente VARCHAR(100)
AS
BEGIN
    DECLARE @id_cliente INT;
    SELECT @id_cliente = id_cliente FROM Cliente WHERE email = @email_cliente;

    IF @id_cliente IS NULL
    BEGIN
        SELECT 'Erro: Cliente não encontrado.' AS Resultado;
        RETURN;
    END

    SELECT e.id_emprestimo, e.data_emprestimo, e.data_devolucao, e.status,
           m.id_midia, m.titulo, m.autor, m.categoria, m.imagem
    FROM Emprestimo e
    INNER JOIN Midia m ON e.id_midia = m.id_midia
    WHERE e.id_cliente = @id_cliente;
END
GO


-- Listar todos os Empréstimos (com imagens)
CREATE PROCEDURE sp_ListarEmprestimos
AS
BEGIN
    SELECT e.id_emprestimo, e.data_emprestimo, e.data_devolucao, e.status,
           c.nome AS cliente, c.email,
           m.titulo, m.autor, m.categoria, m.imagem
    FROM Emprestimo e
    INNER JOIN Cliente c ON e.id_cliente = c.id_cliente
    INNER JOIN Midia m ON e.id_midia = m.id_midia
    ORDER BY e.data_emprestimo DESC;
END
GO*/