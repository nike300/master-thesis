import bpy

suchbegriff = "FL06_W001"
gefunden = False

# Alle Objekte deselektieren
bpy.ops.object.select_all(action='DESELECT')

for obj in bpy.context.scene.objects:
    # Prüfen, ob die Eigenschaft "BMKZ" existiert und dem Suchbegriff entspricht
    if obj.get("BMKZ") == suchbegriff:
        print(f"Treffer! Das Original-Objekt heißt: {obj.name}")
        
        # Objekt aktiv setzen und selektieren
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        gefunden = True
        break

if gefunden:
    override_erfolgreich = False
    
    # Iteration durch Fenster, Bereiche und schließlich Regionen
    for window in bpy.context.window_manager.windows:
        for area in window.screen.areas:
            if area.type == 'VIEW_3D':
                for region in area.regions:
                    # Wir suchen gezielt den Haupt-Zeichenbereich des Viewports
                    if region.type == 'WINDOW':
                        with bpy.context.temp_override(window=window, area=area, region=region):
                            bpy.ops.view3d.view_selected()
                            override_erfolgreich = True
                        break # Regionen-Schleife abbrechen
            if override_erfolgreich:
                break # Area-Schleife abbrechen
        if override_erfolgreich:
            break # Window-Schleife abbrechen
else:
    print(f"Ein Fenster mit dem BMKZ {suchbegriff} existiert nicht.")