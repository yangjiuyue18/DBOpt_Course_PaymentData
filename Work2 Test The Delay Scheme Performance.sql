-- 开启时间统计    
SET STATISTICS TIME ON;     
    
-- 插入大量数据    
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
  
PRINT 'test insert data';         
    
DECLARE @endTime DATETIME = GETDATE();    
PRINT 'Вставка занимает(插入耗时): ' + CAST(DATEDIFF(MILLISECOND, @startTime, @endTime) / 1000.0 AS NVARCHAR) + ' s';  -- 修改这里，将毫秒数除以1000得到秒数 