using LitteraAPI.DTOS;
using LitteraAPI.Models;
using LitteraAPI.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Routes;

public static class RLista
{
    public static void RoutesLista(this WebApplication app)
    {
        app.MapPost("/ListarDesejosCliente", async ([FromBody] Mcliente cliente, [FromServices] RepoLista repoLista) => //testada
        {
            try
            {
                var desejos = await repoLista.ListarDesejosCliente(cliente.Email);
                return Results.Ok(desejos);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: "+ ex.Message);
            }
            
        });

        app.MapDelete("/DeletarDesejosCliente", async ([FromBody] RequestLista requestLista, [FromServices] RepoLista repoLista) =>
        {
            try
            {
                var rows = await repoLista.DeletarDesejoCliente(requestLista.Cliente.Email, requestLista.Midia.IdMidia);

                return rows 
                    ? Results.Ok("Desejo removido com sucesso.")
                    : Results.NotFound("Desejo não encontrado.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }   
                
        });

        app.MapPost("/AdicionarDesejosCliente", async ([FromBody] RequestLista requestLista, [FromServices] RepoLista repoLista) =>//testada
        {
            try
            {
                var rows = await repoLista.AdicionarDesejoCliente(requestLista.Cliente.Email, requestLista.Midia.IdMidia);

                return rows 
                    ? Results.Ok("Desejo adicionado com sucesso.")
                    : Results.NotFound("Desejo já existe.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message); 
            }
            
        });

    }
}