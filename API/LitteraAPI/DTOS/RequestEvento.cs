using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestEvento
{
    public Mevento Evento { get; set; }
    public DateOnly DataInicio { get; set; }
    public DateOnly DataFim { get; set; }   
    public string Horario { get; set; }
}