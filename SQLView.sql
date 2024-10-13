/*
SELECT OrderID, SUM(CONVERT(money, (UnitPrice * Quantity) * (1 - Discount) / 100) * 100) AS Subtotal
FROM dbo.[Order Details]
GROUP BY OrderID

-- Bunu sürekli yazmak yerine:
SELECT * FROM [dbo].[Order Subtotals]
-- View'ler data tutmuyor sorgularý tutuyor, çaðýrýldýðýnda sorguyu çalýþtýrýyor

SELECT * FROM INFORMATION_SCHEMA.VIEWS
SELECT * FROM INFORMATION_SCHEMA.TABLES
*/

----------
-- VIEW --
----------

--SELECT * FROM Customers
--SELECT * FROM Orders
--SELECT * FROM [Order Details]
-- Her CustomerID için total ciromu yazan sorgu
-- dbo yazmasam hangi user ile login olursam onun adý yazar
CREATE VIEW dbo.CustomerTotal
AS
SELECT C.CustomerID, C.CompanyName, 
SUM(OD.Quantity * OD.UnitPrice * (1 - OD.Discount)) [CustomerTotal]
FROM Customers C INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID, C.CompanyName
-- Çalýþtýrýnca yeni view oluþur

-- Artýk böyle çaðýrabilirim.
SELECT * FROM [dbo].[CustomerTotal]

SELECT * FROM INFORMATION_SCHEMA.VIEWS
 
SELECT * FROM Employees -- EmployeeId ve ReportsTo sütunlarý iliþkili

CREATE VIEW dbo.EmployeeManager
AS
SELECT E.EmployeeID [ManagerID], CONCAT(E.FirstName, ' ', E.LastName) [Manager],
CONCAT(EMP.FirstName, ' ', EMP.LastName) [Employee], EMP.EmployeeID [EmployeeID]
FROM Employees E INNER JOIN Employees EMP ON E.EmployeeID = EMP.ReportsTo

SELECT * FROM [dbo].[EmployeeManager]

-- View deðiþtirme
ALTER VIEW dbo.EmployeeManager
AS
SELECT E.EmployeeID [ManagerID], CONCAT(E.FirstName, ' ', E.LastName) [Manager],
CONCAT(EMP.FirstName, ' ', EMP.LastName) [Employee], EMP.EmployeeID [EmployeeID]
FROM Employees E RIGHT JOIN Employees EMP ON E.EmployeeID = EMP.ReportsTo

-- View'i yaratýrken kullandýðým base table'larda deðiþiklik yapýlsýn istemiyorsam:
CREATE VIEW dbo.Employee
WITH SCHEMABINDING ---> Deðiþiklipi önlüyor
AS
SELECT E.EmployeeID, E.FirstName + ' ' + E.LastName [FullName], E.Title
FROM dbo.Employees E

ALTER TABLE Employees
ALTER COLUMN Title varchar(max)


-- View'ime index eklemek istersem
CREATE VIEW dbo.View_Customers -- View_ þeklinde kendi yazdýðýmýz olduðuna dikkat çekebiliriz
WITH SCHEMABINDING -- Bu olmazsa index oluþturamayýz
AS
SELECT CustomerID, CompanyName, ContactTitle
FROM dbo.Customers

CREATE UNIQUE CLUSTERED INDEX VIX_View_Customers_CustomerID
ON [dbo].[View_Customers](CustomerID) -- Hangi view'ýn hangi sütunu
-- Dataya hýzlý eriþmek için yaptýðým bir yapý

-- Önce View
CREATE VIEW dbo.ViewCustomerInfo
AS
SELECT CustomerID, CONCAT(CompanyName, ' - ', ContactTitle) CustomerInfo
FROM Customers

-- Sonra Index (Üstte ekleyemedik altta sch... sayesinde olacak)
CREATE UNIQUE CLUSTERED INDEX VIX_Customers_CustomerInfo
ON [dbo].[ViewCustomerInfo](CustomerInfo)

ALTER VIEW dbo.ViewCustomerInfo
WITH SCHEMABINDING -- Sonra ekledik bu sebeple alter 
AS
SELECT CustomerID, CONCAT(CompanyName, ' - ', ContactTitle) CustomerInfo
FROM dbo.Customers

-- Bir objeye ulaþmak için 4 parçalý isimlendirme:
-- FQN - Fully Qualified Name
-- [serverName].[databaseName].[owner].[tableName]
-- [DESKTOP-6QTPFUC].[NORTHWIND].[sa].[Customers] 
-- [DESKTOP-6QTPFUC].[NORTHWIND].[dbo].[Customers] 
-- DESKTOP-6QTPFUC.NORTHWIND.dbo.Customers 
-- DESKTOP-6QTPFUC...Customers -- Boþ býrakabilirim

CREATE VIEW dbo.View_TotalProductCount
AS
SELECT COUNT_BIG(*) [Count], O.OrderID, SUM(OD.Quantity) [TotalProductCount]
FROM Orders O INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY O.OrderID

SELECT * FROM [dbo].View_TotalProductCount

SELECT * FROM INFORMATION_SCHEMA.VIEWS

-- View definition kýsmýndaki kodun eriþilemez/görünmez olmasý için:
ALTER VIEW dbo.View_TotalProductCount
--WITH ENCRYPTION
AS
SELECT COUNT_BIG(*) [Count], O.OrderID, SUM(OD.Quantity) [TotalProductCount]
FROM Orders O INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY O.OrderID