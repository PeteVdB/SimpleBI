CREATE VIEW LZ_UCI.vw_Teams
AS
SELECT
[Code] AS [Code],
[Name] AS [Name],
[Team Category] AS [Team Category],
[Country] AS [Country],
[Continent] AS [Continent],
[Format] AS [Format],
[Email] AS [Email],
[Website] AS [Website]
FROM LZ_UCI.Teams
