import bpy

# --- KONFIGURATION ---
# Liste der Textbausteine, nach denen gesucht werden soll
SEARCH_KEYWORDS = [
    "FAS_PAN_XXX_TB_L" #Balkonfenster
#    "_Rain"
#    "Kuche"
]
# ---------------------

def select_specific_windows():
    # 1. Aktuelle Auswahl komplett aufheben
    bpy.ops.object.select_all(action='DESELECT')
    
    count = 0
    last_selected = None
    
    # 2. Durch alle Objekte der aktuellen Szene gehen
    for obj in bpy.context.scene.objects:
        
        # 3. Prüfen, ob IRGENDEIN Suchbegriff aus der Liste im Namen vorkommt
        # Die any() Funktion ist hier sehr effizient.
        if any(keyword in obj.name for keyword in SEARCH_KEYWORDS):
            
            # Objekt auswählen
            obj.select_set(True)
            last_selected = obj
            count += 1
            
    # 4. Das letzte gefundene Objekt zum "aktiven" Objekt machen
    if last_selected is not None:
        bpy.context.view_layer.objects.active = last_selected
        
    # Ausgabe in der Systemkonsole
    print(f"Erfolg: Es wurden {count} Objekte ausgewählt.")
    print("Gesuchte Keywords:")
    for kw in SEARCH_KEYWORDS:
        print(f" - {kw}")

# Skript ausführen
select_specific_windows()