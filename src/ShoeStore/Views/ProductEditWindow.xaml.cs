using System.Globalization;
using System.IO;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media.Imaging;
using Microsoft.Win32;
using ShoeStore.Data;
using ShoeStore.Models;
using ShoeStore.Services;

namespace ShoeStore.Views;

public partial class ProductEditWindow : Window
{
    private static readonly Regex DigitsRegex = new("^[0-9]+$");
    private static readonly Regex PriceRegex = new("^[0-9.,]+$");

    private readonly Product product;
    private readonly bool isNew;

    // Полный путь к выбранному, но ещё не сохранённому фото
    private string? pendingImageFile;

    // Одновременно может быть открыто только одно окно редактирования
    public static bool IsOpen { get; private set; }

    // existing == null — режим добавления нового товара
    public ProductEditWindow(Product? existing)
    {
        InitializeComponent();

        isNew = existing == null;
        product = existing ?? new Product();

        Title = isNew ? "Добавление товара" : "Редактирование товара";

        LoadLookups();
        FillFields();

        IsOpen = true;
        Closed += (_, _) => IsOpen = false;
    }

    private void LoadLookups()
    {
        CategoryComboBox.ItemsSource = LookupRepository.GetCategories();
        ManufacturerComboBox.ItemsSource = LookupRepository.GetManufacturers();
        SupplierComboBox.ItemsSource = LookupRepository.GetSuppliers();
        UnitComboBox.ItemsSource = LookupRepository.GetUnits();
    }

    private void FillFields()
    {
        PreviewImage.Source = ImageService.Load(product.ImagePath);

        if (isNew)
        {
            IdPanel.Visibility = Visibility.Collapsed;
            DiscountTextBox.Text = "0";
            StockTextBox.Text = "0";
            return;
        }

        IdTextBox.Text = product.ProductId.ToString();
        NameTextBox.Text = product.ProductName;
        CategoryComboBox.SelectedValue = product.CategoryId;
        DescriptionTextBox.Text = product.Description;
        ManufacturerComboBox.SelectedValue = product.ManufacturerId;
        SupplierComboBox.SelectedValue = product.SupplierId;
        PriceTextBox.Text = product.Price.ToString("0.00", CultureInfo.InvariantCulture);
        UnitComboBox.SelectedValue = product.UnitId;
        StockTextBox.Text = product.StockQuantity.ToString();
        DiscountTextBox.Text = product.Discount.ToString();
    }

    private void IntegerTextBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
    {
        e.Handled = !DigitsRegex.IsMatch(e.Text);
    }

    private void PriceTextBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
    {
        e.Handled = !PriceRegex.IsMatch(e.Text);
    }

    private void ChooseImageButton_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Title = "Выберите фото товара",
            Filter = "Изображения (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg"
        };

        if (dialog.ShowDialog(this) != true)
        {
            return;
        }

        try
        {
            BitmapImage image = ImageService.LoadFromFile(dialog.FileName);

            if (!ImageService.FitsSizeLimit(image))
            {
                MessageService.Warning(
                    $"Размер фото {image.PixelWidth}×{image.PixelHeight} пикселей превышает допустимый " +
                    $"({ImageService.MaxWidth}×{ImageService.MaxHeight}). Уменьшите изображение и выберите файл снова.",
                    "Фото слишком большое");
                return;
            }

            pendingImageFile = dialog.FileName;
            PreviewImage.Source = image;
        }
        catch (Exception)
        {
            MessageService.Error(
                "Не удалось открыть файл как изображение. Выберите другой файл в формате PNG или JPG.",
                "Ошибка чтения фото");
        }
    }

    private void SaveButton_Click(object sender, RoutedEventArgs e)
    {
        if (!TryReadForm(out Product edited, out string errorText))
        {
            MessageService.Warning(errorText, "Проверьте введённые данные");
            return;
        }

        string? oldImagePath = product.ImagePath;
        string? newImagePath = null;

        try
        {
            if (pendingImageFile != null)
            {
                newImagePath = ImageService.SaveProductImage(pendingImageFile);
            }

            edited.ImagePath = newImagePath ?? oldImagePath;

            if (isNew)
            {
                ProductRepository.Add(edited);
            }
            else
            {
                edited.ProductId = product.ProductId;
                ProductRepository.Update(edited);
            }
        }
        catch (Exception exception)
        {
            // Товар не сохранён — новый файл фото больше не нужен
            TryDeleteImage(newImagePath);

            MessageService.Error(
                "Не удалось сохранить товар: " + exception.Message +
                "\n\nПроверьте данные и повторите сохранение.",
                "Ошибка сохранения");
            return;
        }

        if (newImagePath != null)
        {
            TryDeleteImage(oldImagePath);
        }

        MessageService.Info("Товар успешно сохранён.", "Сохранено");
        Close();
    }

    private void BackButton_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }

    private bool TryReadForm(out Product edited, out string errorText)
    {
        var errors = new List<string>();
        edited = new Product();

        string name = NameTextBox.Text.Trim();

        if (name.Length == 0)
        {
            errors.Add("• Введите наименование товара.");
        }

        int categoryId = GetSelectedId(CategoryComboBox);

        if (categoryId == 0)
        {
            errors.Add("• Выберите категорию из списка.");
        }

        int manufacturerId = GetSelectedId(ManufacturerComboBox);

        if (manufacturerId == 0)
        {
            errors.Add("• Выберите производителя из списка.");
        }

        int supplierId = GetSelectedId(SupplierComboBox);

        if (supplierId == 0)
        {
            errors.Add("• Выберите поставщика из списка.");
        }

        int unitId = GetSelectedId(UnitComboBox);

        if (unitId == 0)
        {
            errors.Add("• Выберите единицу измерения из списка.");
        }

        string priceText = PriceTextBox.Text.Trim().Replace(',', '.');
        bool priceParsed = decimal.TryParse(priceText, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out decimal price);

        if (!priceParsed || price < 0)
        {
            errors.Add("• Цена: введите число не меньше 0, например 1999.90.");
        }
        else if (Math.Round(price, 2) != price)
        {
            errors.Add("• Цена: допускается не более двух знаков после запятой.");
        }

        if (!int.TryParse(StockTextBox.Text.Trim(), NumberStyles.None, CultureInfo.InvariantCulture, out int stock))
        {
            errors.Add("• Количество на складе: введите целое число не меньше 0.");
        }

        bool discountParsed = int.TryParse(DiscountTextBox.Text.Trim(), NumberStyles.None, CultureInfo.InvariantCulture, out int discount);

        if (!discountParsed || discount > 100)
        {
            errors.Add("• Скидка: введите целое число от 0 до 100.");
        }

        if (errors.Count > 0)
        {
            errorText = "Товар не сохранён. Исправьте:\n\n" + string.Join("\n", errors);
            return false;
        }

        edited = new Product
        {
            ProductName = name,
            CategoryId = categoryId,
            Description = DescriptionTextBox.Text.Trim(),
            ManufacturerId = manufacturerId,
            SupplierId = supplierId,
            Price = price,
            UnitId = unitId,
            StockQuantity = stock,
            Discount = discount
        };
        errorText = "";
        return true;
    }

    private static int GetSelectedId(ComboBox comboBox)
    {
        return comboBox.SelectedValue is int id ? id : 0;
    }

    private static void TryDeleteImage(string? relativePath)
    {
        try
        {
            ImageService.DeleteProductImage(relativePath);
        }
        catch (IOException)
        {
            // Файл занят или недоступен: лишний файл не должен ломать сохранение товара
        }
    }
}
