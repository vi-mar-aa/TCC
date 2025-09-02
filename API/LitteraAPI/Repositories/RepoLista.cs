using LitteraAPI.Models;
using LitteraAPI.DTOS;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoLista
{
    
  private readonly string _connectionString;
    
  public RepoLista(IConfiguration configuration)
  {
    _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
  }

  public async Task<List<RequestLista>> ListarDesejosCliente(string EmailCliente)
  {
    var lista = new List<RequestLista>();
    using var con = new SqlConnection(_connectionString);

    using (var cmd = new SqlCommand("sp_ListaDesejosCliente", con))
    {
      cmd.CommandType = System.Data.CommandType.StoredProcedure;
      cmd.Parameters.AddWithValue("@email", EmailCliente); //checar parametros depois
      await con.OpenAsync();
      using var reader = await cmd.ExecuteReaderAsync();

      while (await reader.ReadAsync())
      {
        lista.Add(new RequestLista()
        {
          Midia = new Mmidia
          {
            IdMidia = (int)reader["id_midia"],
            Titulo = (string)reader["titulo"],
            Autor = (string)reader["autor"],
            Anopublicacao = (int)reader["ano_publicacao"],
            Imagem = Convert.ToBase64String((byte[])reader["imagem"])
          }
        });
      }
      return lista;
    }
  }

  public async Task<bool> DeletarDesejoCliente(string EmailCliente, int IdMidia)
  {
    using var con = new SqlConnection(_connectionString);
    using (var cmd = new SqlCommand("sp_ListaDesejosExcluir", con))
    {
      cmd.CommandType = System.Data.CommandType.StoredProcedure;
      cmd.Parameters.AddWithValue("@email", EmailCliente);
      cmd.Parameters.AddWithValue("@id_midia", IdMidia);
      
      await con.OpenAsync();
      using (var reader = await cmd.ExecuteReaderAsync())
      {
        return reader.HasRows;
      }
    }
  }

  public async Task<bool> AdicionarDesejoCliente(string EmailCliente, int IdMidia)
  {
    using var con = new SqlConnection(_connectionString);
    using (var cmd = new SqlCommand("sp_ListaDesejosAdicionar", con))
    {
      cmd.CommandType = System.Data.CommandType.StoredProcedure;
      cmd.Parameters.AddWithValue("@email", EmailCliente);
      cmd.Parameters.AddWithValue("@id_midia", IdMidia);
      
      await con.OpenAsync();
      using (var reader = await cmd.ExecuteReaderAsync())
      {
        return reader.HasRows;
      }
    }
  }
  
  
  
}

/*
 *
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
 * 
 */