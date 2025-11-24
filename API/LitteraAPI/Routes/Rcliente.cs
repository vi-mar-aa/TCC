using LitteraAPI.DTOS;
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
        
        app.MapPost("/AlterarDadosCliente", async ([FromBody] Mcliente editarCliente, [FromServices] RepoCliente repoCliente) =>
        {
            try
            {
                var reset = await repoCliente.AlterarDados(editarCliente); 
                return reset
                    ?Results.Ok("Informações resetadas com sucesso")
                    :Results.NotFound("Informações não resetadas");
            }
            catch (SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }  
        });
        app.MapPost("/AlterarTodosDadosCliente",
            async ([FromBody] Mcliente editarCliente, [FromServices] RepoCliente repoCliente) =>
            {
                try
                {
                    var reset = await repoCliente.AlterarDadosTeste(editarCliente);
                    return reset
                        ? Results.Ok("Informações resetadas com sucesso")
                        : Results.NotFound("Informações não resetadas");
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
                var status = await repoCliente.CadastrarCliente(cadastro);
                return status
                    ? Results.Ok("Cadastro realizado com sucesso.")
                    : Results.NotFound("Impossivel realizar cadastro.");
                
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
                    ? Results.Ok("Usuário suspenso.")
                    : Results.NotFound("Usuário inválido");
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
 
            }
        });
        
        app.MapPost("/InativarContaCliente", async ([FromBody] Mcliente cliente, [FromServices] RepoCliente repo) =>
        {
            try
            {
                var status = await repo.InativarConta(cliente.User);

                return status
                    ? Results.Ok("Usuário suspenso.")
                    : Results.NotFound("Usuário inválido.");
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
 
            }
        });

        app.MapPost("/AlterarFotoPerfilCliente", async ([FromBody]Mcliente cliente, [FromServices] RepoCliente repo) =>
        {
            try
            {
                var status = await repo.AlterarFotoPerfil(cliente);
                return status
                    ? Results.Ok("Foto alterada.")
                    : Results.NotFound("Foto não alterada.");
                
            }catch(SqlException ex){
                return Results.Problem("Erro no banco: " + ex.Message);
            }
        });

        app.MapPost("/BuscarLeitorPorUsername", async ([FromBody] RequestPesquisa request, [FromServices] RepoCliente repo) =>
        {
            try
            {
                var leitor = await repo.PesquisarLeitor(request.SearchText);
                return Results.Ok(leitor);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });

        app.MapPost("BuscarLeitorPorEmail", async ([FromBody] Mcliente cliente, [FromServices] RepoCliente repo) =>
        {
            try
            {
                var leitor = await repo.PesquisarLeitorPorEmail(cliente.Email);
                return Results.Ok(leitor);
            }
            catch(SqlException ex)
            {
                return Results.Problem("Erro no banco: " + ex.Message);
            }
            
        });

        
    }
}

    
