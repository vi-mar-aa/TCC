using LitteraAPI.DTOS;
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
        
        app.MapPost("/RenovarEmprestimo", async ([FromBody] RequestEmprestimo request, [FromServices] RepoEmprestimo repo) => //testada
        {
            try
            {
                var rows = await repo.RenovarEmprestimo(request.NovaData, request.Emprestimo.IdEmprestimo);

                return rows 
                    ? Results.Ok("Renovacão realizada com sucesso.")
                    : Results.NotFound("Data inválida ou emprestimo não existente.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }   
                
        });

        app.MapPost("/DevolverMidia", async ([FromBody] RequestEmprestimo request, [FromServices] RepoEmprestimo repo) => //testada
        {
            try
            {
                var rows = await repo.ConcluirEmprestimo(request.Emprestimo.IdEmprestimo);
                return rows
                    ? Results.Ok("Devolução realizada com sucesso.")
                    : Results.NotFound("Midia Inálida.");

            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 

            }
        });

        app.MapPost("/CriarEmprestimo", async ([FromBody] RequestEmprestimo request, [FromServices] RepoEmprestimo repo) => //testada
        {

            try
            {
                var rows = await repo.AdicionarEmprestimo(request);
                return rows
                    ? Results.Ok("Emprestimo adicionado com sucesso.")
                    : Results.NotFound("Dados inválidos.");

            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 

            }
            
        });

    }
}