using System.Windows;

namespace ShoeStore.Services;

// Все окна сообщений приложения: тип, заголовок и пиктограмма подбираются по ситуации
public static class MessageService
{
    public static void Error(string message, string title = "Ошибка")
    {
        MessageBox.Show(message, title, MessageBoxButton.OK, MessageBoxImage.Error);
    }

    public static void Warning(string message, string title = "Предупреждение")
    {
        MessageBox.Show(message, title, MessageBoxButton.OK, MessageBoxImage.Warning);
    }

    public static void Info(string message, string title = "Информация")
    {
        MessageBox.Show(message, title, MessageBoxButton.OK, MessageBoxImage.Information);
    }

    // Предупреждение о необратимой операции с подтверждением
    public static bool Confirm(string message, string title = "Подтверждение")
    {
        MessageBoxResult result = MessageBox.Show(message, title, MessageBoxButton.YesNo, MessageBoxImage.Warning);
        return result == MessageBoxResult.Yes;
    }
}
