import bpy

def remove_all_bmkz_attributes():
    count = 0
    
    # Wir iterieren durch ALLE Objekte in der Datei (nicht nur die in der aktiven Szene)
    for obj in bpy.data.objects:
        # Prüfen, ob das Custom Property existiert
        if "BMKZ" in obj:
            # Attribut löschen
            del obj["BMKZ"]
            count += 1
            
    print("=" * 60)
    print(f"ERFOLG: Das Attribut 'BMKZ' wurde von {count} Objekten restlos gelöscht!")
    print("=" * 60)

# Skript ausführen
remove_all_bmkz_attributes()