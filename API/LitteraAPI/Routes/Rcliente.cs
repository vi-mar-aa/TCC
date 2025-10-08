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
            
            /* map post cria o end point http post
             * o cadastrar cliente é o caminho da url, como o cliente vai chamar a rota
             * o segundo parametro é uma função que vai ser executada quando alguem fazer a requisição post
             * o [from body] Mcliente cadastro le o body da requisição e tenta converter para o modelo cliente
             * o [from services] RepoCliente repoCliente é uma forma do frame work criar automaticamente uma nova instancia do repocliente
             * 
             */
            
        });

        app.MapPost("/ResetarSenhaCliente", async ([FromBody] Mcliente resetSenha, [FromServices] RepoCliente repoCliente) =>
        {
            try
            {
                await repoCliente.ResetarSenha(resetSenha); 
                return Results.Ok("Senha resetada com sucesso");
            }
            catch
            {
                return Results.Problem("Erro ao resetar senha");
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
        
        
    }
}

    
