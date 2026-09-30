using ShoeStore.Models;

namespace ShoeStore.Data;

public static class OrderRepository
{
    public static List<OrderRow> GetAll()
    {
        var orders = new List<OrderRow>();

        using var connection = Database.OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = @"
            SELECT o.OrderId, o.OrderDate, COALESCE(u.FullName, '—'), o.Status,
                   COALESCE(GROUP_CONCAT(p.ProductName || ' × ' || oi.Quantity, '; '), '')
            FROM CustomerOrder o
            LEFT JOIN AppUser u ON u.UserId = o.CustomerId
            LEFT JOIN OrderItem oi ON oi.OrderId = o.OrderId
            LEFT JOIN Product p ON p.ProductId = oi.ProductId
            GROUP BY o.OrderId
            ORDER BY o.OrderId DESC";

        using var reader = command.ExecuteReader();

        while (reader.Read())
        {
            orders.Add(new OrderRow
            {
                OrderId = reader.GetInt32(0),
                OrderDate = reader.GetString(1),
                CustomerName = reader.GetString(2),
                Status = reader.GetString(3),
                Items = reader.GetString(4)
            });
        }

        return orders;
    }
}
