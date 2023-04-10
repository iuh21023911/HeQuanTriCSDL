USE AdventureWorks2008R2
--I) Câu lệnh SELECT sử dụng các hàm thống kê với các mệnh đề Group by và Having:
--1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có 
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó 
--SubTotal =SUM(OrderQty*UnitPrice).SELECT SOH.SalesOrderID, Orderdate, SubTotal = SUM(OrderQty*UnitPrice) 
FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE YEAR(OrderDate) = 2008 AND MONTH(OrderDate) = 6
GROUP BY SOH.SalesOrderID,OrderDate
HAVING SUM(OrderQty*UnitPrice)  > 70000
--2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia 
--có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory, 
--Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin 
--bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền 
--(SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)
SELECT ST.TerritoryID,COUNT(*) AS CountOfCust,SubTotal = SUM(OrderQty*UnitPrice) FROM Sales.SalesTerritory ST 
JOIN Sales.Customer C ON ST.TerritoryID = C.TerritoryID
JOIN Sales.SalesOrderHeader SOH ON SOH.CustomerID = C.CustomerID
JOIN Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID
GROUP BY ST.TerritoryID, CountryRegionCode
HAVING CountryRegionCode= 'US'
--3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm 
--SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
SELECT SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
 FROM Sales.SalesOrderDetail
WHERE CarrierTrackingNumber LIKE '4BD%'
GROUP BY SalesOrderID, CarrierTrackingNumber
--4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán 
--trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.
SELECT P.ProductID, Name, AverageOfQty = AVG(SOD.OrderQty) FROM Production.Product P JOIN Sales.SalesOrderDetail SOD ON P.ProductID = SOD.ProductID
WHERE UnitPrice < 25
GROUP BY P.ProductID, Name
HAVING AVG(SOD.OrderQty) > 5
--5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm 
--JobTitle,CountOfPerson=Count(*)
SELECT JobTitle, CountOfPerson=Count(*) FROM HumanResources.Employee
GROUP BY JobTitle
HAVING Count(*) > 20
--6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên 
--kết thúc bằng 'Bicycles' và tổng trị giá > 800000, thông tin gồm 
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
--(sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và 
--[Purchasing].[PurchaseOrderDetail])
SELECT BusinessEntityID, V.Name, ProductID, SumOfQty = SUM(OrderQty), SubTotal=SUM(UnitPrice*OrderQty) FROM Purchasing.Vendor V 
JOIN Purchasing.PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
JOIN Purchasing.PurchaseOrderDetail POD ON POD.PurchaseOrderID = POH.PurchaseOrderID
WHERE V.Name LIKE '%Bicycles'
GROUP BY BusinessEntityID, V.Name, ProductID
HAVING SUM(UnitPrice*OrderQty) > 800000
--7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng 
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và 
--SubTotal
SELECT P.ProductID, P.Name, CountOfOrderId = COUNT(SOD.SalesOrderID), SubTotal = SUM(UnitPrice*OrderQty) FROM Sales.SalesOrderDetail SOD 
JOIN Production.Product P ON SOD.ProductID = P.ProductID
JOIN Sales.SalesOrderHeader SOH ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE DATEPART(Q, 1) = 1 AND YEAR(OrderDate) = 2008
GROUP BY P.ProductID, P.Name
HAVING SUM(UnitPrice*OrderQty) > 10000 AND COUNT(SOD.SalesOrderID) > 500
--8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến 
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName 
--as FullName), Số hóa đơn (CountOfOrders).
SELECT P.BusinessEntityID AS PersonID, FullName = FirstName + ' ' + LastName, COUNT(*) AS CountOfOrders FROM Person.Person P JOIN Sales.SalesOrderHeader SOH ON SOH.CustomerID = P.BusinessEntityID
WHERE YEAR(OrderDate) BETWEEN 2007 AND 2008
GROUP BY P.BusinessEntityID, FirstName + ' ' + LastName
HAVING COUNT(*) > 25
--9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng 
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name, 
--CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader, 
--Sales.SalesOrderDetail và Production.Product)SELECT P.ProductID, P.Name, COUNT(OrderQty) FROM Production.Product P JOIN Sales.SalesOrderDetail SOD ON P.ProductID = SOD.ProductIDJOIN Sales.SalesOrderHeader SOH ON SOH.SalesOrderID = SOD.SalesOrderDetailIDWHERE Name LIKE 'Sport%' OR Name LIKE 'Bike%'GROUP BY P.ProductID, NameHAVING COUNT(OrderQty) > 500--10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông 
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
--bình (AvgofRate). Dữ liệu từ các bảng
--[HumanResources].[Department], 
--[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory].
SELECT D.DepartmentID, Name, AVG(Rate) FROM HumanResources.Department D JOIN HumanResources.EmployeeDepartmentHistory EDH ON D.DepartmentID = EDH.DepartmentID
JOIN HumanResources.EmployeePayHistory EPH ON EPH.BusinessEntityID = EDH.BusinessEntityID
GROUP BY D.DepartmentID, Name
HAVING AVG(Rate) > 30
--II) Subquery
--1) Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có 
--trên 100 đơn đặt hàng trong tháng 7 năm 2008
SELECT * FROM Production.Product
WHERE ProductID IN (SELECT ProductID FROM Sales.SalesOrderDetail SOD JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
					WHERE YEAR(OrderDate) = 2008 AND MONTH(OrderDate) = 7
					GROUP BY ProductID
					HAVING COUNT(*) > 100)
--2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
--trong tháng 7/2008SELECT P.ProductID, Name FROM Production.Product P JOIN Sales.SalesOrderDetail SOD ON P.ProductID = SOD.ProductIDJOIN Sales.SalesOrderHeader SOH ON SOH.SalesOrderID = SOD.SalesOrderIDWHERE YEAR(OrderDate) = 2008 AND MONTH(OrderDate) = 7GROUP BY P.ProductID, NameHAVING COUNT(*) >= ALL (	SELECT COUNT(*) FROM Sales.SalesOrderDetail SOD JOIN Sales.SalesOrderHeader SOH ON SOH.SalesOrderID = SOD.SalesOrderID						WHERE YEAR(OrderDate) = 2008 AND MONTH(OrderDate) = 7						GROUP BY ProductID)--3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm: 
--CustomerID, Name, CountOfOrder
SELECT SOH.CustomerID, Name = LastName + ' ' + FirstName, COUNT(*) FROM Sales.SalesOrderHeader SOH JOIN Person.Person P ON SOH.CustomerID = P.BusinessEntityID
GROUP BY SOH.CustomerID, LastName, FirstName
HAVING COUNT(*) >= ALL(	SELECT COUNT(*)
						FROM Sales.SalesOrderHeader
						GROUP BY CustomerID)
--4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với 
--tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng 
--bảng Production.Product và Production.ProductModel)
SELECT * FROM Production.Product
WHERE ProductModelID IN (	SELECT ProductModelID FROM Production.ProductModel
							WHERE Name LIKE 'Long-Sleeve Logo Jersey')

SELECT * FROM Production.Product P
WHERE EXISTS (	SELECT ProductModelID FROM Production.ProductModel
				WHERE Name LIKE 'Long-Sleeve Logo Jersey' AND ProductModelID = P.ProductModelID)
--5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
--đa cao hơn giá trung bình của tất cả các mô hình.
SELECT P.ProductID, PM.Name FROM Production.ProductModel PM JOIN Production.Product P ON PM.ProductModelID = P.ProductModelID
GROUP BY P.ProductID, PM.Name
HAVING MAX(ListPrice) >= ALL (SELECT AVG(ListPrice)
						FROM Production.ProductModel PM JOIN Production.Product P ON PM.ProductModelID = P.ProductModelID)
--6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng 
--đặt hàng > 5000 (dùng IN, EXISTS)
SELECT * FROM Production.Product
WHERE ProductID IN (SELECT ProductID FROM Sales.SalesOrderDetail
					GROUP BY ProductID
					HAVING SUM(OrderQty) > 5000)
--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao 
--nhất trong bảng Sales.SalesOrderDetail
SELECT distinct * FROM Sales.SalesOrderDetail
WHERE UnitPrice >= ALL (SELECT UnitPrice FROM Sales.SalesOrderDetail)
--8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID, 
--Nam; dùng 3 cách Not in, Not exists và Left join.
SELECT * FROM Production.Product
WHERE ProductID NOT IN (SELECT ProductID FROM Sales.SalesOrderDetail)

SELECT * FROM Production.Product P
WHERE NOT EXISTS (	SELECT ProductID FROM Sales.SalesOrderDetail
					WHERE P.ProductID = ProductID)

SELECT * FROM Production.Product P LEFT JOIN Sales.SalesOrderDetail SOD ON SOD.ProductID = P.ProductID
WHERE SOD.ProductID IS NULL
--9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm 
--EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng 
--HumanResources.Employees và Sales.SalesOrdersHeader)
SELECT BusinessEntityID, FirstName, LastName FROM Person.Person
WHERE BusinessEntityID in 
		(SELECT BusinessEntityID FROM HumanResources.Employee E JOIN Sales.SalesOrderHeader SOH ON E.BusinessEntityID = SOH.SalesPersonID
		WHERE OrderDate >'2008-5-1')
--10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
--trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008.
SELECT * FROM Sales.SalesOrderHeader
WHERE CustomerID IN (SELECT CustomerID FROM Sales.SalesOrderHeader
					WHERE YEAR(OrderDate) = 2007 AND CustomerID NOT IN (SELECT CustomerID FROM Sales.SalesOrderHeader
																		WHERE YEAR(OrderDate) = 2008))