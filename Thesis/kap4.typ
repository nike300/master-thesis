= Implementierung und Validierung des Proof of Concept<Kap4>
// Vorstellung Four (Turm 1)
Das FOUR sind vier zusammenhängende Türme in der Innenstadt von Frankfurt am Main.  
== Import Umgebungsdaten
Hessische Verwaltung für Bodenmanagement und Geoinformation 

== Import IFC
Da die oben genannten Punkte zum Teil nicht erfüllt werden, musste beim Import der FOUR-IFC-Datei noch folgendes gemacht werden:
-

== Positionierung der IFC im Modell
Problem der Georeferenzierung. Ungenauigkeit. Vertex Snapping
- Schwierig höhe z richtig zu bekommmen
- Bereinigung von Redundanzen im Kontextmodell (Bestehendes Gebäude aus OSM löschen)

== Die eigentliche Simulation
Entweder mit Simulation im Hintergrund (anscheinend kaputt) oder mit Mathe Simulation
Mathe simulation mit Algorithmus zur Sonnenstandsberechnung nach NOAA (National Oceanic and Atmospheric Administration)

=== Zeitlicher Umfang und Auflösung
*Zeitlicher Umfang:* Es stellt sich die Frage, wie viele volle Kalenderjahre berechnet werden müssen, um den realen Sonnenverlauf hinreichend abzubilden. Der Umlauf der Erde um die Sonne unterliegt langperiodischen Schwankungen (Milanković-Zyklen) @dwdMilanZyklen. Diese sind für die Lebensdauer eines Gebäudes als nicht relevant anzusehen, weshalb der berechnete Sonnenverlauf für den Betrachtungszeitraum als statisch betrachtet werden kann. 

Da das kalendarische Jahr vom astronomischen Sonnenjahr (ca. 365,24 Tage @astr04eduSonnenjahr) abweicht, wird diese Differenz alle vier Jahre durch ein Schaltjahr korrigiert. Die hieraus resultierende zeitliche Verschiebung des Sonnenstandes am selben Kalendertag ist für einen simulierten Schattenwurf in @fig-schaltjahr beispielhaft dargestellt. Da es sich bei den räumlichen Abweichungen lediglich um wenige Zentimeter handelt, ist es ausreichend, die Simulation auf ein einzelnes Referenzjahr zu beschränken.
#figure(
  grid(
    columns: (1fr, 1fr), // Zwei gleich breite Spalten
    gutter: 20pt,        // Abstand zwischen den Bildern
    
    // Linkes Bild
    box(width: 100%, height: 250pt, clip: true)[
      #place(center + horizon, image("assets/Schaltjahr20270301_9_00.png", width: 250%))
    ],
    
    // Rechtes Bild
    box(width: 100%, height: 250pt, clip: true)[
      #place(center + horizon, image("assets/Schaltjahr20280301_9_00.png", width: 250%))
    ]
  ),
  caption: [Links: Schattenwurf am 01.03.2027 um 9:00;\ Rechts: Schattenwurf am 01.03.2028 (Schaltjahr) um 9:00]
)<fig-schaltjahr>

*Zeitliche Auflösung* Für die Simulation wurde eine 15-Minütige Auflösung gewählt. 
Eine höhere Auflösung garantiert für den Nutzer einen geringfügig höheren Komfort indem in manchen Fällen erst später Verschattet werden würde
#figure(
  image("assets/AuflösungZeitstrahl.svg" ),
  caption: [Verschattungsverlauf von Fenster FL31_W061 am 01.03.2026 mit Behangzustand beruhend auf 5, 15 und 60 Minütiger Datenauflösung]
)

#figure(
  image("assets/Untitled-design.svg")
)

*Zeitliche Auflösung:* Die Wahl der Auflösung für die Datenausgabe hat maßgeblichen Einfluss auf die Tageslichtausbeute des Gebäudes. Da die Verschattung eine binäre Steuerungsfreigabe (Schatten oder Sonne) für den Blendschutz darstellt, muss bei einer Reduktion der Datenauflösung zwingend eine Worst-Case-Annahme getroffen werden: Fällt innerhalb eines Simulationsintervalls auch nur für eine Minute ein Schlagschatten auf das Fenster, muss der Sonnenschutz für das gesamte Intervall geschlossen werden, um temporäre Blendung auszuschließen. 

fig-zeitliche-aufloesung veranschaulicht diesen Effekt am Beispiel echter Simulationsdaten eines Referenzfensters. In der Realität (1-Minuten-Auflösung) verlässt der Schatten das Fenster um 10:23 Uhr. Bei einer groben stündlichen Diskretisierung (60 Minuten) hält die Automationsstation den Behang jedoch unnötigerweise bis 11:00 Uhr geschlossen, was zu 37 Minuten Verlust an natürlichem Tageslicht führt.

Besonders gravierend wirkt sich eine zu grobe Abtastung bei kurzen Verschattungsereignissen aus, wie sie durch schmale Bauteile (z. B. Masten oder Schornsteine der Nachbarbebauung) entstehen. Die reale Verschattung von 11:05 bis 11:14 Uhr zwingt das System im 60-Minuten-Raster dazu, den Behang von 11:00 bis 12:00 Uhr zu schließen. 

Eine Diskretisierung im 15-Minuten-Raster erweist sich hierbei als optimaler Kompromiss. Einerseits nähert sich die Steuerkurve dem realen Schattenverlauf ausreichend exakt an, um den visuellen Komfort bei hoher Tageslichtautonomie zu wahren. Andererseits entspricht dieses Intervall der in der Gebäudeautomation (BACnet) üblichen Taktung für Zeitpläne (Schedules) und begrenzt die zu speichernde Datenmenge in der SPS auf speichereffiziente 35.040 Datenpunkte pro Jahr (bei einem booleschen Wert pro Fenster).

=== Überlegung zur räumlichen Auflösung

=== Möglichkeiten der Simulationsoptimierung
- Ohne Optimierung (760s)
- Zusammenfügen von umliegenden Objekten 786s (Optimierungepotenzial bei -3,4%)
- löschen von 80% der kleinen Häuser 764s
- Mathe-Skript 793s
- Mathe Skript mit Normalenoptimierung: 408s
- ""+Winkel: 434s
== Validierung der Ergebnisse
- Über webcam (installiert auf dem nexttower (137m hoch) am Thurn-und-Taxis-Platz 21.06.25; 9:15
  - das validiert vor allem auch den mathematischen code im skript
- Vorort mit Helligkeitssensoren in Fenstern? - Optional, wenn noch zeit ist
