import bpy
import os
import time
import datetime
import math
from mathutils import Vector

# --- SONNEN-MATHEMATIK (NOAA Algorithmus) ---
def calculate_sun_vector(dt_utc, latitude, longitude):
    """
    Berechnet den Sonnenvektor für einen UTC-Zeitpunkt und Koordinaten.
    Gibt einen normalisierten Blender-Vektor (X, Y, Z) zurück.
    Y = Norden, Z = Oben.
    """
    # Konstanten
    RAD = math.pi / 180.0
    DEG = 180.0 / math.pi

    # Zeit in Julian Centuries
    def jd_from_date(date):
        a = (14 - date.month) // 12
        y = date.year + 4800 - a
        m = date.month + 12 * a - 3
        return date.day + ((153 * m + 2) // 5) + 365 * y + y // 4 - y // 100 + y // 400 - 32045 + (date.hour - 12) / 24.0 + date.minute / 1440.0

    jd = jd_from_date(dt_utc)
    jc = (jd - 2451545.0) / 36525.0

    # Geometrische mittlere Länge der Sonne
    l0 = (280.46646 + 36000.76983 * jc + 0.0003032 * jc * jc) % 360
    
    # Mittlere Anomalie
    m = 357.52911 + 35999.05029 * jc - 0.0001537 * jc * jc
    
    # Exzentrizität der Erdbahn
    e = 0.016708634 - 0.000042037 * jc - 0.0000001267 * jc * jc
    
    # Sonnen-Gleichung des Zentrums
    c = (1.914602 - 0.004817 * jc - 0.000014 * jc * jc) * math.sin(m * RAD) + \
        (0.019993 - 0.000101 * jc) * math.sin(2 * m * RAD) + \
        0.000289 * math.sin(3 * m * RAD)

    # Wahre Länge und Anomalie
    true_long = l0 + c
    
    # Schiefe der Ekliptik
    obliquity = 23.439291 - 0.0130042 * jc - 0.00000016 * jc * jc + 25.696e-8 * jc * jc * jc
    
    # Rektaszension und Deklination
    ra = math.atan2(math.cos(obliquity * RAD) * math.sin(true_long * RAD), math.cos(true_long * RAD))
    dec = math.asin(math.sin(obliquity * RAD) * math.sin(true_long * RAD))

    # Greenwich Mean Sidereal Time
    gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + jc*jc*(0.000387933 - jc/38710000)
    gmst = (gmst % 360.0)

    # Stundenwinkel
    lmst = gmst + longitude
    hour_angle = (lmst * RAD) - ra

    # Elevation (Höhe) und Azimut
    sin_lat = math.sin(latitude * RAD)
    cos_lat = math.cos(latitude * RAD)
    sin_dec = math.sin(dec)
    cos_dec = math.cos(dec)
    cos_ha = math.cos(hour_angle)

    sin_el = sin_lat * sin_dec + cos_lat * cos_dec * cos_ha
    elevation = math.asin(sin_el)

    cos_az = (sin_dec - sin_lat * sin_el) / (cos_lat * math.cos(elevation))
    # Clamp wegen float ungenauigkeiten
    cos_az = max(-1.0, min(1.0, cos_az))
    azimuth = math.acos(cos_az)

    if math.sin(hour_angle) > 0:
        azimuth = 2 * math.pi - azimuth

    # Umrechnung in Blender Vektor (Y = Norden)
    # Z = Sin(Elevation)
    # Y = Cos(Elevation) * Cos(Azimuth)
    # X = Cos(Elevation) * Sin(Azimuth)
    
    z = math.sin(elevation)
    hyp = math.cos(elevation)
    y = hyp * math.cos(azimuth) 
    x = hyp * math.sin(azimuth)

    # Vektor erstellen (Richtung zur Sonne)
    vec = Vector((x, y, z))
    return vec, elevation

# --- KONFIGURATION ------------------------------------------------
# 1. Pfad dieses Skripts ermitteln
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# 2. Einen Ordner nach OBEN gehen
PARENT_DIR = os.path.dirname(SCRIPT_DIR)

# 3. Von dort in den Nachbarordner "BlenderOutputs" gehen
OUTPUT_DIR = os.path.join(PARENT_DIR, "BlenderOutputs")

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

OUTPUT_FILE = os.path.join(OUTPUT_DIR, "verschattung_final_dst_math.csv")

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

# Koordinaten für Frankfurt am Main (Four)
    LATITUDE = 50.11
    LONGITUDE = 8.68

    # 5. Die Hauptschleife (High Performance Mode)
    for day, month in SIMULATION_DATES:
        
        # Datumsobjekt erstellen
        current_date_obj = datetime.date(YEAR, month, day)
        
        # Sommerzeit Check (Offset bestimmen)
        if dst_start_date <= current_date_obj < dst_end_date:
            utc_offset = 2 # Sommerzeit UTC+2
            tz_label = "Sommerzeit (UTC+2)"
        else:
            utc_offset = 1 # Winterzeit UTC+1
            tz_label = "Winterzeit (UTC+1)"

        # Minuten-Schleife
        for total_minutes in range(START_HOUR * 60, (END_HOUR * 60) + 1, MINUTES_STEP):
            
            current_step += 1
            hour = total_minutes // 60
            minute = total_minutes % 60
            
            # --- NEU: Zeit in UTC umrechnen für die Mathe-Funktion ---
            # Wir erstellen ein datetime objekt für JETZT
            dt_local = datetime.datetime(YEAR, month, day, hour, minute)
            # Wir ziehen den Offset ab, um UTC zu bekommen
            dt_utc = dt_local - datetime.timedelta(hours=utc_offset)

            # --- NEU: Vektor berechnen statt Szene updaten ---
            # Wir rufen unsere Mathe-Funktion auf
            sun_vec_direction, sun_elevation_rad = calculate_sun_vector(dt_utc, LATITUDE, LONGITUDE)
            
            # Elevation in Grad für die Statistik
            sun_elevation_deg = math.degrees(sun_elevation_rad)
            is_night = sun_elevation_deg < 0

            # Fortschrittsanzeige
            if current_step % 10 == 0 or current_step == total_steps:
                print(f"Fortschritt: {current_step}/{total_steps} ({day}.{month}. {hour:02d}:{minute:02d} | {tz_label})")

            col_name = f"{day}.{month}._{hour:02d}:{minute:02d}"
            time_headers.append(col_name)

            # --- OPTIMIERUNG 2: DER NACHT-SKIP ---
            if is_night:
                for res_list in results:
                    res_list.append("2")
                continue 

            # --- RAYCAST ---
            # Wir nutzen jetzt den berechneten Vektor 'sun_vec_direction'
            # WICHTIG: Die Sonne ist "unendlich weit weg", die Richtung ist für alle Fenster gleich.
            
            for i, sensor in enumerate(sensors):
                start_loc = sensor.matrix_world.translation
                
                # Vektor = Richtung * Distanz (wir nehmen 1000m, damit es lang genug ist)
                # Aber für ray_cast brauchen wir nur die Richtung (direction)
                direction = sun_vec_direction
                
                # Offset 20cm Richtung Sonne
                ray_start = start_loc + (direction * 0.2)

                # Wir schießen 1000m weit in Richtung Sonne
                hit, _, _, _, hit_obj, _ = bpy.context.scene.ray_cast(
                    depsgraph,
                    ray_start,
                    direction,
                    distance=1000.0 
                )
                
                if hit:
                    if hit_obj.type == 'MESH':
                        results[i].append("1")
                    else:
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