using System.Windows;
using ShoeStore.Data;
using ShoeStore.Services;

namespace ShoeStore.Views;

public partial class OrdersWindow : Window
{
    public OrdersWindow()
    {
        InitializeComponent();

        try
        {
            OrdersDataGrid.ItemsSource = OrderRepository.GetAll();
        }
        catch (Exception exception)
        {
            MessageService.Error(
                "Не удалось загрузить заказы: " + exception.Message + "\n\nЗакройте окно и откройте его снова.",
                "Ошибка базы данных");
        }
    }

    private void BackButton_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}
