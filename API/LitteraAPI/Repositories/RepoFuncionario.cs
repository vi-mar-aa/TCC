using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoFuncionario
{
    private readonly string _connectionString;
    
    public RepoFuncionario(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }
    
    public async Task<bool> LoginFuncionario(Mfuncionario loginB)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_LoginFuncionario", con))
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email", loginB.Email); 
            cmd.Parameters.AddWithValue("@senha", loginB.Senha);

            await con.OpenAsync();
            // Use ExecuteReaderAsync para ler o resultado da procedure
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task CadastrarBibliotecario(Mfuncionario funcionario)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_CadastrarFuncionario", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_cargo", 1);
            cmd.Parameters.AddWithValue("@email", funcionario.Email);
            cmd.Parameters.AddWithValue("@senha", funcionario.Senha);
            cmd.Parameters.AddWithValue("@cpf", funcionario.Cpf);
            cmd.Parameters.AddWithValue("@nome", funcionario.Nome);
            cmd.Parameters.AddWithValue("@telefone", funcionario.Telefone);
            cmd.Parameters.AddWithValue("@status_conta", "ativo");
            
            await con.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
    }
    
    public async Task CadastrarAdm(Mfuncionario funcionario)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_CadastrarAdm", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_cargo", 2);
            cmd.Parameters.AddWithValue("@email", funcionario.Email);
            cmd.Parameters.AddWithValue("@senha", funcionario.Senha);
            cmd.Parameters.AddWithValue("@cpf", funcionario.Cpf);
            cmd.Parameters.AddWithValue("@nome", funcionario.Nome);
            cmd.Parameters.AddWithValue("@telefone", funcionario.Telefone);
            cmd.Parameters.AddWithValue("@status_conta", "ativo");
            
            await con.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
    }
    
    
    
}