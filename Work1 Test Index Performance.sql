-- ����ʱ��ͳ��    
SET STATISTICS TIME ON;    
-- ����I/Oͳ�ƣ���ѡ�����ڲ鿴����I/O��    
-- SET STATISTICS IO ON;    
    
-- �����������    
DECLARE @startTime DATETIME = GETDATE();    
-- Insert Payment data  
;WITH Numbers AS (    
    SELECT    
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum    
    FROM    
        master.sys.all_objects    
    CROSS JOIN    
        master.sys.all_objects AS Objects2    
    CROSS JOIN    
        master.sys.all_objects AS Objects3  -- �����Ҫ�����У������ټ�CROSS JOIN  
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
    RowNum BETWEEN 1 AND 10000; -- ����10,000������֧����¼  
  
PRINT 'test insert data';         
    
DECLARE @endTime DATETIME = GETDATE();    
PRINT '�����ѧӧܧ� �٧ѧߧڧާѧ֧�(�����ʱ): ' + CAST(DATEDIFF(MILLISECOND, @startTime, @endTime) / 1000.0 AS NVARCHAR) + ' s';  -- �޸����������������1000�õ�����  
    
DECLARE @TestCounter INT = 0;  
DECLARE @TotalTests INT = 2; -- �趨���Դ���  
DECLARE @RandomPayer uniqueidentifier, @RandomPayee uniqueidentifier, @RandomProject uniqueidentifier;   
  
WHILE @TestCounter < @TotalTests  
BEGIN  
    -- ���ѡ�� Payer, Payee, �� Project  
    SELECT TOP 1 @RandomPayer = Payer FROM dbo.Payment ORDER BY NEWID();  
    SELECT TOP 1 @RandomPayee = Payee FROM dbo.Payment WHERE Payer = @RandomPayer ORDER BY NEWID();  
    SELECT TOP 1 @RandomProject = Project FROM dbo.Payment WHERE Payer = @RandomPayer AND Payee = @RandomPayee ORDER BY NEWID();  
      
    -- ��¼��ʼʱ��  
    SET @startTime = GETDATE();  
      
    -- ִ�и��²���  
    UPDATE dbo.Payment  
    SET Amount = Amount + 100 -- �������Ǹ�����������ÿ����¼��Amount����100  
    WHERE Payer = @RandomPayer  
      AND Payee = @RandomPayee  
      AND Project = @RandomProject;  
      
    -- ��¼����ʱ�䲢��ӡ��ʱ  
    SET @endTime = GETDATE();  
    PRINT '����֧�ѧ�ڧ� ��ҧߧ�ӧݧ֧ߧڧ� �٧ѧߧڧާѧ֧�(���²�����ʱ): ' + CAST(DATEDIFF(MILLISECOND, @startTime, @endTime) / 1000.0 AS NVARCHAR) + ' s';  
      
    -- ׼����һ��ѭ��  
    SET @TestCounter = @TestCounter + 1;  
END  
  
-- �ر�ʱ���I/Oͳ��  
SET STATISTICS TIME OFF;  
-- SET STATISTICS IO OFF;