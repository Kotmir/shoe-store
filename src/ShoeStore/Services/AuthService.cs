using ShoeStore.Data;
using ShoeStore.Models;

namespace ShoeStore.Services;

public static class AuthService
{
    // Возвращает пользователя или null, если логин/пароль не подошли
    public static AppUser? Authenticate(string login, string password)
    {
        using var connection = Database.OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = @"
            SELECT UserId, Login, FullName, RoleId
            FROM AppUser
            WHERE Login = $login AND Password = $password";
        command.Parameters.AddWithValue("$login", login);
        command.Parameters.AddWithValue("$password", password);

        using var reader = command.ExecuteReader();

        if (!reader.Read())
        {
            return null;
        }

        return new AppUser
        {
            UserId = reader.GetInt32(0),
            Login = reader.GetString(1),
            FullName = reader.GetString(2),
            RoleId = reader.GetInt32(3)
        };
    }
}
