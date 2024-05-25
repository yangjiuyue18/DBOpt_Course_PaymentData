-- 开启时间统计    
SET STATISTICS TIME ON;    
-- 开启I/O统计（可选，用于查看物理I/O）    
-- SET STATISTICS IO ON;    
    
-- 插入大量数据    
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
    RowNum BETWEEN 1 AND 10000; -- 生成10,000条测试支付记录  
  
PRINT 'test insert data';         
    
DECLARE @endTime DATETIME = GETDATE();    
PRINT 'Вставка занимает(插入耗时): ' + CAST(DATEDIFF(MILLISECOND, @startTime, @endTime) / 1000.0 AS NVARCHAR) + ' s';  -- 修改这里，将毫秒数除以1000得到秒数  
    
DECLARE @TestCounter INT = 0;  
DECLARE @TotalTests INT = 2; -- 设定测试次数  
DECLARE @RandomPayer uniqueidentifier, @RandomPayee uniqueidentifier, @RandomProject uniqueidentifier;   
  
WHILE @TestCounter < @TotalTests  
BEGIN  
    -- 随机选择 Payer, Payee, 和 Project  
    SELECT TOP 1 @RandomPayer = Payer FROM dbo.Payment ORDER BY NEWID();  
    SELECT TOP 1 @RandomPayee = Payee FROM dbo.Payment WHERE Payer = @RandomPayer ORDER BY NEWID();  
    SELECT TOP 1 @RandomProject = Project FROM dbo.Payment WHERE Payer = @RandomPayer AND Payee = @RandomPayee ORDER BY NEWID();  
      
    -- 记录开始时间  
    SET @startTime = GETDATE();  
      
    -- 执行更新操作  
    UPDATE dbo.Payment  
    SET Amount = Amount + 100 -- 假设我们给符合条件的每条记录的Amount增加100  
    WHERE Payer = @RandomPayer  
      AND Payee = @RandomPayee  
      AND Project = @RandomProject;  
      
    -- 记录结束时间并打印耗时  
    SET @endTime = GETDATE();  
    PRINT 'Операция обновления занимает(更新操作耗时): ' + CAST(DATEDIFF(MILLISECOND, @startTime, @endTime) / 1000.0 AS NVARCHAR) + ' s';  
      
    -- 准备下一次循环  
    SET @TestCounter = @TestCounter + 1;  
END  
  
-- 关闭时间和I/O统计  
SET STATISTICS TIME OFF;  
-- SET STATISTICS IO OFF;