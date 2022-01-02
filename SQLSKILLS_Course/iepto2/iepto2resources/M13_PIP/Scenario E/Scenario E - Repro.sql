-- Adapted from Jonathan Kehayias
-- Source: http://www.simple-talk.com/sql/database-administration/optimizing-tempdb-configuration-with-sql-server-2012-extended-events/
USE Credit;
GO

SET NOCOUNT ON;
GO

WHILE 1 = 1 
    BEGIN

        IF OBJECT_ID('tempdb..#member') IS NOT NULL 
            BEGIN
                DROP TABLE #member;
            END

        CREATE TABLE #member
        (
         [member_no] [int] NOT NULL,
         [lastname] [varchar](15) NOT NULL,
         [firstname] [varchar](15) NOT NULL,
         [middleinitial] [char](1) NULL,
         [street] [varchar](15) NOT NULL,
         [city] [varchar](15) NOT NULL,
         [state_prov] [char](2) NOT NULL,
         [country] [char](2) NOT NULL,
         [mail_code] [char](10) NOT NULL,
         [phone_no] [char](13) NULL,
         [photograph] [image] NULL,
         [issue_dt] [datetime] NOT NULL,
         [expr_dt] [datetime] NOT NULL,
         [region_no] [int] NOT NULL,
         [corp_no] [int] NULL,
         [prev_balance] [money] NULL,
         [curr_balance] [money] NULL,
         [member_code] [char](2) NOT NULL
        );


        INSERT  INTO #member
                (member_no,
                 lastname,
                 firstname,
                 middleinitial,
                 street,
                 city,
                 state_prov,
                 country,
                 mail_code,
                 phone_no,
                 photograph,
                 issue_dt,
                 expr_dt,
                 region_no,
                 corp_no,
                 prev_balance,
                 curr_balance,
                 member_code)
                SELECT TOP 100
                        member_no,
                        lastname,
                        firstname,
                        middleinitial,
                        street,
                        city,
                        state_prov,
                        country,
                        mail_code,
                        phone_no,
                        photograph,
                        issue_dt,
                        expr_dt,
                        region_no,
                        corp_no,
                        prev_balance,
                        curr_balance,
                        member_code
                FROM    dbo.member;

        SELECT  member_no
        FROM    #member;

    END 
GO