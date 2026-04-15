import bpy

def remove_aks_attributes():
    selected_objs = bpy.context.selected_objects
    removed_count = 0

    for obj in selected_objs:
        # Pruefung auf beide gelaeufige Schreibweisen des Attributs
        for prop_name in ["SE-AKS", "BMKZ"]:
            if prop_name in obj:
                del obj[prop_name]
                removed_count += 1

    print(f"Cleanup abgeschlossen: Attribut bei {removed_count} Objekten entfernt.")

# Skriptausfuehrung
remove_aks_attributes()