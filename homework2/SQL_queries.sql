#1

SELECT companion.*
FROM DoctorWho.dbo.tblCompanion AS companion 
LEFT OUTER JOIN DoctorWho.dbo.tblEpisodeCompanion AS epCompanion
ON companion.CompanionId = epCompanion.CompanionId
WHERE epCompanion.EpisodeId is NULL
GO

#2

SELECT events.EventName, events.EventDate, countries.CountryName 
FROM WorldEvents.dbo.tblEvent AS events
INNER JOIN WorldEvents.dbo.tblCountry AS countries
ON countries.CountryID = events.CountryID
WHERE events.EventDate > (
	SELECT MAX(EventDate)
	FROM WorldEvents.dbo.tblEvent
	WHERE CountryID = 21
)
ORDER BY events.EventDate DESC
GO

#3

SELECT country.CountryName
FROM WorldEvents.dbo.tblEvent AS events
INNER JOIN WorldEvents.dbo.tblCountry as country
ON events.CountryID = country.CountryID
WHERE (
	SELECT COUNT(events.CountryID) AS number_of_events
	FROM WorldEvents.dbo.tblEvent AS events
	WHERE events.CountryID = country.CountryID
	GROUP BY events.CountryID
) > 8
GROUP BY country.CountryName
ORDER BY country.CountryName
GO

#4.1

WITH ThisOrThat AS(
	SELECT
	CASE
		WHEN events.EventDetails LIKE '%this%' THEN 1
		ELSE 0
	END AS ifThis,
	CASE
	WHEN events.EventDetails LIKE '%that%' THEN 1
		ELSE 0
	END AS ifThat
	FROM WorldEvents.dbo.tblEvent AS events
)
SELECT ifThis, ifThat, COUNT(*) AS 'number of events'
FROM ThisOrThat
GROUP BY ifThis, ifThat

#4.2

WITH ThisOrThat AS(
	SELECT events.EventName, events.EventDetails,
	CASE
		WHEN events.EventDetails LIKE '%this%' THEN 1
		ELSE 0
	END AS ifThis,
	CASE
	WHEN events.EventDetails LIKE '%that%' THEN 1
		ELSE 0
	END AS ifThat
	FROM WorldEvents.dbo.tblEvent AS events
)
SELECT EventName, EventDetails
FROM ThisOrThat
WHERE ifThis = 1 AND ifThat = 1

#5

WITH 
ManyCountries AS (
	SELECT continents.ContinentName, MAX(continents.ContinentID) as ContinentID, 
	COUNT(countries.CountryId) AS number_of_countries
	FROM WorldEvents.dbo.tblContinent as continents
	INNER JOIN WorldEvents.dbo.tblCountry as countries
	ON countries.ContinentID = continents.ContinentID
	GROUP BY continents.ContinentName
	HAVING COUNT(countries.CountryId) >= 3 
),
FewEvents AS(
	SELECT countries.ContinentID, COUNT(events.EventID) AS number_of_events
	FROM WorldEvents.dbo.tblEvent as events
	INNER JOIN WorldEvents.dbo.tblCountry as countries
	ON countries.CountryID = events.CountryID
	GROUP BY countries.ContinentID
	HAVING COUNT(events.EventID) <=10
)
SELECT ManyCountries.ContinentName,  ManyCountries.number_of_countries, 
FewEvents.number_of_events
FROM ManyCountries 
INNER JOIN FewEvents ON ManyCountries.ContinentID = FewEvents.ContinentID

#6

CREATE VIEW ShowTheEra AS (
	SELECT events.EventId,
	CASE
		WHEN year(events.EventDate) < 1900 THEN '19th century and earlier'
		WHEN year(events.EventDate) < 2000 THEN '20th century'
		ELSE '21th century'
	END AS Era
	FROM WorldEvents.dbo.tblEvent AS events
)
GO
SELECT Era, COUNT(EventID)
FROM ShowTheEra
GROUP BY Era
GO

#7

CREATE VIEW EpisodeYearSeries AS (
	SELECT YEAR(episodes.EpisodeDate) as EpisodeYear,
	episodes.SeriesNumber, episodes.EpisodeId
	FROM DoctorWho.dbo.tblEpisode as episodes
)
GO
SELECT EpisodeYear, [1], [2], [3], [4], [5]
FROM EpisodeYearSeries as episodes
PIVOT( COUNT(EpisodeId) FOR SeriesNumber IN ([1], [2], [3], [4], [5])
) AS EpisodeYearSeriesPivot
GO