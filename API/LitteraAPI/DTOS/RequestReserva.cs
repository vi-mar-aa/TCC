using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestReserva
{
    public Mreserva Reserva { get; set; }
    public Mmidia Midia { get; set; }
    
    public Mcliente Cliente { get; set; }
    
    public Mfuncionario Funcionario { get; set; }
    public Memprestimo Emprestimo { get; set; }
    
    public string ChaveIdentificadora { get; set; }
    
    public string TempoRestante { get; set; }
}