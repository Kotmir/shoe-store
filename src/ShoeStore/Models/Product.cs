using System.Windows.Media;
using ShoeStore.Services;

namespace ShoeStore.Models;

public class Product
{
    public int ProductId { get; set; }

    public string ProductName { get; set; } = "";

    public int CategoryId { get; set; }

    public string CategoryName { get; set; } = "";

    public string Description { get; set; } = "";

    public int ManufacturerId { get; set; }

    public string ManufacturerName { get; set; } = "";

    public int SupplierId { get; set; }

    public string SupplierName { get; set; } = "";

    public decimal Price { get; set; }

    public int UnitId { get; set; }

    public string UnitName { get; set; } = "";

    public int StockQuantity { get; set; }

    public int Discount { get; set; }

    public string? ImagePath { get; set; }

    public decimal FinalPrice => Math.Round(Price * (100 - Discount) / 100m, 2);

    public bool HasDiscount => Discount > 0;

    public bool IsBigDiscount => Discount > 15;

    public bool IsOutOfStock => StockQuantity <= 0;

    // Фото товара или картинка-заглушка, если фото нет
    public ImageSource? Photo => ImageService.Load(ImagePath);
}
