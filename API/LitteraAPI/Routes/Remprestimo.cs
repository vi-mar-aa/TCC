using LitteraAPI.Models;
using LitteraAPI.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Routes;

public static class Remprestimo
{
    public static void Routesemprestimo(this WebApplication app)
    {
        app.MapPost("/ListarEmprestimosCliente", async ([FromBody]Mcliente cliente, [FromServices] RepoEmprestimo repo) => //testada
        {
            try
            {
                var emprestimos = await repo.ListarEmprestimosCliente(cliente.Email);
                return Results.Ok(emprestimos);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });

        app.MapPost("/ListarHistoricoEmprestimosCLiente", async ([FromBody] Mcliente cliente, [FromServices] RepoEmprestimo repo) => //testada
        {
            try
            {
                var emprestimos = await repo.ListarHistoriaEmprestimosCliente(cliente.Email);
                return Results.Ok(emprestimos);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });

    }
}