CREATE DATABASE hw2;
USE hw2;

DROP database hw2;
SET GLOBAL max_allowed_packet = 1073741824;
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';


CREATE TABLE authors (
  author_id INT PRIMARY KEY,
  name     VARCHAR(100),
  country VARCHAR(100),
  birth_year INT
);


LOAD DATA LOCAL INFILE 'C:/Program Files/data/authors.csv'
INTO TABLE authors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

DROP TABLE authors;
SELECT COUNT(*) FROM authors;


CREATE TABLE books (
  book_id INT PRIMARY KEY,
  title VARCHAR(20),
  author_id INT,
  genre VARCHAR(20),
  price INT,
  publication_year INT
);


DROP TABLE sales;

LOAD DATA LOCAL INFILE 'C:/Program Files/data/books.csv'
INTO TABLE books
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE sales (
  sale_id INT PRIMARY KEY,
  book_id INT,
  store VARCHAR(100),
  sale_date DATE,
  price DECIMAL(10,2),
  quantity INT
);


LOAD DATA LOCAL INFILE 'C:/Program Files/data/sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


SELECT COUNT(*) FROM authors;

-- 1. НЕОПТИМІЗОВАНИЙ ЗАПИТ

EXPLAIN analyze
SELECT
    b.title AS book_title,
    (SELECT a.name FROM authors a WHERE a.author_id = b.author_id) AS author_name,
    SUM(s.quantity * s.price) AS total_revenue
FROM
    sales s
JOIN
    books b ON s.book_id = b.book_id
WHERE
    YEAR(s.sale_date) = 2023
AND
    b.genre = 'Fantasy' 
AND
    b.author_id IN (
        SELECT author_id
        FROM authors
        WHERE country = 'USA' 
    )
GROUP BY
    b.book_id, b.title
ORDER BY
    total_revenue DESC
LIMIT 10;


-- 2. ОПТИМІЗОВАНИЙ ЗАПИТ

CREATE INDEX index_book_id ON sales (book_id);
CREATE INDEX index_author_id ON books (author_id);
CREATE INDEX index_authors_country ON authors (country);
CREATE INDEX index_books_genre ON books (genre);
CREATE INDEX index_sales_date ON sales (sale_date);

ALTER TABLE books
DROP INDEX index_book_id;

ALTER TABLE authors
DROP INDEX index_author_id;


EXPLAIN ANALYZE
WITH CteUsaAuthors AS (
SELECT author_id, name AS author_name
FROM authors 
WHERE country = 'USA'
) 
SELECT author_name, b.title AS book_title, SUM(s.quantity * s.price) AS total_revenue
FROM sales s
JOIN
books b ON s.book_id = b.book_id
JOIN
    CteUsaAuthors a ON a.author_id = b.author_id
WHERE
s.sale_date >= '2023-01-01' AND s.sale_date < '2024-01-01'
AND
    b.genre = 'Fantasy' 
GROUP BY
    b.book_id, b.title, a.author_name
ORDER BY
total_revenue DESC
LIMIT 10;


EXPLAIN ANALYZE
WITH CteUsaAuthors AS (
SELECT author_id, name AS author_name
FROM authors 
WHERE country = 'USA'
) 
SELECT author_name, b.title AS book_title, SUM(s.quantity * s.price) AS total_revenue
FROM sales s USE INDEX (index_sales_date)
JOIN
books b USE INDEX (index_books_genre, index_author_id) ON s.book_id = b.book_id
JOIN
    CteUsaAuthors a ON a.author_id = b.author_id
WHERE
s.sale_date >= '2023-01-01' AND s.sale_date < '2024-01-01'
AND
    b.genre = 'Fantasy' 
GROUP BY
    b.book_id, b.title, a.author_name
ORDER BY
total_revenue DESC
LIMIT 10;



EXPLAIN ANALYZE
WITH /*+ SUBQUERY(MATERIALIZATION) */ CteUsaAuthors AS (
SELECT author_id, name AS author_name
FROM authors 
WHERE country = 'USA'
) 
SELECT author_name, b.title AS book_title, SUM(s.quantity * s.price) AS total_revenue
FROM sales s USE INDEX (index_sales_date)
JOIN
books b USE INDEX (index_books_genre, index_author_id) ON s.book_id = b.book_id
JOIN
    CteUsaAuthors a ON a.author_id = b.author_id
WHERE
s.sale_date >= '2023-01-01' AND s.sale_date < '2024-01-01'
AND
    b.genre = 'Fantasy' 
GROUP BY
    b.book_id, b.title, a.author_name
ORDER BY
total_revenue DESC
LIMIT 10;
