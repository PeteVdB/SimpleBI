﻿/*****       Code is generated by a tool.       *****/
CREATE TABLE [UCI].[Riders] (
    [FIT_DWH_ID] int IDENTITY(1, 1) NOT NULL,
    [Function]    NVARCHAR    NULL,
    [Last Name]    NVARCHAR    NULL,
    [First Name]    NVARCHAR    NULL,
    [Birth date]    DATETIME    NULL,
    [Birth date year]    DATETIME    NULL,
    [Birth Year]    DATETIME    NULL,
    [Gender]    NVARCHAR    NULL,
    [Category]    NVARCHAR    NULL,
    [Country]    NVARCHAR    NULL,
    [Continent]    NVARCHAR    NULL,
    [Team Code]    NVARCHAR    NULL,
    [Team Name]    NVARCHAR    NULL,
    [UCIID]    NVARCHAR    NULL,
    [CheckSum_BK] int NULL,
    [CheckSum_AllAttributes] int NULL,
    [InsertDate] datetime null DEFAULT getdate(),
    [UpdateDate] datetime null DEFAULT getdate(),
)
GO

CREATE CLUSTERED COLUMNSTORE INDEX cci_Riders ON [UCI].[Riders]
GO
