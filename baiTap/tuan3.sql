USE AdventureWorks2008R2
GO
--1)  Tạo  view  dbo.vw_Products  hiển  thị  danh  sách  các  sản  phẩm  từ  bảng 
--Production.Product và bảng  Production.ProductCostHistory. Thông tin  bao gồm 
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
CREATE VIEW dbo.vw_Products AS
SELECT P.ProductID, Name, Color, Size, Style, P.StandardCost, EndDate, StartDate 
FROM Production.Product P JOIN Production.ProductCostHistory PCH ON P.ProductID = PCH.ProductID
GO
SELECT * FROM dbo.vw_Products
--2)  Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt 
--hàng trong quí 1 năm 2008  và có tổng trị giá >10000, thông tin gồm ProductID, 
--Product_Name, CountOfOrderID và SubTotal.
GO
CREATE VIEW List_Product_View AS
SELECT P.ProductID, P.Name, CountOfOrderID = COUNT(*), SubTotal = SUM(OrderQty*UnitPrice) 
FROM Production.Product P JOIN Sales.SalesOrderDetail SOD ON P.ProductID = SOD.ProductID
JOIN Sales.SalesOrderHeader SOH ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE YEAR(OrderDate) = 2008 AND DATEPART(Q, OrderDate) = 1 
GROUP BY P.ProductID, P.Name
HAVING COUNT(*)>500 AND SUM(OrderQty*UnitPrice) > 10000
GO
SELECT * FROM List_Product_View
--3)  Tạo view dbo.vw_CustomerTotals  hiển thị tổng tiền bán được (total sales) từ cột 
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm 
--CustomerID,  YEAR(OrderDate)  AS  OrderYear,  MONTH(OrderDate)  AS 
--OrderMonth,  SUM(TotalDue).
GO
CREATE VIEW vw_CustomerTotals AS
SELECT CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue) AS totalSales
FROM Sales.SalesOrderHeader
GROUP BY CustomerID,YEAR(OrderDate), MONTH(OrderDate)
GO
SELECT * FROM vw_CustomerTotals
--4)  Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân 
--viên  theo  từng  năm.  Thông  tin gồm  SalesPersonID,  OrderYear,  sumOfOrderQty
GO
CREATE VIEW vw_totalQtyPerYear AS
SELECT SalesPersonID, YEAR(OrderDate) AS OrderYear, sumOfOrderQty = SUM(OrderQty) 
FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY SalesPersonID, YEAR(OrderDate)
GO
SELECT * FROM vw_totalQtyPerYear
--5)  Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn 
--đặt hàng từ năm 2007 đến 2008, thông tin  gồm  mã khách (PersonID) , họ tên 
--(FirstName +'  '+ LastName as FullName), Số hóa đơn  (CountOfOrders).
GO
CREATE VIEW ListCustomer AS
SELECT CustomerID, Name = (FirstName + ' ' + LastName), CountOfOrders = COUNT(*) FROM Person.Person P JOIN Sales.SalesOrderHeader SOH ON P.BusinessEntityID = SOH.CustomerID
WHERE YEAR(OrderDate) between 2007 AND 2008
GROUP BY CustomerID, FirstName, LastName
HAVING COUNT(*) > 25
GO
SELECT * FROM ListCustomer
--6)  Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với 
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên  50 sản phẩm, thông 
--tin  gồm  ProductID,  Name,  SumOfOrderQty,  Year.  (dữ  liệu  lấy  từ  các  bảng
--Sales.SalesOrderHeader, Sales.SalesOrderDetail, và Production.Product)
GO
CREATE VIEW ListProduct_view AS
SELECT P.ProductID, Name, SumOfOrderQty = SUM(OrderQty), Year = YEAR(OrderDate) FROM Production.Product P JOIN Sales.SalesOrderDetail SOD ON P.ProductID = SOD.ProductID
JOIN Sales.SalesOrderHeader SOH ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE Name LIKE 'Bike%' OR Name LIKE 'Sport%'
GROUP BY P.ProductID, Name, YEAR(OrderDate)
HAVING SUM(OrderQty) > 500
GO
SELECT * FROM ListProduct_View
--7)  Tạo view List_department_View chứa  danh sách  các  phòng  ban  có lương  (Rate: 
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID), 
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng 
--[HumanResources].[Department],[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory].
GO
CREATE VIEW List_department_View AS
SELECT D.DepartmentID, Name, AvgOfRate = AVG(Rate) FROM HumanResources.Department D JOIN HumanResources.EmployeeDepartmentHistory EDH ON EDH.DepartmentID = D.DepartmentID
JOIN HumanResources.EmployeePayHistory EPH ON EPH.BusinessEntityID = EDH.BusinessEntityID
GROUP BY D.DepartmentID, Name
HAVING AVG(Rate) > 30
GO
SELECT * FROM List_department_View
--8)  Tạo view  Sales.vw_OrderSummary  với từ khóa  WITH ENCRYPTION gồm 
--OrderYear  (năm  của  ngày  lập),  OrderMonth  (tháng  của  ngày  lập),  OrderTotal 
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view  này
GO
CREATE VIEW vw_OrderSummary WITH ENCRYPTION AS
SELECT OrderYear = YEAR(OrderDate), OrderMonth = MONTH(OrderDate), OrderTotal = SUM(UnitPrice*OrderQty)
FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
GO
SELECT * FROM vw_OrderSummary
GO
sp_helptext vw_OrderSummary
--9)  Tạo  view  Production.vwProducts  với  từ  khóa  WITH  SCHEMABINDING 
--gồm ProductID, Name, StartDate,EndDate,ListPrice  của  bảng Product và bảng 
--ProductCostHistory.  Xem  thông  tin  của  View.  Xóa  cột  ListPrice  của  bảng 
--Product. Có xóa được không? Vì sao?
GO
CREATE VIEW Production.vwProducts WITH  SCHEMABINDING AS
SELECT P.ProductID, Name, StartDate,EndDate,ListPrice 
FROM Production.Product P JOIN Production.ProductCostHistory PCH ON P.ProductID = PCH.ProductID
GO
SELECT * FROM Production.vwProducts
GO
ALTER TABLE Production.Product
DROP COLUMN ListPrice
--Không xóa được. Do đang có đối tượng truy cập vào cột này
--10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các 
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality 
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
GO
CREATE VIEW view_Department AS
SELECT DepartmentID, Name, GroupName FROM HumanResources.Department
WHERE GroupName = 'Manufacturing' OR GroupName = 'Quality Assurance'
WITH CHECK OPTION
GO
SELECT * FROM view_Department
--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm 
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có 
--chèn được không? Giải thích.
GO
INSERT view_Department VALUES('phong ban', 'a')
--không chèn được. Do không phù hợp ràng buộc
--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một 
--phòng thuộc nhóm “Quality Assurance”.
INSERT view_Department VALUES( 'Phong ban', 'Manufacturing')
--c. Dùng câu lệnh Select xem kết quả trong bảng Department.
SELECT * FROM view_Department