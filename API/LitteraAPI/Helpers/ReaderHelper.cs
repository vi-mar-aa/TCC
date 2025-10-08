using Microsoft.Data.SqlClient;

namespace LitteraAPI.Helpers;

public static class ReaderHelper
{

    public static string? GetStringSafe(SqlDataReader reader, string column)
    {
        return reader[column] == DBNull.Value ? null : (string)reader[column];
    }

    public static int? GetIntSafe(SqlDataReader reader, string column) 
    {
        return reader[column] == DBNull.Value ? null : (int?)reader[column];
    }

    public static DateTime? GetDateTimeSafe(SqlDataReader reader, string column) 
    { 
        return reader[column] == DBNull.Value ? null : (DateTime?)reader[column];
    }
    
    public static byte[]? GetBytesSafe(SqlDataReader reader, string column) 
    { 
        return reader[column] == DBNull.Value ? null : (byte[])reader[column];
    }
    
}