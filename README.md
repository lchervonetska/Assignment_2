HW 2

# 1.
To optimize the AI-generated query, I used indexes:
CREATE INDEX index_book_id ON sales (book_id);
CREATE INDEX index_author_id ON books (author_id);
They will speed up our JOINs


CREATE INDEX index_authors_country ON authors (country);
CREATE INDEX index_books_genre ON books (genre);
CREATE INDEX index_sales_date ON sales (sale_date);
They will speed up filtration


2. 


