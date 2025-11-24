using LitteraAPI.DTOS;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoEvento
{
    private readonly string _connectionString;
    
    public RepoEvento(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }

    public async Task<bool> AdicionarEvento(RequestEvento evento, DateTime dataInicio, DateTime dataFim)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_EventoCriar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@titulo", evento.Evento.Titulo);
            cmd.Parameters.AddWithValue("@data_inicio", dataInicio);
            cmd.Parameters.AddWithValue("@data_fim", dataFim);
            cmd.Parameters.AddWithValue("@local_evento", evento.Evento.LocalEvento);
            cmd.Parameters.AddWithValue("@email", evento.Funcionario.Email);
      
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task<bool> InativarEvento(int id)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_EventoInativar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_evento", id);
      
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }
    
    public async Task<List<RequestEvento>> ListarEventos()
    {
        var eventos = new List<RequestEvento>();
        using var con = new SqlConnection(_connectionString);

        using (var cmd = new SqlCommand("sp_EventosAtivos", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                eventos.Add(new RequestEvento()
                {
                    Evento = new Mevento()
                    {
                        IdEvento = (int)reader["id_evento"],
                        Titulo = (string)reader["titulo"],
                        DataInicio = (DateTime)reader["data_inicio"],
                        DataFim = (DateTime)reader["data_fim"],
                        LocalEvento = (string)reader["local_evento"],
                    },
                    Funcionario = new Mfuncionario()
                    {
                        IdFuncionario = (int)reader["id_funcionario"]
                    
                    },
                });
            }
            return eventos;
        }
    }
    public async Task<List<RequestEvento>> ListarEventosHistorico()
    {
        var eventos = new List<RequestEvento>();
        using var con = new SqlConnection(_connectionString);

        using (var cmd = new SqlCommand("sp_EventosHistorico", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                eventos.Add(new RequestEvento()
                {
                    Evento = new Mevento()
                    {
                        IdEvento = (int)reader["id_evento"],
                        Titulo = (string)reader["titulo"],
                        DataInicio = (DateTime)reader["data_inicio"],
                        DataFim = (DateTime)reader["data_fim"],
                        LocalEvento = (string)reader["local_evento"],
                    },
                    Funcionario = new Mfuncionario()
                    {
                        IdFuncionario = (int)reader["id_funcionario"]
                    
                    },
                });
            }
            return eventos;
        }
    }
    
}

