import bpy
import os
import time
import datetime
import math
from mathutils import Vector

# --- KONFIGURATION ------------------------------------------------
try:
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    PARENT_DIR = os.path.dirname(SCRIPT_DIR)
    OUTPUT_DIR = os.path.join(PARENT_DIR, "BlenderOutputs")
except:
    OUTPUT_DIR = "C:/Temp" # Fallback

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

# --- Konfiguration ---
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "21.06.2026.csv")
print(f"Ziel-Datei: {OUTPUT_FILE}")
# --- SCHALTER ---
OUTPUT_ANGLE = True  # True: Gibt den Azimut aus | False: Gibt nur '0' aus
# --- Zeiteinstellungen ---
YEAR = 2026
SIMULATION_DATES = []
start_date = datetime.date(YEAR, 6, 21)
for i in range(1): 
    current_date = start_date + datetime.timedelta(days=i)
    SIMULATION_DATES.append((current_date.day, current_date.month))
START_HOUR = 5
END_HOUR = 22
MINUTES_STEP = 15
# --- Koordinaten ---
LATITUDE = 50.1126
LONGITUDE = 8.67472
# ------------------------------------------------------------------

# --- SONNEN-MATHEMATIK (NOAA Algorithmus) ---
def calculate_sun_vector(dt_utc, latitude, longitude):
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
    if math.sin(hour_angle) > 0: azimuth = 2 * math.pi - azimuth
    z = math.sin(elevation)
    hyp = math.cos(elevation)
    y = hyp * math.cos(azimuth) 
    x = hyp * math.sin(azimuth)
    return Vector((x, y, z)), elevation

def get_true_window_normal_and_corners(obj, tower_center_2d):
    mesh = obj.data
    matrix = obj.matrix_world
    matrix_rot = matrix.to_3x3()
    largest_face = None
    max_area = -1.0
    limit = 50 
    for i, poly in enumerate(mesh.polygons):
        if i > limit: break
        if poly.area > max_area:
            max_area = poly.area
            largest_face = poly
    if largest_face is None: return Vector((0, 1, 0)), [matrix.translation]
    world_normal = (matrix_rot @ largest_face.normal).normalized()
    world_normal.z = 0 
    face_center_world = matrix @ largest_face.center
    face_pos_2d = Vector((face_center_world.x, face_center_world.y, 0))
    outward_dir = (face_pos_2d - tower_center_2d).normalized()
    if world_normal.dot(outward_dir) < 0: world_normal = -world_normal
    corners_world = []
    for loop_idx in largest_face.loop_indices:
        vertex_idx = mesh.loops[loop_idx].vertex_index
        corners_world.append(matrix @ mesh.vertices[vertex_idx].co)
    return world_normal, corners_world

def run_final_simulation():
    start_time = time.time()
    print("=" * 60)
    print(f"STARTE SIMULATION")
    print("=" * 60)
    
    depsgraph = bpy.context.evaluated_depsgraph_get()
    
    # --- STRIKTER BMKZ FILTER ---
    raw_sensors = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH' and "BMKZ" in obj]
    print(f"Es wurden {len(raw_sensors)} gültige Fensterscheiben mit BMKZ gefunden.")
    
    # Sortieren nach BMKZ für saubere Spalten in der CSV
    raw_sensors.sort(key=lambda x: str(x["BMKZ"]))
    sensors = raw_sensors 
    
    results = [ [] for _ in sensors ]
    time_headers = []
    
    # Geometrie Vorverarbeitung
    print("Berechne physikalische Normalen und Eckpunkte...")
    center_sum = Vector((0, 0, 0))
    for s in sensors: 
        center_sum += sum((s.matrix_world @ Vector(corner) for corner in s.bound_box), Vector((0,0,0))) / 8.0
    tower_center = center_sum / len(sensors) if sensors else Vector((0,0,0))
    tower_center.z = 0 
    
    sensor_geometry = []
    for s in sensors:
        normal, corners = get_true_window_normal_and_corners(s, tower_center)
        sensor_geometry.append({"normal": normal, "corners": corners})
    
    # Setup Zeiten
    dst_start_date = datetime.date(YEAR, 3, 29) 
    dst_end_date = datetime.date(YEAR, 10, 25)  
    total_steps = len(SIMULATION_DATES) * (int((END_HOUR - START_HOUR) * (60 / MINUTES_STEP)) + 1)
    current_step = 0

    # Hauptschleife
    for day, month in SIMULATION_DATES:
        current_date_obj = datetime.date(YEAR, month, day)
        utc_offset = 2 if dst_start_date <= current_date_obj < dst_end_date else 1
        
        for total_minutes in range(START_HOUR * 60, (END_HOUR * 60) + 1, MINUTES_STEP):
            current_step += 1
            hour, minute = total_minutes // 60, total_minutes % 60
            
            dt_utc = datetime.datetime(YEAR, month, day, hour, minute) - datetime.timedelta(hours=utc_offset)
            sun_vec_direction, sun_elevation_rad = calculate_sun_vector(dt_utc, LATITUDE, LONGITUDE)
            is_night = math.degrees(sun_elevation_rad) < 0
            
            if current_step % 1 == 0 or current_step == total_steps: 
                print(f"Fortschritt: {current_step}/{total_steps} ({day}.{month}. {hour:02d}:{minute:02d})")
                
            time_headers.append(f"{day}.{month}._{hour:02d}:{minute:02d}")
            
            if is_night:
                for res_list in results: res_list.append("N") 
                continue 

            # Raycast Schleife
            for i, sensor in enumerate(sensors):
                geom = sensor_geometry[i]
                dot = sun_vec_direction.dot(geom["normal"])
                
                # Backface Culling
                if dot <= 0:
                     results[i].append("R") 
                     continue
                
                is_completely_shaded = True
                
                # Ecken-Prüfung
                for corner_loc in geom["corners"]:
                    ray_start = corner_loc + (sun_vec_direction * 0.3) 
                    hit, _, _, _, hit_obj, _ = bpy.context.scene.ray_cast(depsgraph, ray_start, sun_vec_direction, distance=1000.0)
                    
                    if not (hit and hit_obj.type == 'MESH'):
                        is_completely_shaded = False
                        break # Eine sonnige Ecke reicht -> Abbruch!
                
                # Auswertung
                if is_completely_shaded:
                    results[i].append("V") # Komplett im Schatten
                else:
                    if OUTPUT_ANGLE:
                        # --- NEU: Relativer horizontaler Azimut ---
                        # 1. 2D-Winkel (XY-Ebene) von Sonne und Fenster berechnen
                        sun_az = math.atan2(sun_vec_direction.y, sun_vec_direction.x)
                        win_az = math.atan2(geom["normal"].y, geom["normal"].x)
                        
                        # 2. Differenz in Grad berechnen
                        az_diff = math.degrees(sun_az - win_az)
                        
                        # 3. Winkel auf den Bereich -180° bis +180° normieren
                        az_diff = (az_diff + 180) % 360 - 180
                        
                        # Ausgabe in die Liste (z.B. -45.2 oder 70.1)
                        results[i].append(f"{az_diff:.1f}")
                    else:
                        results[i].append("0")

    # --- CSV EXPORT (TRANSIPONIERT) ---
    print("Schreibe CSV...")
    with open(OUTPUT_FILE, "w") as f:
        # Kopfzeile mit allen echten BMKZ Werten
        sensor_names = [str(sensor["BMKZ"]) for sensor in sensors]
        f.write("Zeitpunkt;" + ";".join(sensor_names) + "\n")
        
        # Daten-Zeilen (Zeiten)
        for t, time_label in enumerate(time_headers):
            # Hier die Änderung: .replace('.', ',') für jeden Wert
            row_data = [str(results[i][t]).replace('.', ',') for i in range(len(sensors))]
            f.write(f"{time_label};" + ";".join(row_data) + "\n")
    print(f"FERTIG in {time.time() - start_time:.2f} Sekunden.")

run_final_simulation()