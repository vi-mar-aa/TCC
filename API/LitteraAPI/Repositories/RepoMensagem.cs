using LitteraAPI.DTOS;
using LitteraAPI.Helpers;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoMensagem
{
    private readonly string _connectionString;
    
    public RepoMensagem(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }
    
    public async Task<bool> AdicionarPost(RequestForum post)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MensagemAdicionar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@titulo", post.mensagem.Titulo);
            cmd.Parameters.AddWithValue("@email_cliente", post.cliente.Email);
            cmd.Parameters.AddWithValue("@conteudo", post.mensagem.Conteudo);
            //cmd.Parameters.AddWithValue("@id_pai", post.mensagem.IdPai);
      
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    /*public async Task<bool> InativarPost(int id)
    {
        
    }*/

    public async Task<bool> AdicionarComentario(RequestForum post)
    {
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand("sp_MensagemAdicionar", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@titulo", post.mensagem.Titulo);
            cmd.Parameters.AddWithValue("@email_cliente", post.cliente.Email);
            cmd.Parameters.AddWithValue("@conteudo", post.mensagem.Conteudo);
            cmd.Parameters.AddWithValue("@id_pai", post.mensagem.IdPai);
      
            await con.OpenAsync();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                return reader.HasRows;
            }
        }
    }

    public async Task<List<RequestForum>> ListarPostCompleto(int id) //lista post + comentarios do post especificado
    {
        var post = new List<RequestForum>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_PostCompleto", con)) 
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_post", id);
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                post.Add(new RequestForum()
                {
                    mensagem = new Mmensagem()
                    {
                        IdMensagem = (int)reader["id_mensagem"],
                        IdPai = ReaderHelper.GetIntSafe(reader, "id_pai"),
                        Titulo = reader["titulo"].ToString(),
                        Conteudo = ReaderHelper.GetStringSafe(reader, "conteudo"),
                        DataPostagem = (DateTime)reader["data_postagem"],
                        Curtidas = (int)reader["curtidas"],
                    },
                    cliente = new Mcliente()
                    {
                        Nome = (string)reader["autor"],
                        User = (string)reader["username"],
                        ImagemPerfil = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_cliente"])
                    },
                    //QtdComentarios = (int)reader["qtd_comentarios"] ta faltando retornar
                });
                
            }
            
            return post;
        }
    }
    
    public async Task<List<RequestForum>> ListarTodosPosts(string filtro) //lista todos os posts sem comentarios associados
    {
        var post = new List<RequestForum>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_PostsListar", con)) 
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ordenar_por", filtro);
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                post.Add(new RequestForum()
                {
                    mensagem = new Mmensagem()
                    {
                        IdMensagem = (int)reader["id_mensagem"],
                        //IdPai = ReaderHelper.GetIntSafe(reader, "id_pai"),
                        Titulo = reader["titulo"].ToString(),
                        Conteudo = ReaderHelper.GetStringSafe(reader, "conteudo"),
                        DataPostagem = (DateTime)reader["data_postagem"],
                        Curtidas = (int)reader["curtidas"],
                    },
                    cliente = new Mcliente()
                    {
                        Nome = (string)reader["autor"],
                        User = (string)reader["username"],
                        //ImagemPerfil = UrlMidiaHelper.GetImagemUrl((int)reader["id_cliente"])
                    },
                    QtdComentarios = (int)reader["qtd_comentarios"]
                    
                });

            }
            
            return post;
        }
    }

    public async Task<List<RequestForum>> ListarHistoricoPostsLeitor(string email)
    {
        var post = new List<RequestForum>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_LeitorPostsHistorico", con)) 
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@email", email);
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                post.Add(new RequestForum()
                {
                    mensagem = new Mmensagem()
                    {
                        IdMensagem = (int)reader["id_mensagem"],
                        //IdPai = ReaderHelper.GetIntSafe(reader, "ano_publicacao"), ta faltando o retorno na proc 
                        //Titulo = reader["titulo"].ToString(),
                        Conteudo = ReaderHelper.GetStringSafe(reader, "conteudo"),
                        DataPostagem = (DateTime)reader["data_postagem"],
                    },
                    cliente = new Mcliente()
                    {
                        Nome = (string)reader["autor"],
                        User = (string)reader["username"],
                        //ImagemPerfil = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_cliente"]) preisa retornar o id do cliente
                    },
                    
                });

            }
            
            return post;
        }
    }
    
    
    
}

