USE PaymentData;
GO

-- Insert AccountType data
INSERT INTO dbo.AccountType (Oid, Name, OptimisticLockField, GCRecord)
VALUES 
(NEWID(), 'Basic Account', 0, NULL),
(NEWID(), 'Advanced Account', 0, NULL),
(NEWID(), 'Temporary Account', 0, NULL),
(NEWID(), 'Permanent Account', 0, NULL),
(NEWID(), 'Premium Account', 0, NULL),  
(NEWID(), 'Enterprise Account', 0, NULL),  
(NEWID(), 'Trial Account', 0, NULL),  
(NEWID(), 'Non-Profit Account', 0, NULL),  
(NEWID(), 'Educational Account', 0, NULL),  
(NEWID(), 'Government Account', 0, NULL),  
(NEWID(), 'Developer Account', 0, NULL),  
(NEWID(), 'Reseller Account', 0, NULL),  
(NEWID(), 'Affiliate Account', 0, NULL),  
(NEWID(), 'VIP Account', 0, NULL);

-- Insert PaymentParticipant data
DECLARE @i int = 1;
DECLARE @ppOid UNIQUEIDENTIFIER;
DECLARE @atOid UNIQUEIDENTIFIER = (SELECT TOP 1 Oid FROM dbo.AccountType ORDER BY NEWID());
WHILE @i <= 20000
BEGIN
    SET @ppOid = NEWID();
    INSERT INTO dbo.PaymentParticipant (Oid, Balance, Name, OptimisticLockField, GCRecord, ObjectType, ActiveFrom, InactiveFrom, BankDetails)
    VALUES (@ppOid, 1000 * (@i % 10), 'Participant ' + CAST(@i AS NVARCHAR(10)), 0, NULL, @i % 4, DATEADD(DAY, -(@i % 365), GETDATE()), NULL, 'Bank details ' + CAST(@i AS NVARCHAR(10)));

    -- Insert Employee data
    INSERT INTO dbo.Employee (Oid, SecondName, BusyUntil, Stuff, HourPrice, Patronymic, PlanfixId)
    VALUES (@ppOid, 'Employee ' + CAST(@i AS NVARCHAR(10)), DATEADD(DAY, 365, GETDATE()), @i, 100 * (@i % 10), 'Middle Name ' + CAST(@i AS NVARCHAR(10)), @i);

    -- Insert Client data
    INSERT INTO dbo.Client (Oid, FirstName, SecondName, Phone)
    VALUES (@ppOid, 'Client ' + CAST(@i AS NVARCHAR(10)), 'Surname ' + CAST(@i AS NVARCHAR(10)), 'Phone ' + CAST(@i AS NVARCHAR(15)));

    -- Insert Supplier data
    INSERT INTO dbo.Supplier (Oid, Contact, ProfitByMaterialAsPayer, ProfitByMaterialAsPayee, CostByMaterialAsPayer)
    VALUES (@ppOid, 'Contact ' + CAST(@i AS NVARCHAR(10)), 1, 0, 1);

    -- Insert Bank data
    INSERT INTO dbo.Bank (Oid, AccountType)
    VALUES (@ppOid, @atOid);

    -- Insert Cashbox data
    INSERT INTO dbo.Cashbox (Oid, AccountType)
    VALUES (@ppOid, @atOid);

    SET @i = @i + 1;
END

-- Insert Project data  -- use gpt
;WITH Numbers AS (  
    SELECT  
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum  
    FROM  
        master.sys.all_objects  
    CROSS JOIN  
        master.sys.all_objects AS Objects2  
)  
INSERT INTO dbo.Project (Oid, Name, Address, Client, Manager, Foreman, OptimisticLockField, GCRecord, Balance, BalanceByMaterial, BalanceByWork, PlaningStartDate, Status, FinishDate, Area, WorkPriceRate, WorkersPriceRate)  
SELECT  
    NEWID(),  
    'Project ' + CAST(RowNum AS NVARCHAR(10)),  
    'Address ' + CAST(RowNum AS NVARCHAR(10)),  
    (SELECT TOP 1 Oid FROM dbo.Client ORDER BY NEWID()),  
    (SELECT TOP 1 Oid FROM dbo.Employee ORDER BY NEWID()),  
    (SELECT TOP 1 Oid FROM dbo.Employee ORDER BY NEWID()),  
    0, NULL,  
    10000 * (RowNum % 10),  
    5000 * (RowNum % 10),  
    3000 * (RowNum % 10),  
    DATEADD(DAY, RowNum % 365, GETDATE()),  
    RowNum % 5,  
    DATEADD(DAY, RowNum + 30, GETDATE()),  
    100 + RowNum,  
    10.0,  
    15.0  
FROM  
    Numbers  
WHERE  
    RowNum BETWEEN 1 AND 10000; -- Generating 10,000 test projects, adjust as needed  

-- Insert PaymentCategory data --use gpt
INSERT INTO dbo.PaymentCategory (Oid, Name, OptimisticLockField, GCRecord, ProfitByMaterial, CostByMaterial)
VALUES 
(NEWID(), 'Material Costs', 0, NULL, 1, 0),
(NEWID(), 'Labor Costs', 0, NULL, 0, 1),
(NEWID(), 'Overhead Costs', 0, NULL, 0, 0),    -- 间接费用  
(NEWID(), 'Marketing and Advertising', 0, NULL, 0, 0),    -- 市场营销和广告费用  
(NEWID(), 'Shipping and Handling', 0, NULL, 0, 1),    -- 运输和处理费用  
(NEWID(), 'Taxes and Fees', 0, NULL, 0, 1),    -- 税费  
(NEWID(), 'Research and Development', 0, NULL, 0, 1),    -- 研发成本  
(NEWID(), 'Rent and Utilities', 0, NULL, 0, 1);    -- 租金和公共设施费用;

-- Insert Payment data  
;WITH Numbers AS (    
    SELECT    
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum    
    FROM    
        master.sys.all_objects    
    CROSS JOIN    
        master.sys.all_objects AS Objects2    
    CROSS JOIN    
        master.sys.all_objects AS Objects3  -- 如果需要更多行，可以再加CROSS JOIN  
)    
INSERT INTO dbo.Payment (Oid, Amount, Category, Project, Payer, Payee, Date, OptimisticLockField, GCRecord)  
SELECT    
    NEWID(),    
    1000 * (RowNum % 100),    
    (SELECT TOP 1 Oid FROM dbo.PaymentCategory ORDER BY NEWID()),    
    (SELECT TOP 1 Oid FROM dbo.Project ORDER BY NEWID()),    
    (SELECT TOP 1 Oid FROM dbo.PaymentParticipant ORDER BY NEWID()),    
    (SELECT TOP 1 Oid FROM dbo.PaymentParticipant ORDER BY NEWID()),    
    DATEADD(DAY, -(RowNum % 365), GETDATE()),    
    0,    
    NULL    
FROM    
    Numbers    
WHERE    
    RowNum BETWEEN 1 AND 40000; -- 生成40,000条测试支付记录  
  
PRINT 'Test data insertion completed';  
GO