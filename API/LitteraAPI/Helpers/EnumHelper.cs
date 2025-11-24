using System;
using System.Reflection;
using System.Runtime.Serialization;

namespace LitteraAPI.Helpers
{
    public static class EnumHelper
    {
        // Converte do banco (string) para enum, considerando EnumMember
        public static T GetEnumSafe<T>(object value, T defaultValue = default) where T : struct, Enum
        {
            if (value == null || value == DBNull.Value)
                return defaultValue;

            var stringValue = value.ToString()?.Trim();
            if (string.IsNullOrEmpty(stringValue))
                return defaultValue;

            // Primeiro, tenta encontrar pelo EnumMember
            foreach (var field in typeof(T).GetFields(BindingFlags.Public | BindingFlags.Static))
            {
                var attr = field.GetCustomAttribute<EnumMemberAttribute>();
                if (attr != null && attr.Value.Equals(stringValue, StringComparison.OrdinalIgnoreCase))
                    return (T)field.GetValue(null);
            }

            // Fallback: tenta parse pelo nome do enum (case-insensitive)
            if (Enum.TryParse<T>(stringValue, true, out var result))
                return result;

            // Nenhum match encontrado, retorna default
            return defaultValue;
        }

        // Converte do enum para string (para salvar no banco, por exemplo)
        public static string ToStringValue<T>(T enumValue) where T : struct, Enum
        {
            var type = typeof(T);
            var memInfo = type.GetMember(enumValue.ToString());
            var attr = memInfo[0].GetCustomAttribute<EnumMemberAttribute>();
            return attr?.Value ?? enumValue.ToString();
        }
    }
}