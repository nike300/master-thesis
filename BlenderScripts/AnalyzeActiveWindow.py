import bpy
import os
import datetime
import math
import sys

# --- KONFIGURATION ------------------------------------------------
# SICHERER PFAD-FINDER (Verhindert Absturz)
try:
    # Versuch 1: Relativ zum Skript (wie in Main.py)
    SCRIPT_PATH = os.path.abspath(__file__)
    SCRIPT_DIR = os.path.dirname(SCRIPT_PATH)
    PARENT_DIR = os.path.dirname(SCRIPT_DIR)
    OUTPUT_DIR = os.path.join(PARENT_DIR, "BlenderOutputs")
except (NameError, TypeError):
    # Versuch 2: Fallback zur .blend Datei (falls Skript nicht gespeichert)
    print("WARNUNG: Konnte Skript-Pfad nicht finden. Nutze .blend Pfad.")
    if bpy.data.is_saved:
        BLEND_DIR = os.path.dirname(bpy.data.filepath)
        OUTPUT_DIR = os.path.join(BLEND_DIR, "BlenderOutputs")
    else:
        # Notfall: Desktop
        OUTPUT_DIR = os.path.join(os.path.expanduser("~"), "Desktop", "BlenderOutputs")

# Ordner erstellen
if not os.path.exists(OUTPUT_DIR):
    try:
        os.makedirs(OUTPUT_DIR)
    except Exception as e:
        print(f"FEHLER beim Erstellen des Ordners: {e}")

print(f"Ausgabe-Ordner: {OUTPUT_DIR}")

OBSTACLE_COLLECTION = "map_6.osm_buildings" 
SUN_OBJECT_NAME = "Sun"

# Deine Test-Konfiguration
SIMULATION_DATES = [(5, 2)] 
START_HOUR = 6
END_HOUR = 20
MINUTES_STEP = 15 
YEAR = 2026
# ------------------------------------------------------------------

def get_last_sunday(year, month):
    if month == 12:
        next_month = datetime.date(year + 1, 1, 1)
    else:
        next_month = datetime.date(year, month + 1, 1)
    last_day_of_month = next_month - datetime.timedelta(days=1)
    offset = (last_day_of_month.weekday() + 1) % 7
    return last_day_of_month - datetime.timedelta(days=offset)

def analyze_active_window():
    # 1. Das ausgewählte Fenster holen
    sensor = bpy.context.active_object
    
    if not sensor:
        print("FEHLER: Bitte erst ein Fenster im 3D-View auswählen!")
        return
        
    sensor_name = sensor.get("BMKZ", sensor.name)
    # Dateiname dynamisch basierend auf Fenstername
    safe_name = sensor_name.replace("/", "_").replace("\\", "_")
    output_file = os.path.join(OUTPUT_DIR, f"Detail_Analyse_{safe_name}.csv")

    print("=" * 60)
    print(f"STARTE DETAIL-ANALYSE (PHYSICS ONLY) FÜR: {sensor_name}")
    print("=" * 60)

    # 2. Ressourcen
    sun = bpy.data.objects.get(SUN_OBJECT_NAME)
    depsgraph = bpy.context.evaluated_depsgraph_get()
    
    obstacles = set()
    if OBSTACLE_COLLECTION in bpy.data.collections:
        for o in bpy.data.collections[OBSTACLE_COLLECTION].objects:
            obstacles.add(o.name)

    # 3. Simulation
    sp = bpy.context.scene.sun_pos_properties
    sp.year = YEAR
    dst_start = get_last_sunday(YEAR, 3)
    dst_end = get_last_sunday(YEAR, 10)

    data_rows = []

    for day, month in SIMULATION_DATES:
        current_date = datetime.date(YEAR, month, day)
        
        # Sommerzeit Check
        if dst_start <= current_date < dst_end:
            sp.utc_zone = 2.0
            tz_info = "Sommerzeit"
        else:
            sp.utc_zone = 1.0
            tz_info = "Winterzeit"

        for total_minutes in range(START_HOUR * 60, (END_HOUR * 60) + 1, MINUTES_STEP):
            hour = total_minutes // 60
            minute = total_minutes % 60
            time_val = hour + (minute / 60.0)
            
            # Sonne setzen
            sp.day = day
            sp.month = month
            sp.time = time_val
            bpy.context.view_layer.update()

            sun_loc = sun.matrix_world.translation
            is_night = sun_loc.z < 0 

            # A) Nacht
            if is_night:
                data_rows.append(f"{day}.{month}.{YEAR};{hour:02d}:{minute:02d};2;NACHT;{sun_loc.z:.2f}")
                continue

            # B) Raycast (Physikalisch gegen ALLES)
            start_loc = sensor.matrix_world.translation
            sun_vec = (sun_loc - start_loc)
            direction = sun_vec.normalized()
            dist = sun_vec.length

            # Offset 0.2m Richtung Sonne
            ray_start = start_loc + (direction * 0.2)

            hit, _, _, _, hit_obj, _ = bpy.context.scene.ray_cast(
                depsgraph,
                ray_start, 
                direction,
                distance=dist
            )
            
            status = "0"
            blocker_name = "-" # Kein Hindernis
            
            if hit:
                # --- LOGIK FIX: ALLES IST EIN HINDERNIS ---
                # Auch wenn hit_obj == sensor ist!
                
                if hit_obj.type == 'MESH':
                    status = "1" # SCHATTEN!
                    
                    if hit_obj.name in obstacles:
                        blocker_name = f"UMGEBUNG ({hit_obj.name})"
                    elif hit_obj == sensor:
                        blocker_name = "SELBSTVERSCHATTUNG (Fenster)"
                    else:
                        blocker_name = f"GEBÄUDE/BAUTEIL ({hit_obj.name})"
                
                else:
                    status = "0"
                    blocker_name = f"KEIN_MESH ({hit_obj.name})"

            data_rows.append(f"{day}.{month}.{YEAR};{hour:02d}:{minute:02d};{status};{blocker_name};{sun_loc.z:.2f}")

    # 4. Schreiben
    with open(output_file, "w") as f:
        f.write("Datum;Uhrzeit;Status_Code;Verursacher_Name;Sonnen_Elevation\n")
        f.write("\n".join(data_rows))

    print(f"FERTIG! Detail-Datei erstellt: {output_file}")

analyze_active_window()