-- MySQL Script generated for shoe-store
-- Model: Shoe Store   Version: 1.0

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `shoesdemo` DEFAULT CHARACTER SET utf8mb4 ;
USE `shoesdemo` ;

-- Table `roles`
CREATE TABLE IF NOT EXISTS `roles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- Table `users`
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `role_id` INT NOT NULL,
  `full_name` VARCHAR(150) NOT NULL,
  `login` VARCHAR(100) NOT NULL,
  `password` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_users_roles_idx` (`role_id` ASC),
  CONSTRAINT `fk_users_roles`
    FOREIGN KEY (`role_id`)
    REFERENCES `roles` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- Table `categories`
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- Table `manufacturers`
CREATE TABLE IF NOT EXISTS `manufacturers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- Table `suppliers`
CREATE TABLE IF NOT EXISTS `suppliers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- Table `products`
CREATE TABLE IF NOT EXISTS `products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `article` VARCHAR(50) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `unit` VARCHAR(20) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `discount` INT NULL DEFAULT 0,
  `stock_qty` INT NOT NULL,
  `description` TEXT NULL,
  `photo` VARCHAR(255) NULL,
  `category_id` INT NOT NULL,
  `manufacturer_id` INT NOT NULL,
  `supplier_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_products_categories_idx` (`category_id` ASC),
  INDEX `fk_products_manufacturers_idx` (`manufacturer_id` ASC),
  INDEX `fk_products_suppliers_idx` (`supplier_id` ASC),
  CONSTRAINT `fk_products_categories`
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_products_manufacturers`
    FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`),
  CONSTRAINT `fk_products_suppliers`
    FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`))
ENGINE = InnoDB;

-- Table `prodorders` (Связь заказов и товаров с защитой от удаления)
CREATE TABLE IF NOT EXISTS `prodorders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `qty` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_prodorders_products_idx` (`product_id` ASC),
  CONSTRAINT `fk_prodorders_products`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON DELETE RESTRICT -- Важно для Этапа 8 (ошибка 1451 при удалении)
    ON UPDATE CASCADE)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;