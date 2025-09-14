using LitteraAPI.DTOS;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoIndicacao
{
    private readonly string _connectionString;
    
    public RepoIndicacao(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }
    
    public async Task<List<MIndicacao>> ListarIndicacoes()
    {
        var lista = new List<MIndicacao>();
        using var con = new SqlConnection(_connectionString);

        using (var cmd = new SqlCommand("sp_ListarIndicacoes", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                lista.Add(new MIndicacao()
                {
                        TextoIndicacao = (string)reader["titulo"],
                        AutorIndicado = (string)reader["autor"],
                        // = (int)reader["ano_publicacao"],
                        //Imagem = Convert.ToBase64String((byte[])reader["imagem"])
                    
                });
                
                
            }
            return lista;
        }
    }
    
}