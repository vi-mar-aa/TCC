using LitteraAPI.Models;
namespace LitteraAPI.DTOS;

public class RequestDenuncia
{
    public Mmensagem Mensagem { get; set; }
    public Mcliente CLiente { get; set; }
    public Mdenuncia Denuncia { get; set; }
    
    public Mfuncionario Funcionario { get; set; }
}