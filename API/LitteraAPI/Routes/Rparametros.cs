using LitteraAPI.Models;
using LitteraAPI.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Routes;

public static class Rparametros
{
    public static void Routesparametros(this WebApplication app)
    {
        app.MapPost("/ConfigurarParametros", async ([FromBody] MParametros parametros, [FromServices] RepoParametros repo) => //testada
        {
            try
            {
                var rows = await repo.ConfigurarParametros(parametros);

                return rows 
                    ? Results.Ok("Parametros configurados com sucesso")
                    : Results.NotFound("Erro ao configurar parametros");
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: "+ ex.Message);
            }
        });
    }
}