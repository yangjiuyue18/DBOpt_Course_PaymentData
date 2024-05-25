IF DB_NAME() <> N'PaymentData' SET NOEXEC ON;
GO

-- 创建登录名和用户
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'OperatorLogin')
    CREATE LOGIN OperatorLogin WITH PASSWORD = 'StrongPassword1!';
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'AnalystLogin')
    CREATE LOGIN AnalystLogin WITH PASSWORD = 'StrongPassword2!';
GO

USE PaymentData;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'OperatorUser')
    CREATE USER OperatorUser FOR LOGIN OperatorLogin;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'AnalystUser')
    CREATE USER AnalystUser FOR LOGIN AnalystLogin;
GO

-- 创建角色 Создайте персонажа
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Operator')
    CREATE ROLE Operator;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Analyst')
    CREATE ROLE Analyst;
GO

-- 为角色分配权限 Назначение разрешений ролям
GRANT INSERT, UPDATE, DELETE ON dbo.Payment TO Operator;
GRANT SELECT ON dbo.Payment TO Analyst;
GRANT SELECT ON dbo.PaymentParticipant TO Analyst;
GO

-- 将用户添加到角色  Создайте персонажа
ALTER ROLE Operator ADD MEMBER OperatorUser;
ALTER ROLE Analyst ADD MEMBER AnalystUser;
GO

-- 创建 BalanceChanges 表 Создание таблицы BalanceChanges
IF OBJECT_ID(N'dbo.BalanceChanges', 'U') IS NULL
CREATE TABLE dbo.BalanceChanges (
  ChangeID INT IDENTITY(1,1) PRIMARY KEY,
  PaymentID uniqueidentifier NOT NULL,
  OldBalance INT NULL,
  NewBalance INT NULL,
  ChangeDate DATETIME DEFAULT GETDATE()
);
GO

/*
"chatgpt" используется при создании триггеров и при создании хранимой 
процедуры updataBalances table, с предложением ввести в базу данных две роли и дать 
решение для отсрочки расчета остатков.
*/


-- 创建触发器记录变更数据 Создание триггеров для записи измененных данных
IF OBJECT_ID(N'dbo.trg_payment_insert', 'TR') IS NULL
EXEC sp_executesql N'CREATE OR ALTER TRIGGER trg_payment_insert
ON dbo.Payment
AFTER INSERT
AS
BEGIN
  INSERT INTO dbo.BalanceChanges (PaymentID, OldBalance, NewBalance)
  SELECT i.Oid, NULL, NULL -- 修改为正确的列名或去掉此处
  FROM inserted i;
END';
GO

IF OBJECT_ID(N'dbo.trg_payment_update', 'TR') IS NULL
EXEC sp_executesql N'CREATE OR ALTER TRIGGER trg_payment_update
ON dbo.Payment
AFTER UPDATE
AS
BEGIN
  INSERT INTO dbo.BalanceChanges (PaymentID, OldBalance, NewBalance)
  SELECT i.Oid, NULL, NULL -- 修改为正确的列名或去掉此处
  FROM inserted i
  JOIN deleted d ON i.Oid = d.Oid;
END';
GO

-- 创建存储过程 UpdateBalances  Создайте процедуру UpdateBalances
IF OBJECT_ID(N'dbo.UpdateBalances', 'P') IS NULL
EXEC sp_executesql N'CREATE OR ALTER PROCEDURE dbo.UpdateBalances
AS
BEGIN
  UPDATE dbo.PaymentParticipant
  SET Balance = (SELECT SUM(Amount) FROM dbo.Payment WHERE Payee = PaymentParticipant.Oid)
  WHERE Oid IN (SELECT DISTINCT Payee FROM dbo.Payment);

  UPDATE dbo.PaymentParticipant
  SET Balance = (SELECT SUM(Amount) FROM dbo.Payment WHERE Payer = PaymentParticipant.Oid)
  WHERE Oid IN (SELECT DISTINCT Payer FROM dbo.Payment);
END';
GO

-- 安排定时任务 UpdateBalancesJob  Планирование задач по времени UpdateBalancesJob
USE msdb;
GO

IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'UpdateBalancesJob')
BEGIN
  EXEC sp_add_job @job_name = N'UpdateBalancesJob', @enabled = 1, @description = N'Job to update balances periodically';
  EXEC sp_add_jobstep @job_name = N'UpdateBalancesJob', @step_name = N'Step1', @subsystem = N'TSQL', @command = N'EXEC PaymentData.dbo.UpdateBalances';
  EXEC sp_add_schedule @job_name = N'UpdateBalancesJob', @name = N'DailySchedule', @freq_type = 4, @freq_interval = 1, @active_start_time = 010000;
  EXEC sp_attach_schedule @job_name = N'UpdateBalancesJob', @schedule_name = N'DailySchedule';
  EXEC sp_add_jobserver @job_name = N'UpdateBalancesJob', @server_name = @@SERVERNAME;
END;
GO

-- 启动定时任务 Запуск задания с таймером
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs_view WHERE name = N'UpdateBalancesJob' AND enabled = 1)
BEGIN
  EXEC msdb.dbo.sp_start_job @job_name = N'UpdateBalancesJob';
END;
GO
