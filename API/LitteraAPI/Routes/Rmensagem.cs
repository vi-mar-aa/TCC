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

        app.MapPost("/ListarPostCompleto", async ([FromBody]RequestForum forum, [FromServices] RepoMensagem repo) =>
        {
            try
            {
                var post = await repo.ListarPostCompleto(forum.mensagem.IdMensagem);
                return Results.Ok(post);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: "+ ex.Message);
            }
        });
        
        app.MapPost("/ListarTodosPosts", async ([FromBody]RequestForum forum, [FromServices] RepoMensagem repo) =>
        {
            try
            {
                var post = await repo.ListarTodosPosts(forum.Filtro.ToString());
                return Results.Ok(post);
            }
            catch(SqlException ex)
            {
                Results.NotFound("Opção de filtro inválida");
                return Results.Problem("Erro no banco: "+ ex.Message);
                
            }
        });

        app.MapPost("/ListarHistoricoPostsLeitor", async([FromBody]RequestForum forum, [FromServices] RepoMensagem repo)=>
        {
            try
            {
                var post = await repo.ListarHistoricoPostsLeitor(forum.cliente.Email);
                return Results.Ok(post);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: "+ ex.Message);
                
            }
            
        });

        app.MapPost("/InativarPost", async ([FromBody]RequestForum forum, [FromServices] RepoMensagem repo) =>
        {
            try
            {
                var rows = await repo.InativarPost(forum.mensagem.IdMensagem);

                return rows 
                    ? Results.Ok("Post inativado com sucesso.")
                    : Results.NotFound("Referência a um post inválido.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
        });
    }
}