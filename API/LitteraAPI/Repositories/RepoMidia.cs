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

    public async Task<byte[]> ObterImagem(int id)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_SelecionarImagemMidiaPorID", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_midia", id); 
            await con.OpenAsync();
            var result = await cmd.ExecuteScalarAsync();
            return result == DBNull.Value ? null : (byte[])result;
        }
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
                   Anopublicacao = ReaderHelper.GetStringSafe(reader, "ano_publicacao"),
                   Localpublicacao = ReaderHelper.GetStringSafe(reader, "local_publicacao"),
                   Npaginas = ReaderHelper.GetIntSafe(reader, "numero_paginas"),
                   Isbn = ReaderHelper.GetStringSafe(reader, "isbn"),
                   Imagem = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_midia"]),
                   NomeTipo = ReaderHelper.GetStringSafe(reader, "nome_tipo"),
                   ContExemplares = ReaderHelper.GetIntSafe(reader, "total_exemplares"),
                   Duracao = ReaderHelper.GetStringSafe(reader, "duracao"),
                   Estudio = ReaderHelper.GetStringSafe(reader, "estudio"),
                   Roterista = ReaderHelper.GetStringSafe(reader, "roteirista"),
                   
                    
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
                    Anopublicacao = ReaderHelper.GetStringSafe(reader, "ano_publicacao"),
                    Roterista = ReaderHelper.GetStringSafe(reader, "roteirista"),
                    Imagem = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_midia"])
                    
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
                    Anopublicacao = ReaderHelper.GetStringSafe(reader, "ano_publicacao"),
                    //Roterista = ReaderHelper.GetStringSafe(reader, "roteirista"),
                    Imagem = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_midia_exemplo"])
                    
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
                    Anopublicacao = ReaderHelper.GetStringSafe(reader, "ano_publicacao"),
                    Genero = EnumHelper.GetEnumSafe<GeneroMidia>(reader["genero"]),
                    Imagem = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_midia"])
                    
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
                    Anopublicacao = ReaderHelper.GetStringSafe(reader, "ano_publicacao"),
                    Genero = EnumHelper.GetEnumSafe<GeneroMidia>(reader["genero"]),
                    Imagem = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_midia_exemplo"])
                    
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
                    Anopublicacao = ReaderHelper.GetStringSafe(reader, "ano_publicacao"),
                    Edicao = ReaderHelper.GetStringSafe(reader, "edicao"),
                    Localpublicacao = ReaderHelper.GetStringSafe(reader, "local_publicacao"),
                    Npaginas = ReaderHelper.GetIntSafe(reader, "numero_paginas"),
                    Isbn = ReaderHelper.GetStringSafe(reader, "isbn"),
                    //NomeTipo = ReaderHelper.GetStringSafe(reader, "nome_tipo"),
                    ContExemplares = ReaderHelper.GetIntSafe(reader, "quantidade_exemplares"),
                    Duracao = ReaderHelper.GetStringSafe(reader, "duracao"),
                    Estudio = ReaderHelper.GetStringSafe(reader, "estudio"),
                    Roterista = ReaderHelper.GetStringSafe(reader, "roteirista"),
                    Genero = EnumHelper.GetEnumSafe<GeneroMidia>(reader["genero"]),
                    Dispo = EnumHelper.GetEnumSafe<StatusMidia>(reader["disponibilidade"]),
                    Imagem = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_midia"])
                    
                });

            }
            
            return midia;
        }
    }

    public async Task<bool> AdicionarLivro(RequestMidia request)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MidiaAdicionar_Livro", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email_funcionario", request.Funcionario.Email);
            cmd.Parameters.AddWithValue("@titulo", request.Midia.Titulo);
            cmd.Parameters.AddWithValue("@sinopse", request.Midia.Sinopse);
            cmd.Parameters.AddWithValue("@autor", request.Midia.Autor);
            cmd.Parameters.AddWithValue("@editora", request.Midia.Editora);
            cmd.Parameters.AddWithValue("@ano_publicacao", request.Midia.Anopublicacao);
            cmd.Parameters.AddWithValue("@edicao", request.Midia.Edicao);
            cmd.Parameters.AddWithValue("@local_publicacao", request.Midia.Localpublicacao);
            cmd.Parameters.AddWithValue("@numero_paginas", request.Midia.Npaginas);
            cmd.Parameters.AddWithValue("@isbn", request.Midia.Isbn);
            cmd.Parameters.AddWithValue("@genero", EnumHelper.ToStringValue(request.Midia.Genero));
            cmd.Parameters.AddWithValue("@imagem_base64", request.Midia.Imagem);
           
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
        
    }

    public async Task<bool> AdicionarFilme(RequestMidia request){
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MidiaAdicionar_Filme", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email_funcionario", request.Funcionario.Email);
            cmd.Parameters.AddWithValue("@titulo", request.Midia.Titulo);
            cmd.Parameters.AddWithValue("@sinopse", request.Midia.Sinopse);
            cmd.Parameters.AddWithValue("@roteirista", request.Midia.Roterista);
            cmd.Parameters.AddWithValue("@estudio", request.Midia.Estudio);
            cmd.Parameters.AddWithValue("@ano_publicacao", request.Midia.Anopublicacao);
            cmd.Parameters.AddWithValue("@duracao", request.Midia.Duracao);
            //cmd.Parameters.AddWithValue("@local_publicacao", request.Midia.Localpublicacao); ???
            cmd.Parameters.AddWithValue("@genero", EnumHelper.ToStringValue(request.Midia.Genero));
            cmd.Parameters.AddWithValue("@imagem_base64", request.Midia.Imagem);
           
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }
    
    public async Task<bool> AdicionarRevista(RequestMidia request)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MidiaAdicionar_Revista", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email_funcionario", request.Funcionario.Email);
            cmd.Parameters.AddWithValue("@titulo", request.Midia.Titulo);
            cmd.Parameters.AddWithValue("@sinopse", request.Midia.Sinopse);
            cmd.Parameters.AddWithValue("@editora", request.Midia.Editora);
            cmd.Parameters.AddWithValue("@ano_publicacao", request.Midia.Anopublicacao);
            cmd.Parameters.AddWithValue("@local_publicacao", request.Midia.Localpublicacao);
            cmd.Parameters.AddWithValue("@numero_paginas", request.Midia.Npaginas);
            cmd.Parameters.AddWithValue("@genero", EnumHelper.ToStringValue(request.Midia.Genero));
            cmd.Parameters.AddWithValue("@imagem_base64", request.Midia.Imagem);
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
        
    }
    
    public async Task<bool> AlterarLivro(RequestMidia request)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MidiaAlterar_Livro", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_midia", request.Midia.IdMidia);
            cmd.Parameters.AddWithValue("@titulo", request.Midia.Titulo);
            cmd.Parameters.AddWithValue("@sinopse", request.Midia.Sinopse);
            cmd.Parameters.AddWithValue("@autor", request.Midia.Autor);
            cmd.Parameters.AddWithValue("@editora", request.Midia.Editora);
            cmd.Parameters.AddWithValue("@ano_publicacao", request.Midia.Anopublicacao);
            cmd.Parameters.AddWithValue("@edicao", request.Midia.Edicao);
            cmd.Parameters.AddWithValue("@local_publicacao", request.Midia.Localpublicacao);
            cmd.Parameters.AddWithValue("@numero_paginas", request.Midia.Npaginas);
            cmd.Parameters.AddWithValue("@isbn", request.Midia.Isbn);
            cmd.Parameters.AddWithValue("@genero", EnumHelper.ToStringValue(request.Midia.Genero));
            cmd.Parameters.AddWithValue("@disponibilidade", EnumHelper.ToStringValue(request.Midia.Dispo));
            cmd.Parameters.AddWithValue("@imagem_base64", request.Midia.Imagem);
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
        
    }
    
    public async Task<bool> AlterarFilme(RequestMidia request){
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MidiaAlterar_Filme", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_midia", request.Midia.IdMidia);
            cmd.Parameters.AddWithValue("@titulo", request.Midia.Titulo);
            cmd.Parameters.AddWithValue("@sinopse", request.Midia.Sinopse);
            cmd.Parameters.AddWithValue("@roteirista", request.Midia.Roterista);
            cmd.Parameters.AddWithValue("@estudio", request.Midia.Estudio);
            cmd.Parameters.AddWithValue("@ano_publicacao", request.Midia.Anopublicacao);
            cmd.Parameters.AddWithValue("@duracao", request.Midia.Duracao);
            //cmd.Parameters.AddWithValue("@local_publicacao", request.Midia.Localpublicacao); ???
            cmd.Parameters.AddWithValue("@genero", EnumHelper.ToStringValue(request.Midia.Genero));
            cmd.Parameters.AddWithValue("@disponibilidade", EnumHelper.ToStringValue(request.Midia.Dispo));
            cmd.Parameters.AddWithValue("@imagem_base64", request.Midia.Imagem);
            
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }
    
    public async Task<bool> AlterarRevista(RequestMidia request)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MidiaAlterar_Revista", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_midia", request.Midia.IdMidia);
            cmd.Parameters.AddWithValue("@titulo", request.Midia.Titulo);
            cmd.Parameters.AddWithValue("@sinopse", request.Midia.Sinopse);
            cmd.Parameters.AddWithValue("@editora", request.Midia.Editora);
            cmd.Parameters.AddWithValue("@ano_publicacao", request.Midia.Anopublicacao);
            cmd.Parameters.AddWithValue("@local_publicacao", request.Midia.Localpublicacao);
            cmd.Parameters.AddWithValue("@numero_paginas", request.Midia.Npaginas);
            cmd.Parameters.AddWithValue("@genero", request.Midia.Genero.ToString());
            cmd.Parameters.AddWithValue("@genero", EnumHelper.ToStringValue(request.Midia.Genero));
            cmd.Parameters.AddWithValue("@disponibilidade", EnumHelper.ToStringValue(request.Midia.Dispo));
            cmd.Parameters.AddWithValue("@imagem_base64", request.Midia.Imagem);
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
        
    }

    public async Task<bool> InativarMidia(int id)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MidiaInativar", con))
        {    
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_midia", id);
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task<List<Mmidia>> PesquisaAcervo(string searchtext)
    {
        var midia = new List<Mmidia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_AcervoBuscar", con))
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@q", searchtext);
            
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                midia.Add(new Mmidia()
                {
                    
                    IdMidia = (int)reader["id_midia"],
                    Titulo = ReaderHelper.GetStringSafe(reader, "titulo"),
                    Autor = ReaderHelper.GetStringSafe(reader, "autor"),
                    Anopublicacao = ReaderHelper.GetStringSafe(reader, "ano_publicacao"),
                    NomeTipo = ReaderHelper.GetStringSafe(reader, "nome_tipo"),
                    Dispo = EnumHelper.GetEnumSafe<StatusMidia>(reader["disponibilidade"]), 
                    Isbn = ReaderHelper.GetStringSafe(reader, "isbn"),
                    Estudio = ReaderHelper.GetStringSafe(reader, "estudio"),
                    Roterista = ReaderHelper.GetStringSafe(reader, "roteirista"),
                    Imagem = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_midia"])
                    
                });

            }
            
            return midia;
        }
    }

}

