namespace LitteraAPI.Helpers;

public static class DateTimeHelper
{
    public static (DateTime Inicio, DateTime Fim) ConverterHorario(
        string faixaHorarios,
        DateTime dataInicio,
        DateTime dataFim)
    {
        if (string.IsNullOrWhiteSpace(faixaHorarios))
            throw new ArgumentException("faixaHorarios vazio");

        var partes = faixaHorarios.Split('/');
        if (partes.Length != 2)
            throw new ArgumentException("Formato inválido. Use 'HH[:mm]/HH[:mm]' ou 'H/H'.");

        var tsInicio = ParseHourPart(partes[0].Trim());
        var tsFim    = ParseHourPart(partes[1].Trim());

        // Opcional: se quiser trabalhar com a data local quando o DateTime vier em UTC:
        // dataInicio = dataInicio.Kind == DateTimeKind.Utc ? dataInicio.ToLocalTime() : dataInicio;
        // dataFim    = dataFim.Kind    == DateTimeKind.Utc ? dataFim.ToLocalTime()    : dataFim;

        // Preserva o dia mas aplica hora e minuto do TimeSpan
        var inicio = new DateTime(
            dataInicio.Year, dataInicio.Month, dataInicio.Day,
            tsInicio.Hours, tsInicio.Minutes, tsInicio.Seconds, DateTimeKind.Unspecified);

        var fim = new DateTime(
            dataFim.Year, dataFim.Month, dataFim.Day,
            tsFim.Hours, tsFim.Minutes, tsFim.Seconds, DateTimeKind.Unspecified);

        // Se for no mesmo dia e fim <= inicio => considerar virada para o dia seguinte
        if (dataInicio.Date == dataFim.Date && fim <= inicio)
            fim = fim.AddDays(1);

        return (inicio, fim);
    }

    private static TimeSpan ParseHourPart(string part)
    {
        // aceita "16", "4", "16:30", "02:15", etc.
        if (string.IsNullOrWhiteSpace(part))
            throw new ArgumentException("parte de horário vazio");

        // se contém ':', usa TimeSpan.TryParse (formatos hora:minuto)
        if (part.Contains(':'))
        {
            if (TimeSpan.TryParse(part, out var ts))
                return ts;
            throw new ArgumentException($"Horário inválido: '{part}'");
        }

        // se for inteiro (ex: "16") -> interpreta como horas
        if (int.TryParse(part, out var horas))
        {
            if (horas < 0 || horas > 23)
                throw new ArgumentException($"Hora inválida: {horas}. Espere 0-23.");
            return TimeSpan.FromHours(horas);
        }

        // caso contrário, erro
        throw new ArgumentException($"Formato de horário inválido: '{part}'");
    }
}
