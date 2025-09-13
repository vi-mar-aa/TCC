namespace LitteraAPI.Models;

public class MIndicacao
{
    public int IdIndicacao { get; set; }
    public int IdFuncionario { get; set; }
    public string TextoIndicacao { get; set; }
    public string AutorIndicado { get; set; }
    public DateTime DataIndicacao { get; set; }
}