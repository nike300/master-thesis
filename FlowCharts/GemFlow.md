graph TD
    Start([Start Evaluierungszyklus]) --> Präsenz{Anwesenheit?}
    
    %% Energie-Modus (Niemand da)
    Präsenz -- Nein --> Energie[Thermische Optimierung:\nBehang zu Sommer / auf Winter]
    
    %% Komfort-Modus (Jemand da)
    Präsenz -- Ja --> Wetter{Helligkeit Dachsensor:\n> Grenzwert z.B. 20 klx?}
    
    %% Wetter-Check
    Wetter -- Nein (Bewölkt) --> Auf1([Behang auf:\nTageslicht maximieren])
    Wetter -- Ja (Sonnig) --> Azimut{Sonnenazimut:\nSonne auf Fassade?}
    
    %% Fassaden-Check
    Azimut -- Nein --> Auf2([Behang auf:\nKeine direkte Einstrahlung])
    Azimut -- Ja --> Sim{Simulationsdaten:\nFenster verschattet?}
    
    %% Verschattungs-Check (Dein Workflow!)
    Sim -- Ja (Fremdschatten) --> Auf3([Behang auf:\nSchatten blockiert Sonne])
    Sim -- Nein (Direkte Sonne) --> Blendschutz[Blendschutz aktiv:\nBehang abfahren]
    
    %% Lamellennachführung
    Blendschutz --> Lamelle[Cut-Off Steuerung:\nLamellenwinkel basierend auf\nSonnenhöhenwinkel anpassen]
    Lamelle --> Ende([Zyklus Ende])
    Auf1 --> Ende
    Auf2 --> Ende
    Auf3 --> Ende
    Energie --> Ende