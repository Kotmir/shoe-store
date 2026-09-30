using ShoeStore.Models;

namespace ShoeStore.Data;

public static class LookupRepository
{
    public static List<LookupItem> GetCategories()
    {
        return Read("Category", "CategoryId", "CategoryName");
    }

    public static List<LookupItem> GetManufacturers()
    {
        return Read("Manufacturer", "ManufacturerId", "ManufacturerName");
    }

    public static List<LookupItem> GetSuppliers()
    {
        return Read("Supplier", "SupplierId", "SupplierName");
    }

    public static List<LookupItem> GetUnits()
    {
        return Read("Unit", "UnitId", "UnitName");
    }

    // Имена таблиц и столбцов — только константы из этого класса, не пользовательский ввод
    private static List<LookupItem> Read(string table, string idColumn, string nameColumn)
    {
        var items = new List<LookupItem>();

        using var connection = Database.OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = $"SELECT {idColumn}, {nameColumn} FROM {table} ORDER BY {nameColumn}";

        using var reader = command.ExecuteReader();

        while (reader.Read())
        {
            items.Add(new LookupItem(reader.GetInt32(0), reader.GetString(1)));
        }

        return items;
    }
}
