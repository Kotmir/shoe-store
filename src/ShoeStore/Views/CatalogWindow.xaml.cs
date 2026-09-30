using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using ShoeStore.Data;
using ShoeStore.Models;
using ShoeStore.Services;

namespace ShoeStore.Views;

public partial class CatalogWindow : Window
{
    private const int AllSuppliersId = 0;

    private List<Product> allProducts = new();
    private bool isReady;

    public CatalogWindow()
    {
        InitializeComponent();

        UserNameTextBlock.Text = Session.DisplayName;
        LogoImage.Source = ImageService.LoadLogo();

        ConfigureForRole();
        LoadSuppliers();
        LoadProducts();

        isReady = true;
        ApplyFilters();
    }

    private void ConfigureForRole()
    {
        ToolbarPanel.Visibility = Session.CanUseTools ? Visibility.Visible : Visibility.Collapsed;
        OrdersButton.Visibility = Session.CanUseTools ? Visibility.Visible : Visibility.Collapsed;
        AddProductButton.Visibility = Session.AdminOnlyVisibility;
    }

    private void LoadSuppliers()
    {
        var suppliers = new List<LookupItem> { new(AllSuppliersId, "Все поставщики") };

        try
        {
            suppliers.AddRange(LookupRepository.GetSuppliers());
        }
        catch (Exception exception)
        {
            ShowDatabaseError("список поставщиков", exception);
        }

        SupplierComboBox.ItemsSource = suppliers;
        SupplierComboBox.SelectedIndex = 0;
    }

    private void LoadProducts()
    {
        try
        {
            allProducts = ProductRepository.GetAll();
        }
        catch (Exception exception)
        {
            allProducts = new List<Product>();
            ShowDatabaseError("список товаров", exception);
        }

        if (isReady)
        {
            ApplyFilters();
        }
    }

    // Поиск, фильтр и сортировка применяются вместе при каждом изменении параметров
    private void ApplyFilters()
    {
        if (!isReady)
        {
            return;
        }

        IEnumerable<Product> query = allProducts;

        string searchText = SearchTextBox.Text.Trim();

        if (searchText.Length > 0)
        {
            query = query.Where(product => MatchesSearch(product, searchText));
        }

        if (SupplierComboBox.SelectedItem is LookupItem supplier && supplier.Id != AllSuppliersId)
        {
            query = query.Where(product => product.SupplierId == supplier.Id);
        }

        query = SortComboBox.SelectedIndex switch
        {
            1 => query.OrderBy(product => product.StockQuantity),
            2 => query.OrderByDescending(product => product.StockQuantity),
            _ => query
        };

        List<Product> result = query.ToList();
        ProductsItemsControl.ItemsSource = result;

        CountTextBlock.Text = result.Count == 0
            ? "Ничего не найдено. Измените строку поиска или выберите другого поставщика."
            : $"Показано товаров: {result.Count} из {allProducts.Count}";
    }

    // Каждое слово запроса должно встретиться хотя бы в одном текстовом поле товара
    private static bool MatchesSearch(Product product, string searchText)
    {
        string haystack = string.Join(" ",
            product.ProductName,
            product.CategoryName,
            product.Description,
            product.ManufacturerName,
            product.SupplierName,
            product.UnitName);

        string[] words = searchText.Split(' ', StringSplitOptions.RemoveEmptyEntries);

        return words.All(word => haystack.Contains(word, StringComparison.CurrentCultureIgnoreCase));
    }

    private void SearchTextBox_TextChanged(object sender, TextChangedEventArgs e)
    {
        ApplyFilters();
    }

    private void FilterComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        ApplyFilters();
    }

    private void ProductItem_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
    {
        if (!Session.IsAdmin)
        {
            return;
        }

        if (sender is FrameworkElement { DataContext: Product product })
        {
            OpenEditForm(product);
        }
    }

    private void AddProductButton_Click(object sender, RoutedEventArgs e)
    {
        OpenEditForm(null);
    }

    // product == null — добавление нового товара
    private void OpenEditForm(Product? product)
    {
        if (ProductEditWindow.IsOpen)
        {
            MessageService.Warning(
                "Окно редактирования товара уже открыто. Завершите работу в нём или закройте его, затем откройте другой товар.",
                "Окно уже открыто");
            return;
        }

        try
        {
            var window = new ProductEditWindow(product) { Owner = this };
            window.Closed += (_, _) => LoadProducts();
            window.Show();
        }
        catch (Exception exception)
        {
            ShowDatabaseError("форма товара", exception);
        }
    }

    private void DeleteButton_Click(object sender, RoutedEventArgs e)
    {
        if (!Session.IsAdmin || sender is not FrameworkElement { DataContext: Product product })
        {
            return;
        }

        bool confirmed = MessageService.Confirm(
            $"Удалить товар «{product.ProductName}»? Это действие нельзя отменить.",
            "Подтверждение удаления");

        if (!confirmed)
        {
            return;
        }

        try
        {
            if (ProductRepository.IsInOrders(product.ProductId))
            {
                MessageService.Error(
                    $"Товар «{product.ProductName}» нельзя удалить: он присутствует в заказах. " +
                    "Сначала измените или удалите заказы с этим товаром.",
                    "Удаление запрещено");
                return;
            }

            ProductRepository.Delete(product.ProductId);
            ImageService.DeleteProductImage(product.ImagePath);
            LoadProducts();
            MessageService.Info("Товар удалён.", "Готово");
        }
        catch (Exception exception)
        {
            ShowDatabaseError("удаление товара", exception);
        }
    }

    private void OrdersButton_Click(object sender, RoutedEventArgs e)
    {
        if (!Session.CanUseTools)
        {
            MessageService.Warning("Просмотр заказов доступен только менеджеру и администратору.", "Доступ запрещён");
            return;
        }

        new OrdersWindow { Owner = this }.Show();
    }

    private void LogoutButton_Click(object sender, RoutedEventArgs e)
    {
        Session.SignOut();
        new LoginWindow().Show();
        Close();
    }

    private static void ShowDatabaseError(string action, Exception exception)
    {
        MessageService.Error(
            $"Не удалось выполнить операцию ({action}): {exception.Message}" +
            "\n\nПовторите действие. Если ошибка повторится, перезапустите приложение или обратитесь к администратору.",
            "Ошибка базы данных");
    }
}
