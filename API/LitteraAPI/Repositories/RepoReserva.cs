using LitteraAPI.Models;
using LitteraAPI.DTOS;
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
    

    public async Task<List<RequestReserva>> ListarReservasCliente(string emailFunc) //andorid
    {
        var reservas = new List<RequestReserva>();
        using var con = new SqlConnection(_connectionString);

        using (var cmd = new SqlCommand("sp_ReservasClienteListar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email", emailFunc); //parametro
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                reservas.Add(new RequestReserva()
                { 
                    Reserva = new Mreserva
                    {
                        IdReserva = (int)reader["id_reserva"],
                        IdCliente = (int)reader["id_cliente"],
                        IdMidia   = (int)reader["id_midia"],
                        DataLimite =  (DateTime)reader["data_limite"],
                        DataReserva = (DateTime)reader["data_reserva"],
                        StatusReserva = (string)reader["status_reserva"]
                    },
                    Midia = new Mmidia
                    {
                        IdMidia = (int)reader["id_midia"],
                        Titulo = (string)reader["titulo"],
                        Autor  = (string)reader["autor"],
                        Anopublicacao = (int)reader["ano_publicacao"],
                        Imagem = Convert.ToBase64String((byte[])reader["imagem"])
                    }
                    
                });

            }
            
            return reservas;
        }
        
    }
    
    /*CREATE PROCEDURE sp_ReservasClienteListar
    @id_cliente INT
AS
BEGIN
    DECLARE @hoje DATE = CAST(GETDATE() AS DATE);

    SELECT r.id_reserva, r.data_reserva, r.data_limite, r.status_reserva,
           m.id_midia, m.titulo, m.autor, m.ano_publicacao, 
           DATEDIFF(DAY, @hoje, r.data_limite) AS dias_restantes
    FROM Reserva r
    JOIN Midia m ON m.id_midia=r.id_midia
    WHERE r.id_cliente=@id_cliente
      AND r.status_reserva='ativa'
      AND r.data_limite >= @hoje
    ORDER BY r.data_limite ASC;
END
     * 
     */
}