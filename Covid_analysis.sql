/*7 days death rolling average by countries*/
CREATE VIEW death_rolling_average AS WITH cte1 AS (
    SELECT
        location,
        CONVERT(DATE, DATE) AS DATE,
        CONVERT(INT, new_deaths) AS new_deaths
    FROM
        Covid..CovidDeaths
    WHERE
        location NOT IN (
            'Asia',
            'European Union',
            'North America',
            'South America',
            'Europe',
            'International',
            'Upper middle income',
            'Africa',
            'World',
            'Low income',
            'High income',
            'Lower middle income'
        )
)
SELECT
    location,
    DATE,
    new_deaths AS new_deaths,
    AVG(new_deaths) OVER (
        PARTITION BY location
        ORDER BY
            DATE ROWS BETWEEN 6 preceding
            AND CURRENT ROW
    ) AS deaths_rolling_average
FROM
    cte1;
GO

/*unique countries*/
CREATE VIEW countries AS
SELECT
    DISTINCT location
FROM
    Covid..CovidDeaths
WHERE
    location NOT IN (
        'Asia',
        'European Union',
        'North America',
        'South America',
        'Europe',
        'International',
        'Upper middle income',
        'Africa',
        'World',
        'Low income',
        'High income',
        'Lower middle income'
    );
GO
/*total deaths  / total cases worldwide*/
CREATE VIEW total_figures AS
SELECT
    SUM(CAST(new_cases AS FLOAT)) AS total_cases,
    SUM(CAST(new_deaths AS FLOAT)) AS total_deaths,
    (
        SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT))
    ) AS death_percent
FROM
    Covid..CovidDeaths;
GO

/*cases vs  deaths*/
CREATE VIEW cases_vs_deaths AS
SELECT
    location,
    CONVERT(DATE, DATE) AS DATE,
    AVG(CAST(new_cases_smoothed AS FLOAT)) OVER (
        PARTITION BY location
        ORDER BY
            DATE ROWS BETWEEN 6 preceding
            AND CURRENT ROW
    ) AS new_cases,
    AVG(CAST(new_deaths_smoothed AS FLOAT)) OVER (
        PARTITION BY location
        ORDER BY
            DATE ROWS BETWEEN 6 preceding
            AND CURRENT ROW
    ) AS new_deaths
FROM
    Covid..CovidDeaths;
GO

/*vaccine doses per 100 vs new deaths per million*/
CREATE VIEW VACCINEVSDEATH AS
SELECT
    A.location,
    A.DATE,
    CAST(B.total_vaccinations_per_hundred AS FLOAT) AS vaccine_doses,
    A.new_deaths
FROM
    Covid..CovidDeaths AS A
    LEFT JOIN covid..CovidVaccinations AS B ON A.location = B.location
    AND A.DATE = B.DATE;
GO

/*vACCINATED POPULATION PERCENT*/
CREATE VIEW vaccinatedpercent AS
SELECT
    A.location,
    MAX(CAST(B.population AS FLOAT)) AS POPULATION,
    MAX(CAST(B.people_fully_vaccinated AS FLOAT)) AS vaccine_doses,
    (
        MAX(CAST(B.people_fully_vaccinated AS FLOAT)) / MAX(CAST(B.population AS FLOAT))
    ) AS percentVaccinated
FROM
    covid..coviddeaths AS A
    LEFT JOIN Covid..CovidVaccinations AS B ON A.location = B.location
    AND A.date = B.date
WHERE
    CAST(b.population AS FLOAT) ! = 0
GROUP BY
    a.location;
GO

/*total deaths and total cases by country*/
