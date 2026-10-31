USE shop3cats;

SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = ? AND u.password = ?;

SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c    ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s     ON s.id = p.supplier_id;

SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c    ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s     ON s.id = p.supplier_id
WHERE p.name LIKE CONCAT('%', ?, '%')
  AND p.supplier_id = ?
ORDER BY p.stock_qty DESC;

SELECT id, name FROM categories;
SELECT id, name FROM manufacturers;
SELECT id, name FROM suppliers;

INSERT INTO products
  (article, name, unit, price, discount, stock_qty, description, photo, category_id, manufacturer_id, supplier_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

SELECT * FROM products WHERE id = ?;

UPDATE products
SET article=?, name=?, unit=?, price=?, discount=?, stock_qty=?, description=?, photo=?,
    category_id=?, manufacturer_id=?, supplier_id=?
WHERE id = ?;

SELECT COUNT(*) AS used_in_orders FROM prodorders WHERE product_id = ?;

DELETE FROM products WHERE id = ?;
