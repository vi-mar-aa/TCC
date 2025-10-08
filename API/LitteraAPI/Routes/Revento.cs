using LitteraAPI.DTOS;
using LitteraAPI.Helpers;
using LitteraAPI.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Routes;

public static class Revento
{
    public static void RoutesEvento(this WebApplication app)
    {
        app.MapPost("/AdicionarEvento", async ([FromBody] RequestEvento evento, [FromServices] RepoEvento repo) => //testada
        {
            try
            {
                
                var (inicio,fim) = DateTimeHelper.ConverterHorario(evento.Horario, evento.DataInicio, evento.DataFim);
                var eventoAdicionado = await repo.AdicionarEvento(evento, inicio, fim);

                return eventoAdicionado
                    ? Results.Ok("Evento adicionado com sucesso")
                    : Results.NotFound("Erro ao adicionar");
                
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });
        
        app.MapGet("/ListarEventos", async (RepoEvento repo) => //testada
        {
            try
            {
                var eventos = await repo.ListarEventos();
                return Results.Ok(eventos);
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });
        
        

    }
}