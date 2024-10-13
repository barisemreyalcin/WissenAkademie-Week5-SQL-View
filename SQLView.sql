/*
SELECT OrderID, SUM(CONVERT(money, (UnitPrice * Quantity) * (1 - Discount) / 100) * 100) AS Subtotal
FROM dbo.[Order Details]
GROUP BY OrderID

-- Bunu s�rekli yazmak yerine:
SELECT * FROM [dbo].[Order Subtotals]
-- View'ler data tutmuyor sorgular� tutuyor, �a��r�ld���nda sorguyu �al��t�r�yor

SELECT * FROM INFORMATION_SCHEMA.VIEWS
SELECT * FROM INFORMATION_SCHEMA.TABLES
*/

----------
-- VIEW --
----------

--SELECT * FROM Customers
--SELECT * FROM Orders
--SELECT * FROM [Order Details]
-- Her CustomerID i�in total ciromu yazan sorgu
-- dbo yazmasam hangi user ile login olursam onun ad� yazar
CREATE VIEW dbo.CustomerTotal
AS
SELECT C.CustomerID, C.CompanyName, 
SUM(OD.Quantity * OD.UnitPrice * (1 - OD.Discount)) [CustomerTotal]
FROM Customers C INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID, C.CompanyName
-- �al��t�r�nca yeni view olu�ur

-- Art�k b�yle �a��rabilirim.
SELECT * FROM [dbo].[CustomerTotal]

SELECT * FROM INFORMATION_SCHEMA.VIEWS
 
SELECT * FROM Employees -- EmployeeId ve ReportsTo s�tunlar� ili�kili

CREATE VIEW dbo.EmployeeManager
AS
SELECT E.EmployeeID [ManagerID], CONCAT(E.FirstName, ' ', E.LastName) [Manager],
CONCAT(EMP.FirstName, ' ', EMP.LastName) [Employee], EMP.EmployeeID [EmployeeID]
FROM Employees E INNER JOIN Employees EMP ON E.EmployeeID = EMP.ReportsTo

SELECT * FROM [dbo].[EmployeeManager]

-- View de�i�tirme
ALTER VIEW dbo.EmployeeManager
AS
SELECT E.EmployeeID [ManagerID], CONCAT(E.FirstName, ' ', E.LastName) [Manager],
CONCAT(EMP.FirstName, ' ', EMP.LastName) [Employee], EMP.EmployeeID [EmployeeID]
FROM Employees E RIGHT JOIN Employees EMP ON E.EmployeeID = EMP.ReportsTo

-- View'i yarat�rken kulland���m base table'larda de�i�iklik yap�ls�n istemiyorsam:
CREATE VIEW dbo.Employee
WITH SCHEMABINDING ---> De�i�iklipi �nl�yor
AS
SELECT E.EmployeeID, E.FirstName + ' ' + E.LastName [FullName], E.Title
FROM dbo.Employees E

ALTER TABLE Employees
ALTER COLUMN Title varchar(max)


-- View'ime index eklemek istersem
CREATE VIEW dbo.View_Customers -- View_ �eklinde kendi yazd���m�z oldu�una dikkat �ekebiliriz
WITH SCHEMABINDING -- Bu olmazsa index olu�turamay�z
AS
SELECT CustomerID, CompanyName, ContactTitle
FROM dbo.Customers

CREATE UNIQUE CLUSTERED INDEX VIX_View_Customers_CustomerID
ON [dbo].[View_Customers](CustomerID) -- Hangi view'�n hangi s�tunu
-- Dataya h�zl� eri�mek i�in yapt���m bir yap�

-- �nce View
CREATE VIEW dbo.ViewCustomerInfo
AS
SELECT CustomerID, CONCAT(CompanyName, ' - ', ContactTitle) CustomerInfo
FROM Customers

-- Sonra Index (�stte ekleyemedik altta sch... sayesinde olacak)
CREATE UNIQUE CLUSTERED INDEX VIX_Customers_CustomerInfo
ON [dbo].[ViewCustomerInfo](CustomerInfo)

ALTER VIEW dbo.ViewCustomerInfo
WITH SCHEMABINDING -- Sonra ekledik bu sebeple alter 
AS
SELECT CustomerID, CONCAT(CompanyName, ' - ', ContactTitle) CustomerInfo
FROM dbo.Customers

-- Bir objeye ula�mak i�in 4 par�al� isimlendirme:
-- FQN - Fully Qualified Name
-- [serverName].[databaseName].[owner].[tableName]
-- [DESKTOP-6QTPFUC].[NORTHWIND].[sa].[Customers] 
-- [DESKTOP-6QTPFUC].[NORTHWIND].[dbo].[Customers] 
-- DESKTOP-6QTPFUC.NORTHWIND.dbo.Customers 
-- DESKTOP-6QTPFUC...Customers -- Bo� b�rakabilirim

CREATE VIEW dbo.View_TotalProductCount
AS
SELECT COUNT_BIG(*) [Count], O.OrderID, SUM(OD.Quantity) [TotalProductCount]
FROM Orders O INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY O.OrderID

SELECT * FROM [dbo].View_TotalProductCount

SELECT * FROM INFORMATION_SCHEMA.VIEWS

-- View definition k�sm�ndaki kodun eri�ilemez/g�r�nmez olmas� i�in:
ALTER VIEW dbo.View_TotalProductCount
--WITH ENCRYPTION
AS
SELECT COUNT_BIG(*) [Count], O.OrderID, SUM(OD.Quantity) [TotalProductCount]
FROM Orders O INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY O.OrderID