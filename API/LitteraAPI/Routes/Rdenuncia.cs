using LitteraAPI.DTOS;
using LitteraAPI.Models;
using LitteraAPI.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Routes;

public static class Rdenuncia
{
    public static void RoutesDenuncia (this WebApplication app)
    {
        app.MapGet("/ListarDenuncias", async (RepoDenuncia repo) =>
        {
            try
            {
                var denuncias = await repo.ListarDenuncias();
                return Results.Ok(denuncias);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });
        
        app.MapGet("/ListarDenunciaEspecifica", async ([FromBody] Mdenuncia denuncia, [FromServices] RepoDenuncia repo) =>
        {
            try
            {
                var denuncias = await repo.ListarDenunciaEspecifica(denuncia.IdDenuncia);
                return Results.Ok(denuncias);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });

        app.MapPost("/AnalisarDenuncia", async ([FromBody] RequestDenuncia request, [FromServices] RepoDenuncia repo) =>
        {
            try
            {
                var rows = await repo.AnalisarDenuncia(request);

                return rows 
                    ? Results.Ok("Usuário banido com sucesso.")
                    : Results.NotFound("Referência inválida.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });
    }
    
}