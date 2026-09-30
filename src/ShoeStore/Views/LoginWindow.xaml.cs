using System.Windows;
using ShoeStore.Services;

namespace ShoeStore.Views;

public partial class LoginWindow : Window
{
    public LoginWindow()
    {
        InitializeComponent();
        LogoImage.Source = ImageService.LoadLogo();
    }

    private void LoginButton_Click(object sender, RoutedEventArgs e)
    {
        string login = LoginTextBox.Text.Trim();
        string password = PasswordBox.Password;

        if (login.Length == 0 || password.Length == 0)
        {
            MessageService.Warning(
                "Заполните оба поля: введите логин и пароль. Если у вас нет учётной записи, войдите как гость.",
                "Не заполнены поля");
            return;
        }

        try
        {
            var user = AuthService.Authenticate(login, password);

            if (user == null)
            {
                MessageService.Error(
                    "Неверный логин или пароль. Проверьте раскладку клавиатуры и регистр символов, затем повторите ввод.",
                    "Ошибка входа");
                PasswordBox.Clear();
                PasswordBox.Focus();
                return;
            }

            Session.SignIn(user);
            OpenCatalog();
        }
        catch (Exception exception)
        {
            MessageService.Error(
                "Не удалось проверить учётные данные из-за ошибки базы данных: " + exception.Message +
                "\n\nПовторите попытку позже или обратитесь к администратору.",
                "Ошибка базы данных");
        }
    }

    private void GuestButton_Click(object sender, RoutedEventArgs e)
    {
        Session.SignInAsGuest();
        OpenCatalog();
    }

    // Новое окно открываем до закрытия текущего, чтобы приложение не завершилось
    private void OpenCatalog()
    {
        new CatalogWindow().Show();
        Close();
    }
}
