namespace LitteraAPI.Models;

public class Mdenuncia
{
    public int IdDenuncia { get; set; }
    public int IdFuncionario { get; set; }
    public int IdMensagem { get; set; }
    public int IdCliente { get; set; }
    public DateTime DataDenuncia { get; set; }
    public string Motivo { get; set; }
    public string StatusDenuncia { get; set; }
    public string Acao { get; set; }
}