namespace LitteraAPI.Helpers;

public static class EnumHelper
{
    // Converte do banco (string) para enum
  
        public static T GetEnumSafe<T>(object value, T defaultValue = default) where T : struct, Enum
        {
            if (value == null || value == DBNull.Value)
                return defaultValue;

            var stringValue = value.ToString()?.Trim();

            if (string.IsNullOrEmpty(stringValue))
                return defaultValue;

            // tenta parse ignorando case
            if (Enum.TryParse<T>(stringValue, true, out var result))
                return result;

            // fallback: compara em lower case manualmente
            foreach (var name in Enum.GetNames(typeof(T)))
            {
                if (name.ToLower() == stringValue.ToLower())
                    return (T)Enum.Parse(typeof(T), name);
            }

            return defaultValue;
        }
    

    // Converte do enum para string (para salvar no banco, por exemplo)
    public static string ToStringValue<T>(T enumValue) where T : struct, Enum
    {
        return enumValue.ToString();
    }
}
