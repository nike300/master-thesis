import bpy
import bmesh

def calculate_global_area(obj):
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.transform(obj.matrix_world)
    area = sum(f.calc_area() for f in bm.faces)
    bm.free()
    return area

def analyze_window_assignments():
    selected_objs = bpy.context.selected_objects
    mesh_objs = [obj for obj in selected_objs if obj.type == 'MESH']
    
    valid_windows = []
    
    for obj in mesh_objs:
        area = calculate_global_area(obj)
        if area > 1.5:
            valid_windows.append(obj)
            
    print(f"Analyse abgeschlossen: {len(valid_windows)} valide Objekte (Fläche > 1.5 qm) in der Auswahl gefunden.")
    
    aks_dict = {}
    for obj in valid_windows:
        if "SE-AKS" in obj:
            aks = obj["SE-AKS"]
            if aks not in aks_dict:
                aks_dict[aks] = []
            aks_dict[aks].append(obj.name)
            
    duplicates = {aks: names for aks, names in aks_dict.items() if len(names) > 1}
    
    if duplicates:
        print("Warnung: Folgende AKS wurden mehrfach vergeben:")
        for aks, names in duplicates.items():
            print(f" - {aks} zugewiesen an: {', '.join(names)}")
    else:
        print("Datenstruktur konsistent: Keine Mehrfachzuweisungen gefunden.")

analyze_window_assignments()