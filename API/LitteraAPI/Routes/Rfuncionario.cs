
using Microsoft.AspNetCore.Mvc;
using LitteraAPI.Repositories;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;
namespace LitteraAPI.Routes;


public static class Rfuncionario
{
    public static void Routesfuncionario(this WebApplication app)
    {
        app.MapPost("/LoginFuncionario", async ([FromBody] Mfuncionario login, [FromServices] RepoFuncionario repoFuncionario) => //testada
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

        app.MapPost("/CadastrarAdm", async ([FromBody] Mfuncionario func, [FromServices] RepoFuncionario repoFuncionario) => //testada
        {
                try
                {
                    var cadastro = await repoFuncionario.CadastrarAdm(func);

                    return cadastro
                        ? Results.Ok("Adm cadastrado com sucesso")
                        : Results.NotFound("Dados inválidos.");
                }
                catch (SqlException ex)
                {
                    return Results.Problem("Erro no banco: " + ex.Message);
                } 
        });
        
        app.MapPost("/CadastrarBibliotecario", async ([FromBody] Mfuncionario func, [FromServices] RepoFuncionario repoFuncionario) => //testada
        {
            try
            {
                var cadastro = await repoFuncionario.CadastrarBibliotecario(func);

                return cadastro
                    ? Results.Ok("Bibliotecário cadastrado com sucesso")
                    : Results.NotFound("Dados inválidos.");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });

        app.MapGet("/ListarFuncionarios", async (RepoFuncionario repo) => //testada
        {
            try
            {
                var func = await repo.ListarFuncionarios();
                return Results.Ok(func);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });

        app.MapPost("/AlterarFuncionario", async ([FromBody] Mfuncionario funcionario, [FromServices] RepoFuncionario repo) =>
        {
            try
            {
                var rows = await repo.AlterarFuncionario(funcionario);

                return rows 
                    ? Results.Ok("Dados alterados com sucesso.")
                    : Results.NotFound("Referência a um funcionário inválido.");
                
            }catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });
    }
}