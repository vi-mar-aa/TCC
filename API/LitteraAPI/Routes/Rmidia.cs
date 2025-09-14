using LitteraAPI.DTOS;
using LitteraAPI.Helpers;
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
        app.MapGet("/ListarMidias", async (RepoMidia repo) => //testada
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

        app.MapGet("/ListarMainAcervo", async (RepoMidia repo) => //testada
        {
            try
            {
                var livros = await repo.ListarMidiasAcervoAndroidMain();
                return Results.Ok(livros);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });
        
        app.MapGet("/ListarPopulares", async (RepoMidia repo) => //testada, mas falta a proc retornar o ano de publicação
        {
            try
            {
                var livros = await repo.ListarMidiasPopulares();
                return Results.Ok(livros);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });

        app.MapPost("/ListarMidiasPorGenero", async ([FromBody] Mmidia midia, [FromServices] RepoMidia repo) => //testada
        { //da pra usar para os filtros
            try
            {
                var livros = await repo.ListarMidiasPorGeneroMain(EnumHelper.ToStringValue(midia.Genero));
                return Results.Ok(livros);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });
        
        app.MapPost("/ListarMidiasSimilares", async ([FromBody] Mmidia midia, [FromServices] RepoMidia repo) => //testada
        {
            try
            {
                var livros = await repo.ListarMidiasPorGeneroSimilares(midia.IdMidia);
                return Results.Ok(livros);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });

        app.MapPost("/ListaMidiaEspecifica", async ([FromBody] Mmidia midia, [FromServices] RepoMidia repo) =>
        {
            try
            {
                var livros = await repo.ListarMidiaEspec(midia.IdMidia);
                return Results.Ok(livros);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });

        app.MapPost("/AdicionarLivro", async ([FromBody] RequestMidia request, [FromServices] RepoMidia repo) => //testada
        {
            try
            {
                var rows = await repo.AdicionarLivro(request);

                return rows 
                    ? Results.Ok("Midia adicionada com sucesso.")
                    : Results.NotFound("Dados inválidos.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
            
        });
        
        app.MapPost("/AdicionarFilme", async ([FromBody] RequestMidia request, [FromServices] RepoMidia repo) =>
        {
            try
            {
                var rows = await repo.AdicionarFilme(request);

                return rows 
                    ? Results.Ok("Midia adicionada com sucesso.")
                    : Results.NotFound("Dados inválidos.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
            
        });
        
        app.MapPost("/AdicionarRevista", async ([FromBody] RequestMidia request, [FromServices] RepoMidia repo) =>
        {
            try
            {
                var rows = await repo.AdicionarRevista(request);

                return rows 
                    ? Results.Ok("Midia adicionada com sucesso.")
                    : Results.NotFound("Dados inválidos.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
            
        });
        
        app.MapPost("/AlterarLivro", async ([FromBody] RequestMidia request, [FromServices] RepoMidia repo) =>
        {
            try
            {
                var rows = await repo.AlterarLivro(request);

                return rows 
                    ? Results.Ok("Midia alterada com sucesso.")
                    : Results.NotFound("Dados inválidos.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
            
        });
        
        app.MapPost("/AlterarFilme", async ([FromBody] RequestMidia request, [FromServices] RepoMidia repo) =>
        {
            try
            {
                var rows = await repo.AlterarFilme(request);

                return rows 
                    ? Results.Ok("Midia alterada com sucesso.")
                    : Results.NotFound("Dados inválidos.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
            
        });
        
        app.MapPost("/AlterarRevista", async ([FromBody] RequestMidia request, [FromServices] RepoMidia repo) =>
        {
            try
            {
                var rows = await repo.AlterarRevista(request);

                return rows 
                    ? Results.Ok("Midia alterada com sucesso.")
                    : Results.NotFound("Dados inválidos.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
            
        });
        
        app.MapDelete("/ExcluirMidia", async ([FromBody] RequestMidia request, [FromServices] RepoMidia repo) =>
        {
            try
            {
                var rows = await repo.InativarMidia(request.Midia.IdMidia);

                return rows 
                    ? Results.Ok("Midia excluida com sucesso.")
                    : Results.NotFound("Dados inválidos, midia não encontrada.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
            
        });
        
        /*app.MapPost("/CadastrarMidia", async ([FromBody] RequestMidia rmidia, [FromServices] RepoMidia repoMidia) =>
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


        });*/

    }
}