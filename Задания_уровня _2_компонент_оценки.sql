---1.Компонент оперативного учета

------Опустошите данные в таблице
DELETE FROM dbo.Payment; 
DELETE FROM dbo.PaymentParticipant;  
DELETE FROM dbo.PaymentCategory; 

------Роли оперативного учета: добавление, удаление, изменение(for help gpt)
DECLARE @StartTime DATETIME;
DECLARE @EndTime DATETIME;
DECLARE @Count INT = 1;

SET @StartTime = GETDATE();

BEGIN TRANSACTION;

    WHILE @Count <= 2000
    BEGIN
        DECLARE @participantId UNIQUEIDENTIFIER = NEWID();
        DECLARE @categoryId UNIQUEIDENTIFIER = NEWID();

        INSERT INTO dbo.PaymentParticipant (Oid, Name, Balance)
        VALUES (@participantId, 'Test Participant ' + CAST(@Count AS VARCHAR(10)), 0);

        INSERT INTO dbo.PaymentCategory (Oid, Name, ProfitByMaterial, CostByMaterial)
        VALUES (@categoryId, 'Test Category ' + CAST(@Count AS VARCHAR(10)), 0, 0);

        INSERT INTO dbo.Payment (Oid, Amount, Category, Payer, Payee, Date, Project)
        VALUES (NEWID(), 100, @categoryId, @participantId, @participantId, GETDATE(), NULL);

        SET @Count = @Count + 1;
    END;

    UPDATE dbo.Payment
    SET Amount = Amount+50
    WHERE Payer = @participantId;

COMMIT TRANSACTION;

SET @EndTime = GETDATE();

SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS TotalExecutionTimeMS;

----------------------------------------------------------------------------------------------------------------------------------------

-----2.Часть анализируемой роли

-- ------Опустошите данные в таблице
DELETE FROM dbo.Payment; 
DELETE FROM dbo.PaymentParticipant; 
DELETE FROM dbo.PaymentCategory;  

---------вставить данные
DECLARE @StartTime DATETIME;
DECLARE @EndTime DATETIME;
DECLARE @Count INT = 1;

SET @StartTime = GETDATE();

BEGIN TRANSACTION;

    WHILE @Count <= 2000
    BEGIN
        DECLARE @participantId UNIQUEIDENTIFIER = NEWID();
        DECLARE @categoryId UNIQUEIDENTIFIER = NEWID();

        INSERT INTO dbo.PaymentParticipant (Oid, Name, Balance)
        VALUES (@participantId, 'Test Participant ' + CAST(@Count AS VARCHAR(10)), 0);

        INSERT INTO dbo.PaymentCategory (Oid, Name, ProfitByMaterial, CostByMaterial)
        VALUES (@categoryId, 'Test Category ' + CAST(@Count AS VARCHAR(10)), 0, 0);

        INSERT INTO dbo.Payment (Oid, Amount, Category, Payer, Payee, Date, Project)
        VALUES (NEWID(), 100, @categoryId, @participantId, @participantId, GETDATE(), NULL);

        SET @Count = @Count + 1;
    END;

COMMIT TRANSACTION;

SET @EndTime = GETDATE();

SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS TotalExecutionTimeMS;

----- ---Данные запроса
USE PaymentData;
GO

DECLARE @StartTime DATETIME, @EndTime DATETIME;

SET @StartTime = GETDATE();

SELECT TOP 1000 
    Oid, Amount, Category, Project, Justification, Comment, Date, 
    Payer, Payee, OptimisticLockField, GCRecord, CreateDate, 
    CheckNumber, IsAuthorized, Number 
FROM dbo.Payment;

SET @EndTime = GETDATE();

SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS TotalExecutionTimeMs;