namespace LitteraAPI.Models;

public class MIndicacao
{
    public int IdIndicacao { get; set; }
    public int IdCliente { get; set; }
    public string TextoIndicacao { get; set; }
    public string AutorIndicado { get; set; }
    public DateTime DataIndicacao { get; set; }
}