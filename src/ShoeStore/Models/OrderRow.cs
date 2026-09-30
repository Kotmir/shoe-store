namespace ShoeStore.Models;

public class OrderRow
{
    public int OrderId { get; set; }

    public string OrderDate { get; set; } = "";

    public string CustomerName { get; set; } = "";

    public string Status { get; set; } = "";

    public string Items { get; set; } = "";
}
