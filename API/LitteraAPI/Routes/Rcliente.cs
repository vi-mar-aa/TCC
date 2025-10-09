using Microsoft.AspNetCore.Mvc;
using LitteraAPI.Repositories;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.DependencyInjection;

namespace LitteraAPI.Routes;

public static class Rcliente
{
    public static void Routescliente(this WebApplication app)
    {
        app.MapGet("/cliente/{id}/imagem", async (int id, RepoCliente repo) =>
        {
            var imagem = await repo.ObterImagem(id);
            if (imagem == null)
            {
                return Results.NotFound();
            }
            
            return Results.File((byte[])imagem, "image/png");
        });
        
        app.MapPost("/LoginCliente", async ([FromBody] Mcliente login, [FromServices] RepoCliente repoCliente) =>
        {
            try
            {
                var loginSucedido = await repoCliente.LoginCliente(login);

                return loginSucedido
                    ? Results.Ok("Login realizado com sucesso")
                    : Results.NotFound("Usuário ou senha incorretos");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });
        
        app.MapPost("/ResetarSenhaCliente", async ([FromBody] Mcliente resetSenha, [FromServices] RepoCliente repoCliente) =>
        {
            try
            {
                var reset = await repoCliente.ResetarSenha(resetSenha); 
                return reset
                    ?Results.Ok("Senha resetada com sucesso")
                    :Results.NotFound("Senha não resetada");
            }
            catch
            {
                return Results.Problem("Erro ao resetar senha");
            }  
        });

        app.MapPost("/CadastrarCliente", async ([FromBody] Mcliente cadastro, [FromServices] RepoCliente repoCliente) =>
        {
            try
            {

                await repoCliente.CadastrarCliente(cadastro);
                return Results.Ok("Cliente cadastrado com sucesso");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
            
        });


        app.MapPost("/SuspenderCliente", async ([FromBody] Mcliente cliente, [FromServices] RepoCliente repo) =>
        {
            try
            {
                var status = await repo.SuspenderCliente(cliente.User);

                return status
                    ? Results.Ok("Login realizado com sucesso")
                    : Results.NotFound("Usuário ou senha incorretos");
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
 
            }
        });

        app.MapPost("BuscarLeitor", async ([FromBody] Mcliente cliente, [FromServices] RepoCliente repo) =>
        {
            try
            {
                var leitor = await repo.PesquisarLeitor(cliente.User);
                return Results.Ok(leitor);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });

    }
}

    
