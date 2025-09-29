using LitteraAPI.DTOS;
using LitteraAPI.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Routes;

public static class Rmensagem
{
    public static void RoutesMensagem(this WebApplication app)
    {
        app.MapPost("/AdicionarPost", async ([FromBody]RequestForum forum, [FromServices] RepoMensagem repo) => //testada
        {
            try
            {
                var rows = await repo.AdicionarPost(forum);

                return rows 
                    ? Results.Ok("Post adicionado com sucesso.")
                    : Results.NotFound("Usuário não encontrado ou referência a um post inválido.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
        });
        
        app.MapPost("/AdicionarComentario", async ([FromBody]RequestForum forum, [FromServices] RepoMensagem repo) => //testada
        {
            try
            {
                var rows = await repo.AdicionarComentario(forum);

                return rows 
                    ? Results.Ok("Post adicionado com sucesso.")
                    : Results.NotFound("Usuário não encontrado ou referência a um post inválido.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
        });
        
        
    }
}