
-- STEP 1: Create Database
CREATE DATABASE CreditCardAnalysis;
GO

USE CreditCardAnalysis;
GO

-- STEP 2: Create Tables
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name NVARCHAR(100),
    Age INT,
    Location NVARCHAR(100),
    AccountBalance DECIMAL(10, 2)
);

CREATE TABLE Merchants (
    MerchantID INT PRIMARY KEY,
    MerchantName NVARCHAR(100),
    Location NVARCHAR(100),
    Industry NVARCHAR(100)
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    MerchantID INT FOREIGN KEY REFERENCES Merchants(MerchantID),
    Amount DECIMAL(10, 2),
    Date DATETIME,
    Category NVARCHAR(100),
    FraudFlag BIT
);

-- STEP 3: Sample Data Population
-- Customers
INSERT INTO Customers (CustomerID, Name, Age, Location, AccountBalance)
VALUES 
(1, 'Alice Johnson', 34, 'New York', 1200.50),
(2, 'Bob Smith', 45, 'Los Angeles', 3000.00),
(3, 'Charlie Brown', 29, 'Chicago', 800.75);

-- Merchants
INSERT INTO Merchants (MerchantID, MerchantName, Location, Industry)
VALUES
(1, 'SuperMart', 'New York', 'Retail'),
(2, 'TechWorld', 'San Francisco', 'Electronics'),
(3, 'TravelEase', 'Chicago', 'Travel');

-- Transactions
INSERT INTO Transactions (TransactionID, CustomerID, MerchantID, Amount, Date, Category, FraudFlag)
VALUES
(1, 1, 1, 200.00, '2024-01-01', 'Groceries', 0),
(2, 2, 2, 1500.00, '2024-01-02', 'Electronics', 1),
(3, 3, 3, 500.00, '2024-01-03', 'Travel', 0),
(4, 1, 3, 120.00, '2024-01-04', 'Travel', 0),
(5, 2, 1, 300.00, '2024-01-05', 'Groceries', 0);

-- STEP 4: Analytical Queries

-- 1. Total transactions and average transaction amount per customer
SELECT 
    c.Name AS CustomerName,
    COUNT(t.TransactionID) AS TotalTransactions,
    AVG(t.Amount) AS AvgTransactionAmount
FROM Transactions t
JOIN Customers c ON t.CustomerID = c.CustomerID
GROUP BY c.Name;

-- 2. Most common transaction categories
SELECT 
    Category, 
    COUNT(TransactionID) AS TransactionCount
FROM Transactions
GROUP BY Category
ORDER BY TransactionCount DESC;

-- 3. Detect anomalies: Transactions greater than twice the customer's average spending
WITH AvgSpending AS (
    SELECT 
        CustomerID, 
        AVG(Amount) AS AvgAmount
    FROM Transactions
    GROUP BY CustomerID
)
SELECT 
    t.TransactionID, 
    c.Name AS CustomerName, 
    t.Amount, 
    a.AvgAmount
FROM Transactions t
JOIN AvgSpending a ON t.CustomerID = a.CustomerID
JOIN Customers c ON t.CustomerID = c.CustomerID
WHERE t.Amount > 2 * a.AvgAmount;

-- 4. Monthly spending trends per category
SELECT 
    FORMAT(t.Date, 'yyyy-MM') AS Month,
    t.Category,
    SUM(t.Amount) AS TotalSpending
FROM Transactions t
GROUP BY FORMAT(t.Date, 'yyyy-MM'), t.Category
ORDER BY Month, TotalSpending DESC;

-- 5. Top-spending customers using window functions
SELECT 
    c.Name AS CustomerName,
    SUM(t.Amount) AS TotalSpent,
    RANK() OVER (ORDER BY SUM(t.Amount) DESC) AS Rank
FROM Transactions t
JOIN Customers c ON t.CustomerID = c.CustomerID
GROUP BY c.Name
ORDER BY Rank;
