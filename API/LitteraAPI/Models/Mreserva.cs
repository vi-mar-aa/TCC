namespace LitteraAPI.Models;

public class Mreserva
{
    public int IdReserva { get; set; }
    public int IdCliente { get; set; }
    public int IdMidia { get; set; }
    public DateTime DataReserva { get; set; }
    public DateTime DataLimite { get; set; }
    public string StatusReserva { get; set; }
   
}