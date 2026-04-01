import bpy
import bmesh

def calculate_global_area(obj):
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.transform(obj.matrix_world)
    area = sum(f.calc_area() for f in bm.faces)
    bm.free()
    return area

def assign_aks_to_selected_windows():
    WINDOW_KEYWORD = "_PAN_"
    selected_objs = bpy.context.selected_objects
    
    # Trennung der Objekttypen und Filterung nach Namenskonvention
    mesh_objs = [obj for obj in selected_objs if obj.type == 'MESH' and WINDOW_KEYWORD in obj.name]
    text_objs = [obj for obj in selected_objs if obj.type in {'FONT', 'CURVE'}]
    
    # Extraktion der Textinhalte
    available_texts = []
    for t_obj in text_objs:
        if t_obj.type == 'FONT':
            available_texts.append((t_obj, t_obj.data.body))
        else:
            available_texts.append((t_obj, t_obj.name))
            
    if not available_texts:
        print("Fehler: Keine Textobjekte in der aktuellen Auswahl detektiert.")
        return

    assigned_count = 0

    for window in mesh_objs:
        area = calculate_global_area(window)
        
        # Filterbedingung: Flaeche groesser 1.5 Quadratmeter
        if area > 1.5:
            min_distance = float('inf')
            closest_aks = None
            
            win_location = window.location
            
            # Nearest-Neighbor-Suche
            for text_obj, text_string in available_texts:
                dist = (win_location - text_obj.location).length
                
                if dist < min_distance:
                    min_distance = dist
                    closest_aks = text_string
                    
            if closest_aks:
                window["SE-AKS"] = closest_aks
                assigned_count += 1
                print(f"Match: {window.name} (Flaeche: {area:.2f} qm) -> {closest_aks}")

    print(f"Prozess beendet. {assigned_count} Fenstern wurde ein AKS zugewiesen.")

# Skriptausfuehrung
assign_aks_to_selected_windows()