import pandas as pd
import numpy as np
import random
import os

def generate_flight_data(input_dir='.', output_dir='.'):
    """
    Generate routes.csv and reservations.csv based on existing
    airports.csv, airlines.csv, airplanes.csv, and passengers.csv files.
    
    Args:
        input_dir: Directory containing the input CSV files
        output_dir: Directory where output CSV files will be saved
    """
    print("Reading existing CSV files...")
    
    # Load existing data files
    try:
        airports = pd.read_csv(os.path.join(input_dir, 'airports.csv'))
        airlines = pd.read_csv(os.path.join(input_dir, 'airlines.csv'))
        airplanes = pd.read_csv(os.path.join(input_dir, 'airplanes.csv'))
        passengers = pd.read_csv(os.path.join(input_dir, 'passengers.csv'))
        
        print(f"Successfully loaded CSV files:")
        print(f"  - Airports: {len(airports)} airports")
        print(f"  - Airlines: {len(airlines)} airlines")
        print(f"  - Airplanes: {len(airplanes)} airplanes")
        print(f"  - Passengers: {len(passengers)} passengers")
    except Exception as e:
        print(f"Error loading CSV files: {e}")
        return
    
    # 1. Generate Routes
    print("\nGenerating routes.csv...")
    route_count = 2500
    
    # Get IDs for reference
    airport_ids = airports['ID'].tolist()
    airline_ids = airlines['ID'].tolist()
    airplane_ids = airplanes['ID'].tolist()
    
    # Create routes DataFrame
    routes_data = []
    for i in range(1, route_count + 1):
        # Find two different airports for departure and arrival
        departure_airport_id = random.choice(airport_ids)
        arrival_airport_id = random.choice(airport_ids)
        
        # Make sure departure and arrival airports are different
        while arrival_airport_id == departure_airport_id:
            arrival_airport_id = random.choice(airport_ids)
        
        # Randomly assign an airline and airplane
        airline_id = random.choice(airline_ids)
        airplane_id = random.choice(airplane_ids)
        
        # In real life,a round 37% of flights experienced delay
        late = 1 if random.random() < 0.37 else 0
        
        routes_data.append({
            'ID': i,
            'Departure Airport ID': departure_airport_id,
            'Arrival Airport ID': arrival_airport_id,
            'Airline ID': airline_id,
            'Aircraft ID': airplane_id,
            'Delayed': late
        })
    
    routes_df = pd.DataFrame(routes_data)
    print(f"Generated {len(routes_df)} routes successfully.")
    
    # 2. Generate Reservations
    print("\nGenerating reservations.csv...")
    reservation_count = 15000
    
    # Service classes
    service_classes = ["Economy", "Business", "First"]
    
    # Get passenger IDs
    passenger_ids = passengers['ID'].tolist()
    
    # Create reservations DataFrame
    reservations_data = []
    for i in range(1, reservation_count + 1):
        # Get a random passenger ID
        passenger_id = random.choice(passenger_ids)
        
        # Get a random route ID (1-500 from our generated routes)
        route_id = random.randint(1, route_count)
        
        # Get a random service class (80% of economy class, 12% of business and 8% of first class)
        service_class = random.choices(service_classes, weights=[80, 12, 8], k=1)[0]
        
        reservations_data.append({
            'ID': i,
            'Passenger_ID': passenger_id,
            'Route ID': route_id,
            'Class': service_class
        })
    
    reservations_df = pd.DataFrame(reservations_data)
    print(f"Generated {len(reservations_df)} reservations successfully.")
    
    # 3. Save generated files
    routes_output_path = os.path.join(output_dir, 'routes.csv')
    reservations_output_path = os.path.join(output_dir, 'reservations.csv')
    
    routes_df.to_csv(routes_output_path, index=False)
    reservations_df.to_csv(reservations_output_path, index=False)
    
    print(f"\nFiles saved successfully:")
    print(f"  - Routes: {routes_output_path}")
    print(f"  - Reservations: {reservations_output_path}")
    
    # Display sample data
    print("\nSample of generated routes.csv (first 5 rows):")
    print(routes_df.head().to_string())
    
    print("\nSample of generated reservations.csv (first 5 rows):")
    print(reservations_df.head().to_string())

if __name__ == "__main__":
    # You can modify these directories if your files are in different locations
    input_directory = '.'  # Current directory - where the input CSVs are located
    output_directory = '.'  # Current directory - where to save the output CSVs
    
    generate_flight_data(input_directory, output_directory)
