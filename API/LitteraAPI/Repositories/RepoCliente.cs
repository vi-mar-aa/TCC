using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoCliente
{
    private readonly string _connectionString;
    
    public RepoCliente(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }

    public async Task LoginCliente(string email, string senha)
    {
        using var con = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand("sp_LoginCliente", con);
        
        cmd.Parameters.AddWithValue("@email", email);
        cmd.Parameters.AddWithValue("@senha", senha);
        
        await con.OpenAsync();
        await cmd.ExecuteNonQueryAsync();
        
    }
    
}