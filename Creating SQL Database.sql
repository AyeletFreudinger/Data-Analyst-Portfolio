CREATE DATABASE Sales

Go

USE Sales

GO

CREATE SCHEMA Purchasing

CREATE TABLE Purchasing.ShipMethod
(ShipMethodID INT NOT NULL,
Name NVARCHAR(50) NOT NULL,
ShipBase MONEY NOT NULL,
ShipRate MONEY NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT ShipMethodID_PK PRIMARY KEY(ShipMethodID)
)

GO

CREATE SCHEMA Person

CREATE TABLE Person.Address
(AddressID INT NOT NULL,
AddressLine1 NVARCHAR(60) NOT NULL,
AddressLine2 NVARCHAR(60),
City NVARCHAR(30) NOT NULL,
StateProvinceID INT NOT NULL,
PostalCode NVARCHAR(15) NOT NULL,
ModifiedDate DATETIME NOT NULL
CONSTRAINT AddressID_PK PRIMARY KEY(AddressID)
)

GO

CREATE SCHEMA Sales

CREATE TABLE Sales.CurrencyRate
(CurrencyRateID INT NOT NULL,
CurrencyRateDate DATETIME NOT NULL,
FromCurrencyCode NCHAR(3) NOT NULL,
ToCurrencyCode NCHAR(3) NOT NULL,
AverageRate MONEY NOT NULL,
EndOfDayRate MONEY NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT CurrencyRateID_PK PRIMARY KEY(CurrencyRateID)
)

GO

CREATE TABLE Sales.SpecialOfferProduct
(SpecialOfferID INT NOT NULL,
ProductID INT NOT NULL,
ModifiedDate DATETIME NOT NULL
CONSTRAINT SpecialOfferID_ProductID_PK PRIMARY KEY(SpecialOfferID,ProductID)
)

GO

CREATE TABLE Sales.Customer
(CustomerID INT NOT NULL,
PersonID INT,
StoreID INT,
TerritoryID INT,
ModifiedDate DATETIME NOT NULL
CONSTRAINT CustomerID_PK PRIMARY KEY(CustomerID)
)

GO

CREATE TABLE Sales.SalesTerritory
(TerritoryID INT NOT NULL,
Name NVARCHAR(50) NOT NULL,
CountryRegionCode NVARCHAR(3) NOT NULL,
[Group] NVARCHAR(50) NOT NULL,
SalesYTD MONEY NOT NULL,
SalesLastYear MONEY NOT NULL,
CostYTD MONEY NOT NULL,
CostLastYear MONEY NOT NULL,
ModifiedDate DATETIME NOT NULL
CONSTRAINT TerritoryID_PK PRIMARY KEY(TerritoryID)
)

GO

CREATE TABLE Sales.SalesPerson
(BusinessEntityID INT NOT NULL,
TerritoryID INT,
SalesQuota MONEY,
Bonus MONEY NOT NULL,
CommissionPct SMALLMONEY NOT NULL,
SalesYTD MONEY NOT NULL,
SalesLastYear MONEY NOT NULL,
ModifiedDate DATETIME NOT NULL
CONSTRAINT BusinessEntityID_PK PRIMARY KEY(BusinessEntityID)
 )

GO

CREATE TABLE Sales.CreditCard
(CreditCardID INT NOT NULL,
CardType NVARCHAR(50) NOT NULL,
CardNumber NVARCHAR(25) NOT NULL,
ExpMonth TINYINT NOT NULL,
ExpYear SMALLINT NOT NULL,
ModifiedDate DATETIME NOT NULL
CONSTRAINT CreditCardID_PK PRIMARY KEY(CreditCardID)
)

GO

CREATE TABLE Sales.SalesOrderHeader
(SalesOrderID INT NOT NULL,
RevisionNumber TINYINT NOT NULL,
OrderDate DATETIME NOT NULL,
DueDate DATETIME NOT NULL,
ShipDate DATETIME,
Status TINYINT NOT NULL,
CustomerID INT NOT NULL,
SalesPersonID INT,
TerritoryID INT,
BillToAddressID INT NOT NULL,
ShipToAddressID INT NOT NULL,
ShipMethodID INT NOT NULL,
CreditCardID INT,
CreditCardApprovalCode VARCHAR(15),
CurrencyRateID INT,
Subtotal MONEY NOT NULL,
TaxAMT MONEY NOT NULL,
Freight MONEY NOT NULL,
Comment NVARCHAR(128),
ModifiedDate DATETIME NOT NULL
CONSTRAINT SalesOrderID_PK PRIMARY KEY(SalesOrderID),
CONSTRAINT CustomerID_FK FOREIGN KEY(CustomerID) REFERENCES Sales.Customer(CustomerID),
CONSTRAINT ShipMethodID_FK FOREIGN KEY(ShipMethodID) REFERENCES Purchasing.ShipMethod(ShipMethodID),
CONSTRAINT BillToAddressID_FK FOREIGN KEY(BillToAddressID) REFERENCES Person.Address(AddressID),
CONSTRAINT ShipToAddressID_FK FOREIGN KEY(ShipToAddressID) REFERENCES Person.Address(AddressID),
CONSTRAINT TerritoryID_FK FOREIGN KEY(TerritoryID) REFERENCES Sales.SalesTerritory(TerritoryID),
CONSTRAINT SalesPersonID_FK FOREIGN KEY(SalesPersonID) REFERENCES Sales.SalesPerson(BusinessEntityID),
CONSTRAINT CreditCardID_FK FOREIGN KEY(CreditCardID) REFERENCES Sales.CreditCard(CreditCardID),
CONSTRAINT CurrencyRateID_FK FOREIGN KEY(CurrencyRateID) REFERENCES Sales.CurrencyRate(CurrencyRateID)
)

Go

CREATE TABLE Sales.SalesOrderDetail
(SalesOrderID INT NOT NULL,
SalesOrderDetailID INT NOT NULL,
CarrierTrackingNumber NVARCHAR(25),
OrderQty SMALLINT NOT NULL,
ProductID INT NOT NULL,
SpecialOfferID INT NOT NULL,
UnitPrice MONEY NOT NULL,
UnitPriceDiscount MONEY NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT SalesOrderID_SalesOrderDetailID_PK PRIMARY KEY(SalesOrderID,SalesOrderDetailID),
CONSTRAINT SpecialOfferID_ProductID_FK FOREIGN KEY(SpecialOfferID,ProductID) REFERENCES Sales.SpecialOfferProduct(SpecialOfferID,ProductID),
CONSTRAINT SaleOrderID_FK FOREIGN KEY(SalesOrderID) REFERENCES Sales.SalesOrderHeader(SalesOrderID)
)

GO

INSERT INTO sales.Purchasing.ShipMethod
SELECT ShipMethodID,Name,ShipBase,ShipRate,ModifiedDate 
FROM AdventureWorks2022.Purchasing.ShipMethod

GO

INSERT INTO sales.Person.Address
SELECT AddressID,AddressLine1,AddressLine2,City,StateProvinceID,PostalCode,ModifiedDate
FROM AdventureWorks2022.Person.Address

GO

INSERT INTO Sales.Sales.CurrencyRate
SELECT CurrencyRateID,CurrencyRateDate,FromCurrencyCode,ToCurrencyCode,AverageRate,EndOfDayRate,ModifiedDate
FROM AdventureWorks2022.Sales.CurrencyRate

GO

INSERT INTO Sales.Sales.SpecialOfferProduct
SELECT SpecialOfferID,ProductID,ModifiedDate
FROM AdventureWorks2022.Sales.SpecialOfferProduct

GO

INSERT INTO Sales.Sales.Customer 
SELECT CustomerID,PersonID,StoreID,TerritoryID,ModifiedDate
FROM AdventureWorks2022.Sales.Customer

GO

INSERT INTO Sales.Sales.SalesTerritory
SELECT TerritoryID,Name,CountryRegionCode,[Group],SalesYTD,SalesLastYear,CostYTD,CostLastYear,ModifiedDate
FROM AdventureWorks2022.Sales.SalesTerritory

GO

INSERT INTO Sales.Sales.SalesPerson
SELECT BusinessEntityID,TerritoryID,SalesQuota,Bonus,CommissionPct,SalesYTD,SalesLastYear,ModifiedDate
FROM AdventureWorks2022.Sales.SalesPerson

GO

INSERT INTO Sales.Sales.CreditCard
SELECT CreditCardID,CardType,CardNumber,ExpMonth,ExpYear,ModifiedDate 
FROM AdventureWorks2022.Sales.CreditCard

GO

INSERT INTO Sales.Sales.SalesOrderHeader
SELECT SalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,Status,CustomerID,
SalesPersonID,TerritoryID,BillToAddressID,ShipToAddressID,ShipMethodID,CreditCardID,
CreditCardApprovalCode,CurrencyRateID,Subtotal,TaxAMT,Freight,Comment,ModifiedDate
FROM AdventureWorks2022.Sales.SalesOrderHeader

GO

INSERT INTO Sales.Sales.SalesOrderDetail
SELECT SalesOrderID,SalesOrderDetailID,CarrierTrackingNumber,OrderQty,
ProductID,SpecialOfferID,UnitPrice,UnitPriceDiscount,ModifiedDate 
FROM AdventureWorks2022.Sales.SalesOrderDetail

GO