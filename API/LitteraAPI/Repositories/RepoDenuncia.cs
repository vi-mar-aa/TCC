using LitteraAPI.DTOS;
using LitteraAPI.Helpers;
using LitteraAPI.Models;
using Microsoft.Data.SqlClient;

namespace LitteraAPI.Repositories;

public class RepoDenuncia
{
    private readonly string _connectionString;
    
    public RepoDenuncia(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("SqlServer") ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }

    public async Task<List<RequestDenuncia>> ListarDenuncias()
    {
        var denuncias = new List<RequestDenuncia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_DenunciasListar", con)) 
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                denuncias.Add(new RequestDenuncia()
                {
                    Denuncia = new Mdenuncia()
                    {
                      IdDenuncia = (int)reader["id_denuncia"],  
                      DataDenuncia = (DateTime)reader["data_denuncia"],
                      Motivo = (string)reader["motivo"],
                      Status = EnumHelper.GetEnumSafe<StatusDenuncia>(reader["status_denuncia"]),
                      Acao = ReaderHelper.GetStringSafe(reader, "acao_tomada")
                    },
                    Mensagem = new Mmensagem()
                    {
                        IdMensagem = (int)reader["id_mensagem"],
                        IdPai = ReaderHelper.GetIntSafe(reader, ""),
                        Titulo = reader["titulo"].ToString(),
                        Conteudo = ReaderHelper.GetStringSafe(reader, "conteudo"),
                    },
                    CLiente = new Mcliente()
                    {   IdCliente = (int)reader["id_cliente"],
                        Nome = (string)reader["autor"],
                        User = (string)reader["username"],
                        ImagemPerfil = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_cliente"])
                    },
                    Funcionario = new Mfuncionario()
                    {
                        IdFuncionario = (int)reader["id_funcionario"],
                    }
          
                });
                
            }
            
            return denuncias;
        }
    }
    
    public async Task<List<RequestDenuncia>> ListarDenunciaEspecifica(int id)
    {
        var denuncias = new List<RequestDenuncia>();
        
        using var con = new SqlConnection(_connectionString);
        using (var cmd = new SqlCommand ("sp_DenunciaVer", con)) 
        { 
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@id_denuncia", id);
            await con.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                denuncias.Add(new RequestDenuncia()
                {
                    Denuncia = new Mdenuncia() //ajustar retornos
                    {
                      IdDenuncia = (int)reader["id_denuncia"],  
                      DataDenuncia = (DateTime)reader["data_denuncia"],
                      Motivo = (string)reader["motivo"],
                      Status = EnumHelper.GetEnumSafe<StatusDenuncia>(reader["status_denuncia"]),
                      Acao = ReaderHelper.GetStringSafe(reader, "acao_tomada")
                    },
                    Mensagem = new Mmensagem()
                    {
                        IdMensagem = (int)reader["id_mensagem"],
                        IdPai = ReaderHelper.GetIntSafe(reader, ""),
                        Titulo = reader["titulo"].ToString(),
                        Conteudo = ReaderHelper.GetStringSafe(reader, "conteudo"),
                    },
                    CLiente = new Mcliente()
                    {   IdCliente = (int)reader["id_cliente"],
                        Nome = (string)reader["autor"],
                        User = (string)reader["username"],
                        ImagemPerfil = UrlMidiaHelper.GetImagemMidiaUrl((int)reader["id_cliente"])
                    },
                    Funcionario = new Mfuncionario()
                    {
                        IdFuncionario = (int)reader["id_funcionario"],
                    }
          
                });
                
            }
            
            return denuncias;
        }
    }
    
}