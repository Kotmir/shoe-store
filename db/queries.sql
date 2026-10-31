-- ===================================================================
-- Этап 4: Запрос для авторизации (пункты 2.5, 2.6, 3.17 чек-листа)
-- Возвращает ФИО и роль при совпадении логина и пароля
-- ===================================================================
SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = ? AND u.password = ?;


-- ===================================================================
-- Этап 5: Запрос каталога товаров (пункты 2.7-2.11 чек-листа)
-- Подтягивает строковые названия справочников вместо id
-- ===================================================================
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty, 
       p.description, p.photo, 
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s ON s.id = p.supplier_id;


-- ===================================================================
-- Этап 6: Поиск, фильтр и сортировка (пункты 3.2-3.6 чек-листа)
-- Одновременная работа поиска по названию, фильтра по поставщику и сортировки
-- ===================================================================
SELECT p.id, p.article, p.name, p.price, p.stock_qty, s.name AS supplier
FROM products p
JOIN suppliers s ON s.id = p.supplier_id
WHERE p.name LIKE CONCAT('%', ?, '%') AND p.supplier_id = ?
ORDER BY p.stock_qty DESC;


-- ===================================================================
-- Этап 7: Справочники, добавление и редактирование товара (пункты 3.7, 3.10, 3.12, 3.19 чек-листа)
-- ===================================================================

-- Справочники для выпадающих списков
SELECT id, name FROM categories;
SELECT id, name FROM manufacturers;
SELECT id, name FROM suppliers;

-- Добавление нового товара
INSERT INTO products 
(article, name, unit, price, discount, stock_qty, description, photo, category_id, manufacturer_id, supplier_id) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- Открыть товар для редактирования (заполнение формы)
SELECT * FROM products WHERE id = ?;

-- Сохранить изменения (редактирование)
UPDATE products 
SET article=?, name=?, unit=?, price=?, discount=?, stock_qty=?, description=?, photo=?, 
    category_id=?, manufacturer_id=?, supplier_id=? 
WHERE id=?;


-- ===================================================================
-- Этап 8: Защита от удаления купленного товара (пункт 3.16 чек-листа)
-- ===================================================================

-- 1. Проверка наличия товара в заказах перед удалением
SELECT COUNT(*) AS used_in_orders FROM prodorders WHERE product_id = ?;

-- 2. Само удаление (БД откажет с ошибкой 1451, если count > 0)
DELETE FROM products WHERE id = ?;