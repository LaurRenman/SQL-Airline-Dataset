-- =============================================
-- 1. Analyse des passagers qui voyagent le plus 
-- =============================================
-- Passagers avec entre 5 et 9 vols
SELECT `First Name`,`Last Name`,COUNT(Passenger_ID) AS reservation_count
FROM passengers
JOIN reservations ON passengers.ID = Passenger_ID
GROUP BY passengers.ID, `First Name`, `Last Name`
HAVING COUNT(Passenger_ID) BETWEEN 5 AND 9
ORDER BY reservation_count DESC

-- Passagers avec entre 10 et 14 vols
SELECT `First Name`,`Last Name`,COUNT(Passenger_ID) AS reservation_count
FROM passengers
JOIN reservations ON passengers.ID = Passenger_ID
GROUP BY passengers.ID, `First Name`, `Last Name`
HAVING COUNT(Passenger_ID) BETWEEN 10 AND 14
ORDER BY reservation_count DESC

-- Passengers avec plus de 14 vols
SELECT `First Name`,`Last Name`,COUNT(Passenger_ID) AS reservation_count
FROM passengers
JOIN reservations ON passengers.ID = Passenger_ID
GROUP BY passengers.ID, `First Name`, `Last Name`
HAVING COUNT(Passenger_ID) > 14
ORDER BY reservation_count DESC



-- =============================================
-- 2. Analyse des retards par copagnie et par aéroport
-- =============================================
-- 2.1 Nombre de compagnies aériennes qui accumulent le plus de retards
SELECT 
    airlines.`Name` AS Airline_Name,
    COUNT(DISTINCT reservations.`Route ID`) AS Total_Flights,
    COUNT(DISTINCT CASE WHEN routes.`Delayed` = 1 THEN reservations.`Route ID` END) AS Delayed_Flights,
    ROUND(
        COUNT(DISTINCT CASE WHEN routes.`Delayed` = 1 THEN reservations.`Route ID` END) * 1.0 /
        COUNT(DISTINCT reservations.`Route ID`),
        3
    ) AS Delay_Rate_Per_Flight
FROM reservations
JOIN routes ON reservations.`Route ID` = routes.ID
JOIN airlines ON routes.`Airline ID` = airlines.ID
GROUP BY airlines.`Name`
HAVING COUNT(DISTINCT reservations.`Route ID`) > 0
ORDER BY Delay_Rate_Per_Flight DESC, Total_Flights DESC;

-- 2.2 Nombre de vols retardés par aéroport

SELECT
    `Name` AS Airport_Name,
    `Country`,
    COUNT(*) AS Total_Flights,
    SUM(CASE WHEN `Delayed` = 1 THEN 1 ELSE 0 END) AS Delayed_Flights,
    ROUND(
        SUM(CASE WHEN `Delayed` = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*),
        3
    ) AS Delay_Ratio
FROM routes
JOIN airports
    ON airports.ID = `Departure Airport ID` OR airports.ID = `Arrival Airport ID`
GROUP BY airports.ID, `Name`
ORDER BY Delay_Ratio DESC, Total_Flights DESC;


-- =============================================
-- 3. Analyse des avions utilisés 
-- =============================================
-- Requête pour identifier les modèles d'avion les plus utilisés
SELECT `Name` AS Aircraft_Model, COUNT(DISTINCT reservations.`Route ID`) AS Number_of_Flights
FROM reservations
JOIN routes ON `Route ID` = routes.ID
JOIN airplanes ON `Aircraft ID` = airplanes.ID
GROUP BY airplanes.ID
ORDER BY Number_of_Flights DESC
LIMIT 10;

-- =============================================
-- 4. Analyse des aéroports les plus fréquentés
-- =============================================
-- 4.1.1 Création des vues intermediaires pour départs et arrivées
CREATE VIEW airport_departures AS
SELECT `Departure Airport ID` AS Airport_ID, COUNT(reservations.ID) AS Departures
FROM reservations
JOIN routes ON `Route ID` = routes.ID
GROUP BY `Departure Airport ID`;

CREATE VIEW airport_arrivals AS
SELECT `Arrival Airport ID` AS Airport_ID, COUNT(reservations.ID) AS Arrivals
FROM reservations
JOIN routes ON `Route ID`= routes.ID
GROUP BY `Arrival Airport ID`;

-- 4.1.2 Vue agrégée des visites (départs + arrivées)
CREATE VIEW airport_visits AS
SELECT airports.ID,`Name`,City,Country,
    (IFNULL(Departures, 0) + IFNULL(Arrivals, 0)) AS Total_Visits,
    IFNULL(Departures, 0) AS Departures,
    IFNULL(Arrivals, 0) AS Arrivals
FROM airports
LEFT JOIN airport_departures ON airports.ID =  airport_departures.Airport_ID
LEFT JOIN airport_arrivals ON airports.ID = airport_arrivals.Airport_ID; 

-- 4.1.3 Sélection finale des aéroports les plus fréquentés
SELECT * 
FROM airport_visits
ORDER BY Total_Visits DESC
LIMIT 40;


-- 4.2 Analyse des compagnies les plus fréquentés

SELECT `Name` AS Airline_Name, Country, COUNT(Passenger_ID) AS Number_of_Passengers
FROM reservations
JOIN routes ON `Route ID` = routes.ID
JOIN airlines ON `Airline ID` = airlines.ID
GROUP BY airlines.ID, `Name`
ORDER BY Number_of_Passengers DESC;


-- =============================================
-- 5. Analyse des destinations favories des voyageurs français par pays 
-- =============================================

SELECT airports.Country AS Airport_Country,
    SUM(CASE WHEN Nationality = 'France' THEN 1 ELSE 0 END) AS French_Passengers
FROM reservations
JOIN routes ON `Route ID` = routes.ID
JOIN passengers ON Passenger_ID = passengers.ID
JOIN airports ON airports.ID IN (`Departure Airport ID`, `Arrival Airport ID`)
GROUP BY airports.Country
ORDER BY French_Passengers DESC
LIMIT 10;


-- =============================================
-- 6. Distribution du nombre de réservations par tranche d'âge
-- =============================================


SELECT
    AgeGroup,
    COUNT(CASE WHEN FlightCountGroup = '<5' THEN 1 END) AS "<5",
    COUNT(CASE WHEN FlightCountGroup = '5-9' THEN 1 END) AS "5-9",
    COUNT(CASE WHEN FlightCountGroup = '10-14' THEN 1 END) AS "10-14",
    COUNT(CASE WHEN FlightCountGroup = '>14' THEN 1 END) AS ">14"
FROM (
    SELECT
        passengers.ID,
        CASE
            WHEN passengers.Age < 18 THEN '<18'
            WHEN passengers.Age BETWEEN 18 AND 24 THEN '18-24'
            WHEN passengers.Age BETWEEN 25 AND 34 THEN '25-34'
            WHEN passengers.Age BETWEEN 35 AND 44 THEN '35-44'
            WHEN passengers.Age BETWEEN 45 AND 54 THEN '45-54'
            WHEN passengers.Age BETWEEN 55 AND 64 THEN '55-64'
            ELSE '>64'
        END AS AgeGroup,
        CASE
            WHEN COUNT(reservations.ID) < 5 THEN '<5'
            WHEN COUNT(reservations.ID) BETWEEN 5 AND 9 THEN '5-9'
            WHEN COUNT(reservations.ID) BETWEEN 10 AND 14 THEN '10-14'
            ELSE '>14'
        END AS FlightCountGroup
    FROM passengers
    LEFT JOIN reservations ON passengers.ID = Passenger_ID
    GROUP BY passengers.ID, passengers.Age
) AS grouped
GROUP BY AgeGroup
ORDER BY AgeGroup;





