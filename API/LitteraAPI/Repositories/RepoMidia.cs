using System.ComponentModel.DataAnnotations;
using LitteraAPI.DTOS;
using LitteraAPI.Helpers;
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

    public async Task<List<Mmidia>> ListarMidias()
    {
        var midia = new List<Mmidia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_AcervoMidiasTodasInfosComExemplares", con))
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    
                   IdMidia = (int)reader["id_midia"],
                   Idfuncionario = (int)reader["id_funcionario"],
                   Titulo = ReaderHelper.GetStringSafe(reader, "titulo"),
                   Sinopse = ReaderHelper.GetStringSafe(reader, "sinopse"),
                   Autor = ReaderHelper.GetStringSafe(reader, "autor"),
                   Editora = ReaderHelper.GetStringSafe(reader, "editora"),
                   Anopublicacao = ReaderHelper.GetIntSafe(reader, "ano_publicacao"),
                   Localpublicacao = ReaderHelper.GetStringSafe(reader, "local_publicacao"),
                   Npaginas = ReaderHelper.GetIntSafe(reader, "numero_paginas"),
                   Isbn = ReaderHelper.GetStringSafe(reader, "isbn"),
                   Imagem = Convert.ToBase64String((byte[])reader["imagem"]),
                   NomeTipo = ReaderHelper.GetStringSafe(reader, "nome_tipo"),
                   ContExemplares = ReaderHelper.GetIntSafe(reader, "total_exemplares"),
                   Duracao = ReaderHelper.GetStringSafe(reader, "duracao"),
                   Estudio = ReaderHelper.GetStringSafe(reader, "estudio"),
                   Roterista = ReaderHelper.GetStringSafe(reader, "roteirista")
                    
                });

            }
            
            return midia;
        }
    }

    public async Task<List<Mmidia>> ListarMidiasAcervoAndroidMain()
    {
        var midia = new List<Mmidia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_AcervoPrincipal", con))
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    
                    IdMidia = (int)reader["id_midia"],
                    Titulo = ReaderHelper.GetStringSafe(reader, "titulo"),
                    Autor = ReaderHelper.GetStringSafe(reader, "autor"),
                    Anopublicacao = ReaderHelper.GetIntSafe(reader, "ano_publicacao"),
                    Roterista = ReaderHelper.GetStringSafe(reader, "roteirista"),
                    Imagem = Convert.ToBase64String((byte[])reader["imagem"])
                    
                });

            }
            
            return midia;
        }
    }
    
    public async Task<List<Mmidia>> ListarMidiasPorGeneroMain(string genero)
    {
        var midia = new List<Mmidia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_Top15LivrosPorGenero", con)) //testar e verificar parametros
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@genero", genero); 
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    
                    IdMidia = (int)reader["id_midia_exemplo"],
                    Titulo = ReaderHelper.GetStringSafe(reader, "titulo"),
                    Autor = ReaderHelper.GetStringSafe(reader, "autor"),
                    Anopublicacao = ReaderHelper.GetIntSafe(reader, "ano_publicacao"),
                    //Roterista = ReaderHelper.GetStringSafe(reader, "roteirista"),
                    Imagem = Convert.ToBase64String((byte[])reader["imagem"])
                    
                });

            }
            
            return midia;
        }
    }
    
    public async Task<List<Mmidia>> ListarMidiasPorGeneroSimilares(int id)
    {
        var midia = new List<Mmidia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_MidiasMesmoGeneroPorId", con)) //testar e verificar parametros
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_midia", id); 
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    
                    IdMidia = (int)reader["id_midia"],
                    Titulo = ReaderHelper.GetStringSafe(reader, "titulo"),
                    Autor = ReaderHelper.GetStringSafe(reader, "autor"),
                    Anopublicacao = ReaderHelper.GetIntSafe(reader, "ano_publicacao"),
                    Genero = ReaderHelper.GetStringSafe(reader, "genero"),
                    Imagem = Convert.ToBase64String((byte[])reader["imagem"])
                    
                });

            }
            
            return midia;
        }
    }
    
    public async Task<List<Mmidia>> ListarMidiasPopulares()
    {
        var midia = new List<Mmidia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_TopLivrosPopularesGeral", con)) 
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    
                    IdMidia = (int)reader["id_midia_exemplo"],
                    Titulo = ReaderHelper.GetStringSafe(reader, "titulo"),
                    Autor = ReaderHelper.GetStringSafe(reader, "autor"),
                    //Anopublicacao = ReaderHelper.GetIntSafe(reader, "ano_publicacao"),
                    Genero = ReaderHelper.GetStringSafe(reader, "genero"),
                    Imagem = Convert.ToBase64String((byte[])reader["imagem"])
                    
                });

            }
            
            return midia;
        }
    }
    
    
    public async Task<List<Mmidia>> ListarMidiaEspec(int id)
    {
        var midia = new List<Mmidia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_MidiaDetalhes", con))
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_midia", id); 
            
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    
                    IdMidia = (int)reader["id_midia"],
                    Idfuncionario = (int)reader["id_funcionario"],
                    Idtpmidia = (int)reader["id_tpmidia"],
                    CodigoExemplar = (int)reader["codigo_exemplar"],
                    Titulo = ReaderHelper.GetStringSafe(reader, "titulo"),
                    Sinopse = ReaderHelper.GetStringSafe(reader, "sinopse"),
                    Autor = ReaderHelper.GetStringSafe(reader, "autor"),
                    Editora = ReaderHelper.GetStringSafe(reader, "editora"),
                    Anopublicacao = ReaderHelper.GetIntSafe(reader, "ano_publicacao"),
                    Edicao = ReaderHelper.GetStringSafe(reader, "edicao"),
                    Localpublicacao = ReaderHelper.GetStringSafe(reader, "local_publicacao"),
                    Npaginas = ReaderHelper.GetIntSafe(reader, "numero_paginas"),
                    Isbn = ReaderHelper.GetStringSafe(reader, "isbn"),
                    //NomeTipo = ReaderHelper.GetStringSafe(reader, "nome_tipo"),
                    ContExemplares = ReaderHelper.GetIntSafe(reader, "quantidade_exemplares"),
                    Duracao = ReaderHelper.GetStringSafe(reader, "duracao"),
                    Estudio = ReaderHelper.GetStringSafe(reader, "estudio"),
                    Roterista = ReaderHelper.GetStringSafe(reader, "roteirista"),
                    Dispo = (string)reader["disponibilidade"],
                    Genero = ReaderHelper.GetStringSafe(reader, "genero"),
                    Imagem = Convert.ToBase64String((byte[])reader["imagem"]),
                    
                });

            }
            
            return midia;
        }
    }
    
    
    /*public async Task InserirMidia(RequestMidia midia) 
    {
        if (midia.TMidia == 1)//livro                         
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
                //imagem
                
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

    public async Task<List<Mmidia>> ListarMainAndroidGenerosSimilares(string genero)
    {
        var midia = new List<Mmidia>();

        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MainListar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@genero_ref", genero);
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    IdMidia = (int)reader["id_midia"],
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
    
    
    public async Task<List<Mmidia>> ListarMainAndroidPopulares()
    {
        var midia = new List<Mmidia>();

        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MainListar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    IdMidia = (int)reader["id_midia"],
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
    }*/
    
    
    
    
    
    /*CREATE PROCEDURE sp_AcervoPrincipal --pag principal
AS
BEGIN
  SELECT 
    m.id_midia,
    m.imagem,
    m.titulo,
    m.autor,
    m.roteirista,
    m.ano_publicacao
  FROM Midia m
  ORDER BY m.titulo;
END*/
    
    /*
                   IdMidia = (int)reader["id_midia"],
                   Idfuncionario = (int)reader["id_funcionario"],
                   Idtpmidia = (int)reader["id_tpmidia"],
                   Titulo = (string)reader["titulo"],
                   Sinopse = (string)reader["sinopse"],
                   Autor = (string)reader["autor"],
                   Editora = (string)reader["editora"],
                   Anopublicacao = (int)reader["ano_publicacao"],
                   Edicao = (string)reader["edicao"],
                   Localpublicacao = (string)reader["local_publicacao"],
                   Npaginas = (int)reader["numero_paginas"],
                   Isbn = (string)reader["isbn"],
                   Dispo = (string)reader["disponibilidade"],
                   Genero = (string)reader["genero"],
                   Imagem = Convert.ToBase64String((byte[])reader["imagem"]),
                   NomeTipo = (string)reader["nome_tipo"],
                   ContExemplares = (int)reader["total_exemplares"],

                   Duracao = (string)reader["duracao"],
                   Estudio = (string)reader["estudio"],
                   Roterista = (string)reader["roterista"],
                   */
    
    

    
    
}

