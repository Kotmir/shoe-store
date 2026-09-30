using System.IO;
using System.Reflection;
using Microsoft.Data.Sqlite;

namespace ShoeStore.Data;

public static class Database
{
    private static readonly string DatabasePath = Path.Combine(AppContext.BaseDirectory, "shoestore.db");

    public static SqliteConnection OpenConnection()
    {
        var connection = new SqliteConnection("Data Source=" + DatabasePath);
        connection.Open();

        using var command = connection.CreateCommand();
        command.CommandText = "PRAGMA foreign_keys = ON;";
        command.ExecuteNonQuery();

        return connection;
    }

    // Создаёт таблицы при первом запуске и наполняет тестовыми данными, если БД пустая
    public static void Initialize()
    {
        using var connection = OpenConnection();
        ExecuteScript(connection, ReadEmbeddedScript("schema.sql"));

        if (IsEmpty(connection))
        {
            ExecuteScript(connection, ReadEmbeddedScript("seed.sql"));
        }
    }

    private static bool IsEmpty(SqliteConnection connection)
    {
        using var command = connection.CreateCommand();
        command.CommandText = "SELECT COUNT(*) FROM Role;";
        return Convert.ToInt32(command.ExecuteScalar()) == 0;
    }

    private static void ExecuteScript(SqliteConnection connection, string script)
    {
        using var command = connection.CreateCommand();
        command.CommandText = script;
        command.ExecuteNonQuery();
    }

    private static string ReadEmbeddedScript(string resourceName)
    {
        using Stream? stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(resourceName);

        if (stream == null)
        {
            throw new InvalidOperationException("В приложение не встроен скрипт БД: " + resourceName);
        }

        using var reader = new StreamReader(stream);
        return reader.ReadToEnd();
    }
}
