using Microsoft.Data.Sqlite;
using ShoeStore.Models;

namespace ShoeStore.Data;

public static class ProductRepository
{
    private const string SelectSql = @"
        SELECT p.ProductId, p.ProductName, p.CategoryId, c.CategoryName, p.Description,
               p.ManufacturerId, m.ManufacturerName, p.SupplierId, s.SupplierName,
               p.Price, p.UnitId, u.UnitName, p.StockQuantity, p.Discount, p.ImagePath
        FROM Product p
        JOIN Category c ON c.CategoryId = p.CategoryId
        JOIN Manufacturer m ON m.ManufacturerId = p.ManufacturerId
        JOIN Supplier s ON s.SupplierId = p.SupplierId
        JOIN Unit u ON u.UnitId = p.UnitId
        ORDER BY p.ProductId";

    public static List<Product> GetAll()
    {
        var products = new List<Product>();

        using var connection = Database.OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = SelectSql;

        using var reader = command.ExecuteReader();

        while (reader.Read())
        {
            products.Add(ReadProduct(reader));
        }

        return products;
    }

    public static void Add(Product product)
    {
        using var connection = Database.OpenConnection();
        using var transaction = connection.BeginTransaction();

        // ID не вводится вручную: берём максимальный из БД и прибавляем 1
        using (var idCommand = connection.CreateCommand())
        {
            idCommand.Transaction = transaction;
            idCommand.CommandText = "SELECT COALESCE(MAX(ProductId), 0) + 1 FROM Product";
            product.ProductId = Convert.ToInt32(idCommand.ExecuteScalar());
        }

        using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = @"
            INSERT INTO Product
                (ProductId, ProductName, CategoryId, Description, ManufacturerId, SupplierId,
                 Price, UnitId, StockQuantity, Discount, ImagePath)
            VALUES
                ($id, $name, $categoryId, $description, $manufacturerId, $supplierId,
                 $price, $unitId, $stock, $discount, $imagePath)";
        AddParameters(command, product);
        command.ExecuteNonQuery();

        transaction.Commit();
    }

    public static void Update(Product product)
    {
        using var connection = Database.OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = @"
            UPDATE Product
            SET ProductName = $name, CategoryId = $categoryId, Description = $description,
                ManufacturerId = $manufacturerId, SupplierId = $supplierId, Price = $price,
                UnitId = $unitId, StockQuantity = $stock, Discount = $discount, ImagePath = $imagePath
            WHERE ProductId = $id";
        AddParameters(command, product);
        command.ExecuteNonQuery();
    }

    public static void Delete(int productId)
    {
        using var connection = Database.OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = "DELETE FROM Product WHERE ProductId = $id";
        command.Parameters.AddWithValue("$id", productId);
        command.ExecuteNonQuery();
    }

    public static bool IsInOrders(int productId)
    {
        using var connection = Database.OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = "SELECT COUNT(*) FROM OrderItem WHERE ProductId = $id";
        command.Parameters.AddWithValue("$id", productId);
        return Convert.ToInt32(command.ExecuteScalar()) > 0;
    }

    private static void AddParameters(SqliteCommand command, Product product)
    {
        command.Parameters.AddWithValue("$id", product.ProductId);
        command.Parameters.AddWithValue("$name", product.ProductName);
        command.Parameters.AddWithValue("$categoryId", product.CategoryId);
        command.Parameters.AddWithValue("$description", product.Description);
        command.Parameters.AddWithValue("$manufacturerId", product.ManufacturerId);
        command.Parameters.AddWithValue("$supplierId", product.SupplierId);
        command.Parameters.AddWithValue("$price", product.Price);
        command.Parameters.AddWithValue("$unitId", product.UnitId);
        command.Parameters.AddWithValue("$stock", product.StockQuantity);
        command.Parameters.AddWithValue("$discount", product.Discount);
        command.Parameters.AddWithValue("$imagePath", (object?)product.ImagePath ?? DBNull.Value);
    }

    private static Product ReadProduct(SqliteDataReader reader)
    {
        return new Product
        {
            ProductId = reader.GetInt32(0),
            ProductName = reader.GetString(1),
            CategoryId = reader.GetInt32(2),
            CategoryName = reader.GetString(3),
            Description = reader.GetString(4),
            ManufacturerId = reader.GetInt32(5),
            ManufacturerName = reader.GetString(6),
            SupplierId = reader.GetInt32(7),
            SupplierName = reader.GetString(8),
            Price = Math.Round((decimal)reader.GetDouble(9), 2),
            UnitId = reader.GetInt32(10),
            UnitName = reader.GetString(11),
            StockQuantity = reader.GetInt32(12),
            Discount = reader.GetInt32(13),
            ImagePath = reader.IsDBNull(14) ? null : reader.GetString(14)
        };
    }
}
