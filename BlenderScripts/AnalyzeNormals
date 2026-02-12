import bpy
import bmesh
from mathutils import Vector

def draw_normals():
    sensors = [obj for obj in bpy.context.selected_objects if obj.type == 'MESH']
    
    # Turm Zentrum (vereinfacht)
    center = Vector((0,0,0))
    for s in sensors: center += s.matrix_world.translation
    center /= len(sensors)
    center.z = 0
    
    # Collection für Debug-Linien
    col_name = "DEBUG_NORMALS"
    if col_name in bpy.data.collections:
        bpy.data.collections.remove(bpy.data.collections[col_name])
    new_col = bpy.data.collections.new(col_name)
    bpy.context.scene.collection.children.link(new_col)
    
    print(f"Zeichne Normalen für {len(sensors)} Fenster...")
    
    for obj in sensors:
        # Logik kopiert aus der Lösung oben
        mesh = obj.data
        matrix = obj.matrix_world
        mat_rot = matrix.to_3x3()
        
        largest_face = sorted(mesh.polygons, key=lambda p: p.area)[-1]
        world_normal = (mat_rot @ largest_face.normal).normalized()
        world_normal.z = 0
        
        # Position der Fläche
        face_center = matrix @ largest_face.center
        out_dir = (Vector((face_center.x, face_center.y, 0)) - center).normalized()
        
        if world_normal.dot(out_dir) < 0:
            world_normal = -world_normal
            
        # Linie zeichnen (als Curve Object)
        curve_data = bpy.data.curves.new('normal_vec', type='CURVE')
        curve_data.dimensions = '3D'
        spline = curve_data.splines.new('POLY')
        
        # Start (Fenster) -> Ende (2m nach außen)
        p1 = face_center
        p2 = face_center + (world_normal * 2.0) # 2 Meter lang
        
        spline.points.add(1)
        spline.points[0].co = (p1.x, p1.y, p1.z, 1)
        spline.points[1].co = (p2.x, p2.y, p2.z, 1)
        
        curve_obj = bpy.data.objects.new(f"DEBUG_{obj.name}", curve_data)
        new_col.objects.link(curve_obj)

    print("Fertig! Blaue Linien im Ordner DEBUG_NORMALS prüfen.")

draw_normals()