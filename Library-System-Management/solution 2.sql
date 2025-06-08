-- adding some new records to issued_status table
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 24 day, '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 13 day,  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL 7 day,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL 32 day,  '978-0-375-50167-0', 'E101');

select * from issued_status;

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;



/*
Task : 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

select * from members;
select * from issued_status;
select * from books;
select * from return_status;

select current_date;

select ist.issued_member_id,m.member_name,b.book_title,ist.issued_date,DATEDIFF(current_date,ist.issued_date ) as overdue_days,rs.return_date
 from issued_status as ist
join members as m
on ist.issued_member_id=m.member_id
join books as b
on b.isbn=ist.issued_book_isbn
left join return_status as rs
on rs.issued_id=ist.issued_id
 where rs.return_date is null and DATEDIFF(current_date,ist.issued_date )>30
 order by 1;
 
 /*    
Task : Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/


select * from books;
select * from return_status;
select * from issued_status;


DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(20),
    IN p_issued_id VARCHAR(20),
    IN p_book_quality VARCHAR(15)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert return record
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    -- Get the book's ISBN and name from issued_status
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status to 'yes'
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Display message (visible in client tools like MySQL Workbench)
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END$$

DELIMITER ;

-- Testing FUNCTION add_return_records

-- issued_id = IS135
-- ISBN = WHERE isbn = '978-0-307-58837-1';

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');
-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

/*
Task : Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

-- Task : CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
);


SELECT * FROM active_members;

-- Task : Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select e.emp_name,b.*, count(ist.issued_id) as no_books_issued from employees e
join issued_status ist
on e.emp_id=ist.issued_emp_id
join branch b 
on e.branch_id=b.branch_id
group by 1,2
order by no_books_issued DESC;

/*
Task : Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/





DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(20),
    IN p_issued_member_id VARCHAR(20),
    IN p_issued_book_isbn VARCHAR(50),
    IN p_issued_emp_id VARCHAR(20)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Check if book is available
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        -- Insert issue record
        INSERT INTO issued_status(
            issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id
        ) VALUES (
            p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id
        );

        -- Update book status to 'no'
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT('Book records added successfully for book ISBN: ', p_issued_book_isbn) AS message;

    ELSE
        SELECT CONCAT('Sorry, the book is unavailable. Book ISBN: ', p_issued_book_isbn) AS message;
    END IF;

END$$

DELIMITER ;

-- checking the procedure

SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;


CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');



CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');


SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'




































