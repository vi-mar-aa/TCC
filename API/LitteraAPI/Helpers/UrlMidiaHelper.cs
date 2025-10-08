namespace LitteraAPI.Helpers;

public static class UrlMidiaHelper
{
    public static string GetImagemMidiaUrl(int idMidia)
    {
        return $"/midia/{idMidia}/imagem"; 
    }

    public static string GetImagemClienteUrl(int idCliente)
    {
        return $"/cliente/{idCliente}/imagem";
    }
}