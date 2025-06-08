-- Task . Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;


-- Task : Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- Task : Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status
WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task : Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task : List Members Who Have Issued More Than One Book
select ist.issued_emp_id,count(ist.issued_emp_id),e.emp_name from issued_status as ist
join employees as e
on ist.issued_emp_id=e.emp_id
group by 1
having count(ist.issued_emp_id)>1;

-- Task : Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
select * from books;


create table book_count
as

select b.isbn,b.book_title ,count(ist.issued_id) from books b
join issued_status ist
on b.isbn=ist.issued_book_isbn
group by 1,2;

select * from book_count;

-- Task . Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic';

-- Task : Find Total Rental Income by Category:

select  b.category,sum(b.rental_price)from  books b
join issued_status ist
on b.isbn=ist.issued_book_isbn 
group by 1;

-- List Members Who Registered in the Last 180 Days:

select * from members;
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C120', 'sam', '145 Main St', '2025-06-06'),
('C121', 'john', '133 Main St', '2025-06-06');

select * from members
where reg_date>=current_date()-interval 180 day;

-- task  List Employees with Their Branch Manager's Name and their branch details:

select * from employees;
select * from branch;


select e1.*,e2.emp_name as manager_name,b.manager_id from employees e1
join branch b 
on e1.branch_id=b.branch_id
join employees e2
on e2.emp_id=b.manager_id;

-- Task . Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

create table rental_price_threshold
as
select * from books
where rental_price>7.00;

select * from rental_price_threshold;

-- Task : Retrieve the List of Books Not Yet Returned

select * from books;
select distinct issued_book_name from issued_status as ist
left join return_status as rs
on ist.issued_id=rs.issued_id
where rs.issued_id is null
;
























































