/* проверка транзакций на подозрительную активность */

/* вывести транзакции, которые произошли с одного и того же аккаунта в течении дня более 1 раза */

SELECT TransactionID, AccountID, TransactionAmount, TransactionDate, Locations
FROM bank_transaction
WHERE (AccountID, CAST(TransactionDate AS DATE)) IN (SELECT AccountID, CAST(TransactionDate AS DATE)
                          FROM bank_transaction 
                          GROUP BY CAST(TransactionDate AS DATE), AccountID
                          HAVING COUNT(AccountID) > 1)					  
ORDER BY TransactionDate, AccountID;


/* Частые транзакции с одного устройства или IP-адреса */

SELECT DeviceID, 
       COUNT(*) AS TransactionCount, 
       MIN(TransactionDate) AS FirstTransaction, 
       MAX(TransactionDate) AS LastTransaction
FROM bank_transaction
GROUP BY DeviceID
HAVING COUNT(*) > 8;


/* Выявление транзакций с подозрительными суммами */

SELECT AccountID, 
       TransactionID, 
       TransactionAmount, 
       AVG(TransactionAmount) OVER (PARTITION BY AccountID) AS AvgTransactionAmount
FROM bank_transaction
WHERE TransactionAmount > 2 * (
    SELECT AVG(TransactionAmount) 
    FROM bank_transaction
);


/* Аномальная скорость проведения транзакций */

SELECT TransactionID, 
       TransactionDuration, 
       AVG(TransactionDuration) OVER () AS AvgTransactionDuration
FROM bank_transaction
WHERE TransactionDuration < 0.1 * (
    SELECT AVG(TransactionDuration) 
    FROM bank_transaction
);


/* Подозрительные последовательности попыток входа */

SELECT AccountID, 
       TransactionID, 
       LoginAttempts
FROM bank_transaction
WHERE LoginAttempts > 4;


/* Распределение транзакций по времени суток (пока не работает) */

SELECT TransactionID, 
       AccountID, 
       TransactionDate, 
       EXTRACT(HOUR FROM TransactionDate::timestamp) AS TransactionHour
FROM bank_transaction
WHERE EXTRACT(HOUR FROM TransactionDate::timestamp) BETWEEN 22 AND 6;


/* Сравнение текущего баланса с суммой транзакции */

SELECT AccountID, 
       TransactionID, 
       TransactionAmount, 
       AccountBalance
FROM bank_transaction
WHERE TransactionAmount > AccountBalance;


/* тренировка запросов в бд */


SELECT COUNT(DISTINCT locations) AS количество_городов,
       -- Самый популярный город
       (SELECT locations 
       FROM bank_transaction
       GROUP BY locations
       ORDER BY COUNT(*) DESC
       LIMIT 1) AS макс_город,
       -- Самая большая сумма транзакции
       MAX(transactionamount) AS Самая_большая_сумма,
       -- Самый популярный тип транзакции
       (SELECT transactiontype 
       FROM bank_transaction
       GROUP BY transactiontype
       ORDER BY COUNT(*) DESC
       LIMIT 1) AS Самый_популярный_тип_транзакции,
       -- Самый популярный способ проведения транзакции
       (SELECT channel 
       FROM bank_transaction
       GROUP BY channel
       ORDER BY COUNT(*) DESC
       LIMIT 1) AS самый_популярный_способ_транзакции
FROM 
    bank_transaction;


/*  */

SELECT bt.transactionid, 
       de.deviceid, 
       de.clientsid, 
       bt.locations

FROM device AS de 
    LEFT JOIN bank_transaction AS bt 
    ON de.clientsid = bt.accountid AND de.deviceid = bt.deviceid

ORDER BY bt.transactionid, de.deviceid, de.clientsid, bt.locations;

-- или

SELECT transactionid, deviceid, accountid, locations
FROM bank_transaction
ORDER BY transactionid;

/*  */



/* Самые популярные элементы (города, способы оплаты, категории клиентов) */

SELECT locations, 
       channel, 
       customeroccupation, 
       COUNT(*) AS Количество_транзакций_в_этой_группе 
FROM bank_transaction
GROUP BY locations, channel, customeroccupation
ORDER BY COUNT(*) DESC;


/* Самые редкие элементы */

SELECT locations,  
       channel, 
       customeroccupation,
       COUNT(*) AS Количество_транзакций_в_этой_группе
FROM bank_transaction
GROUP BY locations, channel, customeroccupation
ORDER BY COUNT(*) ASC;



/* вывести среднее время транзакции */

SELECT AVG(transactionduration) AS Среднее_время_транзакции
FROM  bank_transaction;


/* Статистика времени транзакций по городам */


SELECT DISTINCT locations, 
       AVG(transactionduration), 
       COUNT(*) AS Количество_транзакций, 
       AVG(transactionduration) AS Среднее_время, 
       MIN(transactionduration) AS Минимальное_время, 
       MAX(transactionduration) AS Максимальное_время
FROM  bank_transaction
GROUP BY locations
ORDER BY COUNT (*) DESC;


/* Клиенты с одинаковой ролью и возрастом */

SELECT AccountID, 
       customeroccupation, 
       CustomerAge, 
       AccountBalance

FROM clients

GROUP BY AccountID, 
         customeroccupation, 
         CustomerAge, 
         AccountBalance
ORDER BY customeroccupation, CustomerAge;
