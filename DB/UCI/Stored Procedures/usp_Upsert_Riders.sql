CREATE PROCEDURE [UCI].[usp_Upsert_Riders]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @StartDate DATETIME = getdate()
	DECLARE @RowsUpdated INT = 0
	DECLARE @RowsInserted INT = 0
	DECLARE @RowsDeleted INT = 0
	DECLARE @ErrorMessage NVARCHAR(4000)

	BEGIN TRY

		INSERT INTO [Logging].[Process] (
			StartDate
			,[DBName]
			,[ObjectName]
			,[Action]
			)
		SELECT @StartDate AS StartDate
			,db_name() AS DBName
			,OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID) AS ObjectName
			,'Start' AS [Action]

		IF OBJECT_ID('tempdb..#tmp_Riders') IS NOT NULL
			DROP TABLE #tmp_Riders;

		WITH LZ
		AS (
			SELECT [FIT_DWH_ID] AS LZ_id
				,BINARY_CHECKSUM([Function], [Last Name], [First Name], [Birth date], [Birth date year], [Birth Year], [Gender], [Category], [Country], [Continent], [Team Code], [Team Name], [UCIID]) AS LZ_CheckSum_BK
				,BINARY_CHECKSUM([Function], [Last Name], [First Name], [Birth date], [Birth date year], [Birth Year], [Gender], [Category], [Country], [Continent], [Team Code], [Team Name], [UCIID]) AS LZ_CheckSum_AllAttributes
				,[Function], [Last Name], [First Name], [Birth date], [Birth date year], [Birth Year], [Gender], [Category], [Country], [Continent], [Team Code], [Team Name], [UCIID]
			FROM [LZ_UCI].[Riders]
			)
		SELECT LZ.LZ_id
			,LZ.LZ_CheckSum_BK
			,LZ.LZ_CheckSum_AllAttributes
			,ST.FIT_DWH_ID AS ST_id
			,ST.CheckSum_BK AS ST_CheckSum_BK
			,ST.CheckSum_AllAttributes AS ST_CheckSum_AllAttributes
		INTO #tmp_Riders
		FROM LZ
		FULL OUTER JOIN [UCI].[Riders] ST ON Lz.LZ_CheckSum_BK = ST.CheckSum_BK
        AND LZ.[Function] = ST.[Function]
AND LZ.[Last Name] = ST.[Last Name]
AND LZ.[First Name] = ST.[First Name]
AND LZ.[Birth date] = ST.[Birth date]
AND LZ.[Birth date year] = ST.[Birth date year]
AND LZ.[Birth Year] = ST.[Birth Year]
AND LZ.[Gender] = ST.[Gender]
AND LZ.[Category] = ST.[Category]
AND LZ.[Country] = ST.[Country]
AND LZ.[Continent] = ST.[Continent]
AND LZ.[Team Code] = ST.[Team Code]
AND LZ.[Team Name] = ST.[Team Name]
AND LZ.[UCIID] = ST.[UCIID]

		-- new records => insert
		INSERT INTO [UCI].[Riders] (
			[Function], [Last Name], [First Name], [Birth date], [Birth date year], [Birth Year], [Gender], [Category], [Country], [Continent], [Team Code], [Team Name], [UCIID]
			,[CheckSum_BK]
			,[CheckSum_AllAttributes]
			)
		SELECT [Function], [Last Name], [First Name], [Birth date], [Birth date year], [Birth Year], [Gender], [Category], [Country], [Continent], [Team Code], [Team Name], [UCIID]
			,LZ_CheckSum_BK
			,LZ_CheckSum_AllAttributes
		FROM #tmp_Riders T
		JOIN [LZ_UCI].[Riders] LZ WITH (TABLOCKX) ON T.LZ_id = LZ.[FIT_DWH_ID]
		WHERE ST_CheckSum_BK IS NULL

		SELECT @RowsInserted = @@ROWCOUNT

		-- changed rows => update
		UPDATE ST
		SET [Function] = LZ.[Function], [Last Name] = LZ.[Last Name], [First Name] = LZ.[First Name], [Birth date] = LZ.[Birth date], [Birth date year] = LZ.[Birth date year], [Birth Year] = LZ.[Birth Year], [Gender] = LZ.[Gender], [Category] = LZ.[Category], [Country] = LZ.[Country], [Continent] = LZ.[Continent], [Team Code] = LZ.[Team Code], [Team Name] = LZ.[Team Name], [UCIID] = LZ.[UCIID]
			,CheckSum_BK = T.LZ_CheckSum_BK
			,CheckSum_AllAttributes = T.LZ_CheckSum_AllAttributes
			,UpdateDate = @StartDate
		FROM #tmp_Riders T
		JOIN [LZ_UCI].[Riders] LZ ON T.LZ_id = LZ.[FIT_DWH_ID]
		JOIN [UCI].[Riders] ST ON T.ST_id = ST.[FIT_DWH_ID]
		WHERE T.LZ_CheckSum_AllAttributes <> T.ST_CheckSum_AllAttributes

		SELECT @RowsUpdated = @@ROWCOUNT

		--Rows not in source -> delete
		DELETE ST 
		FROM [UCI].[Riders] ST WITH (TABLOCKX)
		JOIN #tmp_Riders T on ST.FIT_DWH_ID = T.ST_id
		WHERE T.LZ_id IS NULL

		SELECT @RowsDeleted = @@ROWCOUNT

		INSERT INTO [Logging].[Process] (
			StartDate
			,[DBName]
			,[ObjectName]
			,[Action]
			,[RowsInserted]
			,[RowsUpdated]
			,[RowsDeleted]
			)
		SELECT @StartDate AS StartDate
			,db_name() AS DBName
			,OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID) AS ObjectName
			,'Stop' AS [Action]
			,@RowsInserted AS RowsInserted
			,@RowsUpdated AS RowsUpdated
			,@RowsDeleted AS RowsDeleted

	END TRY

	BEGIN CATCH

		SELECT @ErrorMessage = N'Error occured during [UCI].[usp_Upsert_Riders]. Message: ' + ERROR_MESSAGE();

		INSERT INTO [Logging].[Process] (
			StartDate
			,[DBName]
			,[ObjectName]
			,[Action]
			,[Message]
			)
		SELECT @StartDate AS StartDate
			,db_name() AS DBName
			,OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID) AS ObjectName
			,'Error' AS [Action]
			,ERROR_MESSAGE() AS Message;

		THROW;
	END CATCH
END
