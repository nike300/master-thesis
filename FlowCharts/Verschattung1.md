---
config:
  layout: fixed
  themeVariables:
    edgeLabelBackground: '#ffffff'
    fontSize: 16px
---
flowchart TB
    Start(["Start der Simulation"]) --> Init["Konfiguration laden & Verzeichnisse prüfen"]
    Init --> Geo["Geometrie-Analyse:<br>"]
    Geo --> LoopTime{"Zeitliche Iteration:<br>Nächstes 15-Min-Intervall?"}
    LoopTime -- Ja --> NOAA["Sonnenstandsberechnung<br>"]
    NOAA --> IsDay{"Elevation &gt; 0?<br>Tag / Nacht-Prüfung"}
    IsDay -- Nacht --> NightState@{ label: "Status 'N'" }
    IsDay -- Tag --> LoopWindow{"Schleife über alle<br>Fenster"}
    LoopWindow -- Nächstes Fenster --> Culling{"Backface Culling:<br>Sonnenvektor dot Normale &lt;= 0?"}
    Culling -- Ja (Rückseite) --> CullingState@{ label: "Status 'R'" }
    Culling -- Nein (Vorderseite) --> Raycast["Vierpunkt-Raycast:<br>Strahlen von Ecken zur Sonne"]
    Raycast --> CheckHit{"Trifft Strahl ein<br>verschattendes Mesh?"}
    CheckHit -- "Nein (mind. 1 Ecke frei)" --> SunState["Azimut (-90° bis +90°)"]
    LoopTime -- Alle Zeiten geprüft --> Export["Datenexport:<br>CSV schreiben"]
    Export --> End(["Ende der Simulation"])
    NightState --- n1["Untitled Node"]
    n1 --> LoopTime
    LoopWindow -- Alle Fenster geprüft --- n2["Untitled Node"]
    n2 --- n3["Untitled Node"]
    n4["Untitled Node"] L_n4_LoopWindow_0@--> LoopWindow
    n3 --> n1
    SunState --- n5["Untitled Node"]
    n5 --- n4
    CullingState --- n7["Untitled Node"]
    n7 --> LoopWindow
    CheckHit -- Ja (Verschattet) --> n9@{ label: "Status 'V'" }
    n9 --- n10["Filled Circle"]
    n10 --- n11["Filled Circle"]
    n11 --> n7

    NightState@{ shape: rect}
    CullingState@{ shape: rect}
    SunState@{ shape: rect}
    n1@{ shape: anchor}
    n2@{ shape: anchor}
    n3@{ shape: anchor}
    n4@{ shape: anchor}
    n5@{ shape: anchor}
    n7@{ shape: anchor}
    n9@{ shape: rect}
    n10@{ shape: anchor}
    n11@{ shape: anchor}
     Start:::startEnd
     Init:::process
     Geo:::process
     LoopTime:::decision
     NOAA:::process
     IsDay:::decision
     NightState:::result
     LoopWindow:::decision
     Culling:::decision
     CullingState:::result
     Raycast:::process
     CheckHit:::decision
     SunState:::result
     Export:::process
     End:::startEnd
     n9:::result
    classDef startEnd fill:#3572A5,stroke:#2b5c85,stroke-width:2px,color:#fff
    classDef process fill:#f9f9f9,stroke:#333,stroke-width:1px
    classDef decision fill:#e1f5fe,stroke:#0288d1,stroke-width:1px
    classDef result fill:#e8f5e9,stroke:#388e3c,stroke-width:1px
    style Culling font-size:14px
    style n1 stroke-width:0px,stroke-dasharray:0,stroke:none,fill:transparent

    L_n4_LoopWindow_0@{ animation: none }