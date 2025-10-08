using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestForum
{
    public Mmensagem mensagem { get; set; }
    public Mcliente cliente { get; set; }
    
    public int QtdComentarios {get; set; }
    
    public Filtros Filtro { get; set; }

    public enum Filtros
    {
       recentes,
       antigos,
       populares
    }
}