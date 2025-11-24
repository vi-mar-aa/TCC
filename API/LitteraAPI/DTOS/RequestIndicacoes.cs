using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestIndicacoes
{
    public Mcliente Cliente { get; set; }
    
    public MIndicacao Indicacao { get; set; }
    
    public int Contagem { get; set; }
    
}