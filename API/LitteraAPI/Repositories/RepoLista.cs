using LitteraAPI.Models;
using LitteraAPI.DTOS;
using LitteraAPI.Helpers;
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
            Imagem = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_midia"])
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
      cmd.Parameters.AddWithValue("@email_cliente", EmailCliente);
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
      cmd.Parameters.AddWithValue("@email_cliente", EmailCliente);
      cmd.Parameters.AddWithValue("@id_midia", IdMidia);
      
      await con.OpenAsync();
      using (var reader = await cmd.ExecuteReaderAsync())
      {
        return reader.HasRows;
      }
    }
  }
  
  
  
}

