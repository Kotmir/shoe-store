
CREATE DATABASE IF NOT EXISTS shop3cats CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shop3cats;

CREATE TABLE categories (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE manufacturers (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE suppliers (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE roles (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE orderstatus (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE pvz (
    id INT NOT NULL AUTO_INCREMENT,
    postcode CHAR(6) NOT NULL,
    city VARCHAR(30) NOT NULL,
    street VARCHAR(30) NOT NULL,
    house VARCHAR(5) NULL,
    PRIMARY KEY (id)
);

CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(60) NOT NULL,
    login VARCHAR(50) NOT NULL,
    password VARCHAR(30) NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE products (
    id INT NOT NULL AUTO_INCREMENT,
    article VARCHAR(10) NOT NULL,
    name VARCHAR(50) NOT NULL,
    unit VARCHAR(10) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    discount INT NOT NULL,
    stock_qty INT NOT NULL,
    description VARCHAR(255) NULL,
    photo VARCHAR(50) NULL,
    category_id INT NOT NULL,
    manufacturer_id INT NOT NULL,
    supplier_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE orders (
    id INT NOT NULL AUTO_INCREMENT,
    order_date DATETIME NOT NULL,
    delivery_date DATETIME NULL,
    pvz_id INT NOT NULL,
    user_id INT NOT NULL,
    receive_code VARCHAR(10) NOT NULL,
    status_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (pvz_id) REFERENCES pvz(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (status_id) REFERENCES orderstatus(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE prodorders (
    id INT NOT NULL AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    qty INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
