using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestEmprestimo
{
    public Mmidia Midia { get; set; }
    public Mcliente Cliente { get; set; }
    public Memprestimo Emprestimo { get; set; }
    public Mfuncionario funcionario { get; set; }
    public int DiasAtraso { get; set; }
    public Decimal ValorMulta { get; set; }
    public int StatusRenovacao { get; set; }
    
    public DateTime NovaData { get; set; }
}