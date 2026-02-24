import bpy
import os
import datetime
import math
from mathutils import Vector

# --- SONNEN-MATHEMATIK (NOAA Algorithmus) ---
def calculate_sun_vector(dt_utc, latitude, longitude):
    """Gibt Vektor zur Sonne zurück (Y=Norden, Z=Oben) und die Elevation in Radian."""
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

# Zeit-Konfiguration
SIMULATION_DATES = [(1, 3)] 
START_HOUR = 6
END_HOUR = 20
MINUTES_STEP = 60 
YEAR = 2026

# Geokoordinaten (Frankfurt)
LATITUDE = 50.11
LONGITUDE = 8.68
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
    print(f"STARTE DETAIL-ANALYSE (MATH PHYSICS ONLY) FÜR: {sensor_name}")
    print("=" * 60)

    # 2. Ressourcen
    depsgraph = bpy.context.evaluated_depsgraph_get()
    
    obstacles = set()
    if OBSTACLE_COLLECTION in bpy.data.collections:
        for o in bpy.data.collections[OBSTACLE_COLLECTION].objects:
            obstacles.add(o.name)

    # 3. Simulation Vorbereitung
    dst_start = get_last_sunday(YEAR, 3)
    dst_end = get_last_sunday(YEAR, 10)

    data_rows = []

    for day, month in SIMULATION_DATES:
        current_date = datetime.date(YEAR, month, day)
        
        # Sommerzeit Check
        if dst_start <= current_date < dst_end:
            utc_offset = 2
            tz_info = "Sommerzeit"
        else:
            utc_offset = 1
            tz_info = "Winterzeit"

        for total_minutes in range(START_HOUR * 60, (END_HOUR * 60) + 1, MINUTES_STEP):
            hour = total_minutes // 60
            minute = total_minutes % 60
            
            # Zeit in UTC umrechnen für NOAA Mathe
            dt_local = datetime.datetime(YEAR, month, day, hour, minute)
            dt_utc = dt_local - datetime.timedelta(hours=utc_offset)

            # Sonnen-Vektor und Elevation berechnen
            sun_vec_direction, sun_elevation_rad = calculate_sun_vector(dt_utc, LATITUDE, LONGITUDE)
            sun_elevation_deg = math.degrees(sun_elevation_rad)
            
            is_night = sun_elevation_deg < 0

            # A) Nacht
            if is_night:
                # Wir schreiben jetzt die Elevation in Grad in die CSV, nicht mehr den Z-Wert des Blender-Objekts
                data_rows.append(f"{day}.{month}.{YEAR};{hour:02d}:{minute:02d};2;NACHT;{sun_elevation_deg:.2f}°")
                continue

            # B) Raycast (Physikalisch gegen ALLES)
            start_loc = sensor.matrix_world.translation
            direction = sun_vec_direction
            dist = 1000.0 # Wir schießen "unendlich" weit zur Sonne

            # Offset 0.2m Richtung Sonne, damit das Fenster sich nicht selbst auf der Ursprungsfläche blockiert
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

            data_rows.append(f"{day}.{month}.{YEAR};{hour:02d}:{minute:02d};{status};{blocker_name};{sun_elevation_deg:.2f}°")

    # 4. Schreiben
    with open(output_file, "w") as f:
        f.write("Datum;Uhrzeit;Status_Code;Verursacher_Name;Sonnen_Elevation_Grad\n")
        f.write("\n".join(data_rows))

    print(f"FERTIG! Detail-Datei erstellt: {output_file}")

analyze_active_window()