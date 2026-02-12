import bpy
import os
import csv

# --- KONFIGURATION ------------------------------------------------
# 1. Welchen Zeitpunkt willst du visualisieren? (Muss exakt der Spaltenname in der CSV sein!)
TARGET_COLUMN = "5.2._09:00" 

# 2. Pfad zur CSV-Datei
# Wir versuchen den Pfad automatisch zu finden, wie im Hauptskript
try:
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    PARENT_DIR = os.path.dirname(SCRIPT_DIR)
    OUTPUT_DIR = os.path.join(PARENT_DIR, "BlenderOutputs")
    # Pass hier den Dateinamen an, falls du eine andere Version nutzt!
    CSV_FILE = os.path.join(OUTPUT_DIR, "verschattung_final_dst_math_optimized.csv")
except:
    print("FEHLER: Konnte Pfad nicht automatisch finden.")
    CSV_FILE = "C:/Pfad/zu/deiner/datei.csv" # Notfall-Fallback

WINDOW_KEYWORD = "IfcWindow"
# ------------------------------------------------------------------

def setup_result_materials():
    """Erstellt die 3 Status-Materialien, falls sie fehlen."""
    mats = {
        "Result_Sonne": (0.1, 0.8, 0.1, 1.0),   # Grün
        "Result_Schatten": (0.8, 0.1, 0.1, 1.0), # Rot
        "Result_Nacht": (0.05, 0.05, 0.2, 1.0)   # Dunkelblau
    }
    
    mat_objects = {}
    for name, color in mats.items():
        if name in bpy.data.materials:
            mat = bpy.data.materials[name]
        else:
            mat = bpy.data.materials.new(name=name)
            mat.use_nodes = False # Einfaches Material reicht
        
        mat.diffuse_color = color
        mat_objects[name] = mat
        print(f"Material bereit: {name}")
    return mat_objects

def visualize_csv_column():
    if not os.path.exists(CSV_FILE):
        print(f"FEHLER: CSV-Datei nicht gefunden: {CSV_FILE}")
        return

    print(f"Start Visualisierung für Zeitpunkt: {TARGET_COLUMN}")
    
    # 1. Materialien vorbereiten
    status_mats = setup_result_materials()
    mat_list = [status_mats["Result_Sonne"],    # Index 0
                status_mats["Result_Schatten"], # Index 1
                status_mats["Result_Nacht"]]    # Index 2

    # 2. CSV lesen und Daten für den Zeitpunkt speichern
    # Dictionary Map: { "BMKZ_des_Fensters" : Status_Int (0-2) }
    sensor_states = {}
    target_col_idx = -1

    try:
        with open(CSV_FILE, 'r', newline='') as f:
            reader = csv.reader(f, delimiter=';')
            header = next(reader)
            
            # Spaltenindex finden
            try:
                target_col_idx = header.index(TARGET_COLUMN)
            except ValueError:
                print(f"FEHLER: Spalte '{TARGET_COLUMN}' nicht in der CSV gefunden!")
                print(f"Verfügbare Spalten: {header[1:]}")
                return

            # Daten lesen
            for row in reader:
                if not row or len(row) <= target_col_idx: continue
                sensor_id = row[0]
                status_str = row[target_col_idx]
                try:
                    sensor_states[sensor_id] = int(status_str)
                except ValueError:
                    pass # Header oder kaputte Daten ignorieren
                    
    except Exception as e:
        print(f"Fehler beim Lesen der CSV: {e}")
        return

    print(f"Daten geladen für {len(sensor_states)} Fenster. Wende Farben an...")

    # 3. Fenster im 3D-Modell einfärben
    windows = [obj for obj in bpy.context.scene.objects if WINDOW_KEYWORD in obj.name and obj.type == 'MESH']
    
    count_colored = 0
    count_missing = 0

    for win in windows:
        # BMKZ (oder Name) holen, genau wie im Simulations-Skript
        sensor_id = win.get("BMKZ", win.name)
        
        if sensor_id in sensor_states:
            status = sensor_states[sensor_id] # 0, 1 oder 2
            target_mat = mat_list[status]
            
            # Material zuweisen (überschreibt Slot 0 oder fügt neuen hinzu)
            if len(win.data.materials) == 0:
                 win.data.materials.append(target_mat)
            else:
                win.data.materials[0] = target_mat
            count_colored += 1
        else:
            # Fenster im Modell, aber nicht in der CSV (sollte nicht passieren)
            # Optional: Ein "Fehler-Material" (z.B. Pink) zuweisen
            count_missing += 1

    print("="*40)
    print(f"VISUALISIERUNG ABGESCHLOSSEN für {TARGET_COLUMN}")
    print(f"Eingefärbt: {count_colored}")
    print(f"Nicht in CSV gefunden: {count_missing}")
    print("="*40)
    # Viewport aktualisieren
    bpy.context.view_layer.update()

# Skript ausführen
visualize_csv_column()