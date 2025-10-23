--1. Number of registered members
SELECT COUNT(*) AS total_members
FROM members;

--2. Number of books by status (Available / Issued / Lost)
SELECT status, COUNT(*) AS total_books
FROM books
GROUP BY status;

--3. Most borrowed books
SELECT b.book_title, COUNT(i.issued_id) AS total_issued
FROM books b
JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY b.book_title
ORDER BY total_issued DESC
LIMIT 5;

--4. The member who borrows the most books
SELECT m.member_name, COUNT(i.issued_id) AS total_borrowed
FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
GROUP BY m.member_name
ORDER BY total_borrowed DESC
LIMIT 5;

--5. Books not yet returned (currently borrowed)
SELECT 
    b.book_title,
    m.member_name,
    i.issued_date
FROM issued_status i
JOIN books b ON i.issued_book_isbn = b.isbn
JOIN members m ON i.issued_member_id = m.member_id
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;

--6. Average number of books borrowed per member
SELECT 
    ROUND(AVG(book_count), 2) AS avg_books_per_member
FROM (
    SELECT COUNT(i.issued_id) AS book_count
    FROM issued_status i
    GROUP BY i.issued_member_id
) AS sub;

--7. List of books that have not been borrowed permanently
SELECT b.book_title
FROM books b
LEFT JOIN issued_status i ON b.isbn = i.issued_book_isbn
WHERE i.issued_id IS NULL;

--8. Number of books loaned and returned
SELECT COUNT(DISTINCT r.issued_id) AS total_returned
FROM return_status r;

--9. Number of books currently borrowed (not yet returned)
SELECT COUNT(*) AS currently_issued
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;

--10. Reports by Branch (Number of Books, Employees, or Members)
-- A. Number of Employees in Each Branch:
SELECT b.branch_address, COUNT(e.emp_id) AS total_employees
FROM branch b
JOIN employees e ON b.branch_id = e.branch_id
GROUP BY b.branch_address;

--B.Number of loans made by employees of each branch:
SELECT br.branch_address, COUNT(i.issued_id) AS total_issues
FROM branch br
JOIN employees e ON br.branch_id = e.branch_id
JOIN issued_status i ON e.emp_id = i.issued_emp_id
GROUP BY br.branch_address;

--11. The most active branches in lending
SELECT 
    br.branch_address,
    COUNT(i.issued_id) AS total_issued
FROM branch br
JOIN employees e ON br.branch_id = e.branch_id
JOIN issued_status i ON e.emp_id = i.issued_emp_id
GROUP BY br.branch_address
ORDER BY total_issued DESC;

--12. Return Rate in each branch
SELECT 
    br.branch_address,
    COUNT(DISTINCT i.issued_id) AS total_issued,
    COUNT(DISTINCT r.return_id) AS total_returned,
    ROUND(
        (COUNT(DISTINCT r.return_id)::DECIMAL / COUNT(DISTINCT i.issued_id)) * 100, 
        2
    ) AS return_rate_percent
FROM branch br
JOIN employees e ON br.branch_id = e.branch_id
JOIN issued_status i ON e.emp_id = i.issued_emp_id
LEFT JOIN return_status r ON i.issued_id = r.issued_id
GROUP BY br.branch_address
ORDER BY return_rate_percent DESC;

--13. Most borrowed categories (by book type or classification)
SELECT 
    b.category,
    COUNT(i.issued_id) AS total_issued
FROM books b
JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY b.category
ORDER BY total_issued DESC;

--14. Monthly Loan Rate (Trend Analysis)
SELECT 
    TO_CHAR(i.issued_date, 'YYYY-MM') AS month,
    COUNT(*) AS total_issued
FROM issued_status i
GROUP BY TO_CHAR(i.issued_date, 'YYYY-MM')
ORDER BY month;

--15. Members who have not returned their books for a long time (Overdue Books)
SELECT 
    m.member_name,
    b.book_title,
    i.issued_date
FROM issued_status i
JOIN members m ON i.issued_member_id = m.member_id
JOIN books b ON i.issued_book_isbn = b.isbn
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL 
  AND i.issued_date < CURRENT_DATE - INTERVAL '30 days'
ORDER BY i.issued_date;

--16. The most active employee in registering loans
SELECT 
    e.emp_name,
    COUNT(i.issued_id) AS total_issued
FROM employees e
JOIN issued_status i ON e.emp_id = i.issued_emp_id
GROUP BY e.emp_name
ORDER BY total_issued DESC
LIMIT 5;

--17. Member Growth Over Time
SELECT 
    TO_CHAR(reg_date, 'YYYY-MM') AS month,
    COUNT(*) AS new_members
FROM members
GROUP BY TO_CHAR(reg_date, 'YYYY-MM')
ORDER BY month;

 --18.Most Lost Books
 SELECT 
    book_title,
    COUNT(*) AS total_lost
FROM books
WHERE status = 'Lost'
GROUP BY book_title
ORDER BY total_lost DESC;

--19.Library Utilization Rate
SELECT 
    ROUND(
        (SUM(CASE WHEN status = 'Issued' THEN 1 ELSE 0 END)::DECIMAL / COUNT(*)) * 100,
        2
    ) AS utilization_percent
FROM books;
 