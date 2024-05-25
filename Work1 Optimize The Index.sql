-- ������������ [ix_Payment_Payer_Payee_Project] ���� Payer��Payee �� Project ��
CREATE NONCLUSTERED INDEX ix_Payment_Payer_Payee_Project
ON dbo.Payment (Payer, Payee, Project)
INCLUDE (Amount, Category, Justification, Comment, Date)
ON [PRIMARY]

-- ɾ���������� iCategory_Payment��iGCRecord_Payment��iPayee_Payment��iPayer_Payment��iProject_Payment
DROP INDEX iCategory_Payment ON dbo.Payment
DROP INDEX iGCRecord_Payment ON dbo.Payment
DROP INDEX iPayee_Payment ON dbo.Payment
DROP INDEX iPayer_Payment ON dbo.Payment
DROP INDEX iProject_Payment ON dbo.Payment