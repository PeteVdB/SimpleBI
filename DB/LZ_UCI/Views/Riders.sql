CREATE VIEW LZ_UCI.vw_Riders
AS
SELECT
[Function] AS [Function],
[Last Name] AS [Last Name],
[First Name] AS [First Name],
[Birth date] AS [Birth date],
[Birth date year] AS [Birth date year],
[Birth Year] AS [Birth Year],
[Gender] AS [Gender],
[Category] AS [Category],
[Country] AS [Country],
[Continent] AS [Continent],
[Team Code] AS [Team Code],
[Team Name] AS [Team Name],
[UCIID] AS [UCIID]
FROM LZ_UCI.Riders
