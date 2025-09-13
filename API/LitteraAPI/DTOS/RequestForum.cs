using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestForum
{
    public Mmensagem mensagem { get; set; }
    public Mcliente cliente { get; set; }
}