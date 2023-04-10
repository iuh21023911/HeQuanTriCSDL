--Câu 1: (5đ) Hãy vi ết 1 store procedure
--a. Viết thủ tục tên MaSV_Total trả về tổng trị giá các hóa đơn đã xuất 
--bán thuộc về một TerritoryID trong một tháng, năm (tương  ứng  với 
--các tham số đầu vào). Thủ tục trả về giá trị qua tham số OUTPUT.
GO
CREATE PROC [Total] @TerritoryID INT, @month INT, @year INT
AS
BEGIN
	SELECT SUM(SubTotal)
	FROM Sales.SalesTerritory ST JOIN Sales.SalesOrderHeader SOH ON ST.TerritoryID = SOH.TerritoryID
	WHERE ST.TerritoryID = @TerritoryID
	AND MONTH(OrderDate) = @month
	AND YEAR(OrderDate) = @year
	GROUP BY ST.TerritoryID, MONTH(OrderDate), YEAR(OrderDate)
END
GO
--b.  Viết  batch  gọi  thủ tục   với tham số  @TerritoryID=10  ,  @thang 5 , 
--@nam=  2011,  và  xuất ra thông báo  ‘ Tổng trị giá các hóa đơn  thuộc 
--vùng Territorry có tên ….  là …’  
--(Gợi ý :  Name trong Sales.SalesTerritory)
GO
DECLARE @TerritoryID INT, @thang INT, @nam INT
SET @TerritoryID=10
SET @thang = 5
SET @nam=  2011
EXEC [Total] @TerritoryID, @thang , @nam
--Câu 2: (5đ) 
--c.  Hãy  viết  hàm  dạng  table_valued  function  có  tên  MaSV_ThongKe 
--cho  bi ết  Sản phẩm   có tổng số l ượng bán cao nhất trong năm bất kỳ
--(@nam là tham số truyền vào). Thông tin hiển thị bao gồm :  Mã sản 
--phẩm , Tổng số l ượng bán 
GO
CREATE FUNCTION [ThongKe] (@nam INT)
RETURNS TABLE
AS
	RETURN
		SELECT TOP 1 ProductID, TotalOrder = SUM(OrderQty)
		FROM Sales.SalesOrderDetail SOD JOIN Sales.SalesOrderHeader SOH
		ON SOD.SalesOrderID = SOH.SalesOrderID
		WHERE YEAR(OrderDate) = @nam
		GROUP BY ProductID
		ORDER BY SUM(OrderQty) DESC
GO
--d.  Thực thi   hàm  với tham số @nam=  2011
DECLARE @nam INT
SET @nam = 2011
SELECT * FROM [ThongKe](@nam)