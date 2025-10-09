using System.ComponentModel.DataAnnotations;
using LitteraAPI.Helpers;
using Microsoft.AspNetCore.Mvc;
using LitteraAPI.Models;
using LitteraAPI.Repositories;
using Microsoft.Data.SqlClient;


namespace LitteraAPI.Repositories;

public class RepoCliente
{
    private readonly string _connectionString;
    
    public RepoCliente(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }
    
    
    public async Task<byte[]> ObterImagem(int id)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_SelecionarImagemClientePorID", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_cliente", id); 
            await con.OpenAsync();
            var result = await cmd.ExecuteScalarAsync();
            return result == DBNull.Value ? null : (byte[])result;
        }
    }
    
    
    public async Task<bool> LoginCliente(Mcliente login)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_LoginCliente", con))
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
    

    public async Task CadastrarCliente(Mcliente cliente)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_CadastrarCliente", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email", cliente.Email);
            cmd.Parameters.AddWithValue("@senha", cliente.Senha);
            cmd.Parameters.AddWithValue("@cpf", cliente.Cpf);
            cmd.Parameters.AddWithValue("@nome", cliente.Nome);
            cmd.Parameters.AddWithValue("@telefone", cliente.Telefone);
            cmd.Parameters.AddWithValue("@status_conta", "ativo");
            
            await con.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
        
    }

    public async Task<bool> ResetarSenha(Mcliente cliente)
    {
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_ClienteResetarSenhaViaCpfEmail", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email", cliente.Email);
            cmd.Parameters.AddWithValue("@cpf", cliente.Cpf); 
            cmd.Parameters.AddWithValue("@nova_senha", cliente.Senha);
            
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
        
    }
    
    public async Task<bool> SuspenderCliente(string user)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_LeitorSuspender", con))
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@user", user); //parametro errado no banco, verificar
            
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task<List<Mcliente>> PesquisarLeitor(string username)
    {
        var cliente = new List<Mcliente>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_LeitorBuscarPorUsername", con))
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@username", username); 
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                cliente.Add(new Mcliente()
                {
                    IdCliente = (int)reader["id_cliente"],
                    Nome = (string)reader["nome"],
                    User = (string)reader["username"],
                    Email = (string)reader["email"],
                    Telefone = (string)reader["telefone"],
                    Status_conta = (string)reader["status_conta"],
                    ImagemPerfil = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_cliente"])
                });
            }

            return cliente;
        }
    }
    
    
    
}

