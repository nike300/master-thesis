import bpy

for obj in bpy.context.scene.objects:
    if obj.type == 'MESH' and "BMKZ" in obj:
        obj.data.materials.clear()

print("Farben erfolgreich entfernt.")