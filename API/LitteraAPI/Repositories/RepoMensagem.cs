using LitteraAPI.DTOS;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoMensagem
{
    private readonly string _connectionString;
    
    public RepoMensagem(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }
    
    public async Task<bool> AdicionarPost(RequestForum post)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MensagemAdicionar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@titulo", post.mensagem.Titulo);
            cmd.Parameters.AddWithValue("@email_cliente", post.cliente.Email);
            cmd.Parameters.AddWithValue("@conteudo", post.mensagem.Conteudo);
            //cmd.Parameters.AddWithValue("@id_pai", post.mensagem.IdPai);
      
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task<bool> AdicionarComentario(RequestForum post)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MensagemAdicionar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@titulo", post.mensagem.Titulo);
            cmd.Parameters.AddWithValue("@email_cliente", post.cliente.Email);
            cmd.Parameters.AddWithValue("@conteudo", post.mensagem.Conteudo);
            cmd.Parameters.AddWithValue("@id_pai", post.mensagem.IdPai);
      
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }
    
}

/*CREATE PROCEDURE sp_MensagemAdicionar -- funcionando
	@titulo VARCHAR(60),
    @email_cliente VARCHAR(100),
    @conteudo NVARCHAR(255),
    @visibilidade VARCHAR(20),
    @id_pai INT = NULL -- opcional, se vier nulo vira post principal
AS
BEGIN
    DECLARE @id_cliente INT;

    -- 1. Pega o id_cliente pelo email
    SELECT @id_cliente = id_cliente 
    FROM Cliente 
    WHERE email = @email_cliente;

    IF @id_cliente IS NULL
    BEGIN
        --SELECT 'Erro: Cliente não encontrado' AS msg;
        RETURN;
    END;

    -- 2. Valida visibilidade
    IF @visibilidade NOT IN ('publica','privada')
    BEGIN
        --SELECT 'Erro: Visibilidade inválida' AS msg;
        RETURN;
    END;

    -- 3. Se for comentário, verifica se o id_pai existe
    IF @id_pai IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Mensagem WHERE id_mensagem = @id_pai)
    BEGIN
        --SELECT 'Erro: Mensagem pai não encontrada' AS msg;
        RETURN;
    END;

    -- 4. Faz o insert
    INSERT INTO Mensagem (id_cliente, titulo, conteudo, data_postagem, visibilidade, id_pai)
    VALUES (@id_cliente, @titulo, @conteudo, GETDATE(), @visibilidade, @id_pai);

    SELECT 'OK' AS msg;
END;
GO*/