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
    
    public async Task<bool> LoginFuncionario(Mfuncionario login)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_LoginFuncionario", con))
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email", login.Email); 
            cmd.Parameters.AddWithValue("@senha", login.Senha);

            await con.OpenAsync();
            // Use ExecuteReaderAsync para ler o resultado da procedure
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task<bool> CadastrarBibliotecario(Mfuncionario funcionario)
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
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }
    
    public async Task<bool> CadastrarAdm(Mfuncionario funcionario)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_CadastrarFuncionario", con))
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
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task<List<Mfuncionario>> ListarFuncionarios()
    {
        var func = new List<Mfuncionario>();
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_TodosFuncionarios", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                func.Add(new Mfuncionario()
                {
                    IdFuncionario = (int)reader["id_funcionario"],
                    Idcargo = (int)reader["id_cargo"],
                    Nome = (string)reader["nome"],
                    Telefone = (string)reader["telefone"],
                    Email = (string)reader["email"],
                    Cpf = (string)reader["cpf"],
                    Statusconta = (string)reader["status_conta"]
                });
            }
            
            return func;
        }
    }

    public async Task<bool> AlterarFuncionario(Mfuncionario funcionario)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_FuncionarioAlterar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_funcionario", funcionario.IdFuncionario);
            cmd.Parameters.AddWithValue("@nome", funcionario.Nome);
            cmd.Parameters.AddWithValue("@telefone", funcionario.Telefone);
            cmd.Parameters.AddWithValue("@status_conta", funcionario.Statusconta);
            
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }
    
    
}

