import bpy

# SCHWELLENWERT: Alles unter dieser Fläche (in qm) wird markiert
MIN_AREA = 0.5 

def select_tiny_windows():
    bpy.ops.object.select_all(action='DESELECT')
    tiny_count = 0
    
    for obj in bpy.context.scene.objects:
        if "IfcWindow" in obj.name and obj.type == 'MESH':
            # Berechnung der Bounding Box Größe
            # (Näherungswert: Breite * Höhe)
            dims = obj.dimensions
            # Wir nehmen an, das Fenster ist vertikal. Wir multiplizieren die zwei größten Werte.
            # (sortiert die Dimensionen X, Y, Z und nimmt die zwei größten)
            sorted_dims = sorted([dims.x, dims.y, dims.z])
            area = sorted_dims[1] * sorted_dims[2]
            
            if area < MIN_AREA:
                obj.select_set(True)
                tiny_count += 1
                print(f"Winziges Fenster gefunden: {obj.name} ({area:.2f} m²)")

    print(f"Fertig. {tiny_count} zu kleine Fenster markiert.")

select_tiny_windows()