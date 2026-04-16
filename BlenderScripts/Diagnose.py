import bpy

# Wir prüfen genau die Logik, die auch die Simulation nutzt
found_objects = [obj for obj in bpy.context.scene.objects if "BMKZ" in obj and obj.type == 'MESH']

print("--- DIAGNOSE: GEFUNDENE OBJEKTE ---")
print(f"Anzahl gesamt: {len(found_objects)}")

# Wir geben die ersten 20 Namen aus, um ein Muster zu erkennen
for i, obj in enumerate(found_objects[:50]):
    print(f"{i+1}: Name: {obj.name} | BMKZ: {obj['BMKZ']}")

print("----------------------------------")