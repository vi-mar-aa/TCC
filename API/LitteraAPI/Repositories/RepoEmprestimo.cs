using LitteraAPI.DTOS;
using LitteraAPI.Helpers;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoEmprestimo
{
  private readonly string _connectionString;

  public RepoEmprestimo(IConfiguration configuration)
  {
    _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
  }

  public async Task<List<RequestEmprestimo>> ListarEmprestimosCliente(string email)
  {
    var emprestimos = new List<RequestEmprestimo>();
    using var con = new SqlConnection(_connectionString);

    using (var cmd = new SqlCommand("sp_EmprestimosClienteListar", con)) 
    {
      cmd.CommandType = System.Data.CommandType.StoredProcedure;
      cmd.Parameters.AddWithValue("@email", email);
      await con.OpenAsync();
      using var reader = await cmd.ExecuteReaderAsync();

      while (await reader.ReadAsync())
      {
        emprestimos.Add(new RequestEmprestimo()
        {
          Midia = new Mmidia
          {
            IdMidia = (int)reader["id_midia"],
            Titulo = (string)reader["titulo"],
            Autor = (string)reader["autor"],
            Anopublicacao = (int)reader["ano_publicacao"],
            Imagem = Convert.ToBase64String((byte[])reader["imagem"])

          },
          Emprestimo = new Memprestimo()
          {
            IdEmprestimo = (int)reader["id_emprestimo"],
            DataEmprestimo = (DateTime)reader["data_emprestimo"],
            DataDevolucao = (DateTime)reader["data_devolucao"],
            LimiteRenovacoes = (int)reader["limite_renovacoes"]
          },
          DiasAtraso = (int)reader["dias_atraso"],
          ValorMulta = (decimal)reader["multa"],
          StatusRenovacao = (int)reader["pode_renovar"]
        });

      }

      return emprestimos;

    }

  }

  public async Task<List<RequestEmprestimo>> ListarHistoriaEmprestimosCliente (string email)
  {
    var emprestimos = new List<RequestEmprestimo>();
    using var con = new SqlConnection(_connectionString);
    using (var cmd = new SqlCommand("sp_HistoricoEmprestimosPagosCliente", con)) 
    {
      cmd.CommandType = System.Data.CommandType.StoredProcedure;
      cmd.Parameters.AddWithValue("@email", email);
      await con.OpenAsync();
      using var reader = await cmd.ExecuteReaderAsync();

      while (await reader.ReadAsync())
      {
        emprestimos.Add(new RequestEmprestimo()
        {
          Midia = new Mmidia
          {
            IdMidia = (int)reader["id_midia"],
            Titulo = (string)reader["titulo"],
            Autor = (string)reader["autor"],
            Anopublicacao = (int)reader["ano_publicacao"],
            Imagem = Convert.ToBase64String((byte[])reader["imagem"])

          },
          Emprestimo = new Memprestimo()
          {
            IdEmprestimo = (int)reader["id_emprestimo"],
            DataEmprestimo = (DateTime)reader["data_emprestimo"],
            DataDevolucao = (DateTime)reader["data_devolucao"],
            LimiteRenovacoes = (int)reader["limite_renovacoes"],
            Status = EnumHelper.GetEnumSafe<StatusEmprestimo>(reader["status_pagamento"])
          }
        });


      }

      return emprestimos;

    }
  }
  
  public async Task<bool> RenovarEmprestimo(DateTime novaData, int IdEmprestimo)
  {
    using var con = new SqlConnection(_connectionString);
    using (var cmd = new SqlCommand("sp_EmprestimoRenovar", con))
    {
      cmd.CommandType = System.Data.CommandType.StoredProcedure;
      cmd.Parameters.AddWithValue("@id_emprestimo", IdEmprestimo);
      cmd.Parameters.AddWithValue("@novadata", novaData);
      
      await con.OpenAsync();
      using (var reader = await cmd.ExecuteReaderAsync())
      {
        return reader.HasRows;
      }
    }
  }

  public async Task<bool> AdicionarEmprestimo(RequestEmprestimo request)
  {
    using var con = new SqlConnection(_connectionString);
    using (var cmd = new SqlCommand("sp_EmprestimoAdicionar", con))
    {
      cmd.CommandType = System.Data.CommandType.StoredProcedure;
      cmd.Parameters.AddWithValue("@id_midia", request.Midia.IdMidia);
      cmd.Parameters.AddWithValue("@email_cliente", request.Cliente.Email);
      cmd.Parameters.AddWithValue("@email_funcionario", request.funcionario.Email);
      cmd.Parameters.AddWithValue("@data_emprestimo ", request.Emprestimo.DataEmprestimo);
      cmd.Parameters.AddWithValue("@data_devolucao ", request.Emprestimo.DataDevolucao);

      
      await con.OpenAsync();
      using (var reader = await cmd.ExecuteReaderAsync())
      {
        return reader.HasRows;
      }
    }
  }

  public async Task<bool> ConcluirEmprestimo(int id)
  {
    using var con = new SqlConnection(_connectionString);
    using (var cmd = new SqlCommand("sp_DevolverMidia", con))
    {
      cmd.CommandType = System.Data.CommandType.StoredProcedure;
      cmd.Parameters.AddWithValue("@id_emprestimo", id);
      
      await con.OpenAsync();
      using (var reader = await cmd.ExecuteReaderAsync())
      {
        
        return reader.HasRows;
      }
    }
  }
  
  
  
}
