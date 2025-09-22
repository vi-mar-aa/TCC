using LitteraAPI.Repositories;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Routes;

public static class Rindicacao
{
    public static void RoutesIndicacao (this WebApplication app)
    {
        app.MapGet("/ListarIndicacoes", async (RepoIndicacao repo) => //testada
        {
            try
            {
                var indicacoes = await repo.ListarIndicacoes();
                return Results.Ok(indicacoes);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });
        
        
    }
}