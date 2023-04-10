USE AdventureWorks2008R2
GO
--Câu 1
CREATE PROC cau1 (@ProductID INT, @locationID INT, @Quantity INT)
AS
BEGIN
	IF NOT EXISTS (SELECT ProductID FROM Production.ProductInventory 
				WHERE LocationID = @LocationID)
		PRINT CONCAT(N'Không tồn tại Mã Hàng ', @ProductID, N' và Mã vị trí kho hàng ', @locationID)
	ELSE
	BEGIN
		IF(@Quantity IS NOT NULL)
			BEGIN
				UPDATE Production.ProductInventory
				SET Quantity = @Quantity
				WHERE ProductID = @ProductID AND LocationID = @locationID
			END
	END
END
GO
--Trường hợp tồn tại bộ tương ứng mã hàng và đơn hàng
EXEC cau1 1,1,1
--Trường hợp không tồn tại bộ tương ứng mã hàng và đơn hàng
EXEC cau1 1,1243124,1
--Trường hợp @quantity là null
EXEC cau1 1,1,NULL

DROP PROC cau1
GO
--Câu 2:
CREATE FUNCTION cau2 (@VendorID INT, @year INT, @value INT)
RETURNS @table TABLE(VendorID INT, Total MONEY)
AS
BEGIN
	IF @value IS NULL
		INSERT @table
			SELECT BusinessEntityID, SUM(SubTotal) 
			FROM Purchasing.Vendor V JOIN Purchasing.PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
			WHERE YEAR(OrderDate) = @year
			GROUP BY BusinessEntityID
	ELSE
		BEGIN
			INSERT @table
			SELECT BusinessEntityID, SUM(SubTotal) 
			FROM Purchasing.Vendor V JOIN Purchasing.PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
			WHERE BusinessEntityID = @VendorID AND YEAR(OrderDate) = @year
			GROUP BY BusinessEntityID
			HAVING SUM(SubTotal) > @value
		END
	RETURN
END
GO
--Trường hợp @value là null
SELECT * FROM cau2(1682, 2007, null)
--Trường hợp các điều kiện đều thỏa
SELECT * FROM cau2(1682, 2007, 100)

DROP FUNCTION cau2