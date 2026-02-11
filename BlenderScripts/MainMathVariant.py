import bpy
import os
import time
import datetime
import math
from mathutils import Vector

# --- SONNEN-MATHEMATIK (NOAA Algorithmus) ---
def calculate_sun_vector(dt_utc, latitude, longitude):
    """Gibt Vektor zur Sonne zurück (Y=Norden, Z=Oben)"""
    RAD = math.pi / 180.0
    
    def jd_from_date(date):
        a = (14 - date.month) // 12
        y = date.year + 4800 - a
        m = date.month + 12 * a - 3
        return date.day + ((153 * m + 2) // 5) + 365 * y + y // 4 - y // 100 + y // 400 - 32045 + (date.hour - 12) / 24.0 + date.minute / 1440.0

    jd = jd_from_date(dt_utc)
    jc = (jd - 2451545.0) / 36525.0

    l0 = (280.46646 + 36000.76983 * jc + 0.0003032 * jc * jc) % 360
    m = 357.52911 + 35999.05029 * jc - 0.0001537 * jc * jc
    c = (1.914602 - 0.004817 * jc - 0.000014 * jc * jc) * math.sin(m * RAD) + \
        (0.019993 - 0.000101 * jc) * math.sin(2 * m * RAD) + \
        0.000289 * math.sin(3 * m * RAD)
    true_long = l0 + c
    obliquity = 23.439291 - 0.0130042 * jc - 0.00000016 * jc * jc + 25.696e-8 * jc * jc * jc
    
    ra = math.atan2(math.cos(obliquity * RAD) * math.sin(true_long * RAD), math.cos(true_long * RAD))
    dec = math.asin(math.sin(obliquity * RAD) * math.sin(true_long * RAD))
    
    gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + jc*jc*(0.000387933 - jc/38710000)
    gmst = (gmst % 360.0)
    lmst = gmst + longitude
    hour_angle = (lmst * RAD) - ra

    sin_lat = math.sin(latitude * RAD)
    cos_lat = math.cos(latitude * RAD)
    sin_dec = math.sin(dec)
    cos_dec = math.cos(dec)
    cos_ha = math.cos(hour_angle)

    sin_el = sin_lat * sin_dec + cos_lat * cos_dec * cos_ha
    elevation = math.asin(sin_el)

    cos_az = (sin_dec - sin_lat * sin_el) / (cos_lat * math.cos(elevation))
    cos_az = max(-1.0, min(1.0, cos_az))
    azimuth = math.acos(cos_az)

    if math.sin(hour_angle) > 0:
        azimuth = 2 * math.pi - azimuth

    z = math.sin(elevation)
    hyp = math.cos(elevation)
    y = hyp * math.cos(azimuth) 
    x = hyp * math.sin(azimuth)

    return Vector((x, y, z)), elevation

# --- KONFIGURATION ------------------------------------------------
try:
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    PARENT_DIR = os.path.dirname(SCRIPT_DIR)
    OUTPUT_DIR = os.path.join(PARENT_DIR, "BlenderOutputs")
except:
    OUTPUT_DIR = "C:/Temp" # Fallback

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

OUTPUT_FILE = os.path.join(OUTPUT_DIR, "verschattung_final_dst_math_optimized.csv")
print(f"Ziel-Datei: {OUTPUT_FILE}")
# ------------------------------------------------------------------

OBSTACLE_COLLECTION = "map_6.osm_buildings" 
SUN_OBJECT_NAME = "Sun"
WINDOW_KEYWORD = "IfcWindow" 

SIMULATION_DATES = [(5, 2)] 
START_HOUR = 6
END_HOUR = 20
MINUTES_STEP = 60
YEAR = 2026

# Koordinaten Frankfurt (Four)
LATITUDE = 50.11
LONGITUDE = 8.68
# ------------------------------------------------------------------

def run_final_simulation():
    start_time = time.time()
    print("=" * 60)
    print("STARTE OPTIMIERTE MATHE-SIMULATION")
    print("=" * 60)

    # 1. Ressourcen
    depsgraph = bpy.context.evaluated_depsgraph_get()
    
    # 2. Sensoren finden
    raw_sensors = [obj for obj in bpy.context.scene.objects 
                   if WINDOW_KEYWORD in obj.name 
                   and "Style" not in obj.name 
                   and obj.type == 'MESH']
    
    print(f"Sortiere {len(raw_sensors)} Fenster...")
    raw_sensors.sort(key=lambda x: x.get("BMKZ", x.name))
    sensors = raw_sensors 
    
    # Datenspeicher
    results = [ [] for _ in sensors ]
    time_headers = []

    # --- NEU: PRE-CALCULATION DER NORMALEN (Geometrisch) ---
    print("Berechne geometrische Normalen...")
    center_sum = Vector((0, 0, 0))
    valid_sensors = 0
    for s in sensors:
        center_sum += s.matrix_world.translation
        valid_sensors += 1
    
    if valid_sensors > 0:
        tower_center = center_sum / valid_sensors
        tower_center.z = 0 # Nur 2D-Zentrum wichtig
    else:
        tower_center = Vector((0,0,0)) # Fallback

    # Liste mit fixen Normalen erstellen (viel schneller als Matrix-Multiplikation im Loop)
    sensor_normals = []
    for s in sensors:
        # Vektor: Turm-Mitte -> Fenster = Normale nach Außen
        pos = s.matrix_world.translation.copy()
        pos.z = 0
        normal = (pos - tower_center).normalized()
        sensor_normals.append(normal)
    # -------------------------------------------------------

    # Zeit Setup
    dst_start_date = datetime.date(YEAR, 3, 29) # Vereinfacht für Code-Kürze (letzter So März)
    dst_end_date = datetime.date(YEAR, 10, 25)  # Vereinfacht (letzter So Okt)
    
    steps_per_day = int((END_HOUR - START_HOUR) * (60 / MINUTES_STEP)) + 1
    total_steps = len(SIMULATION_DATES) * steps_per_day
    current_step = 0

    # Hauptschleife
    for day, month in SIMULATION_DATES:
        current_date_obj = datetime.date(YEAR, month, day)
        
        if dst_start_date <= current_date_obj < dst_end_date:
            utc_offset = 2
            tz_label = "Sommerzeit"
        else:
            utc_offset = 1
            tz_label = "Winterzeit"

        for total_minutes in range(START_HOUR * 60, (END_HOUR * 60) + 1, MINUTES_STEP):
            current_step += 1
            hour = total_minutes // 60
            minute = total_minutes % 60
            
            # Mathe statt Blender-Sonne
            dt_local = datetime.datetime(YEAR, month, day, hour, minute)
            dt_utc = dt_local - datetime.timedelta(hours=utc_offset)
            sun_vec_direction, sun_elevation_rad = calculate_sun_vector(dt_utc, LATITUDE, LONGITUDE)
            
            is_night = math.degrees(sun_elevation_rad) < 0

            if current_step % 1 == 0 or current_step == total_steps:
                print(f"Fortschritt: {current_step}/{total_steps} ({day}.{month}. {hour:02d}:{minute:02d})")

            time_headers.append(f"{day}.{month}._{hour:02d}:{minute:02d}")

            # NACHT-SKIP
            if is_night:
                for res_list in results:
                    res_list.append("2")
                continue 

            # RAYCAST LOOP
            for i, sensor in enumerate(sensors):
                
                # --- BACKFACE CULLING (Jetzt mit korrekten Normalen) ---
                # Wir holen die vorberechnete Normale aus der Liste
                normal = sensor_normals[i]
                
                # Dot Product:
                # > 0: Sonne scheint von vorne (Winkel < 90°)
                # <= 0: Sonne scheint von hinten (Winkel > 90°) -> Schatten
                
                if sun_vec_direction.dot(normal) <= 0:
                     results[i].append("1")
                     continue
                # -------------------------------------------------------

                start_loc = sensor.matrix_world.translation
                direction = sun_vec_direction
                # Offset etwas erhöhen auf 30cm, um sicher zu gehen
                ray_start = start_loc + (direction * 0.3) 

                hit, _, _, _, hit_obj, _ = bpy.context.scene.ray_cast(
                    depsgraph, ray_start, direction, distance=1000.0 
                )
                
                if hit and hit_obj.type == 'MESH':
                    results[i].append("1")
                else:
                    results[i].append("0")

    # Schreiben
    print("Schreibe CSV...")
    with open(OUTPUT_FILE, "w") as f:
        f.write("SensorID;" + ";".join(time_headers) + "\n")
        for i, sensor in enumerate(sensors):
            row_name = sensor.get("BMKZ", sensor.name)
            f.write(f"{row_name};" + ";".join(results[i]) + "\n")

    duration = time.time() - start_time
    print(f"FERTIG in {duration:.2f} Sekunden.")

run_final_simulation()