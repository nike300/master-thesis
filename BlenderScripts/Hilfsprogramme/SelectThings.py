import bpy

# 1. Aktuelle Auswahl aufheben
bpy.ops.object.select_all(action='DESELECT')

# 2. Deinen Filter anwenden
windows = [obj for obj in bpy.context.scene.objects 
           if "_Rain" in obj.name 
           and "Style" not in obj.name
           and "FAS_PAN_XXX_TB_L" not in obj.name 
           and obj.type == 'MESH'
           and obj.visible_get()]

# 3. Gefilterte Objekte auswählen
for obj in windows:
    obj.select_set(True)

# 4. Letztes Objekt "aktiv" setzen (Standard-Verhalten in Blender)
if windows:
    bpy.context.view_layer.objects.active = windows[-1]

print(f"Erfolg: Es wurden {len(windows)} Objekte ausgewählt.")