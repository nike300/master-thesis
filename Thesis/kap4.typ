= Implementierung und Validierung des Proof of Concept<Kap4>
// Vorstellung Four (Turm 1)
Das FOUR sind vier zusammenhängende Türme in der Innenstadt von Frankfurt am Main.  
== Import Umgebungsdaten
Hessische Verwaltung für Bodenmanagement und Geoinformation 

== Import und Positionierung der IFC
*Import* Da die oben genannten Punkte zum Teil nicht erfüllt werden, musste beim Import der FOUR-IFC-Datei noch folgendes gemacht werden:
-
*Positionierung*
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
)<fig-Zeitstrahl>



*Zeitliche Auflösung:* Die Wahl der Auflösung für die Datenausgabe hat maßgeblichen Einfluss auf die Tageslichtausbeute des Gebäudes. Da die Verschattung eine binäre Steuerungsfreigabe (Schatten oder Sonne) für den Blendschutz darstellt, muss bei einer Reduktion der Datenauflösung zwingend eine Worst-Case-Annahme getroffen werden: Fällt innerhalb eines Simulationsintervalls auch nur für eine Minute ein Schlagschatten auf das Fenster, muss der Sonnenschutz für das gesamte Intervall geschlossen werden, um temporäre Blendung auszuschließen. 

@fig-Zeitstrahl veranschaulicht diesen Effekt am Beispiel echter Simulationsdaten eines Referenzfensters. Der Schatten verlässt das Fenster um 10:23 Uhr. Bei einer groben stündlichen Diskretisierung hält die Steuerung den Behang schon ab 10:00 Uhr geschlossen, was zu 23 Minuten Verlust an natürlichem Tageslicht führt.

Besonders gravierend wirkt sich eine zu grobe Abtastung bei kürzeren Verschattungsereignissen aus, wie sie oft in Großstädten mit vielen Hochhäusern entstehen. Erst Verschattungen länger als 61 Minuten ab der vollen Stunde würde das System im 60-Minuten-Raster dazu führen, den Behang zu öffnen.

Die kleine Auflösung von 5 Minuten schafft es, die Behänge sehr eng am eigentlichen Schattenverlauf des Fensters zu fahren. Selbst die kurze Verschattung von 11:05 bis 11:15 kann erfasst werden. Dieser Vorteil wird zum Nachteil, wenn man den Nutzerkomfort berücksichtigt. Eine im schlimmsten Fall alle 5 Minuten sich bewegende Jalousie kann als visuell und akustisch störend und ablenkend empfunden werden. Diese kurzen Jalousiebewegungen könnten in der Steuerlogik verhindert werden, dies erhöht jedoch die Fehleranfälligkeit und Komplexität des Systems.

Somit erweist sich eine Diskretisierung im 15-Minuten-Raster hierbei als optimaler Kompromiss. Einerseits nähert sich die Steuerkurve dem realen Schattenverlauf ausreichend exakt an, um den visuellen Komfort bei hoher Tageslichtausbeute zu wahren, andererseits wird die zu speichernde Datenmenge pro Fenster auf "nur" 35.040 Datenpunkte.

=== Überlegung zur räumlichen Auflösung
Neben der zeitlichen Diskretisierung bestimmt die räumliche Abtastung der Fensterflächen die Zuverlässigkeit der Simulationsergebnisse. Für jedes Fenster im IFC-Modell muss definiert werden, mit wie vielen Testpunkten der Verschattungsstatus ermittelt wird. 

Ein naheliegender Ansatz wäre die Unterteilung der Fensterfläche in ein feines Raster, um den prozentualen Verschattungsgrad für eine dynamische Höhennachführung des Behanges zu ermitteln. Im Kontext der in Kapitel 4.4.1 gewählten zeitlichen Auflösung von 15 Minuten erweist sich diese Lösung in der Praxis jedoch als nicht zielführend: Die Schattenkante wandert innerhalb eines 15-Minuten-Intervalls zu weit, was zu schwer nachvollziehbaren Nachführbewegungen der Aktorik führen würde. Daher fokussiert sich die Betrachtung auf zwei pragmatische Optionen:

*2. Einpunkt-Messung (Fenstermittelpunkt):*
Es wird ein einzelner Raycast vom geometrischen Zentrum des Fensters zur Sonne berechnet.
Dieser Ansatz hat den Vorteil, dass er die geringste Rechenzeit aufweist. Allerdings ist die Einpunkt-Messung anfällig für Halbschatten-Situationen. Verdeckt ein Schatten beispielsweise nur die untere Fensterhälfte, meldet der Mittelpunkt unter Umständen noch keine Verschattung. Umgekehrt kann der Mittelpunkt bereits verschattet sein, während die obere Fensterhälfte noch stark blendet.

*2. Vierpunkt-Messung (Eckpunkte):*
Die Simulation prüft die vier Extrempunkte der Fenstergeometrie. Die Auswertung erfolgt über eine logische ODER-Verknüpfung: Sobald mindestens einer der vier Punkte direkte Sonneneinstrahlung detektiert, gilt das gesamte Fenster als besonnt.
Diagonale oder wandernde Schattenkanten werden sicher erkannt, wodurch temporäre Blendungen (die bei der Einpunkt-Messung übersehen würden) verhindert werden.
Der Nachteil ist die Vervierfachung der Rechenzeit gegenüber der Einpunkt-Messung. Zudem können sehr schmale, vertikale Objekte (z. B. Masten), die schmaler als die Fensterbreite sind, theoretisch übersehen werden. Dies stellt im urbanen Kontext jedoch ein vernachlässigbares Restrisiko dar. In einzelnen Fällen, kann auch ein Schattenwurf, der nur die untere Fensterkante streift, zu einer nicht notwendigen Reaktion der Jalousie führen. Dies könnte mit dem Hochsetzen der unteren beiden Eckpunkte verhindert werden.

*Fazit für den Prototyp: (XXX)*
Um den visuellen Komfort (Blendschutz) der Nutzer zu garantieren, wird für den entwickelten Workflow die Vierpunkt-Messung gewählt. Die Erhöhung der Rechenzeit wird durch die drastisch verbesserte Steuerungssicherheit gerechtfertigt. Die vier booleschen Einzelwerte werden bereits im Python-Skript durch eine ODER-Logik zu einem einzelnen Status pro Fenster aggregiert, sodass die zu exportierende Datenmenge für die Automationsstation identisch mit der Einpunkt-Messung bleibt.

=== Möglichkeiten der Simulationsoptimierung
- Ohne Optimierung (760s)
- Zusammenfügen von umliegenden Objekten 786s (Optimierungepotenzial bei -3,4%)
- löschen von 80% der kleinen Häuser 764s
- Mathe-Skript 793s
- Mathe Skript mit Normalenoptimierung: 408s
- ""+Winkel: 434s
== Validierung der Ergebnisse
Eine Validierung erfolgt über einen Abgleich zwischen einem gerendertem Bild aus der Simulation und einer Fotoaufnahme des FOUR zu einem festgelegten Zeitpunkt. Für die Fotoaufnahme wird auf die für die Bauüberwachung und Marketing benutzte Webcam zurückgegriffen. Sie befindet sich auf dem 137m hohen Nextower am Thurn-und-Taxis-Platz, der sich ca. 500m Luftlinie vom FOUR entfernt befindet. Auf der Website @zeitrafferFOURFrankfurt können die Bilder der letzten 5 Jahren abgerufen werden. Für die Validierung wurde ein zufälliger Tag mit wenig Wolken am Himmel gewählt, um bei möglichst wenig diffusem Licht, eine klare Schattenbildung zu vergleichen. In .... ist eine klare .. zu sehen

vom  21.06.25; 9:15
  - das validiert vor allem auch den mathematischen code im skript
- Vorort mit Helligkeitssensoren in Fenstern? - Optional, wenn noch zeit ist
