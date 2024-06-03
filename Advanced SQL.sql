--1

SELECT ProductID,Name,Color,ListPrice,Size
FROM production.product
WHERE ProductID NOT IN 
(SELECT ProductID
FROM Sales.SalesOrderDetail)
ORDER BY ProductID;

GO

--2

SELECT c.CustomerID,ISNULL(p.LastName,'Unknown') AS 'LastName',ISNULL(p.FirstName,'Unknown') AS 'FirstName'
FROM Sales.Customer c left join Person.Person p
ON c.PersonID=p.BusinessEntityID
WHERE c.CustomerID NOT IN
(SELECT distinct CustomerID
FROM Sales.SalesOrderHeader)
ORDER BY CustomerID;

GO

--3

WITH TBL1 AS
(SELECT h.CustomerID,p.FirstName,p.LastName,COUNT(h.SalesOrderID) AS CountOfOrders
FROM Sales.SalesOrderHeader h join Sales.Customer c
ON h.CustomerID=c.CustomerID
join Person.Person p
ON c.PersonID=p.BusinessEntityID
GROUP BY h.CustomerID,p.FirstName,p.LastName)
SELECT TOP 10 CustomerID,FirstName,LastName,CountOfOrders
FROM TBL1
ORDER BY CountOfOrders DESC;

GO

--4

SELECT p.FirstName,p.LastName,e.JobTitle,e.HireDate, count(*) over(partition by e.JobTitle) AS CountOfTitle
FROM Person.Person p join HumanResources.Employee e
ON p.BusinessEntityID=e.BusinessEntityID;

GO

--5

WITH TBL1
AS
(SELECT h.SalesOrderID,h.CustomerID,p.LastName,p.FirstName,h.OrderDate,
RANK()OVER(partition by h.CustomerID ORDER BY h.OrderDate DESC) AS RN,
LAG(OrderDate)OVER(PARTITION BY h.CustomerID ORDER BY OrderDate) AS PreviousOrder
FROM Sales.SalesOrderHeader h JOIN Sales.Customer c
ON h.CustomerID=c.CustomerID
JOIN Person.Person p
ON c.PersonID=p.BusinessEntityID)
SELECT SalesOrderID,CustomerID,LastName,FirstName,OrderDate AS LastOrder,PreviousOrder
FROM TBL1
WHERE RN=1
ORDER BY CustomerID;

GO

--6

WITH TBL1 AS
(SELECT datepart(yy,h.OrderDate) as Year,h.SalesOrderID,p.LastName,p.FirstName,h.TotalDue AS Total,
rank()over(partition by datepart(yy,h.OrderDate) order by h.TotalDue DESC) as RN
FROM Sales.SalesOrderHeader h JOIN Sales.Customer c
on h.CustomerID=c.CustomerID
JOIN Person.Person p
on c.PersonID=p.BusinessEntityID)   
SELECT Year,SalesOrderID,LastName,FirstName,FORMAT(Total,'C','EN-US') AS 'Total'
FROM TBL1
WHERE RN=1;

GO

--7

SELECT *
FROM(SELECT YEAR(OrderDate) AS "Year"
,MONTH(OrderDate) AS "Month"
,SalesOrderID
FROM Sales.SalesOrderHeader)A
PIVOT(COUNT(SalesOrderID)FOR Year IN([2011],[2012],[2013],[2014]))PIV
ORDER BY Month;

GO

--8

WITH 
TBL1 AS
(SELECT DATEPART(YY,h.OrderDate) AS Year,DATEPART(MM,h.OrderDate) AS Month,
od.LineTotal AS Sum,
rank()OVER(ORDER BY DATEPART(MM,h.OrderDate) DESC) AS RN_Month
FROM Sales.SalesOrderDetail od JOIN Sales.SalesOrderHeader h
ON od.SalesOrderID=h.SalesOrderID),
TBL2 AS 
(SELECT Year,'grand_total' AS Month,NULL AS Sum,SUM(Sum) AS Cum_Sum,NULL as RN_Month
FROM TBL1
GROUP BY Year),
TBL3 AS
(SELECT Year,CONVERT(VARCHAR(5),Month) as Month,SUM(Sum) AS Sum,
SUM(SUM(Sum)) OVER (PARTITION BY YEAR ORDER BY YEAR,Month) AS Cum_Sum,RN_Month
FROM TBL1
GROUP BY Year,Month,RN_Month
UNION 
SELECT Year,Month,Sum,Cum_Sum,RN_Month
FROM TBL2)
SELECT Year,Month,FORMAT(Sum,'C','EN-US') AS Sum,FORMAT(Cum_Sum,'C','EN-US') AS Cum_Sum
FROM TBL3
ORDER BY Year,RN_Month DESC;

GO

--9

WITH TBL1 AS
(SELECT d.Name AS DepartmentName,e.BusinessEntityID AS "Employee'sID",p.FirstName+' '+p.LastName AS "Employee'sFullName",
e.HireDate,DATEDIFF(YY,e.HireDate,getdate()) AS Seniority,DENSE_RANK()OVER(ORDER BY e.HireDATE,e.BusinessEntityID) AS RN
FROM HumanResources.Department d JOIN HumanResources.EmployeeDepartmentHistory dh
ON d.DepartmentID=dh.DepartmentID
JOIN HumanResources.Employee e
ON dh.BusinessEntityID=e.BusinessEntityID
JOIN Person.Person p
ON e.BusinessEntityID=p.BusinessEntityID),
TBL2 AS
(SELECT *,LAG(RN)OVER(PARTITION BY DepartmentName ORDER BY RN) AS RN_Previous
FROM TBL1)
SELECT t2.DepartmentName,t2.[Employee'sID],t2.[Employee'sFullName],t2.HireDate,t2.Seniority,t1.[Employee'sFullName] AS PreviousEmpName,
t1.HireDate AS PreviousEmpHDate,DATEDIFF(DD,t1.HireDate,t2.HireDate) AS DiffDays
FROM TBL1 t1 right JOIN TBL2 t2
ON t1.RN=t2.RN_Previous AND t1.DepartmentName=t2.DepartmentName
ORDER BY t2.DepartmentName,t2.HireDate DESC;

GO

--10

WITH TBL1 AS
(SELECT DISTINCT e.HireDate,d.DepartmentID
FROM HumanResources.Employee e JOIN HumanResources.EmployeeDepartmentHistory d
ON e.BusinessEntityID=d.BusinessEntityID
WHERE d.EndDate IS NULL),
TBL2 AS
(SELECT e.HireDate,d.DepartmentID,e.BusinessEntityID,p.lastname,p.firstname
FROM HumanResources.Employee e JOIN HumanResources.EmployeeDepartmentHistory d
ON e.BusinessEntityID=d.BusinessEntityID
JOIN Person.Person p
ON d.BusinessEntityID=p.BusinessEntityID)
SELECT HireDate,DepartmentID,
STUFF((SELECT ','+CONCAT_WS(' ',BusinessEntityID,LastName,FirstName)
FROM TBL2 t2
WHERE t2.HireDate=t1.HireDate AND t2.DepartmentID=t1.DepartmentID
FOR XML PATH('')),1,1,'') AS "TeamEmployees"FROM TBL1 t1
ORDER BY HireDate DESC,DepartmentID;

GO
