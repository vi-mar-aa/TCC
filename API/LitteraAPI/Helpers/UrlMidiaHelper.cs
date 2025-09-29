namespace LitteraAPI.Helpers;

public static class UrlMidiaHelper
{
    public static string GetImagemUrl(int idMidia)
    {
        return $"/midia/{idMidia}/imagem"; 
    }
}