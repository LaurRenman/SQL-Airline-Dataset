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
