using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestEvento
{
    public Mevento Evento { get; set; }
    public Mfuncionario Funcionario { get; set; }
    public DateTime DataInicio { get; set; }
    public DateTime DataFim { get; set; }   
    public string Horario { get; set; }
}