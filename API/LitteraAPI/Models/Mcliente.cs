namespace LitteraAPI.Models;

public class Mcliente
{
    public int IdCliente { get; set; }
    public string Nome { get; set; }
    public string User { get; set; }
    public int Cpf { get; set; }
    public string Email { get; set; }
    public string Senha { get; set; }
    public string Telefone { get; set; }
    public string Status_conta { get; set; }
    
    public string ImagemPerfil { get; set; }
}