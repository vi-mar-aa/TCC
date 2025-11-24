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
        _connectionString = configuration.GetConnectionString("SqlServer") 
            ?? throw new InvalidOperationException("Connection string 'SqlServer' not found.");
    }

    public async Task<List<RequestDenuncia>> ListarDenuncias()
    {
        var denuncias = new List<RequestDenuncia>();

        using var con = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand("sp_DenunciasListar", con)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        await con.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            denuncias.Add(new RequestDenuncia()
            {
                Denuncia = new Mdenuncia()
                {
                    IdDenuncia = (int)ReaderHelper.GetIntSafe(reader, "id_denuncia"),
                    DataDenuncia = (DateTime)reader["data_denuncia"],
                    Motivo = ReaderHelper.GetStringSafe(reader, "motivo"),
                    Status = EnumHelper.GetEnumSafe<StatusDenuncia>(reader["status_denuncia"]),
                    Acao = ReaderHelper.GetStringSafe(reader, "acao_tomada")
                },
                Mensagem = new Mmensagem()
                {
                    IdMensagem = (int)ReaderHelper.GetIntSafe(reader, "id_mensagem"),
                    Titulo = null,   // coluna não existe na SP
                    Conteudo = null  // coluna não existe na SP
                },
                CLiente = new Mcliente()
                {
                    IdCliente = (int)ReaderHelper.GetIntSafe(reader, "id_cliente"),
                    Nome = ReaderHelper.GetStringSafe(reader, "nome"), // <-- CORRIGIDO
                    User = ReaderHelper.GetStringSafe(reader, "username"),
                    ImagemPerfil = UrlMidiaHelper.GetImagemMidiaUrl(
                        (int)ReaderHelper.GetIntSafe(reader, "id_cliente")
                    )
                },
                Funcionario = new Mfuncionario()
                {
                    IdFuncionario = (int)ReaderHelper.GetIntSafe(reader, "id_funcionario")
                }
            });
        }

        return denuncias;
    }

    public async Task<List<RequestDenuncia>> ListarDenunciaEspecifica(int id)
    {
        var denuncias = new List<RequestDenuncia>();

        using var con = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand("sp_DenunciaVer", con)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        cmd.Parameters.AddWithValue("@id_denuncia", id);

        await con.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            denuncias.Add(new RequestDenuncia()
            {
                Denuncia = new Mdenuncia()
                {
                    IdDenuncia = (int)ReaderHelper.GetIntSafe(reader, "id_denuncia"),
                    DataDenuncia = (DateTime)reader["data_denuncia"],
                    Motivo = ReaderHelper.GetStringSafe(reader, "motivo"),
                    Status = EnumHelper.GetEnumSafe<StatusDenuncia>(reader["status_denuncia"]),
                    Acao = ReaderHelper.GetStringSafe(reader, "acao_tomada")
                },
                Mensagem = new Mmensagem()
                {
                    IdMensagem = (int)ReaderHelper.GetIntSafe(reader, "id_mensagem"),
                    Titulo = null,   // coluna não existe
                    Conteudo = null  // coluna não existe
                },
                CLiente = new Mcliente()
                {
                    IdCliente = (int)ReaderHelper.GetIntSafe(reader, "id_cliente"),
                    Nome = ReaderHelper.GetStringSafe(reader, "nome"), // <-- CORRIGIDO
                    User = ReaderHelper.GetStringSafe(reader, "username"),
                    ImagemPerfil = UrlMidiaHelper.GetImagemMidiaUrl(
                        (int)ReaderHelper.GetIntSafe(reader, "id_cliente")
                    )
                },
                Funcionario = new Mfuncionario()
                {
                    IdFuncionario = (int)ReaderHelper.GetIntSafe(reader, "id_funcionario")
                }
            });
        }

        return denuncias;
    }

    public async Task<bool> AnalisarDenuncia(RequestDenuncia denuncia)
    {
        using var con = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand("sp_DenunciaAnalisar", con)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        cmd.Parameters.AddWithValue("@id_denuncia", denuncia.Denuncia.IdDenuncia);
        cmd.Parameters.AddWithValue("@email_funcionario", denuncia.Funcionario.Email);
        cmd.Parameters.AddWithValue("@motivo", denuncia.Denuncia.Motivo);

        await con.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();

        return reader.HasRows;
    }
}