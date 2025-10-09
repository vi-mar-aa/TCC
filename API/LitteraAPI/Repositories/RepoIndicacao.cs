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

    public async Task<List<RequestIndicacoes>> ListarIndicacoes()
    {
        var lista = new List<RequestIndicacoes>();
        using var con = new SqlConnection(_connectionString);

        using (var cmd = new SqlCommand("sp_IndicacoesResumo", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                lista.Add(new RequestIndicacoes()
                {
                    Contagem = (int)reader["qtd_indicacoes"],
                    Indicacao = new MIndicacao()
                    {
                        TextoIndicacao = (string)reader["titulo"],
                        AutorIndicado = (string)reader["autor"]
                    },

                    Cliente = new Mcliente()
                    {
                        User = (string)reader["username"],
                        ImagemPerfil =Convert.ToBase64String((byte[])reader["imagem_cliente"])
                    }

                });
            }

        }

        return lista;
    }
    
    

}