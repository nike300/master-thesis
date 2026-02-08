import bpy
import os
import time
import datetime 

# --- KONFIGURATION ------------------------------------------------
# 1. Pfad dieses Skripts ermitteln
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# 2. Einen Ordner nach OBEN gehen
PARENT_DIR = os.path.dirname(SCRIPT_DIR)

# 3. Von dort in den Nachbarordner "BlenderOutputs" gehen
OUTPUT_DIR = os.path.join(PARENT_DIR, "BlenderOutputs")

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

OUTPUT_FILE = os.path.join(OUTPUT_DIR, "verschattung_final_dst.csv")

print(f"Ziel-Datei: {OUTPUT_FILE}")
# ------------------------------------------------------------------

OBSTACLE_COLLECTION = "map_6.osm_buildings" 
SUN_OBJECT_NAME = "Sun"
WINDOW_KEYWORD = "IfcWindow" 

# Zeit-Einstellungen
SIMULATION_DATES = [(5, 2)] 
START_HOUR = 6
END_HOUR = 20
MINUTES_STEP = 60 # Für Test auf 60, später auf 15 stellen
YEAR = 2026
# ------------------------------------------------------------------

def get_last_sunday(year, month):
    """Findet den letzten Sonntag eines Monats im gegebenen Jahr."""
    if month == 12:
        next_month = datetime.date(year + 1, 1, 1)
    else:
        next_month = datetime.date(year, month + 1, 1)
    
    last_day_of_month = next_month - datetime.timedelta(days=1)
    offset = (last_day_of_month.weekday() + 1) % 7
    last_sunday = last_day_of_month - datetime.timedelta(days=offset)
    
    return last_sunday

def run_final_simulation():
    start_time = time.time()
    print("=" * 60)
    print("STARTE SORTIERTE MATRIX-SIMULATION MIT SOMMERZEIT")
    print("=" * 60)

    # 1. Ressourcen
    sun = bpy.data.objects.get(SUN_OBJECT_NAME)
    depsgraph = bpy.context.evaluated_depsgraph_get()
    
    # 2. Sensoren finden und sortieren
    raw_sensors = [obj for obj in bpy.context.scene.objects 
                   if WINDOW_KEYWORD in obj.name 
                   and "Style" not in obj.name 
                   and obj.type == 'MESH']
    
    print(f"Sortiere {len(raw_sensors)} Fenster...")
    raw_sensors.sort(key=lambda x: x.get("BMKZ", x.name))
    sensors = raw_sensors 
    
    # Datenspeicher vorbereiten
    results = [ [] for _ in sensors ]
    time_headers = []

    # 3. Hindernisse cachen
    obstacles = set()
    if OBSTACLE_COLLECTION in bpy.data.collections:
        for o in bpy.data.collections[OBSTACLE_COLLECTION].objects:
            obstacles.add(o.name)

    # 4. Simulation Loop Vorbereitung
    sp = bpy.context.scene.sun_pos_properties
    sp.year = YEAR
    
    dst_start_date = get_last_sunday(YEAR, 3) 
    dst_end_date = get_last_sunday(YEAR, 10) 
    print(f"INFO: Sommerzeit {YEAR}: {dst_start_date} bis {dst_end_date}")

    steps_per_day = int((END_HOUR - START_HOUR) * (60 / MINUTES_STEP)) + 1
    total_steps = len(SIMULATION_DATES) * steps_per_day
    current_step = 0

    # 5. Die Hauptschleife
    for day, month in SIMULATION_DATES:
        
        current_date_obj = datetime.date(YEAR, month, day)
        
        if dst_start_date <= current_date_obj < dst_end_date:
            sp.utc_zone = 2.0
            tz_label = "Sommerzeit (UTC+2)"
        else:
            sp.utc_zone = 1.0
            tz_label = "Winterzeit (UTC+1)"

        # Minuten-Schleife
        for total_minutes in range(START_HOUR * 60, (END_HOUR * 60) + 1, MINUTES_STEP):
            
            hour = total_minutes // 60
            minute = total_minutes % 60
            time_val = hour + (minute / 60.0)
            
            current_step += 1
            
            # --- FIX: Fortschrittsanzeige ---
            # Zeige Fortschritt alle 5 Schritte ODER wenn es der allerletzte Schritt ist
            if current_step % 5 == 0 or current_step == total_steps:
                print(f"Fortschritt: {current_step}/{total_steps} ({day}.{month}. {hour:02d}:{minute:02d} | {tz_label})")

            col_name = f"{day}.{month}._{hour:02d}:{minute:02d}"
            time_headers.append(col_name)

            sp.day = day
            sp.month = month
            sp.time = time_val
            bpy.context.view_layer.update()

            sun_loc = sun.matrix_world.translation
            is_night = sun_loc.z < 0 

            # --- OPTIMIERUNG 2: DER NACHT-SKIP ---
            if is_night:
                # Wir sparen uns die Schleife über 5000 Fenster!
                # Wir füllen einfach alle Listen direkt auf.
                for res_list in results:
                    res_list.append("2")
                # Sofort weiter zur nächsten Uhrzeit
                continue 

            # --- AB HIER NUR NOCH WENN SONNE SCHEINT ---
            
            # Vektoren vorbereiten (Sonne ist für alle Fenster gleich)
            # Das spart auch Rechenzeit
            
            # Raycast Loop über alle Fenster
            for i, sensor in enumerate(sensors):
                
                # Den "if is_night" Check hier drin brauchen wir nicht mehr,
                # da wir oben schon abgebrochen haben.

                start_loc = sensor.matrix_world.translation
                sun_vec = (sun_loc - start_loc)
                direction = sun_vec.normalized()
                dist = sun_vec.length
                
                ray_start = start_loc + (direction * 0.2)

                hit, _, _, _, hit_obj, _ = bpy.context.scene.ray_cast(
                    depsgraph,
                    ray_start,
                    direction,
                    distance=dist
                )
                
                # --- FIX: Strikte Physik (Backface Culling Ersatz) ---
                if hit:
                    if hit_obj.type == 'MESH':
                        # Treffer auf Mesh = Schatten (Egal ob Nachbar oder eigenes Fenster)
                        results[i].append("1")
                    else:
                        # Empty/Hilfsobjekt = Ignorieren
                        results[i].append("0")
                else:
                    results[i].append("0")

    # 6. Schreiben
    print("Schreibe CSV...")
    with open(OUTPUT_FILE, "w") as f:
        f.write("SensorID;" + ";".join(time_headers) + "\n")
        for i, sensor in enumerate(sensors):
            row_name = sensor.get("BMKZ", sensor.name)
            row_data = results[i]
            f.write(f"{row_name};" + ";".join(row_data) + "\n")

    duration = time.time() - start_time
    print(f"FERTIG in {duration:.2f} Sekunden.")
    print(f"Gespeichert unter: {OUTPUT_FILE}")

run_final_simulation()