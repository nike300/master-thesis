graph TD
    %% Styling
    classDef startEnd fill:#f9f,stroke:#333,stroke-width:2px;
    classDef loopNode fill:#ff9,stroke:#333,stroke-width:2px;
    classDef decision fill:#ffb380,stroke:#333,stroke-width:2px;
    classDef process fill:#b3d9ff,stroke:#333,stroke-width:1px;
    classDef data fill:#d9f2d9,stroke:#333,stroke-width:1px;

    Start([Start Simulation])

    subgraph Vorbereitung ["1. Geometrische Vorverarbeitung (Pre-Calculation)"]
        Init[Pfade, Variablen & IFC-Fenster laden]
        CalcCenter[Turm-Zentrum aus Bounding-Boxes berechnen]
        CalcNormals[Physische Fensternormalen berechnen & nach außen richten]
    end

    subgraph Zeitschleife ["2. Hauptschleife (Zeit)"]
        TimeLoop{Für jeden<br>Zeitschritt}
        SunMath[Sonnenvektor & Elevation berechnen<br>NOAA Algorithmus]
        CheckNight{Elevation < 0?<br>Nacht}
        LogNight[Speichere '-2' für alle Fenster]
    end

    subgraph Fensterschleife ["3. Raycast-Schleife (Fenster)"]
        WindowLoop{Für jedes<br>Fenster}
        CalcDot[Skalarprodukt: Sonnenvektor · Normale]
        CheckBackface{Skalarprodukt <= 0?<br>Eigenschatten}
        LogBackface[Speichere '-3'<br>Backface Culling]
        
        CalcAngle[Einfallswinkel berechnen]
        ShootRay[Raycast in Richtung Sonne schießen]
        
        CheckHit{Trifft ein Hindernis?}
        LogShadow[Speichere '-1'<br>Fremdverschattung]
        LogSun[Speichere Winkel<br>Direkte Sonne]
    end

    subgraph Export ["4. Datenexport"]
        WriteCSV[Ergebnisse in CSV-Datei schreiben]
    end
    
    End([Ende Simulation])

    %% Flow-Verbindungen
    Start --> Init
    Init --> CalcCenter
    CalcCenter --> CalcNormals
    CalcNormals --> TimeLoop

    TimeLoop -- Nächster Schritt --> SunMath
    SunMath --> CheckNight

    CheckNight -- Ja --> LogNight
    LogNight --> TimeLoop

    CheckNight -- Nein --> WindowLoop

    WindowLoop -- Nächstes Fenster --> CalcDot
    CalcDot --> CheckBackface

    CheckBackface -- Ja --> LogBackface
    LogBackface --> WindowLoop

    CheckBackface -- Nein --> CalcAngle
    CalcAngle --> ShootRay
    ShootRay --> CheckHit

    CheckHit -- Ja --> LogShadow
    CheckHit -- Nein --> LogSun
    
    LogShadow --> WindowLoop
    LogSun --> WindowLoop

    WindowLoop -- Alle Fenster geprüft --> TimeLoop

    TimeLoop -- Alle Zeiten geprüft --> WriteCSV
    WriteCSV --> End

    %% Klassen zuweisen (Kompatibler Weg für VS Code)
    class Start,End startEnd;
    class Init,CalcCenter,CalcNormals,SunMath,CalcDot,CalcAngle,ShootRay process;
    class TimeLoop,WindowLoop loopNode;
    class CheckNight,CheckBackface,CheckHit decision;
    class LogNight,LogBackface,LogShadow,LogSun,WriteCSV data;