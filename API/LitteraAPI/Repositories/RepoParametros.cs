using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoParametros
{
    private readonly string _connectionString;
    
    public RepoParametros(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }
    
    public async Task<bool> ConfigurarParametros(MParametros parametros)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_ConfigurarParametros", con))
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@multa_dia", parametros.MultaDias);
            cmd.Parameters.AddWithValue("@prazo_devolucao_dias", parametros.PrazoDevolucao); 
            cmd.Parameters.AddWithValue("@limite_emprestimos", parametros.LimiteEmpretismos); 

            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
        
    }
    
}