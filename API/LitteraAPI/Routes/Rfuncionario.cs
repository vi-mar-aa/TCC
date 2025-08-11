
using Microsoft.AspNetCore.Mvc;
using LitteraAPI.Repositories;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;
namespace LitteraAPI.Routes;


public static class Rfuncionario
{
    public static void Routesfuncionario(this WebApplication app)
    {
        app.MapPost("/LoginFuncionario", async ([FromBody] Mfuncionario login, [FromServices] RepoFuncionario repoFuncionario) =>
        {
            try
            {
                var loginSucedido = await repoFuncionario.LoginFuncionario(login);

                return loginSucedido
                    ? Results.Ok("Login realizado com sucesso")
                    : Results.NotFound("Usuário ou senha incorretos");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });

        app.MapPost("/CadastrarAdm", async ([FromBody] Mfuncionario cadastro, [FromServices] RepoFuncionario repoFuncionario) => 
        {
                try
                {

                    await repoFuncionario.CadastrarAdm(cadastro);
                    return Results.Ok("Adm cadastrado com sucesso");
                }
                catch (SqlException ex)
                {
                    return Results.Problem("Erro no banco: " + ex.Message);
                } 
        });
        
        app.MapPost("/CadastrarBibliotecario", async ([FromBody] Mfuncionario cadastro, [FromServices] RepoFuncionario repoFuncionario) => 
        {
            try
            {
                await repoFuncionario.CadastrarBibliotecario(cadastro);
                return Results.Ok("Bibliotecario cadastrado com sucesso");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            } 
        });
    }
}