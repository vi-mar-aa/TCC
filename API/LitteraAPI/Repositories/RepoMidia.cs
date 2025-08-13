using System.ComponentModel.DataAnnotations;
using LitteraAPI.DTOS;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoMidia
{
    private readonly string _connectionString;
    
    public RepoMidia(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }

    public async Task<List<Mmidia>> ListarTodosLivros()
    {
        var midia = new List<Mmidia>();
        
        using var con = new SqlConnection(_connectionString);
        //using (var cmd = new SqlCommand("sp_Acervo", con)) //faltando proc do acervo
        using (var cmd = new SqlCommand("SELECT * FROM Midia", con))
        {
            //cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    IdMidia = (int)reader["id_midia"],
                    Idfuncionario = (int)reader["id_funcionario"],
                    Idtpmidia = (int)reader["id_tpmidia"],
                    Titulo = (string)reader["titulo"],
                    Autor = (string)reader["autor"],
                    Editora = (string)reader["editora"],
                    Anopublicacao = (int)reader["ano_publicacao"],
                    Edicao = (string)reader["edicao"],
                    Localpublicacao = (string)reader["local_publicacao"],
                    Npaginas = (int)reader["numero_paginas"],
                    Isbn = (string)reader["isbn"],
                    Dispo = (string)reader["disponibilidade"],
                    Genero = (string)reader["genero"],
                    Imagem = Convert.ToBase64String((byte[])reader["imagem"])
                    
                });

            }
            
            return midia;
        }
    } 
    
    public async Task<List<Mmidia>> ListarTodosFilmes()
    {
        var midia = new List<Mmidia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_Acervo", con)) //faltando proc do acervo
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    IdMidia = (int)reader["IdMidia"], // este retorno é importante para no futuro a aplicação conseguir ter o parametro para retornar os detalhes do livro
                    Idfuncionario = (int)reader["Idfuncionario"],
                    Idtpmidia = (int)reader["Idtpmidia"],
                    Titulo = (string)reader["Titulo"],
                    Editora = (string)reader["Editora"],
                    //Autor = (string)reader["Autor"], autor?Diretor?
                    Anopublicacao = (int)reader["Anopublicacao"],
                    //Edicao = (string)reader["Edicao"],
                    Localpublicacao = (string)reader["Localpublicacao"],
                    //Npaginas = (int)reader["Npaginas"],
                    //Isbn = (string)reader["Isbn"],
                    Duracao = (string)reader["Duracao"],
                    Estudio = (string)reader["Estudio"],
                    Roterista = (string)reader["Roterista"],
                    Dispo = (string)reader["Dispo"],
                    Genero = (string)reader["Genero"],
                    Imagem = Convert.ToBase64String((byte[])reader["Imagem"])
                    
                });

            }
            
            return midia;
        }
    }                                          
    
    public async Task InserirMidia(RequestMidia midia)  //tmidia e o email são parametros da requisição!!!
    {
        if (midia.TMidia == 1)//livro                         //como especificar o parametro agora????????
        {
            using var con = new SqlConnection(_connectionString);
            using (var cmd = new SqlCommand("sp_CadastrarMidia", con)) //sem proc ainda, ajustar os parametros
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@email", midia.EmailFunc);
                cmd.Parameters.AddWithValue("@id_tpmidia", midia.TMidia);
                cmd.Parameters.AddWithValue("@titulo", midia.Midia.Titulo);
                cmd.Parameters.AddWithValue("@autor", midia.Midia.Autor); 
                cmd.Parameters.AddWithValue("@editora", midia.Midia.Editora);
                cmd.Parameters.AddWithValue("@genero", midia.Midia.Genero);
                cmd.Parameters.AddWithValue("@ano_publicacao", midia.Midia.Anopublicacao);
                cmd.Parameters.AddWithValue("@edicao", midia.Midia.Edicao);
                cmd.Parameters.AddWithValue("@local_publicacao", midia.Midia.Localpublicacao);
                cmd.Parameters.AddWithValue("@numero_paginas", midia.Midia.Npaginas);
                cmd.Parameters.AddWithValue("@isbn", midia.Midia.Isbn);
                cmd.Parameters.AddWithValue("@dispo", "disponivel");
                
                await con.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
                
            }
            
        }else if (midia.TMidia == 2)//filme
        {
            using var con = new SqlConnection(_connectionString);
            using (var cmd = new SqlCommand("sp_CadastrarMidia", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@email", midia.EmailFunc);
                cmd.Parameters.AddWithValue("@id_tpmidia", midia.TMidia);
                cmd.Parameters.AddWithValue("@titulo", midia.Midia.Titulo);
                cmd.Parameters.AddWithValue("@autor", midia.Midia.Autor); //diretor?
                cmd.Parameters.AddWithValue("@genero", midia.Midia.Genero);
                cmd.Parameters.AddWithValue("@local_publicacao",midia.Midia.Localpublicacao);
                cmd.Parameters.AddWithValue("@duracao", midia.Midia.Duracao);
                cmd.Parameters.AddWithValue("@estudio", midia.Midia.Estudio);
                cmd.Parameters.AddWithValue("@roterista", midia.Midia.Roterista);
                cmd.Parameters.AddWithValue("@dispo", "disponivel");
            }
            
            
        }else if (midia.TMidia == 3)//revista
        {
            
            using var con = new SqlConnection(_connectionString);
            using (var cmd = new SqlCommand("sp_CadastrarMid", con)) //sem proc ainda, ajustar os parametros
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@email", midia.EmailFunc);
                cmd.Parameters.AddWithValue("@id_tpmidia", midia.TMidia);
                cmd.Parameters.AddWithValue("@titulo", midia.Midia.Titulo);
                cmd.Parameters.AddWithValue("@autor", midia.Midia.Autor);
                cmd.Parameters.AddWithValue("@editora", midia.Midia.Editora);
                cmd.Parameters.AddWithValue("@genero", midia.Midia.Genero);
                cmd.Parameters.AddWithValue("@ano_publicacao", midia.Midia.Anopublicacao);
                cmd.Parameters.AddWithValue("@edicao",midia.Midia.Edicao);
                cmd.Parameters.AddWithValue("@local_publicacao", midia.Midia.Localpublicacao);
                cmd.Parameters.AddWithValue("@numero_paginas", midia.Midia.Npaginas);
                cmd.Parameters.AddWithValue("@isbn", midia.Midia.Isbn);
                cmd.Parameters.AddWithValue("@dispo", "disponivel");

                await con.OpenAsync();
                await cmd.ExecuteNonQueryAsync();

            }


        }else if (midia.TMidia == 4)//ebook
        {
            
            using var con = new SqlConnection(_connectionString);
            using (var cmd = new SqlCommand("sp_CadastrarMidia", con)) //sem proc ainda, ajustar os parametros
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@email", midia.EmailFunc);
                cmd.Parameters.AddWithValue("@id_tpmidia", midia.TMidia);
                cmd.Parameters.AddWithValue("@titulo", midia.Midia.Titulo);
                cmd.Parameters.AddWithValue("@autor", midia.Midia.Autor);
                cmd.Parameters.AddWithValue("@editora", midia.Midia.Editora);
                cmd.Parameters.AddWithValue("@genero", midia.Midia.Genero);
                cmd.Parameters.AddWithValue("@ano_publicacao", midia.Midia.Anopublicacao);
                cmd.Parameters.AddWithValue("@edicao", midia.Midia.Edicao);
                cmd.Parameters.AddWithValue("@local_publicacao", midia.Midia.Localpublicacao);
                cmd.Parameters.AddWithValue("@numero_paginas", midia.Midia.Npaginas);
                cmd.Parameters.AddWithValue("@isbn", midia.Midia.Isbn);
                cmd.Parameters.AddWithValue("@dispo", "disponivel");

                await con.OpenAsync();
                await cmd.ExecuteNonQueryAsync();

            }
        }
        
        
        
    }
    
}