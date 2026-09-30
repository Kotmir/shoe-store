-- Схема базы данных магазина обуви (3НФ, ссылочная целостность)
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS Role (
    RoleId   INTEGER PRIMARY KEY,
    RoleName TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS AppUser (
    UserId   INTEGER PRIMARY KEY,
    Login    TEXT NOT NULL UNIQUE,
    Password TEXT NOT NULL,
    FullName TEXT NOT NULL,
    RoleId   INTEGER NOT NULL,
    FOREIGN KEY (RoleId) REFERENCES Role (RoleId)
);

CREATE TABLE IF NOT EXISTS Category (
    CategoryId   INTEGER PRIMARY KEY,
    CategoryName TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Manufacturer (
    ManufacturerId   INTEGER PRIMARY KEY,
    ManufacturerName TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Supplier (
    SupplierId   INTEGER PRIMARY KEY,
    SupplierName TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Unit (
    UnitId   INTEGER PRIMARY KEY,
    UnitName TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Product (
    ProductId      INTEGER PRIMARY KEY,
    ProductName    TEXT NOT NULL,
    CategoryId     INTEGER NOT NULL,
    Description    TEXT NOT NULL DEFAULT '',
    ManufacturerId INTEGER NOT NULL,
    SupplierId     INTEGER NOT NULL,
    Price          NUMERIC NOT NULL CHECK (Price >= 0),
    UnitId         INTEGER NOT NULL,
    StockQuantity  INTEGER NOT NULL CHECK (StockQuantity >= 0),
    Discount       INTEGER NOT NULL DEFAULT 0 CHECK (Discount BETWEEN 0 AND 100),
    ImagePath      TEXT NULL,
    FOREIGN KEY (CategoryId)     REFERENCES Category (CategoryId),
    FOREIGN KEY (ManufacturerId) REFERENCES Manufacturer (ManufacturerId),
    FOREIGN KEY (SupplierId)     REFERENCES Supplier (SupplierId),
    FOREIGN KEY (UnitId)         REFERENCES Unit (UnitId)
);

CREATE TABLE IF NOT EXISTS CustomerOrder (
    OrderId    INTEGER PRIMARY KEY,
    OrderDate  TEXT NOT NULL,
    CustomerId INTEGER NULL,
    Status     TEXT NOT NULL,
    FOREIGN KEY (CustomerId) REFERENCES AppUser (UserId)
);

CREATE TABLE IF NOT EXISTS OrderItem (
    OrderId   INTEGER NOT NULL,
    ProductId INTEGER NOT NULL,
    Quantity  INTEGER NOT NULL CHECK (Quantity > 0),
    PRIMARY KEY (OrderId, ProductId),
    FOREIGN KEY (OrderId)   REFERENCES CustomerOrder (OrderId) ON DELETE CASCADE,
    FOREIGN KEY (ProductId) REFERENCES Product (ProductId)
);
