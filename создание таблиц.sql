/* Таблица для всех данных из csv */
CREATE TABLE bank_transaction (
	TransactionID VARCHAR(8),
	AccountID VARCHAR(7),
	TransactionAmount DECIMAL(10,2),
	TransactionDate TIMESTAMP,
	TransactionType VARCHAR(7),
	Locations VARCHAR(20),
	DeviceID VARCHAR(7),
	IP_Address INET,
	MerchantID VARCHAR(4),
	Channel VARCHAR(7),
	CustomerAge SMALLINT,
	CustomerOccupation VARCHAR(20),
	TransactionDuration SMALLINT,
	LoginAttempts SMALLINT,
	AccountBalance DECIMAL(10, 2),
	PreviousTransactionDate TIMESTAMP
);

/* Создать таблицу город */

CREATE TABLE cities AS 
SELECT DISTINCT locations AS LocationsName
FROM bank_transaction;

ALTER TABLE cities
ADD LocationId SERIAL PRIMARY KEY;

/* создание таблицы клиентов */

CREATE TABLE clients AS
SELECT AccountID, CustomerOccupation, CustomerAge, AccountBalance
FROM bank_transaction;

ALTER TABLE clients
ADD CustomerID SERIAL PRIMARY KEY;
   
/* создание таблицы транзакций */

CREATE TABLE transactions AS 
SELECT bt.TransactionID,
	   bt.AccountID
	   bt.TransactionAmount, 
	   bt.TransactionDate, 
	   bt.TransactionType,
	   ci.LocationId AS LocationId,
	   bt.DeviceID, 
	   bt.IP_Address,
	   bt.MerchantID,
	   bt.Channel,
	   bt.TransactionDuration,
	   bt.LoginAttempts,
	   bt.PreviousTransactionDate
FROM bank_transaction AS bt LEFT JOIN cities AS ci
		ON bt.Locations = ci.LocationsName;

/* создание таблицы девайсов */

CREATE TABLE device AS
SELECT DISTINCT DeviceID, AccountID AS ClientsID
FROM bank_transaction;
