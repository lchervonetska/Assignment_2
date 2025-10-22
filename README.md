# HW 2

## 1.
To optimize the AI-generated query, I used indexes:
CREATE INDEX index_book_id ON sales (book_id);
CREATE INDEX index_author_id ON books (author_id);
They will speed up our JOINs


CREATE INDEX index_authors_country ON authors (country);
CREATE INDEX index_books_genre ON books (genre);
CREATE INDEX index_sales_date ON sales (sale_date);
They will speed up filtration


## 2. 
I rewrote the query using CTE.  WITH CteUsaAuthors AS .... This CTE (temporary named table) finds all authors from ‘USA’ and their names once.
I replaced YEAR(s.sale_date) = 2023 with s.sale_date >= ‘2023-01-01’ AND s.sale_date < ‘2024-01-01’. Now the optimizer can fully utilize index_sales_date instead of a full table scan.


## 3. Unoptimized query
Output unoptimized query

<img width="398" height="301" alt="Screenshot 2025-10-22 143926" src="https://github.com/user-attachments/assets/9de14ba3-92a2-4411-9ba7-64705460c2a5" />

EXPLAIN 

<img width="1295" height="169" alt="Screenshot 2025-10-22 144029" src="https://github.com/user-attachments/assets/5bcecc96-9ea2-4d82-9967-e86373da913d" />


EXPLAIN ANALYZE

<img width="1191" height="220" alt="Screenshot 2025-10-22 144257" src="https://github.com/user-attachments/assets/610d1f6b-556a-4947-924b-f4e70d7c1728" />


## 3. Optimized query

Output optimized query

<img width="398" height="293" alt="Screenshot 2025-10-22 144359" src="https://github.com/user-attachments/assets/c9ef3980-7325-4cc9-ab1d-cd860f9b25d6" />

EXPLAIN 

<img width="1326" height="168" alt="Screenshot 2025-10-22 144502" src="https://github.com/user-attachments/assets/d995d105-b23d-4edf-90f9-980873c99e27" />


EXPLAIN ANALYZE

<img width="1068" height="190" alt="Screenshot 2025-10-22 144549" src="https://github.com/user-attachments/assets/eb9c538c-e3bc-4c4a-a2ee-f8c1ce5ba5e9" />


After optimization, the query runs approximately 1.8 times faster.


## 4. MySQL optimizer hints

### Using USE INDEX

<img width="1310" height="256" alt="Screenshot 2025-10-22 144933" src="https://github.com/user-attachments/assets/3cb0a244-a666-4c64-9d49-6ea3812d2372" />


This hint forces MySQL to use only the indexes listed in parentheses, ignoring all others (even if they are better). Performance has deteriorated. 


### Using /*+ SUBQUERY(MATERIALIZATION) */
<img width="1180" height="292" alt="Screenshot 2025-10-22 145216" src="https://github.com/user-attachments/assets/b476877b-d697-4d79-945a-465965572a00" />


Creating a temporary table and writing/reading from it incurs additional overhead, so it does not speed things up. This approach is best used when we refer to our query a couple of times.








