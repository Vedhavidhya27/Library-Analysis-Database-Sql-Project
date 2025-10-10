create database library_management;
use library_management;

-- Table: tbl_publisher
CREATE TABLE tbl_publisher (
    publisher_PublisherName VARCHAR(255) PRIMARY KEY,
    publisher_PublisherAddress TEXT,
    publisher_PublisherPhone VARCHAR(15)
);

select * from tbl_publisher;

-- Table: tbl_book
CREATE TABLE tbl_book (
    book_BookID INT PRIMARY KEY,
    book_Title VARCHAR(255),
    book_PublisherName VARCHAR(255),
    FOREIGN KEY (book_PublisherName) REFERENCES tbl_publisher(publisher_PublisherName)
);

select * from tbl_book;

-- Table: tbl_book_authors
CREATE TABLE tbl_book_authors (
    book_authors_AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    book_authors_BookID INT,
    book_authors_AuthorName VARCHAR(255),
    FOREIGN KEY (book_authors_BookID) REFERENCES tbl_book(book_BookID)
);

select * from tbl_book_authors;

-- Table: tbl_library_branch
CREATE TABLE tbl_library_branch (
    library_branch_BranchID INT PRIMARY KEY AUTO_INCREMENT,
    library_branch_BranchName VARCHAR(255),
    library_branch_BranchAddress TEXT
);

select * from tbl_library_branch;

-- Table: tbl_book_copies
CREATE TABLE tbl_book_copies (
    book_copies_CopiesID INT PRIMARY KEY AUTO_INCREMENT,
    book_copies_BookID INT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies INT,
    FOREIGN KEY (book_copies_BookID) REFERENCES tbl_book(book_BookID),
    FOREIGN KEY (book_copies_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID)
);

select * from tbl_book_copies;

-- Table: tbl_borrower
CREATE TABLE tbl_borrower (
    borrower_CardNo INT PRIMARY KEY,
    borrower_BorrowerName VARCHAR(255),
    borrower_BorrowerAddress TEXT,
    borrower_BorrowerPhone VARCHAR(15)
);

select * from tbl_borrower;

-- Table: tbl_book_loans
CREATE TABLE tbl_book_loans (
    book_loans_LoansID INT PRIMARY KEY AUTO_INCREMENT,
    book_loans_BookID INT,
    book_loans_BranchID INT,
    book_loans_CardNo INT,
    book_loans_DateOut DATE,
    book_loans_DueDate DATE,
    FOREIGN KEY (book_loans_BookID) REFERENCES tbl_book(book_BookID),
    FOREIGN KEY (book_loans_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID),
    FOREIGN KEY (book_loans_CardNo) REFERENCES tbl_borrower(borrower_CardNo)
);

select * from tbl_book_loans;


-- 1.How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
select bc.book_copies_no_of_copies from tbl_book b
inner join tbl_book_copies bc on b.book_bookid = bc.book_copies_bookid
inner join tbl_library_branch lb on bc.book_copies_branchid = lb.library_branch_branchid
where b.book_title = 'The Lost Tribe'
and lb.library_branch_branchname = 'Sharpstown';

-- Conclusion:
-- This query shows how many copies of a specific book are available at a specific library branch.
-- It works by:
-- 1. Joining the book table to find the correct book by its title ("The Lost Tribe").
-- 2. Joining the library branch table to find the correct branch by its name ("Sharpstown").
-- 3. Linking to the book copies table to get the number of copies that exist at that intersection.
-- Final output: A single number representing the total inventory count of that book at that branch. 
-- This helps in managing stock and answering customer availability queries.

-- 2.How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select  l.library_branch_BranchName AS 'Branch Name',bc.book_copies_no_of_copies as no_of_copies
from tbl_book b 
inner join tbl_book_copies bc on b.book_bookid = bc.book_copies_bookid
inner join tbl_library_branch l on  book_copies_branchid = library_branch_branchid
where book_title = "The Lost Tribe";

-- Conclusion:
-- This query shows the distribution of copies for a specific book across all library branches.
-- It works by:
-- 1. Filtering the book table to find the correct book by its title ("The Lost Tribe").
-- 2. Joining the book copies table to get the inventory count for each branch.
-- 3. Joining the library branch table to get the name of each branch.
-- Final output: A list of all library branches along with the number of copies of "The Lost Tribe" each one owns.
-- This helps in understanding the book's availability network-wide and identifying which branches have it in stock.

-- 3.Retrieve the names of all borrowers who do not have any books checked out.
select borrower_cardno as borrower_cardno,borrower_borrowername as borrower_name from tbl_borrower b
where not exists(select 1 from tbl_book_loans bl where bl.book_loans_cardno = borrower_cardno);

-- Conclusion:
-- This query identifies all borrowers who currently have no active book loans.
-- It works by:
-- 1. Selecting all borrowers from the borrower table.
-- 2. Using a WHERE NOT EXISTS clause with a subquery to check the book loans table.
-- 3. The subquery checks if a borrower's card number appears in the loans table (indicating an active loan).
-- 4. Only borrowers with no matching loans are returned.
-- Final output: A list of borrower card numbers and names who have zero books checked out.
-- This helps in identifying inactive users or cleaning up borrower records.

/*4.For each book that is loaned out from the "Sharpstown" branch and whose 
DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address.*/
select b.book_title as book_title,
br.borrower_borrowername as borrower_name,
br.borrower_borroweraddress as borrower_address
from tbl_book_loans bl
inner join tbl_library_branch lb on book_loans_branchid = library_branch_branchid
inner join tbl_book b on book_loans_loansid = book_bookid
inner join tbl_borrower br on book_loans_cardno = borrower_cardno
where lb.library_branch_BranchName = 'Sharpstown' and bl.book_loans_DueDate = '0002-03-18';

-- Conclusion:
-- This query retrieves specific details about books due on a particular date at a specific branch.
-- It works by:
-- 1. Filtering loans from the "Sharpstown" branch with a due date of 2/3/18.
-- 2. Joining the library branch table to isolate the Sharpstown branch.
-- 3. Joining the book table to get the title of each loaned book.
-- 4. Joining the borrower table to get the name and address of each borrower.
-- Final output: A list of book titles, along with the names and addresses of the borrowers who have them checked out from Sharpstown and are due to return them on 2/3/18. 
-- This helps in generating due date reminders or notices for that specific branch and date.

-- 5.For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
select lb.library_branch_branchname as branch_name,
count(l.book_loans_bookid) as total_book_loaned from tbl_library_branch lb
left join tbl_book_loans l on lb.library_branch_branchid = l.book_loans_branchid
group by lb.library_branch_branchname;

-- Conclusion:
-- This query provides an overview of loan activity across all library branches.
-- It works by:
-- 1. Selecting all library branches (using a LEFT JOIN to include branches with no loans).
-- 2. Counting the number of loaned books linked to each branch.
-- 3. Grouping the results by branch name to get a total per branch.
-- Final output: A list of every library branch alongside the total number of books currently loaned out from each one. 
-- This helps assess branch activity levels, manage resource allocation, and identify which branches are the most and least active in terms of circulation.

/*6.Retrieve the names, addresses, and number of books checked out for all borrowers 
who have more than five books checked out.*/
select b.borrower_borrowername as borrower_name,
b.borrower_borroweraddress as borrower_address,
count(l.book_loans_bookid) as no_of_books_checkedout
from tbl_borrower b
inner join tbl_book_loans l on b.borrower_cardno = l.book_loans_cardno
group by b.borrower_borrowername,b.borrower_borroweraddress 
having count(l.book_loans_bookid) > 5;

-- Conclusion:
-- This query identifies borrowers who have exceeded a specific loan threshold.
-- It works by:
-- 1. Joining the borrower table with the book loans table to link borrowers to their loans.
-- 2. Grouping the results by borrower name and address to count each borrower's total loans.
-- 3. Using a HAVING clause to filter out borrowers with 5 or fewer loans, keeping only those with more than 5.
-- Final output: A list of borrower names, their addresses, and the exact number of books they currently have checked out (if it is more than five). 
-- This helps enforce loan policies, manage risk, and identify highly active users.

/* 7.For each book authored by "Stephen King", retrieve the title and 
the number of copies owned by the library branch whose name is "Central".*/
select b.book_title as book_title,
bc.book_copies_no_of_copies as no_of_copies_of_central
from tbl_book_authors ba
inner join tbl_book b on ba.book_authors_bookid = b.book_bookid
inner join tbl_book_copies bc on b.book_bookid = bc.book_copies_bookid
inner join tbl_library_branch lb on book_copies_branchid = lb.library_branch_branchid
where ba.book_authors_authorname = 'Stephen King' and lb.library_branch_branchname = 'Central';

-- Conclusion:
-- This query identifies the inventory of a specific author's books at a specific library branch.
-- It works by:
-- 1. Filtering the book authors table to find all books written by "Stephen King".
-- 2. Joining the book table to get the titles of those books.
-- 3. Joining the book copies and library branch tables to find the number of copies available at the "Central" branch.
-- Final output: A list of all books authored by Stephen King, along with the number of copies of each book that are owned by the Central branch. 
-- This helps in assessing the collection strength of a popular author at a specific location.



