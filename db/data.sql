-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: localhost    Database: shoesdemo
-- ------------------------------------------------------
-- Server version	8.0.34

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

USE `shoesdemo`;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` (`id`, `name`) VALUES 
(1,'Администратор'),
(2,'Менеджер'),
(3,'Клиент');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`id`, `role_id`, `full_name`, `login`, `password`) VALUES 
(1, 1, 'Никифорова Весения Николаевна', '94d5ous@gmail.com', 'password123'),
(2, 3, 'Иванов Иван Иванович', 'ivanov@gmail.com', 'qwerty');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` (`id`, `name`) VALUES 
(1,'Мужская обувь'),
(2,'Женская обувь');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `manufacturers`
--

LOCK TABLES `manufacturers` WRITE;
/*!40000 ALTER TABLE `manufacturers` DISABLE KEYS */;
INSERT INTO `manufacturers` (`id`, `name`) VALUES 
(1,'Kari'),
(2,'Marco Tozzi'),
(3,'Roc'),
(4,'Rieker'),
(5,'Alessio Nesca'),
(6,'CROSBY');
/*!40000 ALTER TABLE `manufacturers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` (`id`, `name`) VALUES 
(1,'Kari');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` (`id`, `article`, `name`, `unit`, `price`, `discount`, `stock_qty`, `description`, `photo`, `category_id`, `manufacturer_id`, `supplier_id`) VALUES 
(1,'А11274','Ботинки','шт',4990.00,3,6,'','',2,1,1),
(3,'Н78275','Туфли','шт',4499.00,4,5,'','',1,1,1),
(4,'G783F5','Ботинки','шт',5900.00,2,8,'','',1,3,1),
(7,'F57247','Туфли','шт',2700.00,2,14,'','',2,2,1),
(9,'8320R5','Туфли','шт',4300.00,2,6,'','',2,4,1),
(10,'G432E4','Туфли','шт',2800.00,3,15,'','',2,1,1),
(12,'E48284','Полуботинки','шт',1800.00,2,14,'','',2,1,1),
(16,'G531F4','Ботинки','шт',6600.00,12,9,'','',2,1,1),
(17,'J542F5','Тапочки','шт',500.00,13,0,'','',1,1,1),
(19,'P76464','Туфли','шт',6800.00,15,15,'','',2,6,1),
(20,'C43665','Ботинки','шт',10200.00,15,9,'','',2,5,1),
(22,'№45715','Полуботинки','шт',4600.00,3,13,'','',2,6,1),
(23,'036484','Туфли','шт',12400.00,16,5,'','',2,1,1),
(29,'K358H6','Тапочки','шт',599.00,20,2,'','',1,4,1);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `prodorders`
-- (Добавлен товар id=1 в заказ, чтобы Этап 8 "удаление купленного товара" выдал ошибку)
--

LOCK TABLES `prodorders` WRITE;
/*!40000 ALTER TABLE `prodorders` DISABLE KEYS */;
INSERT INTO `prodorders` (`id`, `order_id`, `product_id`, `qty`) VALUES 
(1, 1001, 1, 1),
(2, 1001, 3, 2),
(3, 1002, 10, 1);
/*!40000 ALTER TABLE `prodorders` ENABLE KEYS */;
UNLOCK TABLES;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed