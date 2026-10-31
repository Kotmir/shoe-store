-- Переключение на базу данных магазина «Шаг»
USE shop_shag;

-- Авторизация пользователя (сотрудника/клиента)
SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = ? AND u.password = ?;

-- Получение полного списка обуви с информацией о категориях, производителях и поставщиках
SELECT s.id, s.article, s.name, s.size, s.price, s.discount, s.stock_qty,
       s.description, s.photo,
       c.name AS category, m.name AS manufacturer, sup.name AS supplier
FROM shoes s
JOIN categories c    ON c.id = s.category_id
JOIN manufacturers m ON m.id = s.manufacturer_id
JOIN suppliers sup   ON sup.id = s.supplier_id;

-- Поиск и фильтрация обуви (по названию и поставщику) с сортировкой по остаткам
SELECT s.id, s.article, s.name, s.size, s.price, s.discount, s.stock_qty,
       s.description, s.photo,
       c.name AS category, m.name AS manufacturer, sup.name AS supplier
FROM shoes s
JOIN categories c    ON c.id = s.category_id
JOIN manufacturers m ON m.id = s.manufacturer_id
JOIN suppliers sup   ON sup.id = s.supplier_id
WHERE s.name LIKE CONCAT('%', ?, '%')
  AND s.supplier_id = ?
ORDER BY s.stock_qty DESC;

-- Получение данных для выпадающих списков (категории, бренды, поставщики)
SELECT id, name FROM categories;
SELECT id, name FROM manufacturers;
SELECT id, name FROM suppliers;

-- Добавление новой пары обуви в каталог
INSERT INTO shoes
  (article, name, size, price, discount, stock_qty, description, photo, category_id, manufacturer_id, supplier_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- Получение данных конкретной пары обуви по ID (для карточки товара или редактирования)
SELECT * FROM shoes WHERE id = ?;

-- Обновление информации об обуви
UPDATE shoes
SET article=?, name=?, size=?, price=?, discount=?, stock_qty=?, description=?, photo=?,
    category_id=?, manufacturer_id=?, supplier_id=?
WHERE id = ?;

-- Проверка, есть ли данная обувь в существующих заказах (перед удалением)
SELECT COUNT(*) AS used_in_orders FROM shoe_orders WHERE shoe_id = ?;

-- Удаление обуви из каталога
DELETE FROM shoes WHERE id = ?;
