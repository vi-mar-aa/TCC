namespace LitteraAPI.Models;

public class Mmidia
{
     public int IdMidia { get; set; }
     public int Idfuncionario { get; set; } //Vai precisar de pegar o id do funcionario  no banco atraves do email por email
     public int Idtpmidia { get; set; }
     public string Titulo { get; set; }
     public string? Autor { get; set; }
     
     public string? Sinopse { get; set; }
     
     public string? Editora { get; set; }
     public int? Anopublicacao { get; set; }
     public string? Edicao { get; set; }
     public string? Localpublicacao { get; set; } //pra que?
     public int? Npaginas { get; set; }
     public string? Isbn { get; set; }
     public string? Duracao { get; set; }
     public string Estudio { get; set; }
     public string? Roterista { get; set; }
     public string Dispo { get; set; } //bool?
     public string Genero { get; set; }
     
     public string Imagem { get; set; } //base64
     
     public int? ContExemplares { get; set; }
     
     public string? NomeTipo { get; set; }
     
}