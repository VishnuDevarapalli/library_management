create table branch(
branch_id varchar(20) primary key,
manager_id varchar(20),
branch_address varchar(35),
contact_no varchar(20)
);
create table employees(
emp_id varchar(20) primary key,
emp_name varchar(35),
position varchar(25),
salary decimal(10,2),
branch_id varchar(20),-- Fk
foreign key(branch_id) references branch(branch_id)
);
create table books(
isbn VARCHAR(50) PRIMARY KEY,
book_title VARCHAR(80),
category VARCHAR(30),
rental_price DECIMAL(10,2),
status VARCHAR(10),
author VARCHAR(30),
publisher VARCHAR(30)
);
create table members(
member_id VARCHAR(20) PRIMARY KEY,
member_name VARCHAR(30),
member_address VARCHAR(30),
reg_date DATE
);

create table issued_status(
issued_id varchar(20) primary key,
issued_member_id VARCHAR(20),-- FK
issued_book_name VARCHAR(100),
issued_date DATE,
issued_book_isbn VARCHAR(50),-- FK
issued_emp_id VARCHAR(20),-- FK
FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);
create table return_status(
return_id VARCHAR(20) PRIMARY KEY,
issued_id VARCHAR(20),
return_book_name VARCHAR(80),
return_date DATE,
return_book_isbn VARCHAR(50),
FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);






