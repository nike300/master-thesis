import bpy

def center_origins():
    print("Starte Zentrierung der Origins...")
    
    # 1. Alles abwählen
    bpy.ops.object.select_all(action='DESELECT')
    
    # 2. Nur Fenster auswählen
    count = 0
    for obj in bpy.context.scene.objects:
        if "FAS_PAN" in obj.name and obj.type == 'MESH':
            obj.select_set(True)
            count += 1
            
    print(f"{count} Fenster ausgewählt.")
    
    # 3. Der Massen-Befehl (Origin to Geometry)
    # Center 'MEDIAN' setzt den Punkt genau in die mathematische Mitte der Bounding Box
    if count > 0:
        bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='MEDIAN')
        print("Origins zentriert!")
    else:
        print("Keine Fenster gefunden.")

center_origins()