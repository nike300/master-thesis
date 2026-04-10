= Implementierung und Validierung des Proof of Concept<Kap4>
Um den in Kapitel 3 theoretisch konzipierten Systemansatz auf seine praktische Tragfähigkeit zu überprüfen, wird im Folgenden ein Proof of Concept (POC) durchgeführt. Ziel dieses Kapitels ist es, die softwaretechnische Machbarkeit der entwickelten Prozesskette - vom fehlerfreien Import heterogener Datensätze (IFC und GIS) über die raycastingbasierte Verschattungssimulation bis hin zum strukturierten Datenexport - exemplarisch nachzuweisen. Hierfür wurde ein funktionsfähiger Software-Prototyp auf Basis von Blender und Python implementiert. 

Die Entwicklung und Validierung dieses Prototyps erfolgt anhand eines komplexen Referenzprojekts:


// Vorstellung Four (Turm 1)
Das FOUR sind vier zusammenhängende Türme mit Büro- und Wohnungsnutzung in der Innenstadt von Frankfurt am Main. Die vier Türme stehen auf vier Gebäuden (Podesten), die miteinander verbunden sind. Das Bauprojekt befindet sich momentan in der Endphase und soll im Laufe des Jahres 2026 endgültig übergeben werden. In dieser Arbeit wird die Verschattungssimulation am Büroturm T1 angewendet. Die Türme stehen eng beieinander im Zentrum von Frankfurt zwischen verschiedenen Hochhäusern (z.B. dem Commerzbank-Tower und dem MAIN-Tower). Durch dieses eng bebautes Areal treten sehr dynamische Verschattungssituationen auf, die nur durch eine präzise Simulation der Umgebung korrekt dargestellt werden können.
Eine architektonische Besonderheit des FOUR sind die diagonal abgeschrägten Fassadenabschnitte (@fig-FourTageslicht), die den visuellen Freiraum und die Tageslichtzufuhr verbessern sollen.

#figure(
  image("assets/FourTageslichtSchnitte.png"),
  caption: [Darstellung und Erklärung der diagonalen Fassadenabschrägung des FOUR@four_frankfurt_about]
)<fig-FourTageslicht>

Das Simulieren... ???

== Import und Positionierung des Turm 1 <ImportPositionierungT1>
*Import* 
Als erstes wird die ifc-Datei des Referenzgebäudes in Blender importiert. Dies geschieht über das Blender Add-On Bonsai@bonsai_openbim, welches den Import und die Bearbeitung von BIM-Daten ermöglicht. Da die ifc-Modelle beim FOUR schon als Fassaden-Teilmodelle vorliegen, muss hier beim Import kein Filter angewandt werden, um nicht relevante Bauteile auszuschließen.

// *Import* Da die in @AnalyseBIMDatenguete[Kapitel] definierten Anforderungen zum Teil nicht erfüllt werden, musste beim Import der FOUR-IFC-Datei noch folgendes gemacht werden:
-
*Positionierung*
Für die Positionierung des Gebäudes sollte zuerst auf die im IfcSite-Tag hinterlegten Koordinaten zurückgegriffen werden. Nach eingängiger Prüfung stellt sich heraus, dass die Koordinaten auf einen Punkt in der Mitte des Baufelds verweisen und nicht auf den gewünschten Ursprung des ifc-Modells. Nach Sichtung der Planunterlagen wurden im "Masterplan für das BIM-Modell" die richtigen XY-Koordinaten (in Form des Gauß-Krüger-Koordinatensystems) entdeckt. Die Z-Koordinate, also die Höhe des ifc-Ursprungs konnte über einen Schnitt ausfindig gemacht werden. Da Frankfurt ca. 100m über @nn liegt, werden genau 100m als Koordinatenebene festgelegt. Diese Koordinaten werden somit als Ursprung des gesamten Simulationsmodells definiert. 

Für die weitere Verwendung werden die XY-Koordinaten mithilfe einer Anwendung des Bundesamt für Kartographie und Geodäsie@bkg_koordinatentransformation in das benötigte UTM32 Koordinatenreferenzsystem übersetzt. Dafür wird das Verschiebegitter Beta2007 verwendet.

== Import und Positionierung der Umgebungsdaten<ImportUmgebungsdaten>

Für die Modellierung der umgebenden, verschattenden Bebauung wird auf die offenen Geodaten der Hessischen Verwaltung für Bodenmanagement und Geoinformation (HVBG) zurückgegriffen. Die 3D-Gebäudemodelle für das Stadtgebiet Frankfurt am Main werden von offizieller Seite standardmäßig im Format CityGML bereitgestellt.

Da für die verwendete 3D-Software (Blender) keine native Import-Schnittstelle für CityGML-Dateien existiert, war eine vorherige Datenkonvertierung erforderlich. Die Datensätze wurden hierfür in das JSON-basierte Format CityJSON (Datenaustauschformat für digitale 3D-Modelle von Städten und Landschaften @cityjson_standard) überführt.

Der finale Import der Gebäudekörper in die 3D-Umgebung erfolgte über das Open-Source-Plugin CityJSONEditor für Blender. Da die hierarchische Struktur der amtlichen Frankfurter Daten teilweise von den Standardannahmen des Plugins abwich, wurden im Rahmen dieser Arbeit gezielte Anpassungen am Python-Quellcode der Import-Erweiterung vorgenommen. Diese Fehlerbehebungen (Bugfixes) umfassen im Wesentlichen drei Aspekte:
...
+ *Toleranz bei fehlenden Texturen:* Es wird eine Abfrage implementiert, die den Importprozess bei Objekten ohne definierte Fassadentexturen (Appearances) nicht abbricht, sondern die reine Geometrie weiterverarbeitet.
+ *Datentyp-Konvertierung (LoD):* Die Einleseroutine wird dahingehend modifiziert, dass der im Datensatz als Zeichenkette (String) vorliegende Wert für den Detailgrad (Level of Detail, LoD) programmatisch in einen Gleitkommawert (Float) umgewandelt wird.
+ *Filterung geometrieloser Objekte:* Es wird eine Filterroutine integriert, die Datensätze ohne physische 3D-Geometrie (wie bspw. reine Grundstücksgrenzen oder Landnutzungsflächen) beim Import ignoriert, um Programmabbrüche zu verhindern.

...Um beim anschließenden Import eine korrekte räumliche Verortung zu gewährleisten, wurde den generierten Dateien das amtliche Koordinatenreferenzsystem für Hessen (EPSG:25832) manuell in den Metadaten zugewiesen.

...Durch diesen optimierten Workflow können die Gebäudemassen der Umgebung schließlich erfolgreich, geometrisch korrekt und maßstabsgetreu in das Simulationsmodell überführt werden.

== Import und Positionierung Türme 2-4
Da in den CityGML-Daten die FOUR-Türme zum Zeitpunkt dieser Arbeit noch nicht enthalten sind, muss auf die Fassadenmodelle der restlichen Türme zurückgegriffen werden. Sie liegen in LOD 500 vor, was für den genauen Schattenwurf von Vorteil ist. Allerdings sind viele Daten enthalten, die nicht benötigt werden. Somit werden folgende Maßnahmen getroffen, um die Dateigröße zu reduzieren und den Arbeitsspeicher zu entlasten:
- Decimate
- Joinen
- Semantische IFC-Daten löschen
Nach dem Import muss die Position nicht verändert werden, da die Türme 2-4 den gleichen Ursprung hinterlegt haben, wie der Turm 1.

== Aufbereitung IFC-Modell Turm 1?
- Fenster geometrische Mitte festlegen

== Die eigentliche Simulation der Jahresverschattung <SimulationJahresverschattung>
Für die Verschattungssimulation wird ein Python-Skript ausgeführt, welches über die @ide @vs-code#[]@vscode gestartet wird. Der Code unterteilt sich in mehrere Teile:





Entweder mit Simulation im Hintergrund (anscheinend kaputt) oder mit Mathe Simulation
Mathe simulation mit Algorithmus zur Sonnenstandsberechnung nach NOAA (National Oceanic and Atmospheric Administration)

=== Zeitliche Auflösung und Umfang <ZeitlicheAufloesungUmfang>
*Zeitliche Auflösung:* Die Wahl der zeitlichen Auflösung für die Verschattungsdaten hat maßgeblichen Einfluss auf die Tageslichtausbeute des Gebäudes. Da die Verschattung eine binäre Freigabe (Schatten oder Sonne) für den Blendschutz darstellt, muss bei einer Reduktion der Datenauflösung zwingend eine Worst-Case-Annahme getroffen werden: Fällt innerhalb eines Simulationsintervalls auch nur für eine Minute ein Schlagschatten auf das Fenster, muss der Sonnenschutz für das gesamte Intervall geschlossen werden, um temporäre Blendung auszuschließen. 
#figure(
  image("assets/AuflösungZeitstrahl.svg" ),
  caption: [Verschattungsverlauf von Fenster FL31_W061 am 01.03.2026 mit beispielhafter Steuerung und 5, 15 und 60-minütiger Datenauflösung]
)<fig-Zeitstrahl>

@fig-Zeitstrahl veranschaulicht diesen Effekt am Beispiel einer Steuerung mit integrierten Verschattungsdaten in verschiedenen Ausflösungen an einem Refenzfenster.

- *Fall offener Behang:* Die Steuerung detektiert für einen Zeitpunkt $t$, ob für den nächsten berechneten Zeitpunkt ($t+1$) Sonne auf das Fenster fällt. Falls ja, werden die Behänge geschlossen. 
- *Fall geschlossener Behang:* Die Steuerung detektiert für einen Zeitpunkt $t$, ob für den nächsten berechneten Zeitpunkt ($t+1$) keine Sonne mehr auf das Fenster fällt und öffnet die Behänge erst bei $t+1$.

Dadurch wird garantiert, dass der Nutzer zu keinem Zeitpunkt einer möglichen Blendung ausgesetzt ist (außer bei Sonneneinfall zwischen zwei berechneten Zeitpunkten).
Der Schatten verlässt das Fenster um 10:23 Uhr. Bei einer groben stündlichen Diskretisierung hält die Steuerung den Behang schon ab 10:00 Uhr geschlossen, was zu 23 Minuten Verlust an natürlichem Tageslicht führt.

Besonders gravierend wirkt sich eine zu grobe Abtastung bei schnellen Verschattungsänderungen aus, wie sie oft in Großstädten mit vielen Hochhäusern entstehen. Erst Verschattungen länger als 60 Minuten ab der vollen Stunde würde das System im 60-Minuten-Raster dazu führen, den Behang zu öffnen. Im umgekehrten Fall würden Sonnenereignisse kleiner 60 Minuten im ungünstigsten Fall nicht detektiert werden können und der Nutzer wäre potentiell geblendet.

Die kleine Auflösung von 5 Minuten schafft es, die Behänge sehr eng am eigentlichen Schattenverlauf des Fensters zu fahren. Selbst die kurze Verschattung von 11:05 bis 11:15 kann erfasst werden. Dieser Vorteil wird zum Nachteil, wenn man den Nutzerkomfort berücksichtigt. Eine im schlimmsten Fall alle 5 Minuten sich bewegende Jalousie kann als visuell und akustisch störend und ablenkend empfunden werden. Diese kurzen Jalousiebewegungen könnten in der Steuerlogik verhindert werden, dies erhöht jedoch die Fehleranfälligkeit und Komplexität des Systems.

Somit erweist sich eine Diskretisierung im 15-Minuten-Raster hierbei als optimaler Kompromiss. Einerseits nähert sich die Steuerkurve dem realen Schattenverlauf ausreichend exakt an, um den visuellen Komfort bei hoher Tageslichtausbeute zu wahren, andererseits wird die zu speichernde Datenmenge pro Fenster auf "nur" 35.040 Datenpunkte.

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

=== Überlegung zur räumlichen Auflösung <RaeumlicheAufloesung>
Neben der zeitlichen Diskretisierung bestimmt die räumliche Abtastung der Fensterflächen die Zuverlässigkeit der Simulationsergebnisse. Für jedes Fenster im IFC-Modell muss definiert werden, mit wie vielen Testpunkten der Verschattungsstatus ermittelt wird. 

Ein naheliegender Ansatz wäre die Unterteilung der Fensterfläche in ein feines Raster, um den prozentualen Verschattungsgrad für eine dynamische Höhennachführung des Behanges zu ermitteln. Im Kontext der in Kapitel 4.4.1 gewählten zeitlichen Auflösung von 15 Minuten erweist sich diese Lösung in der Praxis jedoch als nicht zielführend: Die Schattenkante wandert innerhalb eines 15-Minuten-Intervalls zu weit, was zu schwer nachvollziehbaren Nachführbewegungen der Aktorik führen würde. Daher fokussiert sich die Betrachtung auf zwei pragmatische Optionen:

*1. Einpunkt-Messung (Fenstermittelpunkt):*
Es wird ein einzelner Raycast vom geometrischen Zentrum des Fensters zur Sonne berechnet.
Dieser Ansatz hat den Vorteil, dass er die geringste Rechenzeit aufweist. Allerdings ist die Einpunkt-Messung anfällig für Halbschatten-Situationen. Verdeckt ein Schatten beispielsweise nur die untere Fensterhälfte, meldet der Mittelpunkt unter Umständen noch keine Verschattung. Umgekehrt kann der Mittelpunkt bereits verschattet sein, während die obere Fensterhälfte noch stark blendet.

*2. Vierpunkt-Messung (Eckpunkte):*
Die Simulation prüft die vier Extrempunkte der Fenstergeometrie. Die Auswertung erfolgt über eine logische ODER-Verknüpfung: Sobald mindestens einer der vier Punkte direkte Sonneneinstrahlung detektiert, gilt das gesamte Fenster als besonnt.
Diagonale oder wandernde Schattenkanten werden sicher erkannt, wodurch temporäre Blendungen (die bei der Einpunkt-Messung übersehen würden) verhindert werden.
Der Nachteil ist die Vervierfachung der Rechenzeit gegenüber der Einpunkt-Messung. Zudem können sehr schmale, vertikale Objekte (z. B. Masten), die schmaler als die Fensterbreite sind, theoretisch übersehen werden. Dies stellt im urbanen Kontext jedoch ein vernachlässigbares Restrisiko dar. In einzelnen Fällen, kann auch ein Schattenwurf, der nur die untere Fensterkante streift, zu einer nicht notwendigen Reaktion der Jalousie führen. Dies könnte mit dem Hochsetzen der unteren beiden Eckpunkte verhindert werden.

*Fazit für den Prototyp: (XXX)*
Um den visuellen Komfort (Blendschutz) der Nutzer zu garantieren, wird für den entwickelten Workflow die Vierpunkt-Messung gewählt. Die Erhöhung der Rechenzeit wird durch die drastisch verbesserte Steuerungssicherheit gerechtfertigt. Die vier booleschen Einzelwerte werden bereits im Python-Skript durch eine ODER-Logik zu einem einzelnen Status pro Fenster aggregiert, sodass die zu exportierende Datenmenge für die Automationsstation identisch mit der Einpunkt-Messung bleibt.

=== Möglichkeiten der Simulationsoptimierung <Simulationsoptimierung>
- Ohne Optimierung (760s)
- Zusammenfügen von umliegenden Objekten 786s (Optimierungepotenzial bei -3,4%)
- löschen von 80% der kleinen Häuser 764s
- Mathe-Skript 793s
- Mathe Skript mit Normalenoptimierung: 408s
- ""+Winkel: 434s
== Validierung der Ergebnisse <ValidierungErgebnisse>
Eine Validierung erfolgt über einen Abgleich zwischen einem gerendertem Bild aus der Simulation und einer Fotoaufnahme des FOUR zu einem festgelegten Zeitpunkt. Für die Fotoaufnahme wird auf die für die Bauüberwachung und Marketing benutzte Webcam zurückgegriffen. Sie befindet sich auf dem 137m hohen Nextower am Thurn-und-Taxis-Platz, der sich ca. 500m vom FOUR entfernt befindet. Auf der Website des Webcamanbieters@zeitrafferFOURFrankfurt können die Bilder der letzten 5 Jahren abgerufen werden. Für die Validierung wurde ein zufälliger Tag mit wenig Wolken am Himmel gewählt, um bei möglichst wenig diffusem Licht, eine klare Schattenbildung zu erkennen. In der Simulation wurde der Nextower eingefügt um die Kameraposition möglichst genau nachzubilden.
In Bild.. .... ist eine klare .. zu sehen

vom  21.06.25; 9:15
  - das validiert vor allem auch den mathematischen code im skript
- Vorort mit Helligkeitssensoren in Fenstern? - Optional, wenn noch zeit ist
