import bpy
import math
from mathutils import Vector

# --- EINSTELLUNGEN ---
GAP_THRESHOLD_Z = 1.5 
START_FLOOR = 6    
PREFIX = "W"       
# ---------------------

def get_true_z_center(obj):
    # Berechnet den wahren geometrischen Z-Mittelpunkt des Objekts
    bbox_corners = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    z_center = sum(c.z for c in bbox_corners) / 8.0
    return z_center

def get_true_xy_center(obj):
    # Berechnet den wahren geometrischen XY-Mittelpunkt des Objekts
    bbox_corners = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    x_center = sum(c.x for c in bbox_corners) / 8.0
    y_center = sum(c.y for c in bbox_corners) / 8.0
    return (x_center, y_center)

def generate_bmkz():
    print("-" * 50)
    print("GENERIERE AUTOMATISCHE BMKZ (Bounding-Box Clustering)")
    print("-" * 50)
    
    # 1. Alle relevanten Fenster holen
    windows = [obj for obj in bpy.context.scene.objects 
               if "_Rain" in obj.name 
               and "Style" not in obj.name
               and obj.type == 'MESH'
               and obj.visible_get()]

    if not windows:
        print("Keine Fenster gefunden!")
        return

    # 2. Nach der WAHREN Geometrie-Höhe (Z) sortieren
    windows.sort(key=lambda x: get_true_z_center(x))
    
    # 3. Lückenbasierte Gruppierung (Clustering)
    floors = []
    current_floor_windows = []
    last_z = None

    for w in windows:
        z_level = get_true_z_center(w)
        
        if last_z is None or abs(z_level - last_z) < GAP_THRESHOLD_Z:
            current_floor_windows.append(w)
        else:
            floors.append(current_floor_windows)
            current_floor_windows = [w]
            
        last_z = z_level

    if current_floor_windows:
        floors.append(current_floor_windows)

    print(f"{len(floors)} Stockwerke anhand von Z-Lücken erkannt.")

    # 4. Fenster pro Stockwerk radial sortieren und benennen
    floor_index = START_FLOOR
    total_renamed = 0

    for floor_windows in floors:
        floor_name = f"{floor_index:02d}" 
        
        # Mittelpunkt des aktuellen Stockwerks berechnen (mit wahren Geometrie-Zentren)
        xy_centers = [get_true_xy_center(w) for w in floor_windows]
        avg_x = sum(center[0] for center in xy_centers) / len(floor_windows)
        avg_y = sum(center[1] for center in xy_centers) / len(floor_windows)
        floor_center = (avg_x, avg_y)

        # Sortierfunktion (Winkel atan2 vom Zentrum)
        def get_angle(obj):
            xy = get_true_xy_center(obj)
            x = xy[0] - floor_center[0]
            y = xy[1] - floor_center[1]
            return math.atan2(y, x)
        
        # Radial sortieren
        floor_windows.sort(key=get_angle)

        # Namen (BMKZ) vergeben
        window_idx = 1
        for w in floor_windows:
            new_bmkz = f"FL{floor_name}_{PREFIX}{window_idx:03d}"
            w["BMKZ"] = new_bmkz
            
            window_idx += 1
            total_renamed += 1
        
        floor_index += 1

    print(f"Fertig! {total_renamed} Fenster verarbeitet.")
    print(f"Beispiel-BMKZ des untersten Fensters: {windows[0]['BMKZ']}")

generate_bmkz()