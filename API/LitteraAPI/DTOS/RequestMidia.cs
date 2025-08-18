
using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestMidia
{
 public string EmailFunc { get; set; }
 public int TMidia { get; set; }
 
 public string Genero { get; set; }
 public Mmidia Midia { get; set; } //referencia a modelo da midia, uma forma de conseguir colocar dados de modelos diferentes no mesmo JSON
}