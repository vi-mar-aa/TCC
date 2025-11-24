using LitteraAPI.DTOS;
using LitteraAPI.Models;
using LitteraAPI.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Routes;

public static class Rdenuncia
{
    public static void RoutesDenuncia(this WebApplication app)
    {

        // LISTAR TODAS AS DENUNCIAS
       
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
        })
        .WithTags("Denuncias");


      
        // LISTAR UMA DENUNCIA ESPECIFICA
        // (AGORA FUNCIONA NO SWAGGER)
 
        app.MapGet("/ListarDenunciaEspecifica/{idDenuncia:int}",
            async (int idDenuncia, RepoDenuncia repo) =>
        {
            try
            {
                var denuncias = await repo.ListarDenunciaEspecifica(idDenuncia);
                return Results.Ok(denuncias);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        })
        .WithTags("Denuncias")
        .WithSummary("Lista denúncia específica")
        .WithDescription("Busca detalhes de uma denúncia usando o ID da denúncia.");



        // ANALISAR / BANIR / RESOLVER
  
        app.MapPost("/AnalisarDenuncia",
            async ([FromBody] RequestDenuncia request,
                   [FromServices] RepoDenuncia repo) =>
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

        })
        .WithTags("Denuncias")
        .WithSummary("Processa e analisa uma denúncia.");
    }
}