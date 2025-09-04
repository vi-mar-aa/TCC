using LitteraAPI.DTOS;
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
            StatusEmprestimo = (string)reader["status_pagamento"]
          }
        });


      }

      return emprestimos;

    }
  }
  
  
  
  
}

/*
 *
 */