using LitteraAPI.DTOS;
using LitteraAPI.Models;
using LitteraAPI.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Routes;

public static class Rreserva
{
        public static void Routesreserva(this WebApplication app)
        {

                app.MapPost("/ListarReservasCliente",async ([FromBody] Mcliente cliente, [FromServices] RepoReserva repoReserva) =>
                {
                        try
                        {
                                var reservas = await repoReserva.ListarReservasCliente(cliente.Email);
                                return Results.Ok(reservas); 
                        }
                        catch(SqlException ex)
                        {
                              return Results.Problem("Erro no banco: " + ex.Message);  
                        }
                        
                });

                ;


        }
}