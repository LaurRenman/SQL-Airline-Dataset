-- =============================================
-- 1. Analyse des passagers fréquents
-- =============================================
-- Requête pour identifier les passagers ayant effectué le plus de vols
SELECT `First Name`,`Last Name`,COUNT(Passenger_ID) AS reservation_count
FROM passengers
JOIN reservations ON passengers.ID = Passenger_ID
GROUP BY passengers.ID, `First Name`, `Last Name`
ORDER BY reservation_count DESC
LIMIT 100;

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
-- 2. Compagnies aériennes avec le plus de retards
-- =============================================
-- Requête pour identifier les compagnies ayant enregistré le plus de vols retardés
SELECT `Name` AS Airline_Name, COUNT(*) AS Number_of_Delays
FROM reservations
JOIN routes ON `Route ID` = routes.ID
JOIN airlines ON `Airline ID` = airlines.ID
WHERE `Delayed` = 1
GROUP BY `Name`
ORDER BY Number_of_Delays DESC
LIMIT 50;

-- =============================================
-- 3. Avions (modèles) avec le plus de vols
-- =============================================
-- Requête pour identifier les modèles d'avion les plus utilisés
SELECT `Name` AS Aircraft_Model, COUNT(reservations.ID) AS Number_of_Flights
FROM reservations
JOIN routes ON `Route ID` = routes.ID
JOIN airplanes ON `Aircraft ID` = airplanes.ID
GROUP BY airplanes.ID
ORDER BY Number_of_Flights DESC
LIMIT 10;

-- =============================================
-- 4. Aéroports les plus fréquentés
-- =============================================
-- 4.1 Création des vues intermediaires pour départs et arrivées
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

-- 4.2 Vue agrégée des visites (départs + arrivées)
CREATE VIEW airport_visits AS
SELECT airports.ID,`Name`,City,Country,
    (IFNULL(Departures, 0) + IFNULL(Arrivals, 0)) AS Total_Visits,
    IFNULL(Departures, 0) AS Departures,
    IFNULL(Arrivals, 0) AS Arrivals
FROM airports
LEFT JOIN airport_departures ON airports.ID =  airport_departures.Airport_ID
LEFT JOIN airport_arrivals ON airports.ID = airport_arrivals.Airport_ID; 

-- 4.3 Sélection finale des aéroports les plus fréquentés
SELECT * 
FROM airport_visits
ORDER BY Total_Visits DESC;

-- =============================================
-- 5. Compagnies les plus populaires en nombre de passagers
-- =============================================
SELECT `Name` AS Airline_Name, COUNT(Passenger_ID) AS Number_of_Passengers
FROM reservations
JOIN routes ON `Route ID` = routes.ID
JOIN airlines ON `Airline ID` = airlines.ID
GROUP BY airlines.ID, `Name`
ORDER BY Number_of_Passengers DESC;


-- =============================================
-- 6. Top 10 des destinations favories des voyageurs français par pays 
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
-- 7. Nombre de vols par groupes d'âges
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





