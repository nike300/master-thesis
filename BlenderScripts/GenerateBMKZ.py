import bpy
import math

# --- EINSTELLUNGEN ---
TOLERANCE_Z = 0.5  # Fenster innerhalb von 0.5m Höhe gehören zum selben Stockwerk
PREFIX = "W"       # W für Window/Fenster
# ---------------------

def generate_bmkz():
    print("-" * 50)
    print("GENERIERE AUTOMATISCHE BMKZ (Raum-IDs)")
    print("-" * 50)
    
    # 1. Alle relevanten Fenster holen (ohne Styles)
    windows = [obj for obj in bpy.context.scene.objects 
               if "IfcWindow" in obj.name 
               and "Style" not in obj.name 
               and obj.type == 'MESH']

    if not windows:
        print("Keine Fenster gefunden!")
        return

    # 2. Nach Höhe (Z) sortieren
    # Wir runden die Z-Werte, um "Floors" zu bilden
    windows.sort(key=lambda x: round(x.matrix_world.translation.z / TOLERANCE_Z))
    
    # Gruppieren in Stockwerke
    floors = {}
    for w in windows:
        z_level = round(w.matrix_world.translation.z, 1) # Auf 10cm genau runden
        found_floor = False
        
        # Check ob wir schon einen Key in der Nähe haben (wg. Ungenauigkeit)
        for f_height in floors.keys():
            if abs(f_height - z_level) < TOLERANCE_Z:
                floors[f_height].append(w)
                found_floor = True
                break
        
        if not found_floor:
            floors[z_level] = [w]

    print(f"{len(floors)} Stockwerke erkannt.")

    # 3. Fenster pro Stockwerk sortieren und benennen
    # Wir sortieren die Stockwerke von unten nach oben
    sorted_levels = sorted(floors.keys())
    
    floor_index = 0
    total_renamed = 0

    for z in sorted_levels:
        floor_windows = floors[z]
        floor_name = f"{floor_index:02d}" # 00, 01, 02... (Erdgeschoss = 00)
        
        # WICHTIG: Sortierung innerhalb des Stockwerks
        # Strategie: Wir sortieren nach Winkel um den Mittelpunkt (im Uhrzeigersinn)
        # 1. Mittelpunkt des Stockwerks berechnen
        avg_x = sum([w.matrix_world.translation.x for w in floor_windows]) / len(floor_windows)
        avg_y = sum([w.matrix_world.translation.y for w in floor_windows]) / len(floor_windows)
        center = (avg_x, avg_y)

        # 2. Sortierfunktion (Winkel atan2)
        def get_angle(obj):
            x = obj.matrix_world.translation.x - center[0]
            y = obj.matrix_world.translation.y - center[1]
            return math.atan2(y, x) # Gibt Winkel von -Pi bis +Pi zurück
        
        # Sortieren (startet meist bei "Westen" oder "Süden" je nach atan2 Definition)
        floor_windows.sort(key=get_angle)

        # 3. Namen vergeben
        window_idx = 1
        for w in floor_windows:
            # Himmelsrichtung grob bestimmen (optional für den Namen)
            # Wir nehmen vereinfacht nur Index: OG01_W001, OG01_W002...
            
            # Das neue BMKZ Format: FL[Stockwerk]_W[Nummer]
            # Z.B.: FL05_W023 (Floor 5, Window 23)
            new_bmkz = f"FL{floor_name}_{PREFIX}{window_idx:03d}"
            
            # WICHTIG: Wir schreiben es in eine Custom Property, nicht den Namen überschreiben (sicherer)
            w["BMKZ"] = new_bmkz
            
            # Optional: Auch im Viewport anzeigen (Name ändern, falls gewünscht)
            # w.name = new_bmkz # <-- Kommentar entfernen, wenn du das Objekt wirklich umbenennen willst
            
            window_idx += 1
            total_renamed += 1
        
        floor_index += 1

    print(f"Fertig! {total_renamed} Fenster mit BMKZ versehen.")
    print("Beispiel: Das erste Fenster heißt jetzt intern:", windows[0]["BMKZ"])

generate_bmkz()