IF OBJECTPROPERTY(object_id('ChargesPT')
        , 'IsUserTable') = 1
	BEGIN
        INSERT INTO [CreditPT].[dbo].[ChargesPT]
                   ([member_no]
                   ,[provider_no]
                   ,[category_no]
                   ,[charge_dt]
                   ,[charge_amt]
                   ,[statement_no]
                   ,[charge_code])
        SELECT
            (SELECT member_no 
                FROM member 
                WHERE ISNULL(NULLIF((datepart(ms, (getdate()))) * 100 % 10000, 0), 1) = member_no)
             ,(SELECT provider_no 
                FROM provider 
                WHERE ISNULL(NULLIF((datepart(ms, (getdate()))) * 10 % 500, 0), 1) = provider_no)
             ,(SELECT category_no 
                FROM category 
                WHERE ISNULL(NULLIF((datepart(ms, (getdate()))) % 10 , 0), 1) = category_no)
             , '20041001'
             , datepart(ms, getdate())
             ,1
             ,'AB'
		SELECT @@IDENTITY AS 'ChargeNo Added'
	END
ELSE
	BEGIN
		RAISERROR('The Charges object does not exist.', 16, 1)
	END