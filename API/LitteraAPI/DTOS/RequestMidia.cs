
using LitteraAPI.Models;

namespace LitteraAPI.DTOS;

public class RequestMidia
{
 
 public Mfuncionario Funcionario { get; set; }
 public Mmidia Midia { get; set; } //referencia a modelo da midia, uma forma de conseguir colocar dados de modelos diferentes no mesmo JSON
}