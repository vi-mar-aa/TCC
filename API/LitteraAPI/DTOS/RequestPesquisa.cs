using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestPesquisa
{
    public Mmidia midia { get; set; }
    public string SearchText { get; set; }
    
}