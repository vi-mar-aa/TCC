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

                app.MapPost("/ListarReservasCliente",async ([FromBody] Mcliente cliente, [FromServices] RepoReserva repoReserva) =>//testada
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

                app.MapGet("/ListarReservas", async (RepoReserva repo) => //testada
                {
                        try
                        {
                                var reservas = await repo.ListarReservas();
                                return Results.Ok(reservas); 
                        }
                        catch(SqlException ex)
                        {
                                return Results.Problem("Erro no banco: " + ex.Message);  
                        }
                });

                app.MapPost("/AdicionarReserva", async ([FromBody] RequestReserva request, [FromServices] RepoReserva repo) => //testada
                {
                        try
                        { 
                                var rows = await repo.CriarReserva(request.Cliente.Email, request.Midia.IdMidia);
                                return rows 
                                        ? Results.Ok("Reserva adicionada com sucesso.")
                                        : Results.NotFound("Dados inválidos.");
                        }
                        catch (SqlException ex)
                        {
                                return Results.Problem("Erro no banco: " + ex.Message);
                        }      
                });

                app.MapPost("/EfetivarReserva", async ([FromBody] RequestReserva request, [FromServices] RepoReserva repo) =>//testada, porem pequeno problema no banco
                {
                        try
                        { 
                                var rows = await repo.EfetivarReserva(request);
                                return rows 
                                        ? Results.Ok("Emprestimo criado com sucesso.")
                                        : Results.NotFound("Dados inválidos.");
                        }
                        catch (SqlException ex)
                        {
                                return Results.Problem("Erro no banco: " + ex.Message);
                        }       
                });

                app.MapPost("/PesquisarReservas", async ([FromBody] RequestPesquisa request, [FromServices]RepoReserva repo) =>
                {
                        try
                        {
                                var reservas = await repo.PesquisarReservas(request.SearchText);
                                return Results.Ok(reservas); 
                        }
                        catch(SqlException ex)
                        {
                                return Results.Problem("Erro no banco: " + ex.Message);  
                        }
                });


        }
}