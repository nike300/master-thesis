import bpy
import bmesh
from mathutils import Vector

def align_normals_outward():
    # 1. Alle ausgewählten Objekte holen (Deine Fenster)
    selected_objects = [obj for obj in bpy.context.selected_objects if obj.type == 'MESH']
    
    if not selected_objects:
        print("Bitte zuerst die Fenster auswählen!")
        return

    print(f"Korrigiere Normalen für {len(selected_objects)} Objekte...")

    # 2. Das Zentrum des Turms berechnen (Durchschnitt aller Positionen)
    # Alternativ kannst du hier manuell Koordinaten setzen, z.B. center = Vector((10, 5, 0))
    center_sum = Vector((0, 0, 0))
    for obj in selected_objects:
        center_sum += obj.matrix_world.translation
    
    tower_center = center_sum / len(selected_objects)
    # Wir ignorieren die Höhe (Z), wir wollen nur, dass sie "horizontal" nach außen zeigen
    tower_center.z = 0 
    
    print(f"Berechnetes Turm-Zentrum (X,Y): {tower_center.x:.2f}, {tower_center.y:.2f}")

    # 3. Schleife über alle Objekte
    bpy.ops.object.mode_set(mode='EDIT')
    
    # Da wir im Multi-Edit-Mode sind, müssen wir das Mesh anders laden
    bm = bmesh.from_edit_mesh(bpy.context.edit_object.data) # Nimmt das aktive
    
    # ACHTUNG: Multi-Object Edit via API ist tricky. 
    # Wir machen es lieber sicher: Objekt für Objekt.
    bpy.ops.object.mode_set(mode='OBJECT')

    for obj in selected_objects:
        mesh = obj.data
        
        # In den BMesh Modus wechseln (schneller RAM Zugriff)
        bm = bmesh.new()
        bm.from_mesh(mesh)
        
        mesh_center = obj.matrix_world.translation
        
        faces_flipped = 0
        
        for face in bm.faces:
            # Wo ist die Fläche in der Welt?
            # Wir nehmen den Flächenmittelpunkt + Objektposition
            face_center_world = obj.matrix_world @ face.calc_center_median()
            
            # Vektor vom Turm-Zentrum zur Fläche (Das ist "Soll-Richtung")
            direction_out = face_center_world - tower_center
            direction_out.z = 0 # Nur horizontale Ausrichtung wichtig
            
            # Aktuelle Normale der Fläche (in Welt-Rotation)
            current_normal_world = obj.matrix_world.to_3x3() @ face.normal
            current_normal_world.z = 0
            
            # Skalarprodukt: Zeigen sie in die gleiche Richtung?
            # < 0 bedeutet: Sie zeigen entgegengesetzt (Winkel > 90 Grad) -> Nach Innen
            if direction_out.dot(current_normal_world) < 0:
                face.normal_flip()
                faces_flipped += 1
        
        # Änderungen zurückschreiben
        if faces_flipped > 0:
            bm.to_mesh(mesh)
            mesh.update()
        
        bm.free()

    print("Fertig! Normalen sind jetzt nach außen gerichtet.")

align_normals_outward()