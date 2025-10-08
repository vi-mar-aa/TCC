namespace LitteraAPI.Models;

public class Mmensagem
{
    public int IdMensagem { get; set; }
    public int IdCliente { get; set; }
    public int ? IdPai { get; set; }
    public string? Titulo { get; set; }
    public string? Conteudo { get; set; }
    public DateTime DataPostagem { get; set; }
    public Boolean Visibilidade { get; set; }
    public int Curtidas { get; set; }
    
    
}