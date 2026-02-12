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

def get_true_window_normal(obj, tower_center_2d):
    """
    Findet die physikalische Normale der größten Fläche (Scheibe)
    und stellt sicher, dass sie vom Turm weg zeigt.
    """
    mesh = obj.data
    matrix = obj.matrix_world
    matrix_rot = matrix.to_3x3()
    
    # 1. Wir suchen die größte Fläche (das Glas)
    largest_face = None
    max_area = -1.0
    
    # Quick-Check: Wenn das Mesh riesig ist, nur die ersten 50 Faces prüfen (Speed)
    limit = 50 
    for i, poly in enumerate(mesh.polygons):
        if i > limit: break
        if poly.area > max_area:
            max_area = poly.area
            largest_face = poly
            
    if largest_face is None:
        return Vector((0, 1, 0)) # Fallback
        
    # 2. Normale in Welt-Koordinaten umrechnen
    world_normal = (matrix_rot @ largest_face.normal).normalized()
    world_normal.z = 0 # Wir wollen nur die horizontale Ausrichtung
    
    # 3. Check: Zeigt sie nach Innen oder Außen?
    # Wir nehmen die echte Position der Fläche (nicht Objekt-Origin!)
    face_center_world = matrix @ largest_face.center
    face_pos_2d = Vector((face_center_world.x, face_center_world.y, 0))
    
    # Vektor vom Zentrum zur Fläche
    outward_dir = (face_pos_2d - tower_center_2d).normalized()
    
    # Wenn die Normale entgegengesetzt zum Zentrum zeigt (Dot < 0),
    # dann haben wir die Rückseite der Scheibe erwischt -> Umdrehen!
    if world_normal.dot(outward_dir) < 0:
        world_normal = -world_normal
        
    return world_normal

# --- KONFIGURATION ------------------------------------------------
try:
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    PARENT_DIR = os.path.dirname(SCRIPT_DIR)
    OUTPUT_DIR = os.path.join(PARENT_DIR, "BlenderOutputs")
except:
    OUTPUT_DIR = "C:/Temp" # Fallback

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

OUTPUT_FILE = os.path.join(OUTPUT_DIR, "verschattung_math_var2.csv")
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

    # --- NEU: PRE-CALCULATION DER ECHTEN GEOMETRIE-NORMALEN ---
    print("Berechne physikalische Normalen aus Mesh-Daten...")
    
    # 1. Turm-Zentrum berechnen (Basis für In/Out Check)
    # WICHTIG: Wir nutzen die Bounding Box Center, das ist sicherer als Origins
    center_sum = Vector((0, 0, 0))
    for s in sensors:
        # Mittelpunkt der Bounding Box in Weltkoordinaten
        bbox_center = sum((s.matrix_world @ Vector(corner) for corner in s.bound_box), Vector((0,0,0))) / 8.0
        center_sum += bbox_center
    
    if len(sensors) > 0:
        tower_center = center_sum / len(sensors)
        tower_center.z = 0 
        print(f"Turm-Zentrum erkannt bei: {tower_center}")
    else:
        tower_center = Vector((0,0,0))

    # 2. Normalen berechnen
    sensor_normals = []
    for s in sensors:
        # Hier rufen wir die neue Funktion auf!
        true_normal = get_true_window_normal(s, tower_center)
        sensor_normals.append(true_normal)
        
    print("Geometrie analysiert. Starte Simulation...")
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

# ... (dieser Teil steht IN der Zeitschleife nach der Berechnung von sun_vec_direction) ...

            # 1. NACHT-CHECK (-2)
            if is_night:
                for res_list in results:
                    res_list.append("-2") # Nacht
                continue 

            # 2. RAYCAST LOOP
            for i, sensor in enumerate(sensors):
                
                # Normale holen (Pre-Calculated Liste nutzen!)
                normal = sensor_normals[i]
                
                # Dot Product berechnen
                # > 0: Sonne scheint auf die Vorderseite
                # <= 0: Sonne scheint auf die Rückseite
                dot = sun_vec_direction.dot(normal)
                
                # --- BACKFACE CULLING (Rückseite - "-3") ---
                if dot <= 0:
                     # Die Sonne ist "hinter" der Scheibe.
                     # Du wolltest "0", aber Vorsicht: 0° wäre auch perfekter Frontal-Einschlag!
                     results[i].append("-3") 
                     continue

                # --- WINKEL BERECHNEN (Wenn Sonne auf Vorderseite) ---
                # Da beide Vektoren (sun_vec & normal) die Länge 1 haben, gilt:
                # Winkel = arccos(dot_product)
                # Wir begrenzen dot auf 1.0 (wegen float-Ungenauigkeiten > 1.0000001)
                dot_clamped = min(dot, 1.0)
                angle_rad = math.acos(dot_clamped)
                angle_deg = math.degrees(angle_rad) # Ergebnis z.B. 45.3 Grad

                # --- RAYCAST (Fremdverschattung prüfen) ---
                start_loc = sensor.matrix_world.translation
                direction = sun_vec_direction
                ray_start = start_loc + (direction * 0.3) 

                hit, _, _, _, hit_obj, _ = bpy.context.scene.ray_cast(
                    depsgraph, ray_start, direction, distance=1000.0 
                )
                
                if hit and hit_obj.type == 'MESH':
                    # --- FREMDVERSCHATTET (-1) ---
                    results[i].append("-1")
                else:
                    # --- SONNE PUR (Winkel eintragen) ---
                    # Wir speichern den Winkel als String mit 1 Nachkommastelle
                    results[i].append(f"{angle_deg:.1f}")

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