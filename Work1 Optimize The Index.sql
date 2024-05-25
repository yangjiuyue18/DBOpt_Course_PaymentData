-- 创建联合索引 [ix_Payment_Payer_Payee_Project] 包含 Payer、Payee 和 Project 列
CREATE NONCLUSTERED INDEX ix_Payment_Payer_Payee_Project
ON dbo.Payment (Payer, Payee, Project)
INCLUDE (Amount, Category, Justification, Comment, Date)
ON [PRIMARY]

-- 删除单列索引 iCategory_Payment、iGCRecord_Payment、iPayee_Payment、iPayer_Payment、iProject_Payment
DROP INDEX iCategory_Payment ON dbo.Payment
DROP INDEX iGCRecord_Payment ON dbo.Payment
DROP INDEX iPayee_Payment ON dbo.Payment
DROP INDEX iPayer_Payment ON dbo.Payment
DROP INDEX iProject_Payment ON dbo.Payment