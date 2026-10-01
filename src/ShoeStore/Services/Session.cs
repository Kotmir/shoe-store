using System.Windows;
using System.Windows.Input;
using ShoeStore.Models;

namespace ShoeStore.Services;

// Текущий пользователь приложения. Гость — это отсутствие пользователя.
public static class Session
{
    public static AppUser? CurrentUser { get; private set; }

    public static UserRole Role => CurrentUser?.Role ?? UserRole.Guest;

    public static string DisplayName => CurrentUser?.FullName ?? "Гость";

    public static bool IsAdmin => Role == UserRole.Admin;

    // Поиск, фильтры, сортировка и просмотр заказов доступны менеджеру и администратору
    public static bool CanUseTools => Role is UserRole.Manager or UserRole.Admin;

    public static Visibility AdminOnlyVisibility => IsAdmin ? Visibility.Visible : Visibility.Collapsed;

    // Карточку товара можно открыть для редактирования только администратору — ему показываем «руку»
    public static Cursor ItemCursor => IsAdmin ? Cursors.Hand : Cursors.Arrow;

    public static string RoleName => Role switch
    {
        UserRole.Admin => "Администратор",
        UserRole.Manager => "Менеджер",
        UserRole.Client => "Клиент",
        _ => "Гость"
    };

    public static void SignIn(AppUser user)
    {
        CurrentUser = user;
    }

    public static void SignInAsGuest()
    {
        CurrentUser = null;
    }

    public static void SignOut()
    {
        CurrentUser = null;
    }
}
