= Implementierung und Validierung des Proof of Concept<Kap4>
Um den in Kapitel 3 theoretisch konzipierten Systemansatz auf seine praktische Tragfähigkeit zu überprüfen, wird im Folgenden ein Proof of Concept (POC) durchgeführt. Ziel dieses Kapitels ist es, die softwaretechnische Machbarkeit der entwickelten Prozesskette - vom fehlerfreien Import heterogener Datensätze (IFC und GIS) über die raycastingbasierte Verschattungssimulation bis hin zum strukturierten Datenexport - exemplarisch nachzuweisen. Hierfür wurde ein funktionsfähiger Software-Prototyp auf Basis von Blender und Python implementiert. 

Die Entwicklung und Validierung dieses Prototyps erfolgt anhand eines komplexen Referenzprojekts:

Hier noch ein Bild vom FOUR wäre gut

// Vorstellung Four (Turm 1)
Das FOUR sind vier zusammenhängende Türme mit Büro- und Wohnungsnutzung in der Innenstadt von Frankfurt am Main. Die vier Türme stehen auf vier Gebäuden (Podesten), die miteinander verbunden sind. Das Bauprojekt befindet sich momentan in der Endphase und soll im Laufe des Jahres 2026 endgültig übergeben werden. In dieser Arbeit wird die Verschattungssimulation am 233m hohen Büroturm T1 angewendet. Der Turm besteht pro Geschoss aus vier Mietbereichen und hat pro Segment einen außenliegenden Sonnenschutz und einen innenliegenden Blendschutz. Er hat 5859 Fenster mit außenliegendem Sonnenschutz. Die Türme stehen eng beieinander im Zentrum von Frankfurt zwischen verschiedenen Hochhäusern (z.B. dem Commerzbank-Tower und dem MAIN-Tower). Durch dieses eng bebautes Areal treten sehr dynamische Verschattungssituationen auf, die nur durch eine präzise Simulation der Umgebung korrekt dargestellt werden können.
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

.. es wurde darauf verzichtet, die gebäude nördlich rauszufiltern wie in kap 3 besprochen

== Import und Positionierung der Türme 2 bis 4 <ImportT24>

Da das Gebäudeensemble FOUR zum Zeitpunkt der Datenerhebung noch nicht in den amtlichen CityGML-Datensätzen erfasst ist, werden für die Verschattungssimulation die detaillierten IFC-Fassadenmodelle der Türme 2 bis 4 herangezogen. Diese liegen in einem sehr hohen Detaillierungsgrad (LOD 500) vor. Dies ist einerseits vorteilhaft für eine hohe Präzision des Schattenwurfs, beinhaltet andererseits jedoch eine massive Menge an nicht benötigten geometrischen und semantischen Daten. Um die Dateigröße zu minimieren und den Arbeitsspeicher während der Simulation zu entlasten, wird eine systematische Reduktion der Modelle durchgeführt:

+ Isolierter Import: Die IFC-Dateien der Nachbartürme werden zunächst in separate Blender-Projekte importiert, um die Hauptdatei nicht initial zu überlasten.
+ Geometrische Aggregation: Sämtliche Einzelbauteile (Meshes) eines Turms werden zu einem zusammenhängenden Polygonnetz verschmolzen.
+ Semantische Bereinigung: Alle nicht-geometrischen Informationen, wie IFC-Hierarchien, Materialdaten und Objektattribute, werden restlos aus der Datei entfernt.
+ Topologische Reduktion: Zur Verringerung der Polygonanzahl wird ein algorithmischer Filter (Decimate-Modifier mit den Parametern Collapse und Planar) auf das aggregierte Modell angewendet. Dieser reduziert redundante Geometrie auf flachen Ebenen, ohne die äußere, schattenwerfende Silhouette zu verfälschen.
+ Referenzierung: Die optimierten Modelldateien werden abschließend über die Link-Funktion speichereffizient in die Simulations-Hauptszene eingebunden.

Eine manuelle räumliche Transformation oder Neuausrichtung entfällt bei diesem Prozess. Da die Modelle der Türme 2 bis 4 denselben globalen Koordinatenursprung (Projektbasispunkt) wie das Referenzmodell des Turms 1 aufweisen, positionieren sie sich beim Import automatisch an den korrekten relativen Koordinaten.
== Aufbereitung des IFC-Modells Turm 1 <AufbereitungIFC>

Die Qualität des vorliegenden IFC-Modells erforderte eine gezielte Vorbearbeitung, um eine konsistente Datengrundlage für die Verschattungssimulation zu schaffen. Im Fokus standen dabei die eindeutige Identifizierbarkeit der Fassadenelemente sowie die Bereinigung geometrischer Inkonsistenzen.

Hinsichtlich der Datenstruktur wurde festgestellt, dass die Zuordnung der Bauteile zu den jeweiligen Geschossen teilweise fehlerhaft war. So waren vertikal übereinanderliegende Fenster demselben Geschoss zugewiesen. Für den weiteren Prozessverlauf wurde diese strukturelle Ungenauigkeit ignoriert, da die Simulation auf den absoluten Koordinaten der Geometrie basiert und nicht auf der logischen Geschosshierarchie des IFC-Baums.

Die ursprünglich vorgesehene Berechnung der geometrischen Fenstermittelpunkte wurde im Zuge der Prozessoptimierung als hinfällig eingestuft. Durch den gewählten Ansatz, die Verschattung an allen vier Eckpunkten eines Fensters zu validieren, entfällt die Notwendigkeit eines zentralen Bezugspunktes. Die Vier-Ecken-Methode bietet zudem eine höhere Granularität bei der Bewertung von Teilverschattungen.

Ein wesentlicher Schritt der Aufbereitung betraf die Fensterflächen im Bereich der Balkone. Diese wurden isoliert und für die Simulation ausgeblendet. Da das IFC-Modell keine Materialeigenschaften übermittelt, würden diese Flächen durch den Simulationsalgorithmus als opake Hindernisse gewertet werden. Dies hätte zur Folge, dass dahinterliegende Fenster fälschlicherweise als verschattet markiert würden, obwohl in der Realität transparente Verglasungen vorliegen.

Zusätzlich wies das Modell geometrische Redundanzen in Form von sich überschneidenden oder doppelt vorhandenen Fensterelementen auf, wie in @fig-FensterÜberschneidung dargestellt. Diese Duplikate wurden manuell identifiziert und entfernt, um Fehlberechnungen und eine unnötige Erhöhung der Rechenlast zu vermeiden.

Schlussendlich wurde ein temporäres Anlagenkennzeichnungssystem für sämtliche Fensterelemente mithilfe eines Skripts implementiert. Diese Maßnahme war notwendig, da die ursprünglichen Objektbezeichnungen keine Informationen über die geschossweise Zuordnung enthielten. Hierfür mussten mithilfe eines Filterlogik, alle relevanten Fensterobjekte vorselektiert werden.
Ein Ansatz um den finalen @aks zuzuordnen wird in @AKSZuordnung aufgezeigt.

#figure(
  image("assets/ÜberschneidendeFenster.png", width: 80%),
  caption: [Bildausschnitt von sich überlagernden Fensterelementen innerhalb der IFC-Struktur.],
  placement: auto
) <fig-FensterÜberschneidung>

== Einrichten der Sonne
#grid(
  columns: (1.5fr, 2fr),
  gutter: 1cm,
  figure(
    image("assets/BlenderSunSettings.png", width: 100%),
    caption: [Einstellungen für Sun Position Add-On],
  ),
  [
    Für die visuelle Darstellung und Validierung des Sonnenstandes innerhalb der 3D-Umgebung wird das in Blender integrierte Add-On Sun Position@blender_sun_position verwendet. Die korrekte Ausrichtung des simulierten Sonnenlichts erfordert die Parametrierung folgender Randbedingungen:

    Im Abschnitt Location werden die exakten geografischen Koordinaten des Projektstandorts definiert. Für das Gebäudeareal FOUR entsprechen diese einem Breitengrad von 50,113 und einem Längengrad von 8,675. Die Nordausrichtung des Modells (North Offset) bleibt in diesem Fall auf null Grad, da die Gebäude bereits korrekt ausgerichtet ist. Die Distanz gibt den Abstand des Sonnenobjekts vom Ursprung an und hat keine Relevanz für den Sonnenstand.
    
    Im Abschnitt Time wird die zeitliche Basis festgelegt. Durch die Zuweisung der lokalen Zeitzone (hier UTC+1) sowie der Eingabe eines spezifischen Datums und einer Uhrzeit berechnet der interne Algorithmus des Moduls automatisch den resultierenden Azimut- und Höhenwinkel. Es muss darauf geachtet werden, während der Sommerzeit das Feld "Dailight Savings" zu aktivieren.
  ]
)
Das gekoppelte Lichtobjekt der Szene wird daraufhin in der virtuellen Umgebung exakt positioniert. Dies ermöglicht eine präzise visuelle Simulation des Schattenwurfs für jeden beliebigen Zeitpunkt im Jahresverlauf.


== Zuordnung AKS Jalousieaktor zu Fenster in BIM-Modell<AKSZuordnung>
Da die Fenster vom Fassadenbauer mit einem Typenkennzeichnungsschlüssel bezeichnet wurden, um die Zuordnung auf der Baustelle zu ermöglichen, ist es nicht möglich, von dem Fenster auf den zuständigen Jalousieaktor zu schließen. Somit muss eine alternative Zuordnung gefunden werden. 
Um die Gebäudeautomation zu planen wurde die Engineering-Software eConfigure von Schneider Electric eingesetzt. Die Planung war zum Zeitpunkt der Arbeit schon komplett abgeschlossen. Bei der Planung wurden Grundrisse der Etagen hinterlegt und alle Komponenten der Raumautomation verortet (siehe @fig-eConfigure). Hierbei gibt es mehrere Symbole für Jalousien, die zum einen den außenliegenden Sonnenschutz und zum anderen den innenliegenden Blendschutz beschreiben. Der Text neben den Symbolen beinhaltet den erforderlichen @aks.
#figure(
  image("assets/AusschnittEConfigure.png"),
  caption: [Ausschnitt der Raumautomation aus eConfigure vom FOUR in Frankfurt],
  placement: auto
)<fig-eConfigure>

Für die Zuordnung muss 
Im nachfolgenden wird ein vorläufiger Prozess stichpunktartig beschrieben, um den @aks des Jalousieaktors in den Fenstern des BIM-Modells zu hinterlegen:
+ In Blender wird die entsprechende Etage als 2D-Grundriss exportiert
+ Behilfsstriche werden in eConfigure entlang der Fensterfront gezogen, um eine spätere Positionierung und Skalierung der Pläne zu ermöglichen
+ Die Grundrisse der vier Mietbereiche werden als DWG (vlt. Fußnote hier zum Dateiformat?) exportiert
+ In AutoCAD werden die vier verschiedenen Grundrisse zusammengeführt, bereinigt, skaliert und positioniert
+ Die Grundrisse aus Blender und aus eConfigure werden übereinander gelegt
+ Alle Daten außer der @aks#[]-Texte werden herausgelöscht
+ Die Datei wird in Blender importiert (Die Texte sind nun um die Fensterfront herum positioniert)
+ Es wird ein Skript ausgeführt, dass für jedes Fenster den Text sucht, der am nächsten liegt und ihn in ein Attribut des Fensters schreibt. Dieses Attribut kann bei der Simulation der Jahresverschattung für die Benennung des Fensters verwendet werden.

Dieser Weg ist zeitaufwendig und wird im Rahmen der Arbeit nur für ein Geschoss angewendet.



== Die eigentliche Simulation der Jahresverschattung <SimulationJahresverschattung>
Für die Verschattungssimulation wird ein Python-Skript ausgeführt, welches über die @ide @vs-code#[]@vscode gestartet wird. Der Code unterteilt sich in mehrere Teile:

Am Anfang muss in der Konfiguration der zu berechnende Zeitbereich eingestellt werden und die zeitliche Auflösung (z.B. 15 Minuten).

#figure(
  image("assets/Verschattung1.svg"),
  caption: [test]
)

Funktionsweise der softwaregestützten Verschattungssimulation

Das entwickelte Python-Skript bildet das technische Kernstück der Prozesskette. Es automatisiert die geometrische Verschattungsanalyse innerhalb der 3D-Umgebung und generiert Steuerungsdaten für die Gebäudeautomation. Der programmatische Ablauf lässt sich in vier konsekutive Phasen unterteilen:

==== Initialisierung und Extraktion der Gebäudegeometrie
In der Vorbereitungsphase durchsucht der Algorithmus den Szenengraphen der Simulationsumgebung nach allen Objekten, die anhand ihrer Namenskonvention als Fenstersensoren ("\_PAN\_" im Namen enthalten) klassifiziert sind. 
// Um die spätere Rechenlast während der Zeitschleifen zu minimieren, werden die geometrischen Eigenschaften jedes Fensters nur ein einziges Mal zu Beginn extrahiert. 
Das Skript ermittelt für jedes Fenster die primäre Glasfläche und berechnet deren physikalischen Normalenvektor. Durch einen vektoriellen Abgleich mit dem geometrischen Zentrum des Gebäudes wird mathematisch verifiziert, dass dieser Normalenvektor stets nach außen zeigt. Parallel dazu speichert das System die exakten 3D-Weltkoordinaten der vier Eckpunkte der Fensterfläche ab, welche als Ausgangspunkte für die spätere Strahlenverfolgung dienen.

==== Astronomische Berechnung der Sonnenvektoren
Die eigentliche Simulation iteriert über den festgelegten Betrachtungszeitraum in diskreten 15-Minuten-Schritten. Für jeden iterativen Zeitschritt übersetzt der integrierte NOAA-Algorithmus den lokalen Längen- und Breitengrad sowie den UTC-korrigierten Zeitstempel in einen dreidimensionalen Richtungsvektor zur Sonne. In dieser Phase findet zudem ein effizienzsteigernder Filterprozess statt: Liegt der berechnete Höhenwinkel der Sonne unter null Grad, registriert das System den Zustand global als Nacht. Der Algorithmus weist allen Fenstern für diesen Zeitstempel den entsprechenden Statuswert zu und überspringt die rechenintensiven Kollisionsprüfungen.

==== Filterung und Vierpunkt-Raycasting
Sobald ein Tag-Zustand vorliegt, iteriert das Skript über alle registrierten Fenster. Die Ermittlung des Verschattungsstatus erfolgt hierbei in einem zweistufigen Verfahren. Der erste Schritt ist ein mathematischer Ausschluss, das sogenannte Backface Culling. Über das Skalarprodukt aus dem berechneten Sonnenvektor und dem zuvor gespeicherten Fensternormalenvektor wird geprüft, ob die direkte Solarstrahlung die Fassade von hinten trifft. Ist dies der Fall, wird die Berechnung für dieses Fenster sofort abgebrochen und der Status für eine rückseitige Verschattung dokumentiert.

Fällt das Licht hingegen in einem positiven Winkel auf die Fassadenvorderseite, initiiert das Skript das Vierpunkt-Raycasting. Von den vier Randkoordinaten des Fensters wird ein theoretischer Sehstrahl in Richtung der Sonne projiziert. Der Algorithmus prüft, ob dieser Strahl auf seinem Weg durch die Szene ein Objekt der umgebenden Bebauung schneidet. Die Schleife bricht ab, sobald nur ein einziger der vier Strahlen die Sonne ungehindert erreicht. In diesem Fall wird das gesamte Fenster als besonnt klassifiziert. Nur wenn alle vier Eckpunkte durch externe Geometrien verdeckt sind, meldet der Algorithmus eine vollständige Verschattung.

==== Datenaggregation und Export
Im finalen Schritt überführt das Skript die akkumulierten Statuswerte in eine Struktur, die als csv-Datei gespeichert wird. Die generierte Exportdatei listet die chronologischen Zeitstempel als Zeilen und ordnet die zugehörigen @aks der Fenster als Spalten an. Diese Formatierung ermöglicht es der Gebäudeautomation im späteren operativen Betrieb, die Matrix sequenziell einzulesen. "Die ausgegebenen diskreten Zahlenwerte differenzieren dabei klar zwischen aktiver Besonnung, Fremdverschattung, Eigenverschattung und fehlender astronomischer Einstrahlung bei Nacht."


=== Zeitliche Auflösung und Umfang (vlt. lieber in Kap 3?) <ZeitlicheAufloesungUmfang>
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

*Zeitlicher Umfang:* Es stellt sich die Frage, wie viele volle Kalenderjahre berechnet werden müssen, um den realen Sonnenverlauf hinreichend abzubilden. Der Umlauf der Erde um die Sonne unterliegt langperiodischen Schwankungen (Milanković-Zyklen@dwdMilanZyklen). Diese sind für die Lebensdauer eines Gebäudes als nicht relevant anzusehen, weshalb der berechnete Sonnenverlauf für den Betrachtungszeitraum als statisch betrachtet werden kann. 

Da das kalendarische Jahr vom astronomischen Sonnenjahr (365,24 Tage) abweicht@astr04eduSonnenjahr, wird diese Differenz alle vier Jahre durch ein Schaltjahr korrigiert. Die hieraus resultierende zeitliche Verschiebung des Sonnenstandes am selben Kalendertag ist für einen simulierten Schattenwurf in @fig-schaltjahr beispielhaft dargestellt. Da es sich bei den räumlichen Abweichungen lediglich um wenige Zentimeter (roter Bereich) handelt, ist es ausreichend, die Simulation auf ein einzelnes Referenzjahr zu beschränken.

/*#figure(
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
*/
#figure(
  image("assets/SchaltjahrUnterschied.png"), caption:[Differenz Schattenwurf am 01.03.2027 und 01.03.2028 (Schaltjahr) um 9:00],
  placement: auto
)<fig-schaltjahr>

Da die Sonne in Frankfurt immer nach 5 Uhr aufgeht und immer vor 22 Uhr untergeht, wird der tägliche zu berechnende Bereich auf 5 bis 22 Uhr festgelegt.

=== Überlegung zur räumlichen Auflösung <RaeumlicheAufloesung>
Neben der zeitlichen Diskretisierung bestimmt die räumliche Abtastung der Fensterflächen die Zuverlässigkeit der Simulationsergebnisse. Für jedes Fenster im IFC-Modell muss definiert werden, mit wie vielen Testpunkten der Verschattungsstatus ermittelt wird. 

Ein naheliegender Ansatz wäre die Unterteilung der Fensterfläche in ein feines Raster, um den prozentualen Verschattungsgrad für eine dynamische Höhennachführung des Behanges zu ermitteln. Im Kontext der in Kapitel 4.4.1 gewählten zeitlichen Auflösung von 15 Minuten erweist sich diese Lösung in der Praxis jedoch als nicht zielführend: Die Schattenkante wandert innerhalb eines 15-Minuten-Intervalls zu weit, was zu schwer nachvollziehbaren Nachführbewegungen der Aktorik führen würde. Daher fokussiert sich die Betrachtung auf zwei pragmatische Optionen:

*1. Einpunkt-Messung (Fenstermittelpunkt):*
Es wird ein einzelner Raycast vom geometrischen Zentrum des Fensters zur Sonne berechnet.
Dieser Ansatz hat den Vorteil, dass er die geringste Rechenzeit aufweist. Allerdings ist die Einpunkt-Messung anfällig für Halbschatten-Situationen. Verdeckt ein Schatten beispielsweise nur die untere Fensterhälfte, meldet der Mittelpunkt unter Umständen noch keine Verschattung. Umgekehrt kann der Mittelpunkt bereits verschattet sein, während die obere Fensterhälfte noch stark blendet.

*2. Vierpunkt-Messung (Eckpunkte):*
Die Simulation prüft die vier Extrempunkte der Fenstergeometrie. Sobald mindestens einer der vier Punkte direkte Sonneneinstrahlung detektiert, gilt das gesamte Fenster als besonnt.
Teilverschattungen werden somit sicher erkannt, wodurch temporäre Blendungen verhindert werden.
Der Nachteil ist eine ca. Verdopplung der Rechenzeit gegenüber der Einpunkt-Messung. Zudem können sehr schmale, vertikale Objekte (z. B. Masten), die schmaler als die Fensterbreite sind, theoretisch übersehen werden. Dies stellt im urbanen Kontext jedoch ein vernachlässigbares Restrisiko dar. In einzelnen Fällen, kann auch ein Schattenwurf, der nur die untere Fensterkante streift, zu einer nicht notwendigen Reaktion der Jalousie führen. Dies könnte mit dem Hochsetzen der unteren beiden Eckpunkte verhindert werden.

*Fazit für den Prototyp:*
Um den visuellen Komfort der Nutzer zu garantieren, wird für den entwickelten Workflow die Vierpunkt-Messung gewählt. Die Erhöhung der Rechenzeit wird durch die verbesserte Steuerungssicherheit gerechtfertigt. Die vier booleschen Einzelwerte werden bereits im Python-Skript zu einem einzelnen Status pro Fenster aggregiert, sodass die zu exportierende Datenmenge für die Automationsstation identisch mit der Einpunkt-Messung bleibt.

=== Berechnungsaufwand und Optimierung <Simulationsoptimierung>
Für diese Arbeit wurde der 20.03.26 im 15-Minuten Takt simuliert. Dieser Tag beschreibt die frühjährliche Tag-Nacht-Gleiche (Äquinoktium) an dem die Sonne genau gleich lang über und unter dem Horizont verbleibt. Da die Hälfte des Jahres mehr und die andere Hälfte weniger Sonnenstunden aufweist, eignet sich dieser Tag für eine Hochrechnung der Simulationsdauer auf das gesamte Jahr.
Die Simulation dauerte 21 Minuten#footnote[Die Berechnung der Jahressimulation erfolgte auf einer Workstation mit folgender Spezifikation: AMD Ryzen 5 7600X (6-Core, 4,7 GHz), 32 GB RAM, AMD Radeon RX 7800 XT, Windows 11 (64-bit), Blender Version 4.5.3], was für eine gesamte Jahresberechnung 5 Tagen und 8 Stunden entspricht. Da diese Simulation nur einmal berechnet werden muss für ein gesamtes Gebäude, liegt die Simulationsdauer im annehmbaren Bereich. Da Blender für Python-Skripte nur einen CPU-Kern benutzen kann, könnten weiter Blender-Instanzen geöffnet werden, um parallel Datumsbereiche des Jahres zu berechnen. Diese müssten dann final in eine Datei bzw. Datenbank zusammengeführt werden.

Auf Backwards Culling eingehen und wieviel es spart
/*
68 x 365 = 24.820 Spalten


- Ohne Optimierung (760s)
- Zusammenfügen von umliegenden Objekten 786s (Optimierungepotenzial bei -3,4%)
- löschen von 80% der kleinen Häuser 764s
- Mathe-Skript 793s
- Mathe Skript mit Normalenoptimierung: 408s
- ""+Winkel: 434s
*/
== Validierung <ValidierungErgebnisse>

=== Validierung der virtuellen Szene
Die Validierung der virtuellen Szene erfolgt durch einen visuellen Abgleich zwischen einem gerenderten Bild der Simulation und einer fotografischen Aufnahme des FOUR zu einem definierten Zeitpunkt. Als Referenz dient eine für die Bauüberwachung und das Marketing genutzte Webcam auf dem 137 Meter hohen Nextower am Thurn-und-Taxis-Platz, welcher sich in etwa 500 Metern Entfernung befindet. Die historischen Aufnahmen sind über die Website des Anbieters @zeitrafferFOURFrankfurt abrufbar. Für den Abgleich wurde ein wolkenarmer Tag gewählt, um durch ein Minimum an diffusem Licht klare Schattenkanten zu erhalten. Der Nextower ist im digitalen Modell integriert, um die Kameraposition exakt nachzubilden.

Das Ergebnis dieses Abgleichs ist in @fig-validierung_t1 dargestellt. Es zeigt sich eine visuell sehr hohe Übereinstimmung der Schattenkanten zwischen Referenzbild und Simulation. Dies belegt die korrekte geometrische Anordnung der Szene in Blender sowie die Präzision des integrierten Sonnenmodells für den gewählten Zeitpunkt.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("assets/webcam_foto.png", width: 100%),
    image("assets/blender_render.png", width: 100%)
  ),
  caption: [Validierung der Verschattungssimulation am Turm 1. Links: Webcam-Aufnahme vom 21.06.2025 (9:15 Uhr). Rechts: Simulationsergebnis zum identischen Zeitpunkt.],
  placement: auto
) <fig-validierung_t1>

Eine alternative Validierungsmethode bestünde in der Installation von Helligkeitssensoren an den Fassaden des FOUR zur Erfassung realer Messwerte an wolkenlosen Tagen. Dieser Ansatz wurde aus zeitlichen Gründen im Rahmen dieser Arbeit nicht weiter verfolgt.

=== Validierung der skriptbasierten Simulation
Während die visuelle Validierung die Geometrie und das interne Sonnenmodell der Software bestätigt, erfordert das entwickelte Simulationsskript eine separate Überprüfung. Dieses Skript greift nicht auf das interne Sonnenstands-Plug-in von Blender zurück, sondern implementiert den NOAA-Algorithmus zur Berechnung des Sonnenstandes.

Zur Validierung des Skripts wird der Verschattungszustand für denselben Referenzzeitpunkt berechnet und in eine CSV-Datei exportiert. Ein separates Auswertungsskript visualisiert diese Daten, indem es die Fassadenelemente des FOUR basierend auf ihrem simulierten Verschattungsstatus einfärbt. Eine Rotfärbung indiziert dabei eine vollständige Verschattung des jeweiligen Fensters, definiert durch die Verdeckung aller vier Eckpunkte.

Wie in @fig-validierungSkript zu erkennen ist, liegen die als verschattet identifizierten Fensterelemente exakt innerhalb der optisch gerenderten Schattenflächen. Diese Deckungsgleichheit bestätigt die korrekte Implementierung des NOAA-Algorithmus sowie die funktionale Zuverlässigkeit des entwickelten Skripts zur algorithmischen Bestimmung der Fassadenverschattung.

#figure(
  box(
    width: 12cm, 
    height: 12cm, 
    clip: true,
    align(center + horizon)[
      #image("assets/ValidierungSkript.png", width: 200%)
    ]
  ),
  caption: [Detailansicht der Szene zur Überprüfung der Simulationsergebnisse. Rot eingefärbte Elemente markieren eine algorithmisch ermittelte vollständige Verschattung.],
  placement: auto
) <fig-validierungSkript>