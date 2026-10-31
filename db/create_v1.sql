SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DROP SCHEMA IF EXISTS `shop_shag`;
CREATE SCHEMA IF NOT EXISTS `shop_shag` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `shop_shag`;

-- =============================================
-- СПРАВОЧНИКИ
-- =============================================

CREATE TABLE IF NOT EXISTS `shop_shag`.`categories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL COMMENT 'Например: Кроссовки, Туфли, Сапоги, Ботинки',
  `parent_id` INT NULL DEFAULT NULL COMMENT 'Для иерархии категорий (Мужская обувь -> Кроссовки)',
  PRIMARY KEY (`id`),
  INDEX `fk_categories_parent_idx` (`parent_id` ASC) VISIBLE,
  CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `shop_shag`.`categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`manufacturers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `country` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`suppliers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `contact_info` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`materials` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL COMMENT 'Натуральная кожа, Замша, Нубук, Текстиль',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`roles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`orderstatus` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(20) NOT NULL COMMENT 'Новый, В пути, Доставлен, Отменен',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`payment_methods` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL COMMENT 'Наличные, Карта при получении, Онлайн оплата, СБП',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`return_reasons` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `reason` VARCHAR(100) NOT NULL COMMENT 'Не подошел размер, Брак, Не понравился цвет',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================
-- ПОЛЬЗОВАТЕЛИ И ЛОКАЦИИ
-- =============================================

CREATE TABLE IF NOT EXISTS `shop_shag`.`users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(60) NOT NULL,
  `phone` VARCHAR(20) NULL DEFAULT NULL,
  `email` VARCHAR(100) NULL DEFAULT NULL,
  `login` VARCHAR(50) NOT NULL,
  `password` VARCHAR(255) NOT NULL COMMENT 'Хэш пароля',
  `role_id` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `login_UNIQUE` (`login` ASC) VISIBLE,
  INDEX `fk_users_role_idx` (`role_id` ASC) VISIBLE,
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `shop_shag`.`roles` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`loyalty_cards` (
  `card_number` VARCHAR(20) NOT NULL,
  `bonus_points` INT NOT NULL DEFAULT 0,
  `discount_tier` DECIMAL(4,2) NOT NULL DEFAULT 0.00 COMMENT 'Процент постоянной скидки клиента',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `card_number_UNIQUE` (`card_number` ASC) VISIBLE,
  INDEX `fk_loyalty_user_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_loyalty_user` FOREIGN KEY (`user_id`) REFERENCES `shop_shag`.`users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`pvz` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `postcode` CHAR(6) NOT NULL,
  `city` VARCHAR(30) NOT NULL,
  `street` VARCHAR(30) NOT NULL,
  `house` VARCHAR(5) NULL DEFAULT NULL,
  `working_hours` VARCHAR(50) NULL DEFAULT '09:00-21:00',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================
-- ТОВАРЫ И СКЛАД
-- =============================================

CREATE TABLE IF NOT EXISTS `shop_shag`.`products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `article` VARCHAR(20) NOT NULL,
  `name` VARCHAR(100) NOT NULL COMMENT 'Название модели обуви',
  `gender` ENUM('M', 'F', 'U', 'K') NOT NULL DEFAULT 'U' COMMENT 'Мужская, Женская, Унисекс, Детская',
  `season` ENUM('Winter', 'Summer', 'Demi', 'All') NOT NULL DEFAULT 'All' COMMENT 'Сезонность',
  `size` DECIMAL(3,1) NULL DEFAULT NULL COMMENT 'Размер обуви (EUR или RU)',
  `color` VARCHAR(30) NULL DEFAULT NULL COMMENT 'Цвет',
  `unit` VARCHAR(10) NOT NULL DEFAULT 'пар',
  `price` DECIMAL(10,2) NOT NULL,
  `discount` INT NOT NULL DEFAULT 0,
  `stock_qty` INT NOT NULL DEFAULT 0,
  `description` TEXT NULL DEFAULT NULL,
  `photo` VARCHAR(255) NULL DEFAULT NULL,
  `category_id` INT NOT NULL,
  `manufacturer_id` INT NOT NULL,
  `supplier_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `article_UNIQUE` (`article` ASC) VISIBLE,
  INDEX `fk_products_category_idx` (`category_id` ASC) VISIBLE,
  INDEX `fk_products_manufacturer_idx` (`manufacturer_id` ASC) VISIBLE,
  INDEX `fk_products_supplier_idx` (`supplier_id` ASC) VISIBLE,
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `shop_shag`.`categories` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_products_manufacturer` FOREIGN KEY (`manufacturer_id`) REFERENCES `shop_shag`.`manufacturers` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_products_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `shop_shag`.`suppliers` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`product_materials` (
  `product_id` INT NOT NULL,
  `material_id` INT NOT NULL,
  `part` VARCHAR(50) NOT NULL DEFAULT 'Верх' COMMENT 'Верх, Подкладка, Подошва',
  PRIMARY KEY (`product_id`, `material_id`, `part`),
  CONSTRAINT `fk_pm_product` FOREIGN KEY (`product_id`) REFERENCES `shop_shag`.`products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pm_material` FOREIGN KEY (`material_id`) REFERENCES `shop_shag`.`materials` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`inventory_transactions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `product_id` INT NOT NULL,
  `transaction_type` ENUM('IN', 'OUT', 'RETURN', 'WRITE_OFF') NOT NULL,
  `qty` INT NOT NULL,
  `transaction_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `comment` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_inventory_product` FOREIGN KEY (`product_id`) REFERENCES `shop_shag`.`products` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`reviews` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `product_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `rating` INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  `comment` TEXT NULL DEFAULT NULL,
`created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `shop_shag`.`products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `shop_shag`.`users` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================
-- КОРЗИНА И ПРОМОКОДЫ
-- =============================================

CREATE TABLE IF NOT EXISTS `shop_shag`.`promocodes` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(20) NOT NULL,
  `discount_percent` INT NOT NULL,
  `valid_until` DATETIME NOT NULL,
  `usage_limit` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `code_UNIQUE` (`code` ASC) VISIBLE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`shopping_cart` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `qty` INT NOT NULL DEFAULT 1,
  `added_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `cart_user_product` (`user_id`, `product_id`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `shop_shag`.`users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `shop_shag`.`products` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================
-- ЗАКАЗЫ И ВОЗВРАТЫ
-- =============================================

CREATE TABLE IF NOT EXISTS `shop_shag`.`orders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `delivery_date` DATETIME NULL DEFAULT NULL,
  `pvz_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `receive_code` VARCHAR(10) NOT NULL,
  `status_id` INT NOT NULL,
  `promocode_id` INT NULL DEFAULT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  INDEX `fk_orders_pvz_idx` (`pvz_id` ASC) VISIBLE,
  INDEX `fk_orders_user_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_orders_status_idx` (`status_id` ASC) VISIBLE,
  INDEX `fk_orders_promo_idx` (`promocode_id` ASC) VISIBLE,
  CONSTRAINT `fk_orders_pvz` FOREIGN KEY (`pvz_id`) REFERENCES `shop_shag`.`pvz` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `shop_shag`.`users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_orders_status` FOREIGN KEY (`status_id`) REFERENCES `shop_shag`.`orderstatus` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_orders_promo` FOREIGN KEY (`promocode_id`) REFERENCES `shop_shag`.`promocodes` (`id`) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`prodorders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `qty` INT NOT NULL,
  `price_at_order` DECIMAL(10,2) NOT NULL COMMENT 'Фиксация цены на момент заказа',
  PRIMARY KEY (`id`),
  INDEX `fk_prodorders_order_idx` (`order_id` ASC) VISIBLE,
  INDEX `fk_prodorders_product_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_prodorders_order` FOREIGN KEY (`order_id`) REFERENCES `shop_shag`.`orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_prodorders_product` FOREIGN KEY (`product_id`) REFERENCES `shop_shag`.`products` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`payments` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `payment_method_id` INT NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `payment_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_successful` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `shop_shag`.`orders` (`id`) ON DELETE CASCADE,

  CONSTRAINT `fk_payments_method` FOREIGN KEY (`payment_method_id`) REFERENCES `shop_shag`.`payment_methods` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_shag`.`returns` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `reason_id` INT NOT NULL,
  `qty` INT NOT NULL,
  `return_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_returns_order` FOREIGN KEY (`order_id`) REFERENCES `shop_shag`.`orders` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_returns_product` FOREIGN KEY (`product_id`) REFERENCES `shop_shag`.`products` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_returns_reason` FOREIGN KEY (`reason_id`) REFERENCES `shop_shag`.`return_reasons` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
