using System.IO;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace ShoeStore.Services;

public static class ImageService
{
    public const string PlaceholderPath = "Images/picture.png";
    public const string LogoPath = "Images/logo.png";
    public const string ProductImagesFolder = "Images/Products";
    public const int MaxWidth = 300;
    public const int MaxHeight = 200;

    // Фото товара; если файла нет — картинка-заглушка
    public static ImageSource? Load(string? relativePath)
    {
        string? fullPath = FindExistingFile(relativePath) ?? FindExistingFile(PlaceholderPath);
        return fullPath == null ? null : LoadFromFile(fullPath);
    }

    public static ImageSource? LoadLogo()
    {
        string? fullPath = FindExistingFile(LogoPath);
        return fullPath == null ? null : LoadFromFile(fullPath);
    }

    // OnLoad читает файл целиком и освобождает его: иначе старое фото нельзя будет удалить
    public static BitmapImage LoadFromFile(string fullPath)
    {
        var image = new BitmapImage();
        image.BeginInit();
        image.CacheOption = BitmapCacheOption.OnLoad;
        image.CreateOptions = BitmapCreateOptions.IgnoreImageCache;
        image.UriSource = new Uri(fullPath);
        image.EndInit();
        image.Freeze();
        return image;
    }

    public static bool FitsSizeLimit(BitmapSource image)
    {
        return image.PixelWidth <= MaxWidth && image.PixelHeight <= MaxHeight;
    }

    // Копирует файл в папку приложения и возвращает путь для хранения в БД
    public static string SaveProductImage(string sourceFile)
    {
        string folder = Path.Combine(AppContext.BaseDirectory, ProductImagesFolder);
        Directory.CreateDirectory(folder);

        string fileName = Guid.NewGuid().ToString("N") + Path.GetExtension(sourceFile).ToLowerInvariant();
        File.Copy(sourceFile, Path.Combine(folder, fileName));

        return ProductImagesFolder + "/" + fileName;
    }

    // Удаляет старое фото из папки приложения; заглушку и логотип не трогает
    public static void DeleteProductImage(string? relativePath)
    {
        if (string.IsNullOrWhiteSpace(relativePath))
        {
            return;
        }

        string imagesRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "Images"));
        string fullPath = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, relativePath));
        string fileName = Path.GetFileName(fullPath);

        bool isInsideImages = fullPath.StartsWith(imagesRoot, StringComparison.OrdinalIgnoreCase);
        bool isSystemImage = fileName.Equals("picture.png", StringComparison.OrdinalIgnoreCase)
                             || fileName.Equals("logo.png", StringComparison.OrdinalIgnoreCase);

        if (isInsideImages && !isSystemImage && File.Exists(fullPath))
        {
            File.Delete(fullPath);
        }
    }

    private static string? FindExistingFile(string? relativePath)
    {
        if (string.IsNullOrWhiteSpace(relativePath))
        {
            return null;
        }

        string fullPath = Path.Combine(AppContext.BaseDirectory, relativePath);
        return File.Exists(fullPath) ? fullPath : null;
    }
}
