-- Тестовые данные, чтобы приложение работало сразу.
-- Замените их данными заказчика (import) после подготовки файлов из Приложения 2.
-- Роли: 1 — клиент, 2 — менеджер, 3 — администратор.

INSERT INTO Role (RoleId, RoleName) VALUES
    (1, 'Авторизированный клиент'),
    (2, 'Менеджер'),
    (3, 'Администратор');

INSERT INTO AppUser (UserId, Login, Password, FullName, RoleId) VALUES
    (1, 'admin',   'admin123',   'Иванов Иван Иванович',    3),
    (2, 'manager', 'manager123', 'Петрова Анна Сергеевна',  2),
    (3, 'client',  'client123',  'Сидоров Пётр Алексеевич', 1);

INSERT INTO Category (CategoryName) VALUES ('Кроссовки'), ('Ботинки'), ('Туфли'), ('Сандалии');
INSERT INTO Manufacturer (ManufacturerName) VALUES ('Nike'), ('Adidas'), ('Ecco'), ('Rieker');
INSERT INTO Supplier (SupplierName) VALUES ('ООО «Обувь-Опт»'), ('ИП Северов'), ('ООО «СтопаТрейд»');
INSERT INTO Unit (UnitName) VALUES ('пара');

INSERT INTO Product
    (ProductId, ProductName, CategoryId, Description, ManufacturerId, SupplierId, Price, UnitId, StockQuantity, Discount, ImagePath)
VALUES
    (1, 'Кроссовки Air Run',    1, 'Лёгкие беговые кроссовки',           1, 1, 7990.00,  1, 15, 0,  NULL),
    (2, 'Кроссовки Street Pro', 1, 'Городские кроссовки на каждый день', 2, 2, 6500.00,  1, 8,  20, NULL),
    (3, 'Ботинки Winter Trek',  2, 'Утеплённые зимние ботинки',          3, 1, 12990.00, 1, 5,  10, NULL),
    (4, 'Ботинки City Boot',    2, 'Демисезонные ботинки из кожи',       4, 3, 8990.00,  1, 0,  0,  NULL),
    (5, 'Туфли Classic',        3, 'Классические мужские туфли',         3, 2, 9990.00,  1, 12, 5,  NULL),
    (6, 'Туфли Office',         3, 'Туфли для офиса',                    4, 3, 7490.00,  1, 3,  25, NULL),
    (7, 'Сандалии Summer',      4, 'Летние сандалии с ремешками',        2, 1, 3490.00,  1, 30, 0,  NULL),
    (8, 'Сандалии Beach',       4, 'Пляжные сандалии',                   1, 2, 2990.00,  1, 0,  20, NULL);

INSERT INTO CustomerOrder (OrderId, OrderDate, CustomerId, Status) VALUES
    (1, '2026-09-20', 3, 'Новый'),
    (2, '2026-09-25', 3, 'Выдан');

INSERT INTO OrderItem (OrderId, ProductId, Quantity) VALUES
    (1, 1, 2),
    (1, 5, 1),
    (2, 2, 1);
