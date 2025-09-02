using LitteraAPI.DTOS;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoEmprestimo
{
    private readonly string _connectionString;

    public RepoEmprestimo(IConfiguration configuration)
    {
      _connectionString = configuration.GetConnectionString("SqlServer");
    }

    public async Task<List<RequestEmprestimo>> ListarEmprestimosCliente(string emailFunc)
    {
      var emprestimos = new List<RequestEmprestimo>();
      using var con = new SqlConnection(_connectionString);

      using (var cmd = new SqlCommand("sp_EmprestimosClienteListar", con))
      {
        cmd.CommandType = System.Data.CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@email", emailFunc);
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
              Autor  = (string)reader["autor"],
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
            ValorMulta = (decimal)reader["valor_multa"],
            StatusRenovacao = (int)reader["status_renovacao"],
          });
          
        }
        
        return emprestimos;

      }
      
    }
}

/*
 * CREATE PROCEDURE sp_HistoricoEmprestimosCliente
  @email VARCHAR(100)
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Cliente WHERE email=@email)
  BEGIN SELECT 'Cliente não encontrado' AS msg; RETURN; END

  SELECT 
    e.id_emprestimo,
    e.data_emprestimo,
    e.data_devolucao,
    m.id_midia,
    m.titulo,
    m.autor,
    m.ano_publicacao,
    m.imagem
  FROM Emprestimo e
  JOIN Midia m   ON m.id_midia = e.id_midia
  JOIN Cliente c ON c.id_cliente = e.id_cliente
  WHERE c.email=@email
    AND e.data_devolucao < CAST(GETDATE() AS DATE)
  ORDER BY e.data_devolucao DESC;
END
GO
 */