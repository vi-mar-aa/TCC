namespace LitteraAPI.Models;

public class Memprestimo
{
    public int IdEmprestimo { get; set; }
    public int IdCliente { get; set; }
    public int IdMidia { get; set; }
    public int IdReserva { get; set; }
    public int IdFuncionario { get; set; }
    public DateTime DataEmprestimo { get; set; }
    public DateTime DataDevolucao { get; set; }
    public int LimiteRenovacoes { get; set; }
    public string StatusEmprestimo { get; set; }
}