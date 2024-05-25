-- ����ʱ��ͳ��    
SET STATISTICS TIME ON;     
    
-- �����������    
DECLARE @startTime DATETIME = GETDATE();    
-- Insert Payment data
PRINT 'Start Insert Payment data';
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
    RowNum BETWEEN 1 AND 40000; -- ����40,000������֧����¼  
  
PRINT 'test insert data';         
    
DECLARE @endTime DATETIME = GETDATE();    
PRINT '�����ѧӧܧ� �٧ѧߧڧާѧ֧�(�����ʱ): ' + CAST(DATEDIFF(MILLISECOND, @startTime, @endTime) / 1000.0 AS NVARCHAR) + ' s';  -- �޸����������������1000�õ����� 