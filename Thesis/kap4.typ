#let short-title = state("short-title", none)
#import "@preview/codly:1.3.0": *
= Implementierung des Proof of Concept (90% fertig) <Kap4>
Um den in Kapitel 3 konzipierten Systemansatz auf seine praktische Tragfähigkeit zu überprüfen, wird im Folgenden ein @poc durchgeführt. Ziel dieses Kapitels ist es, die softwaretechnische Machbarkeit der entwickelten Prozesskette - vom fehlerfreien Import heterogener Datensätze (IFC und GIS) über die raycastingbasierte Verschattungssimulation bis hin zum strukturierten Datenexport - exemplarisch nachzuweisen. Hierfür wurde ein funktionsfähiger Software-Prototyp auf Basis von Blender und Python implementiert. 

Die Entwicklung und Validierung dieses Prototyps erfolgt anhand eines komplexen Referenzprojekts:

#figure(
  image("assets/ÜbersichtFOUR.svg", width: 70%),
  caption: [Grafik des FOUR mit seinen Türmen 1 bis 4@four_frankfurt_about],
  placement: bottom
)

== Vorstellung des Referenzprojekts
Das FOUR sind vier zusammenhängende Türme mit Büro- und Wohnungsnutzung in der Innenstadt von Frankfurt am Main. Die vier Türme stehen auf vier Gebäuden (Podesten), die miteinander verbunden sind. Das Bauprojekt befindet sich momentan in der Endphase und soll im Laufe des Jahres 2026 endgültig übergeben werden. In dieser Arbeit wird die Verschattungssimulation am 233m hohen Büroturm T1 angewendet. Der Turm besteht pro Geschoss aus vier Mietbereichen und hat pro Segment einen außenliegenden Sonnenschutz und einen innenliegenden Blendschutz. Es werden 5859 relevante Fenster im Turm 1 gezählt. Die Türme stehen eng beieinander im Zentrum von Frankfurt zwischen verschiedenen Hochhäusern (z.B. dem Commerzbank-Tower und dem MAIN-Tower). Durch dieses eng bebaute Areal treten sehr dynamische Verschattungssituationen auf, die nur durch eine präzise Simulation der Umgebung korrekt dargestellt werden können.
Eine architektonische Besonderheit des FOUR sind die diagonal abgeschrägten Fassadenabschnitte (@fig-FourTageslicht), die den visuellen Freiraum und die Tageslichtzufuhr verbessern sollen und die Fenster, welche in unterschiedlichen Winkel zur Fassade angeordnet sind.

#figure(
  image("assets/FourTageslichtSchnitte.png"),
  caption: [Darstellung und Erklärung der diagonalen Fassadenabschrägung des FOUR@four_frankfurt_about]
)<fig-FourTageslicht>

Es liegen die Fassadenmodelle aller Türme und Podeste des FOUR als ifc-Dateien vor.

== Datenaufbereitung und Modellaufbau
=== Import, Aufbereitung und Georeferenzierung des BIM-Modells
==== Import und Positionierung des Turm 1 <ImportPositionierungT1>
*Import:*
Als erstes wird eine neue Blenderdatei gespeichert und die ifc-Datei des Referenzgebäudes importiert. Dies geschieht über das Blender Add-On Bonsai@bonsai_openbim, welches den Import und die Bearbeitung von BIM-Daten ermöglicht. Da die ifc-Modelle beim FOUR schon als Fassaden-Teilmodelle vorliegen, muss hier beim Import kein Filter angewandt werden, um nicht relevante Bauteile auszuschließen.

// *Import* Da die in @AnalyseBIMDatenguete[Kapitel] definierten Anforderungen zum Teil nicht erfüllt werden, musste beim Import der FOUR-IFC-Datei noch folgendes gemacht werden:

*Positionierung:*
Für die Positionierung des Gebäudes sollte zuerst auf die im IfcSite-Tag hinterlegten Koordinaten zurückgegriffen werden. Nach eingängiger Prüfung stellt sich heraus, dass die Koordinaten auf einen Punkt in der Mitte des Baufelds verweisen und nicht auf den gewünschten Ursprung des ifc-Modells. Nach Sichtung der Planunterlagen wurden im "Masterplan für das BIM-Modell" die richtigen XY-Koordinaten (in Form des Gauß-Krüger-Koordinatensystems) entdeckt. Die Z-Koordinate, also die Höhe des ifc-Ursprungs konnte über einen Schnitt ausfindig gemacht werden. Da Frankfurt ca. 100m über @nn liegt, werden genau 100m als Koordinatenebene festgelegt. Diese Koordinaten werden somit als Ursprung des gesamten Simulationsmodells definiert. 

Für die weitere Verwendung werden die XY-Koordinaten mithilfe einer Anwendung des Bundesamt für Kartographie und Geodäsie@bkg_koordinatentransformation in das benötigte UTM32 Koordinatenreferenzsystem übersetzt. Dafür wird das Verschiebegitter Beta2007 verwendet.

==== Aufbereitung des IFC-Modells Turm 1 <AufbereitungIFC>

Die Qualität des vorliegenden IFC-Modells erforderte eine gezielte Vorbearbeitung, um eine konsistente Datengrundlage für die Verschattungssimulation zu schaffen. Im Fokus standen dabei die eindeutige Identifizierbarkeit der Fassadenelemente sowie die Bereinigung geometrischer Inkonsistenzen.

Hinsichtlich der Datenstruktur wurde festgestellt, dass die Zuordnung der Bauteile zu den jeweiligen Geschossen teilweise fehlerhaft war. So waren vertikal übereinanderliegende Fenster demselben Geschoss zugewiesen. Für den weiteren Prozessverlauf wurde diese strukturelle Ungenauigkeit ignoriert, da die Simulation auf den absoluten Koordinaten der Geometrie basiert und nicht auf der logischen Geschosshierarchie des IFC-Baums.

Die ursprünglich vorgesehene Berechnung der geometrischen Fenstermittelpunkte wurde im Zuge der Prozessoptimierung als hinfällig eingestuft. Durch den gewählten Ansatz, die Verschattung an allen vier Eckpunkten eines Fensters zu validieren, entfällt die Notwendigkeit eines zentralen Bezugspunktes. Die Vier-Ecken-Methode bietet zudem eine höhere Granularität bei der Bewertung von Teilverschattungen.

Ein wesentlicher Schritt der Aufbereitung betraf die Fensterflächen im Bereich der Balkone. Diese wurden isoliert und für die Simulation ausgeblendet. Da das IFC-Modell keine Materialeigenschaften übermittelt, würden diese Flächen durch den Simulationsalgorithmus als opake Hindernisse gewertet werden. Dies hätte zur Folge, dass dahinterliegende Fenster fälschlicherweise als verschattet markiert würden, obwohl in der Realität transparente Verglasungen vorliegen.

Zusätzlich wies das Modell geometrische Redundanzen in Form von sich überschneidenden oder doppelt vorhandenen Fensterelementen auf, wie in @fig-FensterÜberschneidung dargestellt. Diese Duplikate wurden manuell identifiziert und entfernt, um Fehlberechnungen und eine unnötige Erhöhung der Rechenlast zu vermeiden.

#figure(
  image("assets/ÜberschneidendeFenster.png", width: 80%),
  caption: [Bildausschnitt von sich überlagernden Fensterelementen innerhalb der IFC-Struktur.],
  placement: none
) <fig-FensterÜberschneidung>

Schlussendlich wird ein temporäres Anlagenkennzeichnungssystem erstellt, dass sich auf das jeweilige Geschoss und eine fortlaufende Nummer für sämtliche Fensterelemente bezieht. Zum Beispiel FL13_W034 steht für:  13. Geschoss (Floor) an der 34. Position. Dies wird mithilfe eines Skripts (@DigitaleAnlage) implementiert. Diese Maßnahme ist notwendig, da die ursprünglichen Objektbezeichnungen keine Informationen über die räumliche Zuordnung enthalten. Hierfür müssen mithilfe einer Filterlogik, alle relevanten Fensterobjekte vorselektiert werden. Glasscheiben für die Balkonbrüstung und sehr kleine Fensterflächen haben keine Jalousie und werden somit nicht berücksichtigt.
Ein Ansatz, um den finalen @aks des Jalousieaktors dem Fenster zuzuordnen, wird in @AKSZuordnung aufgezeigt.

=== Zuweisung des Anlagenkennzeichnungsschlüssels (AKS)<AKSZuordnung>
Da die Fenster vom Fassadenbauer mit einem Typenkennzeichnungsschlüssel bezeichnet wurden, um die Zuordnung auf der Baustelle zu ermöglichen, ist es nicht möglich, von dem Fenster auf den zuständigen Jalousieaktor zu schließen. Somit muss eine alternative Zuordnung gefunden werden.
Um die Gebäudeautomation zu planen wurde die Engineering-Software eConfigure von Schneider Electric eingesetzt. Die Planung war zum Zeitpunkt der Arbeit schon komplett abgeschlossen. Bei der Planung wurden Grundrisse der Etagen hinterlegt und alle Komponenten der Raumautomation verortet (siehe @fig-eConfigure). Hierbei gibt es mehrere Symbole für Jalousien, die zum einen den außenliegenden Sonnenschutz und zum anderen den innenliegenden Blendschutz beschreiben. Der Text neben den Symbolen beinhaltet den erforderlichen @aks.
#figure(
  image("assets/AusschnittEConfigure.png"),
  caption: [Ausschnitt der Raumautomation aus eConfigure vom FOUR in Frankfurt],
  placement: none
)<fig-eConfigure>

Für die Zuordnung muss also eine Übertragung des Anlagenkennzeichnungssystems (AKS) der Jalousieaktoren auf die Fensterelemente im BIM-Modell erfolgen.
Im nachfolgenden wird ein vorläufiger Prozess stichpunktartig beschrieben:



+ *Referenzexport*: Der betroffene Geschossgrundriss wird aus der 3D-Umgebung (Blender) als zweidimensionale Referenz exportiert.
+ *Planvorbereitung*: Im Projektierungstool eConfigure werden Hilfslinien entlang der Fassadenkontur erstellt, um eine spätere Skalierung und Positionierung der Pläne zu ermöglichen.
+ *Datenexport*: Die Grundrisse der vier Mietbereiche werden aus eConfigure in das etablierte CAD-Austauschformat DWG exportiert.
+ *Aufbereitung und Referenzierung*: In AutoCAD werden die Teilgrundrisse zusammengeführt, bereinigt, maßstäblich skaliert und räumlich positioniert.
+ *Überlagerung*: Die geometrischen Referenzdaten aus Blender und die Planungsdaten aus eConfigure werden visuell überlagert.
+ *Datenreduktion*: Sämtliche Planinhalte mit Ausnahme der textuellen @aks#[]-Bezeichner werden entfernt.
+ *Reimport in die 3D-Umgebung*: Die bereinigte DWG-Datei wird in Blender importiert. Die textuellen Bezeichner befinden sich nun räumlich exakt entlang der Fassadenlinie (siehe @fig-AKSumFenster).
+ *Algorithmische Zuweisung*: Ein Python-Skript iteriert über alle Fensterelemente und identifiziert für jedes Fenster das räumlich nächstgelegene Textobjekt (Nearest-Neighbor-Suche). Der ausgelesene String wird als Attribut in das Fensterobjekt geschrieben. Dieses Attribut dient in der anschließenden Verschattungssimulation als eindeutiger, auslesbarer Identifikator.
#figure(
  image("assets/PositionierungAKS.png", width: 60%),
  caption: [Draufsicht von FOUR Turm 1 mit an den Fenstern platzierten AKS-Texten für Etage 45 in Blender],
  placement: none
)<fig-AKSumFenster>
Da dieser prototypischer Weg sehr zeitaufwendig ist, wird im Rahmen dieser Arbeit nur ein Geschoss bearbeitet. Für die spätere Simulation wird der in @AufbereitungIFC festgelegte, temporäre @aks für die Bezeichnung der Fenster verwendet.


=== Integration der urbanen Umgebungsdaten
==== Import und Positionierung der Umgebungsdaten...<ImportUmgebungsdaten>

Für die Modellierung der umgebenden, verschattenden Bebauung wird auf die offenen Geodaten der @hvbg#[]@Hessen3D zurückgegriffen. Die 3D-Gebäudemodelle für das Stadtgebiet Frankfurt am Main werden von offizieller Seite standardmäßig im Format CityGML (internationaler Standard des Open Geospatial Consortiums (OGC) zur Modellierung, Speicherung und dem Austausch semantischer 3D-Stadtmodelle@citygml_30) bereitgestellt.

Da für Blender keine native Import-Schnittstelle für CityGML-Dateien existiert, ist eine vorherige Datenkonvertierung erforderlich. Die Datensätze werden hierfür in das JSON-basierte Format CityJSON (ebenfalls Datenaustauschformat für digitale 3D-Modelle von Städten und Landschaften@cityjson) mithilfe eines Tools@cityjson_conversion überführt.

Der finale Import der Gebäudekörper in die 3D-Umgebung erfolgt über das Open-Source-Plugin CityJSONEditor@github_cityjsoneditor für Blender. Da die hierarchische Struktur der amtlichen Frankfurter Daten teilweise von den Standardannahmen des Plugins abwich, wurden im Rahmen dieser Arbeit gezielte Anpassungen am Python-Quellcode der Import-Erweiterung vorgenommen. Diese Fehlerbehebungen umfassen im Wesentlichen drei Aspekte:
+ *Toleranz bei fehlenden Texturen:* Es wird eine Abfrage implementiert, die den Importprozess bei Objekten ohne definierte Fassadentexturen (Appearances) nicht abbricht, sondern die reine Geometrie weiterverarbeitet.
+ *Datentyp-Konvertierung (@lod):* Die Einleseroutine wird dahingehend modifiziert, dass der im Datensatz als String vorliegende Wert für den Detailgrad (@lod) programmatisch in einen Float umgewandelt wird.
+ *Filterung geometrieloser Objekte:* Es wird eine Filterroutine integriert, die Datensätze ohne physische 3D-Geometrie (wie bspw. reine Grundstücksgrenzen oder Landnutzungsflächen) beim Import ignoriert, um Programmabbrüche zu verhindern.

Im Anschluss erfolgt die räumliche Verortung des Stadtmodells in der Simulationsumgebung. Die originären CityJSON-Daten sind im globalen ETRS89/UTM-Koordinatensystem referenziert. Da der Projektbasispunkt (P1) in Blender auf (0,0,0) gesetzt ist, muss P1 von den Koordinaten der Umgebungsdaten subtrahiert werden. Die Koordinaten werden im Quellcode hinterlegt. Durch diese Nullpunktverschiebung wird das Makromodell der Umgebung präzise in das kartesische System der Software überführt. Zuletzt werden Gebäude die in zweiter und dritter Reihe zum Turm 1 stehen, ausgewählt und aus der Szene gelöscht. Gebäude, die direkt nördlich des Referenzgebäudes (Turm 1) stehen, werden ebenfalls entfernt.


==== Import und Positionierung der Türme 2 bis 4 <ImportT24>
Da das Gebäudeensemble FOUR zum Zeitpunkt der Datenerhebung noch nicht in den amtlichen CityGML-Datensätzen erfasst ist, werden für die Verschattungssimulation die detaillierten IFC-Fassadenmodelle der Türme 2 bis 4 herangezogen. Diese liegen in einem sehr hohen Detaillierungsgrad (@lod 500) vor. Dies ist einerseits vorteilhaft für eine hohe Präzision des Schattenwurfs, beinhaltet andererseits jedoch eine massive Menge an nicht benötigten geometrischen und semantischen Daten. Um die Dateigröße zu minimieren und den Arbeitsspeicher während der Simulation zu entlasten, wird eine systematische Reduktion der Modelle durchgeführt:

+ *Isolierter Import*: Die IFC-Dateien der Nachbartürme werden zunächst in separate Blender-Projekte importiert, um die Hauptdatei nicht initial zu überlasten.
+ *Geometrische Aggregation*: Sämtliche Einzelbauteile (Meshes) eines Turms werden zu einem zusammenhängenden Polygonnetz verschmolzen.
+ *Semantische Bereinigung*: Alle nicht-geometrischen Informationen, wie IFC-Hierarchien, Materialdaten und Objektattribute, werden restlos aus der Datei entfernt.
+ *Topologische Reduktion*: Zur Verringerung der Polygonanzahl wird ein algorithmischer Filter (Decimate-Modifier mit den Parametern Collapse und Planar) auf das aggregierte Modell angewendet. Dieser reduziert redundante Geometrie auf flachen Ebenen, ohne die äußere, schattenwerfende Silhouette zu verfälschen.
+ *Referenzierung*: Die optimierten Modelldateien werden abschließend über die Link-Funktion in die Simulations-Hauptszene eingebunden.

Eine manuelle räumliche Transformation oder Neuausrichtung entfällt bei diesem Prozess. Da die Modelle der Türme 2 bis 4 denselben globalen Koordinatenursprung (Projektbasispunkt) wie das Referenzmodell des Turms 1 aufweisen, positionieren sie sich beim Import automatisch an den korrekten relativen Koordinaten.

Die aggregierte Szene ist in @fig-fertigeSzene zu sehen...

#figure(
  image("assets/FertigeSzene.png", width: 100%),
  caption: [Aufnahme der fertigen Szene mit Turm 1-4 FOUR und den umgebenden Gebäuden in Blender],
  placement: auto
)<fig-fertigeSzene>

=== Definition der astronomischen Randbedingungen
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


== Durchführung der Verschattungssimulation
=== Parametrisierung der zeitlichen und räumlichen Auflösung
Basierend auf den theoretischen Vorüberlegungen aus @ZeitlicheAufloesungUmfang[Kapitel] ist eine hohe zeitliche Auflösung der Simulation zu bevorzugen. Aufgrund der hohen Komplexität des Projektes (5859 Fenster) und der damit einhergehenden langen Simulationsdauer, wird nur ein 15-Minuten-Raster festgelegt. Auf ein Kalenderjahr (Referenzjahr ohne Schaltjahr) hochgerechnet, resultiert dies in 35.040 Datenpunkten pro Fenster, die im Anschluss an die Raumautomationsstation übergeben werden müssen.

Da die Sonne in Frankfurt am Main am längsten Sommertag nach 05:00 Uhr aufgeht und am längsten Tag vor 22:00 Uhr untergeht, wurde die tägliche Berechnungsschleife im Python-Skript auf den Zeitraum von 05:00 bis 22:00 Uhr limitiert.

Für die räumliche Auflösung wird die Vierpunkt-Messung gewählt, da eine mittlere zeitliche Auflösung von 15 Minuten verwendet wird. Aufgrund der hohen Anzahl der Fenster, wäre eine Rastermessung zu Rechenintensiv und würde eine große Datenmenge generieren.

=== Umsetzung der Jahresverschattung<SimulationJahresverschattung>
Das entwickelte Python-Skript bildet das technische Kernstück der Prozesskette. Es automatisiert die geometrische Verschattungsanalyse innerhalb der 3D-Umgebung und generiert Steuerungsdaten für die Gebäudeautomation. Hierfür wird ein Python-Skript ausgeführt, welches über die @ide @vs-code#[]@vscode gestartet wird. Am Anfang müssen im Konfigurationsteil des Skripts (siehe @code-konfiguration) die gewünschten Parameter eingestellt werden:
- Speicherort und Name der generierten csv-Datei
- Anfangsdatum und Dauer der Simulation in Tagen
- Start- und Endzeit der Berechnung in vollen Stunden
- Zeitliche Auflösung der Simulation in Minuten
- Koordinaten im WGS 84 Koordinatenreferenzsystem

#codly(offset: 19, zebra-fill: none)
#codly(number-format: (n) => box(fill: luma(240), height: 1.5em, outset: 0.5em)[#text(luma(100), size: 0.8em)[#str(n)]])
#figure(
```python
# --- Konfiguration ---
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "Dateiname.csv") # Dateipfad und -name
print(f"Ziel-Datei: {OUTPUT_FILE}")
start_date = datetime.date(YEAR, 1, 1) # Anfangsdatum
for i in range(365): # Simulationsdauer
    current_date = start_date + datetime.timedelta(days=i)
    SIMULATION_DATES.append((current_date.day, current_date.month))
START_HOUR = 5, END_HOUR = 22 # Start- und Endzeit
MINUTES_STEP = 15 # Simulationsauflösung
LATITUDE = 50.1126, LONGITUDE = 8.67472 # Koordinaten
```,
caption: [Konfiguration der Verschattungssimulation],
placement: none)<code-konfiguration>



Der Programmablauf (siehe @fig-flussdiagramm) unterteilt sich in vier Phasen:


==== Initialisierung und Extraktion der Gebäudegeometrie
In der Vorbereitungsphase durchsucht der Algorithmus den Szenengraphen der Simulationsumgebung nach allen Objekten, die anhand des Attributs "@aks" als Fenstersensoren klassifiziert sind. 
// Um die spätere Rechenlast während der Zeitschleifen zu minimieren, werden die geometrischen Eigenschaften jedes Fensters nur ein einziges Mal zu Beginn extrahiert. 
Das Skript ermittelt für jedes Fenster die primäre Glasfläche und berechnet deren physikalischen Normalenvektor. Durch einen vektoriellen Abgleich mit dem geometrischen Zentrum des Gebäudes wird mathematisch verifiziert, dass dieser Normalenvektor stets nach außen zeigt. Parallel dazu speichert das System die exakten 3D-Weltkoordinaten der vier Eckpunkte der Fensterfläche ab, welche als Ausgangspunkte für die spätere Strahlenverfolgung dienen.

==== Astronomische Berechnung der Sonnenvektoren
Die eigentliche Simulation iteriert über den festgelegten Betrachtungszeitraum in diskreten 15-Minuten-Schritten. Für jeden iterativen Zeitschritt übersetzt der integrierte @noaa#[]-Algorithmus den lokalen Längen- und Breitengrad sowie den UTC-korrigierten Zeitstempel in einen dreidimensionalen Richtungsvektor zur Sonne. In dieser Phase findet zudem ein effizienzsteigernder Filterprozess statt: Liegt der berechnete Höhenwinkel der Sonne unter null Grad, registriert das System den Zustand global als Nacht. Der Algorithmus weist allen Fenstern für diesen Zeitstempel den entsprechenden Statuswert zu und überspringt die rechenintensiven Kollisionsprüfungen.

==== Filterung und Vierpunkt-Raycasting
Sobald ein Tag-Zustand vorliegt, iteriert das Skript über alle registrierten Fenster. Die Ermittlung des Verschattungsstatus erfolgt hierbei in einem zweistufigen Verfahren. Der erste Schritt ist ein mathematischer Ausschluss, das sogenannte Backface Culling. Über das Skalarprodukt aus dem berechneten Sonnenvektor und dem zuvor gespeicherten Fensternormalenvektor wird geprüft, ob die direkte Solarstrahlung die Fassade von hinten trifft. Ist dies der Fall, wird die Berechnung für dieses Fenster sofort abgebrochen und der Status für eine rückseitige Verschattung dokumentiert.

Fällt das Licht hingegen in einem positiven Winkel auf die Fassadenvorderseite, initiiert das Skript das Vierpunkt-Raycasting. Von den vier Randkoordinaten des Fensters wird ein theoretischer Sehstrahl in Richtung der Sonne projiziert. Der Algorithmus prüft, ob dieser Strahl auf seinem Weg durch die Szene ein Objekt der umgebenden Bebauung schneidet. Die Schleife bricht ab, sobald nur ein einziger der vier Strahlen die Sonne ungehindert erreicht. In diesem Fall wird das gesamte Fenster als besonnt klassifiziert. Nur wenn alle vier Eckpunkte durch externe Geometrien verdeckt sind, meldet der Algorithmus eine vollständige Verschattung.

==== Datenaggregation und Export
Im finalen Schritt überführt das Skript die akkumulierten Statuswerte in eine Struktur, die als csv-Datei gespeichert wird. Die generierte Exportdatei listet die chronologischen Zeitstempel als Zeilen und ordnet die zugehörigen @aks der Fenster als Spalten an. Diese Formatierung ermöglicht es der Gebäudeautomation im späteren operativen Betrieb, die Matrix sequenziell einzulesen. "Die ausgegebenen diskreten Zahlenwerte differenzieren dabei klar zwischen aktiver Besonnung, Fremdverschattung, Eigenverschattung und fehlender astronomischer Einstrahlung bei Nacht."

#figure(
  image("assets/Verschattung1.png", width: 100%),
  caption: [Flussdiagramm Verschattungsalgorithmus],
  placement: auto
)<fig-flussdiagramm>
#pagebreak()

== Auswertung und Validierung
=== Analyse der Simulationsergebnisse
Die Simulationsergebnisse werden im nachfolgenden an einem Auszug aus der CSV-Datei präsentiert.
#grid(
  columns: (19em, 20.5em),
  gutter: 1em,
  // Zwingt beide Spalten nach oben und linksbündig an den Rand
  // align: (top + left, top + left), 
  [
    #set text(size: 9pt) 
    // figure.align steuert, dass die Caption linksbündig unter der Tabelle steht
    #show figure: set align(left)
    #figure(
      table(
        columns: 3,
        align: (left, center, center),
        
        // x-Wert weiter verringert, macht die Tabelle schmaler = mehr Platz für Text
        inset: (y: 2.5pt, x: 3pt),
        
        stroke: (x, y) => (
          left: none,
          right: none,
          top: if y == 0 { 0.5pt } else { none },
          bottom: 0.5pt,
        ),
        
        fill: (col, row) => if row == 110 { luma(240) } else { none },
        [*Zeitpunkt*], [*FL13_W034*], [*FL13_W035*],
        [21.6.-05:00], [N], [N],
        [21.6.-05:15], [N], [N],
        [21.6.-05:30], [R], [R],
        [21.6.-05:45], [R], [R],
        [21.6.-06:00], [R], [R],
        [21.6.-06:15], [R], [R],
        [21.6.-06:30], [R], [R],
        [21.6.-06:45], [V], [V],
        [...], [...], [...],
        // [21.6.-07:15], [V], [V],
        // [21.6.-07:30], [V], [V],
        // [21.6.-07:45], [V], [V],
        // [21.6.-08:00], [V], [V],
        // [21.6.-08:15], [V], [V],
        // [21.6.-08:30], [V], [V],
        // [21.6.-08:45], [V], [V],
        // [21.6.-09:00], [V], [V],
        // [21.6.-09:15], [V], [V],
        [21.6.-09:30], [V], [V],
        [21.6.-09:45], [56,1], [53,7],
        [21.6.-10:00], [52,7], [50,4],
        [21.6.-10:15], [49,2], [46,9],
        [21.6.-10:30], [45,6], [43,2],
        [21.6.-10:45], [41,6], [39,3],
        [21.6.-11:00], [37,5], [35,1],
        [21.6.-11:15], [33], [30,6],
        [21.6.-11:30], [28,1], [25,8],
        [21.6.-11:45], [V], [V],
        [21.6.-12:00], [V], [V],
        [21.6.-12:15], [11,2], [8,9],
        [21.6.-12:30], [4,7], [2,4],
        [21.6.-12:45], [-2,2], [-4,6],
        [21.6.-13:00], [-9,5], [-11,8],
        [21.6.-13:15], [-17], [-19,4],
        [21.6.-13:30], [-24,7], [-27],
        [21.6.-13:45], [V], [V],
        [...], [...], [...],
      ),
      caption: [Auszug der zeitaufgelösten Verschattungsdaten für zwei Fenster]
    ) <tab-verschattungsdaten>
  ],
  [
  In @tab-verschattungsdaten ist ein Auszug der Simulationsergebnisse für den 21.06.2026 (Sommersonnenwende) dargestellt. Die erste Spalte gibt den Zeitpunkt (Datum und Uhrzeit) der Berechnung an. Die zweite und dritte Spalte zeigen den Verschattungszustand von zwei beispielhaften Fenstern, welche mit dem in @AufbereitungIFC definierten @aks bezeichnet sind.

  Zu Beginn der Simulation (5:00 bis 5:15 Uhr) ist für beide Fenster "N" (Nacht) eingetragen, da die Sonne noch unter dem Horizont liegt. Ab 5:30 Uhr wechselt der Status auf "R" (Rückseite): Die Sonne befindet sich zu diesem Zeitpunkt hinter der Fassadenebene, weshalb keine direkte Besonnung möglich ist. Zwischen 6:45 und 9:30 Uhr werden die Fenster durch externe Gebäudeobjekte verschattet ("V"). Im Anschluss trifft direkte Sonnenstrahlung auf das Glas, was durch den berechneten relativen Azimutwinkel (-90° bis +90°) abgebildet wird.

  Dass die beiden Fenster zur selben Zeit abweichende Azimutwinkel aufweisen, belegt ihre leicht unterschiedliche räumliche Ausrichtung zur Sonne. Der stetig abnehmende Winkelwert spiegelt dabei den fortschreitenden Sonnenlauf wider. Eine hochdynamische Verschattungssituation zeigt sich exemplarisch um 11:45 - 12:00, als die Fenster für ein kurzes Intervall von 30 Minuten erneut verschattet werden und sich direkte Besonnung und Schatten schnell abwechseln. Zwischen 12:30 und 12:45 Uhr wechselt schließlich das Vorzeichen der Winkelwerte von positiv auf negativ. In diesem Zeitraum kreuzt die Sonne die exakte Mittelachse (Flächennormale) der jeweiligen Fenster.
  ]
)
=== Berechnungsaufwand und Optimierung <Simulationsoptimierung>
Für diese Arbeit wurde der 20.03.26 im 15-Minuten Takt simuliert. Dieser Tag beschreibt die frühjährliche Tag-Nacht-Gleiche (Äquinoktium) an dem die Sonne genau gleich lang über und unter dem Horizont verbleibt. Da die Hälfte des Jahres mehr und die andere Hälfte weniger Sonnenstunden aufweist, eignet sich dieser Tag für eine Hochrechnung der Simulationsdauer auf das gesamte Jahr.

Die Simulation dauerte 14,4 Minuten#footnote[Die Berechnung der Jahressimulation erfolgte auf einer Workstation mit folgender Spezifikation: AMD Ryzen 5 7600X (6-Core, 4,7 GHz), 32 GB RAM, AMD Radeon RX 7800 XT, Windows 11 (64-bit), Blender Version 4.5.3], was für eine gesamte Jahresberechnung 3 Tagen und 16 Stunden entspricht. Da diese Simulation nur einmal berechnet werden muss für ein gesamtes Gebäude, liegt die Simulationsdauer im annehmbaren Bereich. Da Blender für Python-Skripte nur einen CPU-Kern benutzen kann, könnten weiter Blender-Instanzen geöffnet werden, um parallel Datumsbereiche des Jahres zu berechnen. Diese müssten dann final in eine Datei bzw. Datenbank zusammengeführt werden.

Durch Anwendung des Backface Culling konnte eine Verkürzung der Rechendauer um ca. 50% erreicht werden.

/*
68 x 365 = 24.820 Spalten


- Ohne Optimierung (760s)
- Zusammenfügen von umliegenden Objekten 786s (Optimierungepotenzial bei -3,4%)
- löschen von 80% der kleinen Häuser 764s
- Mathe-Skript 793s
- Mathe Skript mit Normalenoptimierung: 408s
- ""+Winkel: 434s
*/
=== Visuelle und algorithmische Validierung <ValidierungErgebnisse>
==== Validierung der virtuellen Szene
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

==== Validierung der skriptbasierten Simulation
Während die visuelle Validierung die Geometrie und das interne Sonnenmodell der Software bestätigt, erfordert das entwickelte Simulationsskript eine separate Überprüfung. Dieses Skript greift nicht auf das interne Sonnenstands-Plug-in von Blender zurück, sondern implementiert den @noaa#[]-Algorithmus zur Berechnung des Sonnenstandes.

Zur Validierung des Skripts wird der Verschattungszustand für denselben Referenzzeitpunkt berechnet und in eine CSV-Datei exportiert. Ein separates Auswertungsskript visualisiert diese Daten, indem es die Fassadenelemente des FOUR basierend auf ihrem simulierten Verschattungsstatus einfärbt. Eine Rotfärbung indiziert dabei eine vollständige Verschattung des jeweiligen Fensters, definiert durch die Verdeckung aller vier Eckpunkte.

Wie in @fig-validierungSkript zu erkennen ist, liegen die als verschattet identifizierten Fensterelemente exakt innerhalb der optisch gerenderten Schattenflächen. Diese Deckungsgleichheit bestätigt die korrekte Implementierung des @noaa#[]-Algorithmus sowie die funktionale Zuverlässigkeit des entwickelten Skripts zur algorithmischen Bestimmung der Fassadenverschattung.

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