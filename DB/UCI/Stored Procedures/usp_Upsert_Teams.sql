CREATE PROCEDURE [UCI].[usp_Upsert_Teams]
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

		IF OBJECT_ID('tempdb..#tmp_Teams') IS NOT NULL
			DROP TABLE #tmp_Teams;

		WITH LZ
		AS (
			SELECT [FIT_DWH_ID] AS LZ_id
				,BINARY_CHECKSUM([Code], [Name], [Team Category], [Country], [Continent], [Format], [Email], [Website]) AS LZ_CheckSum_BK
				,BINARY_CHECKSUM([Code], [Name], [Team Category], [Country], [Continent], [Format], [Email], [Website]) AS LZ_CheckSum_AllAttributes
				,[Code], [Name], [Team Category], [Country], [Continent], [Format], [Email], [Website]
			FROM [LZ_UCI].[Teams]
			)
		SELECT LZ.LZ_id
			,LZ.LZ_CheckSum_BK
			,LZ.LZ_CheckSum_AllAttributes
			,ST.FIT_DWH_ID AS ST_id
			,ST.CheckSum_BK AS ST_CheckSum_BK
			,ST.CheckSum_AllAttributes AS ST_CheckSum_AllAttributes
		INTO #tmp_Teams
		FROM LZ
		FULL OUTER JOIN [UCI].[Teams] ST ON Lz.LZ_CheckSum_BK = ST.CheckSum_BK
        AND LZ.[Code] = ST.[Code]
AND LZ.[Name] = ST.[Name]
AND LZ.[Team Category] = ST.[Team Category]
AND LZ.[Country] = ST.[Country]
AND LZ.[Continent] = ST.[Continent]
AND LZ.[Format] = ST.[Format]
AND LZ.[Email] = ST.[Email]
AND LZ.[Website] = ST.[Website]

		-- new records => insert
		INSERT INTO [UCI].[Teams] (
			[Code], [Name], [Team Category], [Country], [Continent], [Format], [Email], [Website]
			,[CheckSum_BK]
			,[CheckSum_AllAttributes]
			)
		SELECT [Code], [Name], [Team Category], [Country], [Continent], [Format], [Email], [Website]
			,LZ_CheckSum_BK
			,LZ_CheckSum_AllAttributes
		FROM #tmp_Teams T
		JOIN [LZ_UCI].[Teams] LZ WITH (TABLOCKX) ON T.LZ_id = LZ.[FIT_DWH_ID]
		WHERE ST_CheckSum_BK IS NULL

		SELECT @RowsInserted = @@ROWCOUNT

		-- changed rows => update
		UPDATE ST
		SET [Code] = LZ.[Code], [Name] = LZ.[Name], [Team Category] = LZ.[Team Category], [Country] = LZ.[Country], [Continent] = LZ.[Continent], [Format] = LZ.[Format], [Email] = LZ.[Email], [Website] = LZ.[Website]
			,CheckSum_BK = T.LZ_CheckSum_BK
			,CheckSum_AllAttributes = T.LZ_CheckSum_AllAttributes
			,UpdateDate = @StartDate
		FROM #tmp_Teams T
		JOIN [LZ_UCI].[Teams] LZ ON T.LZ_id = LZ.[FIT_DWH_ID]
		JOIN [UCI].[Teams] ST ON T.ST_id = ST.[FIT_DWH_ID]
		WHERE T.LZ_CheckSum_AllAttributes <> T.ST_CheckSum_AllAttributes

		SELECT @RowsUpdated = @@ROWCOUNT

		--Rows not in source -> delete
		DELETE ST 
		FROM [UCI].[Teams] ST WITH (TABLOCKX)
		JOIN #tmp_Teams T on ST.FIT_DWH_ID = T.ST_id
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

		SELECT @ErrorMessage = N'Error occured during [UCI].[usp_Upsert_Teams]. Message: ' + ERROR_MESSAGE();

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
