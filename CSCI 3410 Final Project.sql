/**********************************************************************

 ██████╗███████╗ ██████╗██╗    ██████╗ ██╗  ██╗ ██╗ ██████╗ 
██╔════╝██╔════╝██╔════╝██║    ╚════██╗██║  ██║███║██╔═████╗
██║     ███████╗██║     ██║     █████╔╝███████║╚██║██║██╔██║
██║     ╚════██║██║     ██║     ╚═══██╗╚════██║ ██║████╔╝██║
╚██████╗███████║╚██████╗██║    ██████╔╝     ██║ ██║╚██████╔╝
 ╚═════╝╚══════╝ ╚═════╝╚═╝    ╚═════╝      ╚═╝ ╚═╝ ╚═════╝                                                          
 ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
||F |||i |||n |||a |||l |||       |||P |||r |||o |||j |||e |||c |||t ||
||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|

**********************************************************************/

/**********************************************************************

 Database Developer Name: Kevin Mitchell
           Project Title: Voyager Inventory Controller
      Script Create Date: 4/28/19

**********************************************************************/

/**********************************************************************
	CREATE TABLE SECTION
**********************************************************************/
CREATE TABLE kmmitc9478.Addresses(
	Address_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	Street VARCHAR(50) NOT NULL,
	City VARCHAR(25) NOT NULL,
	State_Col VARCHAR(15) NOT NULL DEFAULT 'Georgia',
	Country VARCHAR(25) NOT NULL DEFAULT 'United States',
	Zip_Code VARCHAR(10) NOT NULL
	);

CREATE TABLE kmmitc9478.Worksites(
	Worksite_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	Worksite_Name VARCHAR(30) NOT NULL DEFAULT 'Unnamed',
	Address_ID INT FOREIGN KEY REFERENCES kmmitc9478.Addresses(Address_ID),
	Phone_Number VARCHAR(11) NOT NULL,
	Time_Open TIME(7) NOT NULL DEFAULT '08:00:00',
	Time_Closed TIME(7) NOT NULL DEFAULT '17:00:00'
	);


CREATE TABLE kmmitc9478.User_Accounts(
	User_Account_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	First_Name VARCHAR(25) NOT NULL,
	Last_Name VARCHAR(35) NOT NULL,
	email VARCHAR(40) NOT NULL,
	--Sales Reps do not have a user name or worksite but are users
	Username VARCHAR(30) NULL DEFAULT 'NewUser',
	Worksite_ID INT NULL FOREIGN KEY REFERENCES kmmitc9478.Worksites(Worksite_ID)
	);

CREATE TABLE kmmitc9478.Vendors(
	Vendor_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	Vendor_Name VARCHAR(30) NOT NULL DEFAULT 'NewVendor',
	Address_ID INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.Addresses(Address_ID),
	Phone_Number VARCHAR(11) NOT NULL,
	Sales_Rep INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.User_Accounts(User_Account_ID)
	);


CREATE TABLE kmmitc9478.Computer_Systems(
	System_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	System_Name VARCHAR(20) NOT NULL DEFAULT 'NewSystem',
	System_Make VARCHAR(20) NOT NULL,
	System_Model VARCHAR(20) NOT NULL,
	Serial_Number VARCHAR(35) NOT NULL,
	);

CREATE TABLE kmmitc9478.Computer_Peripherals(
	Peripheral_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	Peripheral_Name VARCHAR(25) NOT NULL DEFAULT 'NewPeripheral',
	Vendor_ID INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.Vendors(Vendor_ID),
	Amount_In_Stock INT NOT NULL DEFAULT 0,
	Total_Amount INT NOT NULL DEFAULT 0
	);

CREATE TABLE kmmitc9478.System_Assignment(
	System_Assign_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	System_ID INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.Computer_Systems(System_ID),
	User_Account_ID INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.User_Accounts(User_Account_ID),
	Date_Assigned DATE NOT NULL DEFAULT GETDATE(),
	Date_Returned DATE NULL
	);

CREATE TABLE kmmitc9478.Peripheral_Assignment(
	Periph_Assign_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	Peripheral_ID INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.Computer_Peripherals(Peripheral_ID),
	User_Account_ID INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.User_Accounts(User_Account_ID),
	Date_Assigned DATE NOT NULL DEFAULT GETDATE(),
	Date_Returned DATE NULL
	);

CREATE TABLE kmmitc9478.Computer_Tickets(
	Ticket_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	System_Assign_ID INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.System_Assignment(System_Assign_ID),
	Summary VARCHAR(2000) NULL,
	Resolution VARCHAR(2000) NULL,
	Date_Opened DATE NOT NULL DEFAULT GETDATE(),
	Date_Closed DATE NULL
	);

CREATE TABLE kmmitc9478.Purchase_Orders(
	Order_ID INT NOT NULL PRIMARY KEY IDENTITY(0,1),
	Vendor_ID INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.Vendors(Vendor_ID),
	System_ID INT NOT NULL FOREIGN KEY REFERENCES kmmitc9478.Computer_Systems(System_ID),
	Date_Ordered DATE NOT NULL DEFAULT GETDATE(),
	Total_Price FLOAT NOT NULL
	);
/**********************************************************************
	CREATE STORED PROCEDURE SECTION
**********************************************************************/
go

--Used to resolve a computer ticket and set the close date to today
create procedure kmmitc9478.resolveTicket (
	@Ticket_ID int,
	@Resolution VARCHAR(2000)
)
as
begin
	UPDATE kmmitc9478.Computer_Tickets
	SET Resolution = @Resolution, Date_Closed = GETDATE()
	WHERE Ticket_ID = @Ticket_ID
end

go

--Used to remove a Computer Ticket
create procedure kmmitc9478.deleteTicket (
	@Ticket_ID int
)
as
begin
	DELETE FROM kmmitc9478.Computer_Tickets
	WHERE Ticket_ID = @Ticket_ID
end

go

/**********************************************************************
	DATA POPULATION SECTION
**********************************************************************/
DECLARE @i INT;
DECLARE @j INT;

--Begn user Declarations
-------------------------
INSERT INTO kmmitc9478.Addresses(Street, City, Zip_Code) VALUES(
	'12345 First Entry Avenue',
	'Gainesville',
	'30501'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Worksites(Worksite_Name, Address_ID, Phone_Number) VALUES(
	'FirstSite',
	@i,
	'6785555555'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email, Username, Worksite_ID) VALUES(
	'Mister',
	'Man',
	'Mister.Man@gmail.com',
	'mrman',
	@i
);

DECLARE @a1 INT;
SET @a1 = SCOPE_IDENTITY();
	

INSERT INTO kmmitc9478.Addresses(Street, City, Zip_Code) VALUES(
	'6546 Apartment Lane Apt 2',
	'Gainesville',
	'30501'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Worksites(Worksite_Name, Address_ID, Phone_Number) VALUES(
	'Apartment Site',
	@i,
	'6785555333'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email, Username, Worksite_ID) VALUES(
	'Misses',
	'Woman',
	'Misses.Woman@gmail.com',
	'mswoman',
	@i
);
DECLARE @a2 INT;
SET @a2 = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Addresses(Street, City, Zip_Code) VALUES(
	'8675 Three-Oh-Nine Drive',
	'Gainesville',
	'30501'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Worksites(Worksite_Name, Address_ID, Phone_Number) VALUES(
	'Tutone',
	@i,
	'5558675309'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email, Username, Worksite_ID) VALUES(
	'Tommy',
	'Tutone',
	'Tommy.Tutone@gmail.com',
	'tjtutone',
	@i
);
DECLARE @a3 INT;
SET @a3 = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Addresses(Street, City, Zip_Code) VALUES(
	'3465 Roll Tide Park',
	'Birmingham',
	'35005'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Worksites(Worksite_Name, Address_ID, Phone_Number) VALUES(
	'"That" Site',
	@i,
	'5555555555'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email, Username, Worksite_ID) VALUES(
	'Bad',
	'Team',
	'bad.team@gmail.com',
	'bxteam',
	@i
);

DECLARE @a4 INT;
SET @a4 = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Addresses(Street, City, State_Col, Zip_Code) VALUES(
	'3465 Giants Lane',
	'New York',
	'New York',
	'10001'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Worksites(Worksite_Name, Address_ID, Phone_Number) VALUES(
	'Yankee Works',
	@i,
	'1111111111'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email, Username, Worksite_ID) VALUES(
	'Last',
	'Guyy',
	'Last.Guyy@gmail.com',
	'loguyy',
	@i
);

DECLARE @a5 INT;
SET @a5 = SCOPE_IDENTITY();
-------------------------
--End user Declarations
-------------------------

----------------------------
--Begin Vendor Declarations
----------------------------
INSERT INTO kmmitc9478.Addresses(Street, City, State_Col, Zip_Code) VALUES(
	'12356 Vendor Suites',
	'Cumming',
	'Georgia',
	'35001'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email) VALUES(
	'Sales',
	'Mann',
	'Sales.Mann@gmail.com'
);

SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Vendors(Vendor_Name, Address_ID, Phone_Number, Sales_Rep) VALUES(
	'Vendor Men',
	@i,
	'1234567890',
	@j
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Computer_Systems(System_Name, System_Make, System_Model, Serial_Number) VALUES(
	'StockLT1001',
	'Lenovo',
	'E555',
	'PF-12345'
	);

DECLARE @s1 INT;
SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.System_Assignment(System_ID, User_Account_ID) VALUES(
	@j,
	@a1
);
SET @s1 = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Purchase_Orders(Vendor_ID, System_ID, Total_Price) VALUES(
	@i,
	@j,
	585.67
	);
	 

INSERT INTO kmmitc9478.Addresses(Street, City, State_Col, Zip_Code) VALUES(
	'4444 Main Street',
	'Flavor Town',
	'Georgia',
	'99999'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email) VALUES(
	'Guy',
	'Fieri',
	'Guy.Fieri@gmail.com'
);

SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Vendors(Vendor_Name, Address_ID, Phone_Number, Sales_Rep) VALUES(
	'Burger Time',
	@i,
	'9999999999',
	@j
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Computer_Systems(System_Name, System_Make, System_Model, Serial_Number) VALUES(
	'StockLT1002',
	'Lenovo',
	'E555',
	'PF-12346'
	);

DECLARE @s2 INT;
SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.System_Assignment(System_ID, User_Account_ID) VALUES(
	@j,
	@a2
);
SET @s2 = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Purchase_Orders(Vendor_ID, System_ID, Total_Price) VALUES(
	@i,
	@j,
	585.67
	);

INSERT INTO kmmitc9478.Computer_Systems(System_Name, System_Make, System_Model, Serial_Number) VALUES(
	'StockLT1003',
	'Lenovo',
	'E560',
	'PF-12346'
	);

DECLARE @s3 INT;
SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.System_Assignment(System_ID, User_Account_ID) VALUES(
	@j,
	@a3
);

SET @s3 = SCOPE_IDENTITY();
INSERT INTO kmmitc9478.Purchase_Orders(Vendor_ID, System_ID, Total_Price) VALUES(
	@i,
	@j,
	605.85
	);


INSERT INTO kmmitc9478.Addresses(Street, City, State_Col, Zip_Code) VALUES(
	'1010 Broad Street',
	'Gainesville',
	'Georgia',
	'30503'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email) VALUES(
	'Anotha',
	'One',
	'Anotha.one@gmail.com'
);

SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Vendors(Vendor_Name, Address_ID, Phone_Number, Sales_Rep) VALUES(
	'DJ Khalid Productions',
	@i,
	'1212121122',
	@j
	);


INSERT INTO kmmitc9478.Addresses(Street, City, State_Col, Zip_Code) VALUES(
	'777 Church Drive',
	'Gainesville',
	'Georgia',
	'30504'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email) VALUES(
	'Pastor',
	'Dave',
	'Pastor.Dave@gmail.com'
);

SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Vendors(Vendor_Name, Address_ID, Phone_Number, Sales_Rep) VALUES(
	'The Church',
	@i,
	'7777777777',
	@j
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Computer_Systems(System_Name, System_Make, System_Model, Serial_Number) VALUES(
	'StockDT1001',
	'HP',
	'ProDesk',
	'5CN123567'
	);

DECLARE @s4 INT;
SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.System_Assignment(System_ID, User_Account_ID) VALUES(
	@j,
	@a4
);
SET @s4 = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Purchase_Orders(Vendor_ID, System_ID, Total_Price) VALUES(
	@i,
	@j,
	2024.88
	);

INSERT INTO kmmitc9478.Addresses(Street, City, State_Col, Zip_Code) VALUES(
	'2356 Last Vendor Avenue',
	'Gainesville',
	'Georgia',
	'30504'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email) VALUES(
	'David',
	'Tenet',
	'David.Tenet@gmail.com'
);

SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Vendors(Vendor_Name, Address_ID, Phone_Number, Sales_Rep) VALUES(
	'The Doctors',
	@i,
	'8888888888',
	@j
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Computer_Systems(System_Name, System_Make, System_Model, Serial_Number) VALUES(
	'StockDT1002',
	'HP',
	'ProDesk',
	'5CN123568'
	);

DECLARE @s5 INT;
SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.System_Assignment(System_ID, User_Account_ID) VALUES(
	@j,
	@a5
);
SET @s5 = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Purchase_Orders(Vendor_ID, System_ID, Total_Price) VALUES(
	@i,
	@j,
	2124.88
	);

----------------------------
--End Vendor Declarations
----------------------------

----------------------------
--Begin Ticket Declarations
----------------------------
INSERT INTO kmmitc9478.Computer_Tickets(System_Assign_ID, Summary, Resolution) VALUES (
	@s1,
	'There is something wrong with it',
	'We fixed it'
	);

INSERT INTO kmmitc9478.Computer_Tickets(System_Assign_ID, Summary, Resolution) VALUES (
	@s2,
	'I broke it',
	'I fixed it'
	);

INSERT INTO kmmitc9478.Computer_Tickets(System_Assign_ID, Summary, Resolution) VALUES (
	@s3,
	'It exploded',
	'It didn"t'
	);

INSERT INTO kmmitc9478.Computer_Tickets(System_Assign_ID, Summary, Resolution) VALUES (
	@s1,
	'There is something wrong with it again',
	'We fixed it again'
	);

INSERT INTO kmmitc9478.Computer_Tickets(System_Assign_ID, Summary) VALUES (
	@s3,
	'It exploded. I need a new one'
	);

----------------------------
--End Ticket Declarations
----------------------------

---------------------------------
--Begin Peripheral Declarations
---------------------------------
INSERT INTO kmmitc9478.Addresses(Street, City, State_Col, Zip_Code) VALUES(
	'1234 Peripheral Lane',
	'Gainesville',
	'Georgia',
	'30501'
	);

SET @i = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.User_Accounts(First_Name, Last_Name, email) VALUES(
	'Peripheral',
	'Mann',
	'Peripheral.Mann@gmail.com'
);

SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Vendors(Vendor_Name, Address_ID, Phone_Number, Sales_Rep) VALUES(
	'999 Peripherals',
	@i,
	'1234569876',
	@j
	);

SET @j = SCOPE_IDENTITY();

INSERT INTO kmmitc9478.Computer_Peripherals(Peripheral_Name, Vendor_ID, Amount_In_Stock, Total_Amount) VALUES(
	'Laptop Bag',
	@j,
	4,
	5
	);
	
SET @i = SCOPE_IDENTITY();
 
INSERT INTO kmmitc9478.Peripheral_Assignment(Peripheral_ID, User_Account_ID) VALUES(
	@i,
	@a1
	);

INSERT INTO kmmitc9478.Computer_Peripherals(Peripheral_Name, Vendor_ID, Amount_In_Stock, Total_Amount) VALUES(
	'Monitor',
	@j,
	9,
	15
	);
	
SET @i = SCOPE_IDENTITY();
 
INSERT INTO kmmitc9478.Peripheral_Assignment(Peripheral_ID, User_Account_ID) VALUES(
	@i,
	@a2
	);

INSERT INTO kmmitc9478.Computer_Peripherals(Peripheral_Name, Vendor_ID, Amount_In_Stock, Total_Amount) VALUES(
	'Keyboard',
	@j,
	36,
	40
	);
	
SET @i = SCOPE_IDENTITY();
 
INSERT INTO kmmitc9478.Peripheral_Assignment(Peripheral_ID, User_Account_ID) VALUES(
	@i,
	@a3
	);

INSERT INTO kmmitc9478.Computer_Peripherals(Peripheral_Name, Vendor_ID, Amount_In_Stock, Total_Amount) VALUES(
	'Mouse',
	@j,
	15,
	15
	);
	
SET @i = SCOPE_IDENTITY();
 
INSERT INTO kmmitc9478.Peripheral_Assignment(Peripheral_ID, User_Account_ID) VALUES(
	@i,
	@a4
	);

INSERT INTO kmmitc9478.Computer_Peripherals(Peripheral_Name, Vendor_ID, Amount_In_Stock, Total_Amount) VALUES(
	'Charger',
	@j,
	14,
	15
	);
	
SET @i = SCOPE_IDENTITY();
 
INSERT INTO kmmitc9478.Peripheral_Assignment(Peripheral_ID, User_Account_ID) VALUES(
	@i,
	@a5
	);

-------------------------------
--End Peripheral Declarations
-------------------------------

/**********************************************************************
	RUN STORED PROCEDURE SECTION
**********************************************************************/

exec kmmitc9478.resolveTicket @Ticket_ID = 1, @Resolution = 'This is the changed resolution'
exec kmmitc9478.deleteTicket @Ticket_ID = 2


/**********************************************************************
	END OF SCRIPT
**********************************************************************/