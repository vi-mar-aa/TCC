using LitteraAPI.DTOS;
using Microsoft.AspNetCore.Mvc;
using LitteraAPI.Repositories;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.DependencyInjection;

namespace LitteraAPI.Routes;

public static class Rmidia
{
    public static void Routesmidia(this WebApplication app)
    {
        app.MapGet("/ListarMidias", async (RepoMidia repo) =>
        {
            try
            {
                var livros = await repo.ListarMidias();
                return Results.Ok(livros);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
            

        });
        

        app.MapPost("/CadastrarMidia", async ([FromBody] RequestMidia rmidia, [FromServices] RepoMidia repoMidia) =>
        {
            try
            {
                await repoMidia.InserirMidia(rmidia);
                return Results.Ok("Midia cadastrado com sucesso");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco ou tipo de midia inválido: " + ex.Message);
            }
            
        } );

        app.MapPost("/MainAndroidSimilares", async ([FromBody]RequestMidia rmidia, [FromServices]RepoMidia repoMidia) =>
        {
            try
            {
                var midias = await repoMidia.ListarMainAndroidGenerosSimilares(rmidia.Genero);
                return Results.Ok(midias);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });

        app.MapPost("/MainAndroidPopulares", async ([FromServices]RepoMidia repoMidia) =>
        {
            try
            {
                var midias = await repoMidia.ListarMainAndroidPopulares();
                return Results.Ok(midias);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
           
        });

    }
}