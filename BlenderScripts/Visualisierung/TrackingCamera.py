import bpy

# WICHTIG: Das Objekt in deiner Szene, das die Sonne darstellt, muss "Sun" heißen.
SUN_NAME = "Sun"

def setup_tracking_camera():
    selected_obj = bpy.context.active_object
    if not selected_obj or selected_obj.type != 'MESH':
        return print("FEHLER: Bitte wähle zuerst ein Fenster im 3D Viewport aus!")

    if SUN_NAME not in bpy.data.objects:
        return print(f"FEHLER: Kein Objekt namens '{SUN_NAME}' gefunden!")
    sun_obj = bpy.data.objects[SUN_NAME]

    # --- NEU: Echten Mittelpunkt der Scheibe finden ---
    mesh = selected_obj.data
    matrix = selected_obj.matrix_world
    
    # Größte Fläche (die Scheibe) finden
    largest_face = max(mesh.polygons, key=lambda p: p.area)
    
    # Mittelpunkt und Normale in Weltkoordinaten umrechnen
    face_center_world = matrix @ largest_face.center
    face_normal_world = (matrix.to_3x3() @ largest_face.normal).normalized()
    # --------------------------------------------------

    # Neue Kamera erstellen
    cam_data = bpy.data.cameras.new(name="WindowCam_Data")
    cam_data.lens = 24 # Weitwinkel
    cam_obj = bpy.data.objects.new("WindowCam", cam_data)
    bpy.context.collection.objects.link(cam_obj)

    # Kamera auf den Mittelpunkt setzen und 0.5 Meter nach außen schieben
    cam_obj.location = face_center_world + (face_normal_world * 0.5)

    # Track-To Constraint hinzufügen
    track_constraint = cam_obj.constraints.new(type='TRACK_TO')
    track_constraint.target = sun_obj
    track_constraint.track_axis = 'TRACK_NEGATIVE_Z'
    track_constraint.up_axis = 'UP_Y'

    # Kamera zur "aktiven" Szene-Kamera machen
    bpy.context.scene.camera = cam_obj
    print(f"ERFOLG: Kamera schwebt nun vor {selected_obj.name} und trackt die Sonne!")

setup_tracking_camera()