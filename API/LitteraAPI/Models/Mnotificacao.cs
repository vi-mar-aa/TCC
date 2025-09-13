namespace LitteraAPI.Models;

public class Mnotificacao
{
    public int IdNotificacao { get; set; }
    public int IdCliente {get; set;}
    public string Titulo { get; set; }
    public string Mensagem { get; set; }
    public DateTime DataCriacao { get; set; }
    public Boolean Lida { get; set; }
}