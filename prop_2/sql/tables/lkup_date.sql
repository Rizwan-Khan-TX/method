CREATE TABLE dw.lkup_date(
    Date_Key                           INT             CONSTRAINT PK_Date Primary Key,
    Full_Date                          DATE            NULL,
    Day_Nbr                            INT             NULL,
    Day_of_the_Week                    VARCHAR(2)      NULL,
    Day_of_the_Month                   VARCHAR(2)      NULL,
    Day_of_the_Quarter                 VARCHAR(2)      NULL,
    Day_of_the_Year                    VARCHAR(3)      NULL,
    Day_Name                           VARCHAR(30)     NULL,
    Day_Short_Name                     VARCHAR(3)      NULL,
    Week_Nbr                           INT             NULL,
    Week_of_the_Month                  VARCHAR(2)      NULL,
    Week_of_the_Quarter                VARCHAR(2)      NULL,
    Week_of_the_Year                   VARCHAR(2)      NULL,
    Week_Begin_Date                    DATE            NULL,
    Week_End_Date                      DATE            NULL,
    Month_Nbr                          INT             NULL,
    Month_of_the_Quarter               VARCHAR(2)      NULL,
    Month_of_the_Year                  VARCHAR(2)      NULL,
    Month_Name                         VARCHAR(30)     NULL,
    Month_Short_Name                   VARCHAR(3)      NULL,
    Quarter_Nbr                        INT             NULL,
    Quarter_of_the_Year                VARCHAR(2)      NULL,
    Quarter_Name                       VARCHAR(3)      NULL,
    Year_Nbr                           INT             NULL,
    Is_Weekend                         BIT             NULL,
    MMYYYY                             VARCHAR(6)      NULL)
GO


INSERT dw.lkup_date (
    Date_Key,
    Full_Date,
    Day_Nbr,
    Day_of_the_Week,
    Day_of_the_Month,
    Day_of_the_Quarter,
    Day_of_the_Year,
    Day_Name,
    Day_Short_Name,
    Week_Nbr,
    Week_of_the_Month,
    Week_of_the_Quarter,
    Week_of_the_Year,
    Week_Begin_Date,
    Week_End_Date,
    Month_Nbr,
    Month_of_the_Quarter,
    Month_of_the_Year,
    Month_Name,
    Month_Short_Name,
    Quarter_Nbr,
    Quarter_of_the_Year,
    Quarter_Name,
    Year_Nbr,
    Is_Weekend,
    MMYYYY)
VALUES
(     '0'            -- Date_Key
    ,'1900-01-01'    -- Full_Date
    ,'1'             -- Day_Nbr
    ,'1'             -- Day_of_the_Week
    ,'01'            -- Day_of_the_Month
    ,'01'            -- Day_of_the_Quarter
    ,'001'           -- Day_of_the_Year
    ,'Monday'        -- Day_Name
    ,'Mon'           -- Day_Short_Name
    ,'1'             -- Week_Nbr
    ,'01'            -- Week_of_the_Month
    ,'01'            -- Week_of_the_Quarter
    ,'01'            -- Week_of_the_Year
    ,'1899-12-31'    -- Week_Begin_Date
    ,'1900-01-06'    -- Week_End_Date
    ,'1'             -- Month_Nbr
    ,'01'            -- Month_of_the_Quarter
    ,'01'            -- Month_of_the_Year
    ,'January'       -- Month_Name
    ,'Jan'           -- Month_Short_Name
    ,'1'             -- Quarter_Nbr
    ,'01'            -- Quarter_of_the_Year
    ,'Q01'           -- Quarter_Name
    ,'1900'          -- Year_Nbr
    ,'0'             -- Is_Weekend
    ,'011900'        -- MMYYYY
    );
GO

INSERT dw.lkup_date (
    Date_Key,
    Full_Date,
    Day_Nbr,
    Day_of_the_Week,
    Day_of_the_Month,
    Day_of_the_Quarter,
    Day_of_the_Year,
    Day_Name,
    Day_Short_Name,
    Week_Nbr,
    Week_of_the_Month,
    Week_of_the_Quarter,
    Week_of_the_Year,
    Week_Begin_Date,
    Week_End_Date,
    Month_Nbr,
    Month_of_the_Quarter,
    Month_of_the_Year,
    Month_Name,
    Month_Short_Name,
    Quarter_Nbr,
    Quarter_of_the_Year,
    Quarter_Name,
    Year_Nbr,
    Is_Weekend,
    MMYYYY)
VALUES
(     '19000101'     -- Date_Key
    ,'1900-01-01'    -- Full_Date
    ,'1'             -- Day_Nbr
    ,'1'             -- Day_of_the_Week
    ,'01'            -- Day_of_the_Month
    ,'01'            -- Day_of_the_Quarter
    ,'001'           -- Day_of_the_Year
    ,'Monday'        -- Day_Name
    ,'Mon'           -- Day_Short_Name
    ,'1'             -- Week_Nbr
    ,'01'            -- Week_of_the_Month
    ,'01'            -- Week_of_the_Quarter
    ,'01'            -- Week_of_the_Year
    ,'1899-12-31'    -- Week_Begin_Date
    ,'1900-01-06'    -- Week_End_Date
    ,'1'             -- Month_Nbr
    ,'01'            -- Month_of_the_Quarter
    ,'01'            -- Month_of_the_Year
    ,'January'       -- Month_Name
    ,'Jan'           -- Month_Short_Name
    ,'1'             -- Quarter_Nbr
    ,'01'            -- Quarter_of_the_Year
    ,'Q01'           -- Quarter_Name
    ,'1900'          -- Year_Nbr
    ,'0'             -- Is_Weekend
    ,'011900'        -- MMYYYY
    );
GO

Declare @Date DateTime =Convert(Date,Getdate())
    ;With A as (
        SELECT  Top 50000 Row_Number() Over (Order by A.Name) RN
        FROM    sys.objects A, sys.objects B)
    ,C as (
        SELECT   DateAdd(d,(A.RN)*-1,@Date) DD
        FROM     A
        Union
        SELECT   @Date
        Union
        SELECT   DateAdd(d,(A.RN)*1,@Date)
        FROM     A)
    ,D as(
        SELECT   Date_Key              =Convert(varchar,DD,112)
                ,Full_Date             =Convert(date,DD)
                ,Day_Nbr               =DatePart(dd,DD)     -- e.g., '01', '02', '31'
                ,Day_of_the_Week       =Right(1000+DatePart(dw,DD),2)
                ,Day_of_the_Month      =Right(1000+DatePart(dd,DD),2)
                ,Day_of_the_Quarter    =Right(1000+datediff(d,DateAdd(q,DatePart(qq,DD)-1,Convert(date,Concat(year(DD),'-01-01'))),DD)+1,2)
                ,Day_of_the_Year       =Right(1000+DatePart(dy,DD),3)
                ,Day_Name              =DateName(dw,DD)
                ,Day_Short_Name        =Left(DateName(dw,DD),3)
                ,Week_Nbr              =DatePart(wk,DD)
                ,Week_of_the_Month     =Right(1000+datediff(wk,DateAdd(mm,DatePart(mm,DD)-1,Convert(date,Concat(year(DD),'-01-01'))),DD)+1,2)
                ,Week_of_the_Quarter   =Right(1000+datediff(wk,DateAdd(qq,DatePart(qq,DD)-1,Convert(date,Concat(year(DD),'-01-01'))),DD)+1,2)
                ,Week_of_the_Year      =Right(1000+DatePart(week,DD),2)
                ,Week_Begin_Date       =Convert(date,DateAdd(d, DatePart(dw,DD)*-1, DD)+1)
                ,Week_End_Date         =Convert(date,DateAdd(d, DatePart(dw,DD)*-1, DD)+7)
                ,Month_Nbr             =DatePart(mm,DD)
                ,Month_of_the_Quarter  =Right(1000+datediff(mm,DateAdd(qq,DatePart(qq,DD)-1,Convert(date,Concat(year(DD),'-01-01'))),DD)+1,2)
                ,Month_of_the_Year     =Right(1000+DatePart(mm,DD),2)
                ,Month_Name            =DateName(mm,DD)
                ,Month_Short_Name      =Left(DateName(mm,DD),3)
                ,Quarter_Nbr           =DatePart(qq,DD)
                ,Quarter_of_the_Year   =Right(1000+DatePart(qq,DD),2)
                ,Quarter_Name          =Concat('Q', Right(1000+DatePart(qq,DD),2))
                ,Year_Nbr              =DatePart(yy,DD)
                ,Is_Weekend            =Case When DatePart(dw,DD) in (7,1) then 1 Else 0 End
                ,MMYYYY                =Replace(Right(Convert(varchar,DD,103),7),'/','')
        FROM C
        Where DD>'1990-01-01')
        MERGE DW.lkup_Date AS tgt
        USING D as src
        On    Tgt.Date_Key=Src.Date_Key
    WHEN NOT MATCHED by TARGET
    THEN
        INSERT (
                Date_Key
                ,Full_Date
                ,Day_Nbr
                ,Day_of_the_Week
                ,Day_of_the_Month
                ,Day_of_the_Quarter
                ,Day_of_the_Year
                ,Day_Name
                ,Day_Short_Name
                ,Week_Nbr
                ,Week_of_the_Month
                ,Week_of_the_Quarter
                ,Week_of_the_Year
                ,Week_Begin_Date
                ,Week_End_Date
                ,Month_Nbr
                ,Month_of_the_Quarter
                ,Month_of_the_Year
                ,Month_Name
                ,Month_Short_Name
                ,Quarter_Nbr
                ,Quarter_of_the_Year
                ,Quarter_Name
                ,Year_Nbr
                ,Is_Weekend
                ,MMYYYY)
        Values(
                Src.Date_Key
                ,Src.Full_Date
                ,Src.Day_Nbr
                ,Src.Day_of_the_Week
                ,Src.Day_of_the_Month
                ,Src.Day_of_the_Quarter
                ,Src.Day_of_the_Year
                ,Src.Day_Name
                ,Src.Day_Short_Name
                ,Src.Week_Nbr
                ,Src.Week_of_the_Month
                ,Src.Week_of_the_Quarter
                ,Src.Week_of_the_Year
                ,Src.Week_Begin_Date
                ,Src.Week_End_Date
                ,Src.Month_Nbr
                ,Src.Month_of_the_Quarter
                ,Src.Month_of_the_Year
                ,Src.Month_Name
                ,Src.Month_Short_Name
                ,Src.Quarter_Nbr
                ,Src.Quarter_of_the_Year
                ,Src.Quarter_Name
                ,Src.Year_Nbr
                ,Src.Is_Weekend
                ,Src.MMYYYY);