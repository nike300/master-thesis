import bpy
import math

# --- KONFIGURATION FÜR DEN VISUAL-CHECK ---
CHECK_MONTH = 2      # Monat (z.B. Februar)
CHECK_DAY = 5        # Tag
CHECK_HOUR = 17      # Stunde
CHECK_MINUTE = 0     # Minute
YEAR = 2026

RAY_OFFSET = 0.8     # 20cm Abstand vom Fensterglas
MAX_DRAW_DIST = 50.0 # Wie lang die grüne Linie gezeichnet wird (wenn kein Treffer)
# ------------------------------------------

def create_mat(name, color):
    if name in bpy.data.materials:
        return bpy.data.materials[name]
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = False
    mat.diffuse_color = color
    return mat

def draw_line(name, p1, p2, material):
    # Kurve erstellen
    curve_data = bpy.data.curves.new(name, type='CURVE')
    curve_data.dimensions = '3D'
    polyline = curve_data.splines.new('POLY')
    polyline.points.add(1)
    polyline.points[0].co = (p1.x, p1.y, p1.z, 1)
    polyline.points[1].co = (p2.x, p2.y, p2.z, 1)
    
    obj = bpy.data.objects.new(name, curve_data)
    bpy.context.collection.objects.link(obj)
    
    # Dicke geben (Bevel)
    curve_data.bevel_depth = 0.05
    
    if material:
        obj.data.materials.append(material)
    return obj

def draw_marker(name, loc, size, material):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=size, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    if material:
        obj.data.materials.append(material)
    return obj

def visualize_raycast():
    # 1. Setup
    sensor = bpy.context.active_object
    if not sensor:
        print("Bitte ein Fenster auswählen!")
        return

    # Alte Debug-Objekte aufräumen (optional)
    for o in bpy.context.scene.objects:
        if o.name.startswith("DEBUG_"):
            bpy.data.objects.remove(o, do_unlink=True)

    print(f"--- VISUALISIERUNG: {CHECK_DAY}.{CHECK_MONTH}. {CHECK_HOUR}:{CHECK_MINUTE} ---")

    # 2. Zeit einstellen
    sun = bpy.data.objects.get("Sun")
    sp = bpy.context.scene.sun_pos_properties
    sp.year = YEAR
    sp.month = CHECK_MONTH
    sp.day = CHECK_DAY
    # Einfache Zeitzone für den Test (ggf. anpassen wie im Hauptskript)
    sp.utc_zone = 1.0 
    sp.time = CHECK_HOUR + (CHECK_MINUTE / 60.0)
    bpy.context.view_layer.update()

    # 3. Vektoren berechnen
    start_loc = sensor.matrix_world.translation
    sun_loc = sun.matrix_world.translation
    sun_vec = (sun_loc - start_loc)
    direction = sun_vec.normalized()
    dist = sun_vec.length

    # 4. Der entscheidende Offset-Startpunkt
    ray_start = start_loc + (direction * RAY_OFFSET)

    # 5. Raycast schießen
    depsgraph = bpy.context.evaluated_depsgraph_get()
    hit, hit_loc, hit_normal, _, hit_obj, _ = bpy.context.scene.ray_cast(
        depsgraph,
        ray_start,
        direction,
        distance=dist
    )

    # 6. Zeichnen (Materials)
    mat_red = create_mat("Debug_Red", (1, 0, 0, 1))     # Schatten
    mat_green = create_mat("Debug_Green", (0, 1, 0, 1)) # Sonne
    mat_blue = create_mat("Debug_Blue", (0, 0, 1, 1))   # Startpunkt

    # A) Startpunkt markieren (Blaue Kugel)
    # Damit siehst du, ob der Strahl VOR dem Glas startet
    draw_marker("DEBUG_StartPoint", ray_start, 0.1, mat_blue)

    # B) Verbindungslinie Fenster -> Startpunkt (dünn grau)
    # Damit du den Offset siehst
    draw_line("DEBUG_OffsetLine", start_loc, ray_start, None)

    if hit and hit_obj.type == 'MESH':
        print(f"TREFFER! Objekt: {hit_obj.name}")
        
        # Rote Linie bis zum Treffer
        draw_line("DEBUG_Ray_Blocked", ray_start, hit_loc, mat_red)
        
        # Treffer markieren
        draw_marker("DEBUG_HitPoint", hit_loc, 0.15, mat_red)
        
    else:
        print("FREIE SICHT! (Sonne)")
        # Grüne Linie in den Himmel zeichnen
        end_point = ray_start + (direction * MAX_DRAW_DIST)
        draw_line("DEBUG_Ray_Clear", ray_start, end_point, mat_green)

visualize_raycast()