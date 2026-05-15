import bpy
import os
import csv

# --- KONFIGURATION --------------------------------------------------
CSV_FILE = r"C:\Users\SESA766787\Desktop\master-thesis\BlenderOutputs\Visualisierung.csv"

# Dein gewünschter Zeitpunkt (wie in der CSV Zeile 1 oder 2)
TARGET_TIME = "21.6._09:15" 
# --------------------------------------------------------------------

def visualize_csv_strict():
    print("=" * 60)
    print(f"STARTE VISUALISIERUNG FÜR: {TARGET_TIME}")
    
    mats = {
        "Vis_Sonne":         (0.2, 0.8, 0.2, 1.0), # Grün  (>= 0)
        "Vis_Fremdschatten": (0.8, 0.1, 0.1, 1.0), # Rot   (-1)
        "Vis_Eigenschatten": (0.3, 0.3, 0.3, 1.0), # Grau  (-3)
        "Vis_Nacht":         (0.05, 0.05, 0.2, 1.0)  # Blau  (-2)
    }
    
    blender_mats = {}
    for name, col in mats.items():
        if name not in bpy.data.materials:
            m = bpy.data.materials.new(name=name)
            m.diffuse_color = col
            blender_mats[name] = m
        else: 
            blender_mats[name] = bpy.data.materials[name]

    if not os.path.exists(CSV_FILE):
        return print(f"FEHLER: Datei {CSV_FILE} nicht gefunden!")

    sensor_names = []
    target_values = []

    with open(CSV_FILE, 'r') as f:
        reader = csv.reader(f, delimiter=';')
        rows = list(reader)
        
        if len(rows) < 2: return print("FEHLER: CSV ist leer.")
        
        sensor_names = rows[0][1:] 
        
        time_found = False
        for row in rows[1:]:
            if row[0] == TARGET_TIME:
                target_values = row[1:]
                time_found = True
                break
                
        if not time_found:
            return print(f"FEHLER: Zeitpunkt '{TARGET_TIME}' nicht in der CSV gefunden!")

    sensor_states = {}
    for i, s_name in enumerate(sensor_names):
        if i < len(target_values):
            val_str = target_values[i].replace(",", ".")
            try: 
                sensor_states[s_name] = float(val_str)
            except: 
                continue

    # --- HIER IST DIE MAGIE: STRIKTER BMKZ FILTER ---
    count = 0
    for obj in bpy.context.scene.objects:
        
        # 1. Prüfen, ob es ein Mesh ist
        # 2. Prüfen, ob das Custom Property "BMKZ" existiert
        if obj.type == 'MESH' and "BMKZ" in obj:
            
            sid = obj["BMKZ"] # Echten Wert auslesen
            
            if sid in sensor_states:
                val = sensor_states[sid]
                
                if val == -2: mat = blender_mats["Vis_Nacht"]
                elif val == -3: mat = blender_mats["Vis_Eigenschatten"]
                elif val == -1: mat = blender_mats["Vis_Fremdschatten"]
                else: mat = blender_mats["Vis_Sonne"] 
                
                if not obj.data.materials: 
                    obj.data.materials.append(mat)
                else: 
                    obj.data.materials[0] = mat
                
                count += 1
            
    bpy.context.view_layer.update()
    print(f"ERFOLG: {count} echte Glasscheiben eingefärbt.")
    print("=" * 60)

visualize_csv_strict()