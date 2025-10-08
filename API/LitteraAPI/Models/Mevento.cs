namespace LitteraAPI.Models;

public class Mevento
{
    public int IdEvento { get; set; }
    public string Titulo { get; set; }
    public DateTime DataInicio { get; set; }
    public DateTime DataFim { get; set; }
    public string LocalEvento { get; set; }
    public string StatusEvento { get; set; }
    public int IdFuncionario { get; set; }
}