import pandas as pd
import os

source_dir = "."
dest_dir = "."

os.makedirs(dest_dir, exist_ok=True)

# Différentes tables nettoyées
def clean_airplanes():
    df = pd.read_csv(os.path.join(source_dir, "airplanes.csv"))
    df.drop(df.columns[[1, 2]], axis=1, inplace=True)  # Supprimer colonnes 2 et 3
    df.insert(0, "ID", range(1, len(df) + 1))
    df.to_csv(os.path.join(dest_dir, "airplanes.csv"), index=False)

def clean_airports():
    df = pd.read_csv(os.path.join(source_dir, "airports.csv"))
    df = df.iloc[:, :10]  # Garder les 10 premières colonnes
    df.drop(df.columns[[4, 5]], axis=1, inplace=True)  # Supprimer les colonnes 5 et 6
    df.columns.values[0] = "ID"  # Renommer la première colonne en ID
    df.to_csv(os.path.join(dest_dir, "airports.csv"), index=False)

def clean_airlines():
    df = pd.read_csv(os.path.join(source_dir, "airlines.csv"))
    df = df.iloc[1:]  # Supprimer la première ligne
    last_col = df.columns[-1]
    df = df[df[last_col] != 'N']  # Supprimer les lignes où la dernière colonne est 'N'
    df = df[[df.columns[1], df.columns[6]]]  # Garder seulement colonnes 1 et 6
    df.insert(0, "ID", range(1, len(df) + 1))
    df.to_csv(os.path.join(dest_dir, "airlines.csv"), index=False)

def clean_passengers():
    df = pd.read_csv(os.path.join(source_dir, "Airline Dataset Updated - v2.csv"))
    df = df.iloc[:, 1:6]  # Supprimer la première colonne
    df = df.head(2000)  # Garder seulement les 1500 premières lignes pour alléger la base de donnée
    df.insert(0, "ID", range(1, len(df) + 1))
    df.to_csv(os.path.join(dest_dir, "passengers.csv"), index=False)

def main():
    clean_airplanes()
    clean_airports()
    clean_airlines()
    clean_passengers()
    print("Tous les fichiers ont été nettoyés et enregistrés.")

if __name__ == "__main__":
    main()
