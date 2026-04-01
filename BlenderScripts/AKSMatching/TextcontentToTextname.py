import bpy

def rename_texts_to_body():
    # Filtert die Auswahl nach nativen Textobjekten
    text_objs = [obj for obj in bpy.context.selected_objects if obj.type == 'FONT']
    renamed_count = 0
    
    for t_obj in text_objs:
        # Extrahiert den Text und entfernt fuehrende/nachfolgende Leerzeichen
        body_text = t_obj.data.body.strip()
        
        if body_text:
            t_obj.name = body_text 
            renamed_count += 1
            
    print(f"Umbenennung abgeschlossen: {renamed_count} Textobjekte aktualisiert.")

# Skriptausfuehrung
rename_texts_to_body()