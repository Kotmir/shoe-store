namespace ShoeStore.Models;

public class AppUser
{
    public int UserId { get; set; }

    public string Login { get; set; } = "";

    public string FullName { get; set; } = "";

    public int RoleId { get; set; }

    // Соответствие RoleId из БД ролям приложения. Если после импорта id ролей изменятся — правьте здесь.
    public UserRole Role => RoleId switch
    {
        2 => UserRole.Manager,
        3 => UserRole.Admin,
        _ => UserRole.Client
    };
}
