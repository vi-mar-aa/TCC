using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestReserva
{
    public Mreserva Reserva { get; set; }
    public Mmidia Midia { get; set; }
}