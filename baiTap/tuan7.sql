USE AdventureWorks2008R2
--1.  Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước  sau:
--Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau:
create table  M_Department
(
DepartmentID int not null primary key, 
Name nvarchar(50),
GroupName nvarchar(50)
)
create table M_Employees 
(
EmployeeID int not null primary key, 
Firstname nvarchar(50),
MiddleName nvarchar(50), 
LastName nvarchar(50),
DepartmentID int foreign key references M_Department(DepartmentID)
)
--Tạo  một  view  tên  EmpDepart_View  bao  gồm  các  field:  EmployeeID,
--FirstName,  MiddleName,  LastName,  DepartmentID,  Name,  GroupName,  dựa 
--trên 2 bảng M_Employees và  M_Department.
--  Tạo  một  trigger  tên  InsteadOf_Trigger  thực  hiện  trên  view
--EmpDepart_View,  dùng  để  chèn  dữ  liệu  vào  các  bảng  M_Employees  và 
--M_Department khi chèn một record mới thông qua view EmpDepart_View.
GO
CREATE VIEW EmpDepart_view AS
SELECT EmployeeID, FirstName,  MiddleName,  LastName,  E.DepartmentID,  Name,  GroupName
FROM M_Employees E JOIN M_Department D ON E.DepartmentID = D.DepartmentID
GO
CREATE TRIGGER InsteadOf_Trigger
ON EmpDepart_view
INSTEAD OF INSERT
AS
BEGIN
	INSERT M_Department SELECT DepartmentID,Name, GroupName FROM inserted
	INSERT M_Employees SELECT EmployeeID, Firstname, MiddleName, LastName, DepartmentID FROM inserted
END
GO
insert EmpDepart_view values(1, 'Nguyen','Hoang','Huy', 11,'Marketing','Sales')
SELECT * FROM EmpDepart_view
--2.  Tạo một trigger thực hiện trên bảng  MSalesOrders có chức năng thiết lập độ ưu 
--tiên của  khách hàng (CustPriority) khi người dùng thực hiện các thao tác  Insert, 
--Update và Delete trên bảng MSalesOrders theo điều kiện như  sau:
--  Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của 
--khách hàng (CustPriority) là 3
--  Nếu tổng tiền  Sum(SubTotal)  của khách hàng từ 10,000 $ đến dưới 50000  $ 
--thì độ ưu tiên của khách hàng (CustPriority) là  2
--  Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000  $ trở lên thì độ ưu tiên 
--của khách hàng (CustPriority) là 1
--Các bước thực hiện:
--  Tạo bảng MCustomers và MSalesOrders theo cấu trúc 

create table  MCustomer
(
CustomerID int not null primary key, 
CustPriority int )
create table MSalesOrders 
(
SalesOrderID int not null primary key, 
OrderDate date,
SubTotal money,
CustomerID int foreign key references MCustomer(CustomerID) 
)
-- Chèn dữ liệu cho bảng MCustomers, lấy dữ liệu từ bảng Sales.Customer, 
--nhưng chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho 
--giá trị null.
-- Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
--Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng 
--khách hàng.
-- Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted.
-- Viết câu lệnh kiểm tra việc thực thi của trigger vừa tạo bằng cách chèn thêm hoặc 
--xóa hoặc update một record trên bảng MSalesOrders
INSERT INTO MCustomer
SELECT CustomerID,null FROM Sales.Customer WHERE CustomerID > 30100 AND CustomerID < 30118

SELECT * FROM MCustomer

INSERT INTO MSalesOrders
SELECT SalesOrderID, OrderDate, SubTotal, CustomerID FROM Sales.SalesOrderHeader WHERE CustomerID > 30100 AND CustomerID < 30118 AND YEAR(OrderDate) = 2008
GO
CREATE TRIGGER cau2 ON MSalesOrders
AFTER INSERT, UPDATE, DELETE
AS
	DECLARE @customerId INT, @subtotal MONEY
	;WITH TableInsertedDeleted AS (
		SELECT CustomerId
		FROM inserted
		UNION
		SELECT CustomerId
		FROM deleted)
	SELECT @customerId = OS.customerID, @subtotal = SUM(SubTotal)
	FROM MsalesOrders OS INNER JOIN TableInsertedDeleted TID ON OS.CustomerID = TID.CustomerID
	GROUP BY OS.CustomerID
	UPDATE MCustomer
	SET CustPriority = (
		CASE
		WHEN @subtotal < 10000 THEN 3
		WHEN @subtotal < 50000 THEN 2
		ELSE 1
		END) WHERE CustomerID = @customerId
GO
SELECT * FROM MCustomer
SELECT * FROM MSalesOrders WHERE CustomerID = 30102
INSERT MSalesOrders
VALUES (1,null,1,30102)
--5.  Viết một trigger thực hiện trên bảng ProductInventory (lưu thông tin số lượng  sản 
--phẩm trong kho). Khi chèn thêm một đơn đặt hàng vào bảng SalesOrderDetail  với 
--số lượng xác định trong   field
--OrderQty, nếu số lượng trong kho 
--Quantity> OrderQty thì cập nhật 
--lại  số   lượng   trong   kho 
--Quantity=  Quantity-  OrderQty, 
--ngược lại nếu Quantity=0 thì xuất 
--thông báo “Kho hết hàng” và đồng 
--thời hủy giao  tác.
select *
from Sales.SalesOrderDetail
go
sp_help 'Sales.SalesOrderDetail'
delete Sales.SalesOrderDetail where SalesOrderID=43659 and SalesOrderDetailID = 121320

insert Sales.SalesOrderDetail(SalesOrderID,OrderQty,ProductID,SpecialOfferID,UnitPrice)
values (43660, 300, 707,1,  100 )

select * from Sales.SpecialOfferProduct where ProductID = 316


go
select * from Production.ProductInventory where ProductID = 707

go 
select * from Production.ProductInventory i join Sales.SpecialOfferProduct s
on i.ProductID = s.ProductID
GO
create trigger  cau5
on Sales.SalesOrderDetail
after insert
as
declare @productid int, @qty smallint  , @locationid int
select  @qty = OrderQty,  @productid = ProductID
from inserted

if exists (select * from  Production.ProductInventory where ProductID = @productid 
						and Quantity >= @qty)
begin
	select  top 1 @locationid=  LocationID
	from  Production.ProductInventory where ProductID = @productid and Quantity >= @qty

	update Production.ProductInventory
	set	Quantity = Quantity - @qty
	where ProductID = @productid  and @locationid=  LocationID
end

else
begin
	print N'Kho ....hết hàng'
	rollback
end
GO

--6.  Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson,  khi 
--người  dùng  chèn thêm một  record mới  trên  bảng  SalesOrderHeader,  theo  quy  định 
--như sau: Nếu tổng tiền bán được của nhân  viên có hóa  đơn  mới  nhập vào bảng 
--SalesOrderHeader  có giá trị >10000000 thì tăng tiền thưởng lên  10% của  mức 
--thưởng hiện tại. Cách thực  hiện:
create table M_SalesPerson 
(
	SalePSID int not null primary key, 
	TerritoryID int,
	BonusPS money
)
create table M_SalesOrderHeader 
(
	SalesOrdID int not null primary key, 
	OrderDate date,
	SubTotalOrd money,
	SalePSID int foreign key references M_SalesPerson(SalePSID)
)
--  Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn 
--những field tương ứng với 2 bảng mới  tạo.
--  Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger 
--thực thi thì dữ liệu trong bảng M_SalesPerson được cập  nhật. 
SELECT SalesOrderID, OrderDate,SubTotal, SalesPersonID FROM Sales.SalesOrderHeader
SELECT BusinessEntityID, TerritoryID, Bonus FROM Sales.SalesPerson
GO
sp_help 'Sales.SalesOrderHeader'
GO

INSERT M_SalesPerson
VALUES (279	,5,	6700.00),
		(282,6,	5000.00),
		(276,4,2000.00)
GO
INSERT M_SalesOrderHeader(SalesOrdID, OrderDate, SubTotalOrd, SalePSID)
VALUES (43659, '2005-07-01', 20565.6206,279),
		(43660,	'2005-07-01',1294.2529,	279),
		(43661,	'2005-07-01', 32726.4786, 282),
		(43663,	'2005-07-01', 419.4589,	276)

GO
CREATE TRIGGER capNhatBonus
ON M_SalesOrderHeader
AFTER INSERT
AS
BEGIN
	DECLARE @salePersonID int, @total MONEY
	SELECT @salePersonID = inserted.SalePSID FROM inserted
	SET @total = (SELECT SUM(SubTotalOrd) FROM M_SalesOrderHeader WHERE SalePSID = @salePersonID)
	if @total > 10000000
	BEGIN
		UPDATE M_SalesPerson
		SET BonusPS = BonusPS*1.1
		WHERE SalePSID = @salePersonID
	END
END
GO
DROP TRIGGER capNhatBonus
GO
SELECT * FROM M_SalesOrderHeader
SELECT * FROM M_SalesPerson --bonus cua salePSID 276 la 2000.00
INSERT M_SalesOrderHeader
VALUES (123, '2005-07-01', 10000000, 276)
SELECT * FROM M_SalesPerson