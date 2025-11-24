namespace LitteraAPI.Helpers;

public class RequestFiltroAcervo
{
    
    public string Tipo { get; set; }              // 'livros', 'filmes', etc.
    public List<string> Generos { get; set; }     // lista de gêneros
    public List<string> Anos { get; set; }        // lista de anos de publicação
    
}
