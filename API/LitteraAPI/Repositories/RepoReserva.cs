using LitteraAPI.Models;
using LitteraAPI.DTOS;
using LitteraAPI.Helpers;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoReserva
{
    private readonly string _connectionString;
    
    public RepoReserva(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }
    

    public async Task<List<RequestReserva>> ListarReservasCliente(string email) //andorid
    {
        var reservas = new List<RequestReserva>();
        using var con = new SqlConnection(_connectionString);

        using (var cmd = new SqlCommand("sp_ReservasClienteListar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email", email); //parametro
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                reservas.Add(new RequestReserva()
                { 
                    Reserva = new Mreserva
                    {
                        IdReserva = (int)reader["id_reserva"],
                        //IdCliente = (int)reader["id_cliente"],
                        IdMidia   = (int)reader["id_midia"],
                        DataLimite =  (DateTime)reader["data_limite"],
                        DataReserva = (DateTime)reader["data_reserva"],
                        StatusReserva = (string)reader["status_reserva"]
                    },
                    Midia = new Mmidia
                    {
                        IdMidia = (int)reader["id_midia"],
                        Titulo = (string)reader["titulo"],
                        Autor  = ReaderHelper.GetStringSafe(reader,"autor"),
                        Anopublicacao = ReaderHelper.GetStringSafe(reader, "ano_publicacao"),
                        Imagem = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_midia"])
                    }
                    
                });

            }
            
            return reservas;
        }
        
    }

    public async Task<List<RequestReserva>> ListarReservas()
    {
        var reservas = new List<RequestReserva>();
        using var con = new SqlConnection(_connectionString);

        using (var cmd = new SqlCommand("sp_ListarTodasReservas", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                reservas.Add(new RequestReserva()
                {
                    Reserva = new Mreserva()
                    {
                        IdReserva = (int)reader["id_reserva"],
                    },
                    ChaveIdentificadora = (string)reader["chave_identificadora"],
                    TempoRestante = (string)reader["tempo_restante"],
                    Cliente = new Mcliente()
                    {
                        User = (string)reader["usuario"],
                    },
                    Midia = new Mmidia
                    {
                        IdMidia = (int)reader["id_midia"],
                        CodigoExemplar = (int)reader["codigo_exemplar"],
                        Titulo = (string)reader["titulo"],
                    },
                    
                });

            }

            return reservas;
        }
    }

    public async Task<bool> CriarReserva(string email, int id)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_ReservaCriar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email", email);
            cmd.Parameters.AddWithValue("@id_midia", id);
      
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task<bool> EfetivarReserva(RequestReserva request)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_ReservaTransformarEmEmprestimo", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_reserva", request.Reserva.IdReserva);
            cmd.Parameters.AddWithValue("@email_funcionario", request.Funcionario.Email);
            cmd.Parameters.AddWithValue("@data_emprestimo", request.Emprestimo.DataEmprestimo);
            cmd.Parameters.AddWithValue("@data_devolucao", request.Emprestimo.DataDevolucao);
      
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task<List<RequestReserva>> PesquisarReservas(string searchText)
    {
        var reservas = new List<RequestReserva>();
        using var con = new SqlConnection(_connectionString);

        using (var cmd = new SqlCommand("sp_PesquisarReservas", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@pesquisa", searchText); 
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                reservas.Add(new RequestReserva()
                {
                    Reserva = new Mreserva()
                    {
                        IdReserva = (int)reader["id_reserva"],
                    },
                    ChaveIdentificadora = (string)reader["chave_identificadora"],
                    TempoRestante = (string)reader["tempo_restante"],
                    Cliente = new Mcliente()
                    {
                        User = (string)reader["usuario"],
                    },
                    Midia = new Mmidia
                    {
                        IdMidia = (int)reader["id_midia"],
                        CodigoExemplar = (int)reader["codigo_exemplar"],
                        Titulo = (string)reader["titulo"],
                        
                    },
                    
                });

            }

            return reservas;
        }
    }
    
}