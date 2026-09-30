using System.Windows;
using System.Windows.Threading;
using ShoeStore.Data;
using ShoeStore.Services;
using ShoeStore.Views;

namespace ShoeStore;

public partial class App : Application
{
    private void OnStartup(object sender, StartupEventArgs e)
    {
        try
        {
            Database.Initialize();
        }
        catch (Exception exception)
        {
            MessageService.Error(
                "Не удалось подключиться к базе данных.\n\nПричина: " + exception.Message +
                "\n\nПроверьте, что папка приложения доступна для записи, и запустите приложение заново.",
                "Ошибка подключения к базе данных");
            Shutdown();
            return;
        }

        new LoginWindow().Show();
    }

    private void OnUnhandledException(object sender, DispatcherUnhandledExceptionEventArgs e)
    {
        MessageService.Error(
            "Произошла непредвиденная ошибка: " + e.Exception.Message +
            "\n\nПриложение продолжит работу. Повторите действие, а если ошибка повторится — обратитесь к администратору.",
            "Непредвиденная ошибка");
        e.Handled = true;
    }
}
