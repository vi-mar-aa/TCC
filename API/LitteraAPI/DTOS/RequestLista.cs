using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestLista
{
    public Mlista ListaDesejos { get; set; }
    public Mcliente Cliente { get; set; }
    public Mmidia Midia { get; set; }
}