# Analyse des résultas

## 1. Analyse des passagers qui voyagent le plus

```sql
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
```

Tous les passagers ne voyagent pas à la même fréquence. Aussi, les voyageurs qui se déplacent beaucoup ne prennent pas toujours la même compagnie aérienne. Dans notre base de données, nous avons groupé les voyageurs en plusieurs catégories: ceux qui voyagent énormement (plus de 14 vols), ceux qui voyagent régulièrement (entre 10 et 14 vols), ceux qui voyagent modérément (entre 5 et 9 vols) et ceux qui voyagent peu (moins de 5 vols).  
Notre base de données recense une quinzaine de voyageurs qui voyagent de manière très fréquente. Ainsi, nos partenaires pourraient récolter ces informations pour mener des campagnes de fidélisation efficaces envers ces voyageurs selon leur profil et les routes empruntées. On pourrait même recommander les individus qui voyagent régulièrement. La fidélisation de ces voyageurs permettrait d'augmenter le revenu de nos partenaires et d'améliorer potentiellement l'image de la marque.

## 2. Compagnies aériennes avec le plus de retards (en ratio retards/vols totaux)

```sql
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
```
Problème identifié:  
Beaucoup de compagnies aériennes ont un ratio de retard extrêmement élevé. Par exemple, Alaska Central Express a un taux de retard de 100%, et c'est loin d'être la seule compagnie aérienne. Chaque minute de retard coûte entre 70 et 150 dollars à une compagnie aérienne. Ensuite, au-delà de la perte financière directe, le retard nuit à l’image de la marque, augmente les coûts de compensation, et impacte la fidélisation des passagers.  
Grâce à notre base de données, nous avons pu repérer de potentiels partenaires qui pourraient bénéficier d'une étude approfondie de notre part sur la cause des retards pour optimiser leur revenu. 

Exemple:  
-Alaska Central Express  
-LSM Airlines  
-Polynesian Airlines

```sql
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
```
Un premier KPI pertinent pour l'analyse des causes de retard que nous avons produits est le ratio de retard par vol dans les différents aéroports. On y observe de nombreux aéroports qui connaissent des retard systématiques comme l'aéroport Dikson en Russie qui a un ration de 100%. En comparaison, l'aéroport de Ben Schoeman en Afrique du Sud a un ratio de 0% de vols retardés. Il est clair que l'organisation d'un aéroport est un facteur important dans les retards de vols. C'est pourquoi nos analyses peuvent être utiles dans l'optimisation de routes et la prédiction de retards (ainsi que des coûts liés) pour une compagnie aérienne.

## 3. Avions (modèles) avec le plus de vols

```sql
SELECT `Name` AS Aircraft_Model, COUNT(DISTINCT reservations.`Route ID`) AS Number_of_Flights
FROM reservations
JOIN routes ON `Route ID` = routes.ID
JOIN airplanes ON `Aircraft ID` = airplanes.ID
GROUP BY airplanes.ID
ORDER BY Number_of_Flights DESC
LIMIT 10;
```

Les modèles Airbus semblent être les plus populaires. En effet, les deux modèles d'avions les plus utilisés sont l'Airbus A350 (20 vols) et l'Airbus A300-600 (16 vols). Ces avions semblent être les champions des voyages aériens, et ont un rôle crucial dans les opérations de nos compagnies aériennes. Ils sont nécessaires et semblent fiables pour des itinéraires avec une forte demande.  
Nos compagnies partenaires peuvent donc utiliser cette information pour maximiser l'utilisation de l'A350 et l'A300-600 sur les itinéraires les plus rentables tout en surveillant les coûts associés à leur entretien et gestion. De plus, avec les événements récents, nos partenaires pourraient investir dans une communication pour promouvoir l'utilisation d'avions fiables Airbus et tenter de capter une part plus importante de marché. 
Des analyses plus approfondies pourront également être menées pour les petites compagnies aériennes qui recherchent des opportunités cachées. Des avions sous-utilisés (et donc un prix plus faible) qui pourraient être tout aussi fiables qu'un Airbus A350.  
En résumé, cette analyse permet d'étudier les tendances sur les modèles utilisés par les compagnies aériennes, et est également une porte d'entrée pour des analyses plus approfondies sur la stratégie d'achat de nouveaux modèles.

## 4. Analyse des aéroports les plus fréquentés

```sql
-- 1. Création des vues intermediaires pour départs et arrivées
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

-- 2. Vue agrégée des visites (départs + arrivées)
CREATE VIEW airport_visits AS
SELECT airports.ID,`Name`,City,Country,
    (IFNULL(Departures, 0) + IFNULL(Arrivals, 0)) AS Total_Visits,
    IFNULL(Departures, 0) AS Departures,
    IFNULL(Arrivals, 0) AS Arrivals
FROM airports
LEFT JOIN airport_departures ON airports.ID =  airport_departures.Airport_ID
LEFT JOIN airport_arrivals ON airports.ID = airport_arrivals.Airport_ID; 

-- 3. Sélection finale des aéroports les plus fréquentés
SELECT * 
FROM airport_visits
ORDER BY Total_Visits DESC;

-- 4. Analyse des compagnies les plus fréquentés
SELECT `Name` AS Airline_Name, COUNT(Passenger_ID) AS Number_of_Passengers
FROM reservations
JOIN routes ON `Route ID` = routes.ID
JOIN airlines ON `Airline ID` = airlines.ID
GROUP BY airlines.ID, `Name`
ORDER BY Number_of_Passengers DESC;
```
L’analyse des aéroports les plus desservis peut être un indicateur de la popularité de certaines destinations et permet aux compagnies émergentes d’envisager des nouvelles destinations à ajouter à leur catalogue.  
Notre analyse nous montre que les aéroports les plus fréquentés sont le Huatugou Airport en Chine, le Barcaldine Airport en Australie et Islas Malvinas Airport en Argentine. Les Etats-Unis semblent être le pays le plus prisé puisqu’il apparait 8 fois dans le top 40 des aéroports les plus fréquentés.  
L’analyse des compagnies aériennes les plus actives permet de se faire une image sommaire de l’état de la concurrence. Il serait pertinent d’étudier les différentes routes desservies par ces compagnies afin de se situer convenablement sur le marché. Notre analyse nous permet d’identifier un secteur saturé : l’Europe de l’Est où opèrent 4 des 10 compagnies aériennes les plus fréquentés (Air Baltic, Budapest Aircraft Services, LOT Polish Airlines, LSM Airlines).

## 5. Analyse des destinations favories des voyageurs français par pays 

```sql
SELECT airports.Country AS Airport_Country,
    SUM(CASE WHEN Nationality = 'France' THEN 1 ELSE 0 END) AS French_Passengers
FROM reservations
JOIN routes ON `Route ID` = routes.ID
JOIN passengers ON Passenger_ID = passengers.ID
JOIN airports ON airports.ID IN (`Departure Airport ID`, `Arrival Airport ID`)
GROUP BY airports.Country
ORDER BY French_Passengers DESC
LIMIT 10;
```

L’analyse des destinations les plus prisées des Français est très pertinente lorsqu’on cherche à se situer sur le marché. On remarque une forte demande pour les Etats-Unis et le Canada ce qui pourrait orienter une compagnie aérienne souhaitant s’introduire sur le marché français vers un potentiel investissement dans des routes transatlantiques. Ce genre d’analyse permet de rendre compte des destinations favorites des ressortissants de chaque pays et ainsi donner une image de la demande pour des vols internes/ internationaux.

## 6. Distribution du nombre de réservations par tranche d'âge

```sql
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
```

Dans l’optique d’une étude de marché, il est pertinent de s’intéresser aux différentes caractéristiques démographiques de la clientèle. Nous avons choisi d’introduire une segmentation du marché par tranche d’âge et par fréquence des vols ce qui pourrait éventuellement servir dans le cadre d’une campagne marketing.  
Il en ressort que les 2 catégories les plus prépondérantes sont celles des moins de 18 ans et celles des plus de 64 ans avec une fréquence des vols modérée (de 5 à 9 vols par passager). On pourrait imaginer la mise en place d’offres visant à attirer cette clientèle comme des réductions sur les prix des billets pour ces tranches d’âge ou des offres saisonniers ciblés sur les vacances scolaires par exemple.
