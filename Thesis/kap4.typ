#let short-title = state("short-title", none)
#import "@preview/codly:1.3.0": *
= Implementierung des Proof of Concept<Kap4>
Um den in Kapitel 3 konzipierten Systemansatz auf seine praktische Tragfähigkeit zu überprüfen, wird im Folgenden ein @poc durchgeführt. Ziel dieses Kapitels ist es, die softwaretechnische Machbarkeit der entwickelten Prozesskette - vom fehlerfreien Import heterogener Datensätze (@ifc#[] und GIS) über die raycastingbasierte Verschattungssimulation bis hin zum strukturierten Datenexport - exemplarisch nachzuweisen. Hierfür wurde ein funktionsfähiger Software-Prototyp auf Basis von Blender und Python implementiert. 
Die Entwicklung und Validierung dieses Prototyps erfolgt anhand eines komplexen Referenzprojekts.


== Vorstellung des Referenzprojekts<kap-VorstellungFOUR>

#figure(
  image("assets/ÜbersichtFOUR.svg", width: 70%),
  caption: [Grafik des FOUR mit seinen Türmen 1 bis 4@four_frankfurt_about],
  placement: auto
)<four-übersicht>

Das FOUR besteht aus vier zusammenhängenden Türmen (siehe @four-übersicht) mit Büro- und Wohnungsnutzung in der Innenstadt von Frankfurt am Main. Die vier Türme stehen auf vier Gebäuden (Podesten), die miteinander verbunden sind. Das Bauprojekt befindet sich in der Endphase und soll im Laufe des Jahres 2026 endgültig übergeben werden. In dieser Arbeit wird die Verschattungssimulation am 233~m hohen Büroturm T1 angewendet. Der Turm besteht pro Geschoss aus vier Mietbereichen und hat pro Segment einen außenliegenden Sonnenschutz und einen innenliegenden Blendschutz. Es werden 5859 relevante Fenster gezählt. Die Türme stehen eng beieinander im Zentrum der Stadt zwischen verschiedenen Hochhäusern (z. B. dem Commerzbank-Tower und dem MAIN-Tower). Durch dieses eng bebaute Areal treten sehr dynamische Verschattungssituationen auf, die nur durch eine präzise Simulation der Umgebung korrekt dargestellt werden können.
Eine architektonische Besonderheit des FOUR sind die diagonal abgeschrägten Fassadenabschnitte (@fig-FourTageslicht), die den visuellen Freiraum und die Tageslichtzufuhr verbessern sollen und die Fenster, welche in unterschiedlichen Winkeln zur Fassade angeordnet sind.

#figure(
  image("assets/FourTageslichtSchnitte.png"),
  caption: [Darstellung und Erklärung der diagonalen Fassadenabschrägung des FOUR~@four_frankfurt_about],
  placement: none
)<fig-FourTageslicht>

// Es liegen die Fassadenmodelle aller Türme und Podeste des FOUR als @ifc#[]-Dateien vor.

== Datenaufbereitung und Modellaufbau<Datenaufbereitung>
Nach der Vorstellung des Referenzprojekts beschreibt dieser Abschnitt die praktische Zusammenführung und Aufbereitung der digitalen Datengrundlagen. Um eine Simulation zu ermöglichen, müssen die komplexen Architekturmodelle der FOUR-Türme und die urbanen Geodaten bereinigt, geometrisch abgeglichen und in der 3D-Software Blender zusammengeführt werden. Im Folgenden wird Schritt für Schritt dargelegt, wie irrelevante Geometrien gefiltert und die unterschiedlichen Koordinatensysteme synchronisiert werden, um ein simulationsbereites Gesamtmodell zu erstellen.
=== Import, Aufbereitung und Georeferenzierung des BIM-Modells
==== Import und Positionierung des Turm 1 <ImportPositionierungT1>
Als Erstes wird eine neue Blenderdatei gespeichert und die @ifc#[]-Datei des Referenzgebäudes importiert. Dies geschieht über das Blender Add-On Bonsai~@bonsai_openbim, welches den Import und die Bearbeitung von BIM-Daten ermöglicht. Da die @ifc#[]-Modelle beim FOUR schon als Fassaden-Teilmodelle vorliegen, muss hier beim Import kein Filter angewandt werden, um nicht relevante Bauteile auszuschließen.

// *Import* Da die in @AnalyseBIMDatenguete[Kapitel] definierten Anforderungen zum Teil nicht erfüllt werden, musste beim Import der FOUR-IFC-Datei noch folgendes gemacht werden:

Für die Positionierung des Gebäudes sollte zuerst auf die im @ifc#[]Site-Tag hinterlegten Koordinaten zurückgegriffen werden. Nach eingehender Prüfung stellt sich heraus, dass die Koordinaten auf einen Punkt in der Mitte des Baufelds verweisen und nicht auf den gewünschten Ursprung des @ifc#[]-Modells. Nach Sichtung der Planunterlagen wurden im "Masterplan für das BIM-Modell" die richtigen XY-Koordinaten (in Form des Gauß-Krüger-Koordinatensystems) entdeckt. Die Z-Koordinate, also die Höhe des @ifc#[]-Ursprungs, konnte über einen Schnitt ausfindig gemacht werden. Da Frankfurt ca. 100~m über @nn liegt, werden genau 100~m als Koordinatenebene festgelegt. Diese Koordinaten werden somit als Projektbasispunkt (P1) des gesamten Simulationsmodells definiert. 

Für die weitere Verwendung werden die XY-Koordinaten mithilfe einer Anwendung des Bundesamtes für Kartographie und Geodäsie~@bkg_koordinatentransformation in das benötigte UTM32-Koordinatenreferenzsystem übersetzt. Dafür wird das Verschiebegitter Beta2007 verwendet.

==== Aufbereitung des @ifc#[]-Modells Turm 1 <AufbereitungIFC>

Die Qualität des vorliegenden @ifc#[]-Modells erfordert eine gezielte Vorbearbeitung, um eine konsistente Datengrundlage für die Verschattungssimulation zu schaffen. Im Fokus stehen dabei die eindeutige Identifizierbarkeit der Fassadenelemente sowie die Bereinigung geometrischer Inkonsistenzen.

Hinsichtlich der Datenstruktur wird festgestellt, dass die Zuordnung der Bauteile zu den jeweiligen Geschossen teilweise fehlerhaft ist. So sind vertikal übereinanderliegende Fenster demselben Geschoss zugewiesen. Für den weiteren Prozessverlauf wird diese strukturelle Ungenauigkeit ignoriert, da die Simulation auf den absoluten Koordinaten der Geometrie basiert und nicht auf der logischen Geschosshierarchie des @ifc#[]-Baums.


//Die ursprünglich vorgesehene Berechnung der geometrischen Fenstermittelpunkte wird im Zuge der Prozessoptimierung als hinfällig eingestuft. Durch den gewählten Ansatz, die Verschattung an allen vier Eckpunkten eines Fensters zu validieren, entfällt die Notwendigkeit eines zentralen Bezugspunktes. Die Vier-Ecken-Methode bietet zudem eine höhere Granularität bei der Bewertung von Teilverschattungen.

Ein wesentlicher Schritt der Aufbereitung betrifft die Fensterflächen im Bereich der Balkone. Diese werden isoliert und für die Simulation ausgeblendet. Da das @ifc#[]-Modell keine Materialeigenschaften übermittelt, würden diese Flächen durch den Simulationsalgorithmus als opake Hindernisse gewertet werden. Dies hätte zur Folge, dass dahinterliegende Fenster fälschlicherweise als verschattet markiert werden würden, obwohl in der Realität transparente Verglasungen vorliegen.

Zusätzlich weist das Modell geometrische Redundanzen in Form von sich überschneidenden oder doppelt vorhandenen Fensterelementen auf, wie in @fig-FensterÜberschneidung dargestellt. Diese Duplikate werden manuell identifiziert und entfernt, um Fehlberechnungen und eine unnötige Erhöhung der Rechenlast zu vermeiden.

#figure(
  image("assets/ÜberschneidendeFenster.png", width: 80%),
  caption: [Bildausschnitt von sich überlagernden Fensterelementen an der Gebäudefassade.],
  placement: none
) <fig-FensterÜberschneidung>


// Schlussendlich wird ein temporäres Anlagenkennzeichnungssystem erstellt, das sich auf das jeweilige Geschoss und eine fortlaufende Nummer für sämtliche Fensterelemente bezieht. Zum Beispiel steht `FL13_W034` für: 13. Geschoss (Floor) an der 34. Position. Dies wird mithilfe eines Skripts (@DigitaleAnlage) implementiert. Diese Maßnahme ist notwendig, da die ursprünglichen Objektbezeichnungen keine Informationen über die räumliche Zuordnung enthalten. Hierfür müssen mithilfe einer Filterlogik alle relevanten Fensterobjekte vorselektiert werden. Glasscheiben für die Balkonbrüstung und sehr kleine Fensterflächen haben keine Jalousie und werden somit nicht berücksichtigt. Die Auswahl der Fenster konnte nicht anhand der @ifc#[]-Klasse `IfcWindow` erfolgen, da die Fensterobjekte an der abgeschrägten Fassadenseite (siehe @kap-VorstellungFOUR) fälschlicherweise der Klasse `IfcBuildingElementProxy` zugeordnet sind. Stattdessen musste die Filterung der Objekte über den Objektnamen erfolgen.

==== Zuweisung des Anlagenkennzeichnungsschlüssels (AKS)<AKSZuordnung>
Ein fehlendes @bks im @ifc#[]-Modell erschwert die Automatisierung der Prozesskette, da die nachträgliche Zuweisung dieser Daten einen hohen manuellen Aufwand erfordert. Für eine Zuordnung von Fenster zu Jalousieaktor und einer vollständigen Realisierung des Gesamtprojekts ist dieser Schritt jedoch zwingend notwendig. Der speziell zur Lösung dieses Problems entwickelte Prozess wird zur Wahrung des Leseflusses an dieser Stelle nicht weiter ausgeführt, sondern ist im Anhang (siehe @AKSZuordnungAnhang) detailliert dokumentiert. 

Für die Validierung der Simulation und die anschließende Datenübergabe im Rahmen dieses Proof of Concept erzeugt stattdessen ein Skript (siehe @DigitaleAnlage) ein temporäres Bezeichnungssystem. Dieses weist den Objekten eine einfache Struktur aus Geschoss und fortlaufender Nummer zu, beispielsweise FL13_W034 für das 13. Geschoss an Position 34. Zuvor selektiert eine Filterlogik die zu berücksichtigenden Fenster. Da die Elemente der abgeschrägten Fassade im Modell der Klasse IfcBuildingElementProxy anstelle von IfcWindow zugeordnet sind, erfolgt diese Filterung über den Objektnamen. Glasflächen ohne Jalousien, wie Balkonbrüstungen oder sehr kleine Fensterflächen, schließt das Skript dabei aus.





=== Integration der urbanen Umgebungsdaten<kap-ImportUmgebungsdaten>
==== Import und Positionierung der Umgebungsdaten
Für die Modellierung der umgebenden, verschattenden Bebauung wird auf die offenen Geodaten der @hvbg~@Hessen3D zurückgegriffen. Die 3D-Gebäudemodelle für das Stadtgebiet Frankfurt am Main werden von offizieller Seite standardmäßig im Format CityGML bereitgestellt.

Da für Blender keine native Import-Schnittstelle für CityGML-Dateien existiert, ist eine vorherige Datenkonvertierung erforderlich. Die Datensätze werden hierfür in das JSON-basierte Format CityJSON mithilfe eines Tools~@cityjson_conversion überführt.

Der finale Import der Gebäudekörper in die 3D-Umgebung erfolgt über das Open-Source-Plugin CityJSONEditor~@github_cityjsoneditor für Blender. Da die amtlichen Frankfurter Daten teilweise von den Standardannahmen des Plugins abwich, wurden im Rahmen dieser Arbeit gezielte Anpassungen am Python-Quellcode der Import-Erweiterung vorgenommen. 

// Diese Fehlerbehebungen umfassen im Wesentlichen drei Aspekte:

// + *Toleranz bei fehlenden Texturen:* Es wird eine Abfrage implementiert, die den Importprozess bei Objekten ohne definierte Fassadentexturen nicht abbricht, sondern die reine Geometrie weiterverarbeitet.
// + *Datentyp-Konvertierung (@lod):* Das Einleseskript wird dahingehend modifiziert, dass der im Datensatz als String vorliegende Wert für den Detailgrad (@lod) systematisch in einen Float umgewandelt wird.
// + *Filterung geometrieloser Objekte:* Es wird eine Filterroutine integriert, die Datensätze ohne physische 3D-Geometrie (z. B. Grundstücksgrenzen) beim Import ignoriert, um Programmabbrüche zu verhindern.

Im Anschluss erfolgt die räumliche Verortung des Stadtmodells in der Simulationsumgebung. Die originären CityJSON-Daten sind im globalen ETRS89/UTM-Koordinatensystem referenziert. Da der Projektbasispunkt (P1) in Blender auf (0,0,0) gesetzt ist, muss P1 von den Koordinaten der Umgebungsdaten subtrahiert werden. Die Koordinaten werden im Quellcode hinterlegt. Durch diese Nullpunktverschiebung wird das Makromodell der Umgebung präzise in das kartesische System der Software überführt. Zuletzt werden Gebäude, die in zweiter und dritter Reihe zum Turm 1 stehen, ausgewählt und aus der Szene gelöscht. Gebäude, die wie in @kap-externeDaten beschrieben, nördlich des Referenzgebäudes (Turm 1) stehen, werden ebenfalls entfernt.
@fig-Umgebungsszene zeigt die Szene mit den Gebäudedaten des @hvbg. Im Hintergrund ist der Nextower zu erkennen, welcher für die Validierung der Simulation von Bedeutung sein wird.

#figure(
  image("assets/NurUmgebung.png", width: 70%),
  caption: [In Blender importierte Innenstadt von Frankfurt am Main],
  placement: none
)<fig-Umgebungsszene>

==== Import und Positionierung der Türme 2 bis 4 <ImportT24>
Da das Gebäudeensemble FOUR zum Zeitpunkt der Datenerhebung noch nicht in den amtlichen CityGML-Datensätzen erfasst ist, werden für die Verschattungssimulation die detaillierten @ifc#[]-Fassadenmodelle der Türme 2 bis 4 herangezogen. Diese liegen in einem sehr hohen Detaillierungsgrad (@lod 500) vor. Dies ist einerseits vorteilhaft für eine hohe Präzision des Schattenwurfs, beinhaltet andererseits jedoch eine massive Menge an nicht benötigten geometrischen und semantischen Daten. Um die Dateigröße zu minimieren und den Arbeitsspeicher während der Simulation zu entlasten, wird eine systematische Reduktion der Modelle durchgeführt:

+ *Isolierter Import*: Die @ifc#[]-Dateien der Nachbartürme werden zunächst in separate Blender-Projekte importiert, um die Hauptdatei nicht initial zu überlasten.
+ *Geometrische Aggregation*: Sämtliche Einzelbauteile (Meshes) eines Turms werden zu einem zusammenhängenden Polygonnetz verschmolzen.
+ *Semantische Bereinigung*: Alle nicht-geometrischen Informationen, wie @ifc#[]-Hierarchien, Materialdaten und Objektattribute, werden restlos aus der Datei entfernt.
+ *Topologische Reduktion*: Zur Verringerung der Polygonanzahl wird ein algorithmischer Filter (Decimate-Modifier mit den Parametern Collapse und Planar) auf das aggregierte Modell angewendet. Dieser reduziert redundante Geometrie auf flachen Ebenen, ohne die äußere, schattenwerfende Silhouette zu verfälschen.
+ *Referenzierung*: Die optimierten Modelldateien werden abschließend über die Link-Funktion in die Simulations-Hauptszene eingebunden.

Eine manuelle räumliche Transformation oder Neuausrichtung entfällt bei diesem Prozess. Da die Modelle der Türme 2 bis 4 denselben Koordinatenursprung wie das Referenzmodell des Turms 1 aufweisen, positionieren sie sich beim Import automatisch an den korrekten relativen Koordinaten. Es ist anzumerken, dass die @ifc#[]-Modelle keine oder nur generische Materialien für die Fassade hinterlegt haben. Es fehlen also die richtigen Materialeigenschaften (z. B. Reflexionsgrade, Rauheit), um eine komplexe Raytracing-Simulation mit Spiegelungen durchzuführen. 

Die aggregierte Szene ist in @fig-fertigeSzene zu sehen. Man erkennt die vier FOUR in der Mitte mit den umliegenden Gebäuden. Bei dem Podest unter Turm 3 und 4 fehlt die Fassade. Hier handelt es sich um eine Unzulänglichkeit des @ifc#[]-Modells, welche aber keinen Einfluss auf die Simulation hat.


#figure(
  image("assets/FertigeSzene.png", width: 70%),
  caption: [Aufnahme der fertigen Szene mit allen FOUR-Türmen und den umgebenden Gebäuden in Blender],
  placement: auto
)<fig-fertigeSzene>

=== Definition der astronomischen Randbedingungen
#grid(
  columns: (1.5fr, 2fr),
  gutter: 0.5cm,
  
  // 1. Eckige Klammer auf, # vor figure, Label ran, eckige Klammer zu, DANN das Komma
  [
    #figure(
      image("assets/BlenderSunSettings.png", width: 100%),
      caption: [Einstellungen für Sun Position Add-On],
    ) <fig-screenshot>
  ], 
  
  // 2. Hier startet ganz normal dein Textblock
  [
    Für die visuelle Darstellung und Validierung des Sonnenstandes innerhalb der 3D-Umgebung wird das in Blender integrierte Add-On Sun Position~@blender_sun_position verwendet. Die korrekte Ausrichtung des simulierten Sonnenlichts erfordert die Parametrierung (@fig-screenshot) folgender Randbedingungen:

    Im Abschnitt Location werden die exakten geografischen Koordinaten des Projektstandorts definiert. Die Nordausrichtung des Modells (North Offset) bleibt in diesem Fall auf null Grad, da alle Gebäude bereits korrekt ausgerichtet sind. Die Distanz gibt den Abstand des Sonnenobjekts im Modell vom Ursprung an und hat keine Relevanz für den Sonnenstand.
    
    Im Abschnitt Time wird die zeitliche Basis festgelegt. Durch die Zuweisung der lokalen Zeitzone (hier UTC+1) sowie der Eingabe eines spezifischen Datums und einer Uhrzeit berechnet der interne Algorithmus des Moduls automatisch den resultierenden Azimut- und Höhenwinkel. Es muss darauf geachtet werden, während der Som-
  ]
)

merzeit das Feld "Daylight Savings" zu aktivieren. Die virtuelle Sonne wird daraufhin in der Simulationsumgebung exakt positioniert. Dies ermöglicht eine präzise visuelle Simulation des Schattenwurfs für jeden beliebigen Zeitpunkt im Jahresverlauf.


== Durchführung der Verschattungssimulation
=== Parametrisierung der zeitlichen und räumlichen Auflösung
Basierend auf den Vorüberlegungen in @ZeitlicheAufloesungUmfang[Kapitel] ist eine hohe zeitliche Auflösung der Simulation vorteilhaft. Aufgrund der Projektgröße mit 5.859 Fenstern und der entsprechend langen Berechnungsdauer wird hierfür ein 15-Minuten-Raster definiert. Dies stellt einen praxisgerechten Kompromiss zwischen Genauigkeit und Simulationsaufwand dar. Um die Rechenzeit weiter zu reduzieren, beschränkt das Python-Skript die Berechnungsschleife auf die potenziellen Sonnenstunden: Da die Sonne in Frankfurt am Main am Tag der Sommersonnenwende nach 05:00 Uhr aufgeht und vor 22:00 Uhr untergeht, ist das Zeitfenster für die tägliche Simulation auf 05:00 bis 22:00 Uhr limitiert.

Für die räumliche Auflösung kommt die Vierpunkt-Messung (Vierpunkt-Raycasting) zum Einsatz. Ein noch feineres Messraster auf den Fensteroberflächen wäre bei dieser Gebäude- und Fenstergröße zu rechenintensiv und würde das zu verarbeitende Datenvolumen für die @ga zu stark ansteigen lassen. Mit den gewählten Parametern -- einem Berechnungszeitraum von 17 Stunden (68 Messungen pro Tag) und der Simulation eines repräsentativen Tages pro Woche (52 Wochen) -- entstehen exakt 3.536 Datenpunkte pro Fenster. Für den gesamten Gebäudekomplex resultiert dies in einem Gesamtdatenvolumen von 20.717.424 Datenpunkten für das simulierte Referenzjahr.
=== Umsetzung der Verschattungssimulation <SimulationJahresverschattung>
Das entwickelte Python-Skript bildet das technische Kernstück der Prozesskette. Es automatisiert die geometrische Verschattungsanalyse innerhalb der 3D-Umgebung und generiert zeitaufgelöste Steuerungsdaten für die @ga. Das Skript wird über die Entwicklungsumgebung @vs-code~@vscode initiiert. Vor der Ausführung werden im zentralen Konfigurationsblock (siehe @kap-code-konfiguration im Anhang) die wesentlichen Randbedingungen und Parameter der Simulation definiert:

- *Export-Konfiguration:* Festlegung, ob der exakte relative Azimutwinkel oder ein Binärwert (`0`) bei unverschatteter Besonnung ausgegeben werden soll.
- *Simulationszeitraum:* Auswahl zwischen einer repräsentativen Jahressimulation (ein simulierter Tag pro Woche) oder der Analyse eines spezifischen Einzeltages.
- *Datumseinstellungen:* Definition des Bezugsjahres sowie (bei Einzeltagssimulation) des exakten Zielmonats und -tages.
- *Tageszeitraum:* Festlegung der täglichen Start- und Endzeit der Berechnung in vollen Stunden.
- *Zeitliche Auflösung:* Definition der Berechnungsschritte in Minuten (z. B. 15-Minuten-Intervalle).
- *Standortdaten:* Geografische Koordinaten (Breiten- und Längengrad) im WGS-84-Referenzsystem.

Der Programmablauf (siehe @fig-flussdiagramm) unterteilt sich in vier Phasen:


// #pagebreak()


==== Initialisierung und Extraktion der Gebäudegeometrie
In der Vorbereitungsphase durchsucht der Algorithmus den Szenengraphen der Simulationsumgebung nach allen Objekten, die anhand des Attributs "@aks" als Fenstersensoren klassifiziert sind. 
// Um die spätere Rechenlast während der Zeitschleifen zu minimieren, werden die geometrischen Eigenschaften jedes Fensters nur ein einziges Mal zu Beginn extrahiert. 
Das Skript ermittelt für jedes Fenster die primäre Glasfläche und berechnet deren physikalischen Normalenvektor. 

#pagebreak() // Startet eine neue Seite exakt für diese Abbildung
#v(0fr)

#figure(
  image("assets/Verschattung1.png", width: 95%),
  caption: [Flussdiagramm Verschattungsalgorithmus]
)<fig-flussdiagramm>

#pagebreak() // Erzwingt, dass der nachfolgende Fließtext auf der nächsten Seite beginnt
 Parallel dazu speichert das System die exakten 3D-Weltkoordinaten der vier Eckpunkte der Fensterfläche ab, welche als Ausgangspunkte für die spätere Strahlenverfolgung dienen.


==== Astronomische Berechnung der Sonnenvektoren
Die eigentliche Simulation iteriert über den festgelegten Betrachtungszeitraum in diskreten 15-Minuten-Schritten. Für jeden iterativen Zeitschritt übersetzt der integrierte @noaa#[]-Algorithmus den lokalen Längen- und Breitengrad sowie den UTC-korrigierten Zeitstempel in einen dreidimensionalen Richtungsvektor zur Sonne. In dieser Phase findet zudem ein effizienzsteigernder Filterprozess statt: Liegt der berechnete Höhenwinkel der Sonne unter null Grad, registriert das System den Zustand global als Nacht. Der Algorithmus weist allen Fenstern für diesen Zeitstempel den entsprechenden Statuswert zu und überspringt die rechenintensiven Kollisionsprüfungen.

==== Filterung und Vierpunkt-Raycasting
Sobald ein Tag-Zustand vorliegt, iteriert das Skript über alle registrierten Fenster. Die Ermittlung des Verschattungsstatus erfolgt hierbei in einem zweistufigen Verfahren. Der erste Schritt ist der mathematische Ausschluss mithilfe des Front-Face-Checks. Über das Skalarprodukt aus dem berechneten Sonnenvektor und der zuvor gespeicherten Fensternormalenvektor wird geprüft, ob die direkte Solarstrahlung das Fenster von hinten trifft. Ist dies der Fall, wird die Berechnung für dieses Fenster sofort abgebrochen und der Status für eine rückseitige Verschattung dokumentiert.

Fällt das Licht hingegen in einem positiven Winkel auf die Fenstervorderseite, initiiert das Skript das Vierpunkt-Raycasting. Von den vier Eckkoordinaten des Fensters wird ein theoretischer Sehstrahl in Richtung der Sonne projiziert. Der Algorithmus prüft, ob dieser Strahl auf seinem Weg durch die Szene ein Objekt der umgebenden Bebauung schneidet. Die Schleife bricht ab, sobald nur ein einziger der vier Strahlen die Sonne ungehindert erreicht. In diesem Fall wird das gesamte Fenster als besonnt klassifiziert. Nur wenn alle vier Eckpunkte durch externe Geometrien verdeckt sind, meldet der Algorithmus eine vollständige Verschattung.


==== Datenaggregation und Export
Im finalen Schritt überführt das Skript die akkumulierten Statuswerte in eine Struktur, die als CSV-Datei gespeichert wird. Die generierte Exportdatei listet die chronologischen Zeitstempel als Zeilen und ordnet die zugehörigen @aks der Fenster als Spalten an. Diese Formatierung ermöglicht es der @ga im späteren operativen Betrieb, die Matrix sequenziell einzulesen.



== Auswertung und Validierung

In diesem Abschnitt werden die Simulationsergebnisse analysiert sowie der Algorithmus visuell und methodisch validiert. Dies stellt sicher, dass die generierten Verschattungsdaten eine verlässliche Grundlage für die automatisierte Sonnenschutzsteuerung bieten.

=== Analyse der Simulationsergebnisse


#grid(
columns: (13em, 22.5em),
gutter: 3em,
[
#show table: set text(size: 10pt)
#show figure: set align(left)
#figure(
table(
columns: 3,
align: (left, center, center),
inset: (y: 2.74pt, x: 3pt),
stroke: (x, y) => (
left: none,
right: none,
top: if y == 0 { 0.5pt } else { none },
bottom: 0.5pt,
),
fill: (col, row) => if row == 110 { luma(240) } else { none },
[*Zeitpunkt~*], [*W034~*], [*W035*],
[21.6.-05:00], [N], [N],
[21.6.-05:15], [N], [N],
[21.6.-05:30], [R], [R],
[21.6.-05:45], [R], [R],
[21.6.-06:00], [R], [R],
[21.6.-06:15], [R], [R],
[21.6.-06:30], [R], [R],
[21.6.-06:45], [V], [V],
[...], [...], [...],
[21.6.-09:30], [V], [V],
[21.6.-09:45], [56], [53],
[21.6.-10:00], [52], [50],
[21.6.-10:15], [49], [46],
[21.6.-10:30], [45], [43],
[21.6.-10:45], [41], [39],
[21.6.-11:00], [37], [35],
[21.6.-11:15], [33], [30],
[21.6.-11:30], [28], [25],
[21.6.-11:45], [V], [V],
[21.6.-12:00], [V], [V],
[21.6.-12:15], [11], [8],
[21.6.-12:30], [4], [2],
[21.6.-12:45], [-2], [-4],
[21.6.-13:00], [-9], [-11],
[21.6.-13:15], [-17], [-19],
[21.6.-13:30], [-24], [-27],
[21.6.-13:45], [V], [V],
[...], [...], [...],
),
caption: [Auszug der Verschattungsdaten für zwei Fenster im 13. OG]
)<tab-verschattungsdaten> 
],
[
Die Struktur und Dynamik der berechneten Verschattungsdaten wird im Folgenden anhand eines Auszugs aus der exportierten CSV-Datei exemplarisch dargelegt. In @tab-verschattungsdaten ist ein Auszug der Simulationsergebnisse für den 21.06.2026 (Sommersonnenwende) dargestellt. Die erste Spalte definiert den Zeitpunkt der Berechnung, während die zweite und dritte Spalte den Verschattungszustand von zwei beispielhaften Fenstern abbilden.

Zu Beginn der Simulation (05:00 bis 05:15 Uhr) ist für beide Fenster der Zustand "N" (Nacht) protokolliert, da sich die Sonne noch unterhalb des Horizonts befindet. Ab 05:30 Uhr wechselt der Status auf "R" (Rückseitenverschattung): Die Sonne steht nun hinter der Fassadenebene, sodass kein direkter Lichteinfall möglich ist. Zwischen 06:45 und 09:30 Uhr werden die Fenster durch umgebende Gebäudestrukturen verschattet, was durch das Kürzel "V" (Fremdverschattung) indiziert wird.

Sobald direkte Sonnenstrahlung auf das Glas trifft, wird anstelle eines Kürzels der berechnete Fensterazimut (in einem Wertebereich von -90° bis +90°) ausgegeben. Dass beide Fenster zur selben Zeit leicht abweichende Azimutwinkel aufweisen, resultiert aus ihrer nicht exakt identischen räumlichen Ausrichtung. Der stetig abnehmende Winkelwert spiegelt dabei die fortschreitende Sonnenbewegung wider.

Eine hochdynamische Verschattungssituation lässt sich exemplarisch im Zeitraum von 11:45 bis 12:00 Uhr beobachten, als die Fenster für ein kurzes Intervall von 30 Minuten erneut durch ein externes
]
)
 Objekt verschattet werden. Ab 12:30 Uhr durchläuft der Winkelwert schließlich den Nullpunkt und wechselt von positiv zu negativ. In diesem Moment kreuzt die Sonne die exakte Flächennormale (Mittelachse) der jeweiligen Fenster.
//#v(-.75em) //Verringert den vertikalen Abstand
 
=== Berechnungsaufwand und Optimierung <Simulationsoptimierung>
Für diese Arbeit wurde das Jahr 2026 für einen Tag pro Woche im 15-Minuten Takt simuliert. Die Simulation dauerte 14 Stunden und 23 Minuten#footnote[Die Berechnung der Jahressimulation erfolgte auf einer Workstation mit folgender Spezifikation: AMD Ryzen 5 7600X (6-Core, 4,7 GHz), 32 GB RAM, AMD Radeon RX 7800 XT, Windows 11 (64-bit), Blender Version 4.5.3]. Die Ergebnisdatei im CSV-Format hat ein Größe von 47~MB.
Bei einer Berechnung jedes einzelnen Tages des Referenzjahres beliefe sich die Rechendauer auf 4 Tage und 5 Stunden und eine Dateigröße von 328~MB. Da diese Simulation für ein gesamtes Gebäude nur einmal berechnet werden muss, liegt die Simulationsdauer im annehmbaren Bereich. Da Blender für Python-Skripte nur einen CPU-Kern benutzen kann, könnten weitere Blender-Instanzen geöffnet werden, um parallel Datumsbereiche des Jahres zu berechnen. Diese müssten dann final in eine Datei bzw. Datenbank zusammengeführt werden.

Durch Anwendung des Backface Culling konnte eine Verkürzung der Rechendauer um ca. 50% erreicht werden.

=== Visuelle und algorithmische Validierung <ValidierungErgebnisse>
==== Validierung der virtuellen Szene
Die Validierung der virtuellen Szene erfolgt durch einen visuellen Abgleich zwischen einem gerenderten Bild der Simulation und einer fotografischen Aufnahme des FOUR zu einem definierten Zeitpunkt. Als Referenz dient eine für die Bauüberwachung und das Marketing genutzte Webcam auf dem 137 Meter hohen Nextower am Thurn-und-Taxis-Platz, welcher sich in etwa 500 Metern Entfernung befindet. Die historischen Webcam-Aufnahmen sind über die Website des Anbieters @zeitrafferFOURFrankfurt abrufbar. Für den Abgleich wurde ein wolkenarmer Tag gewählt, um durch ein Minimum an diffusem Licht klare Schattenkanten zu erhalten. Der Nextower ist im digitalen Modell integriert, um die Kameraposition exakt nachzubilden.

Das Ergebnis dieses Abgleichs ist in @fig-validierung_t1 dargestellt. Es zeigt sich eine visuell sehr hohe Übereinstimmung der Schattenkanten zwischen Referenzbild und Simulation. Dies belegt die korrekte geometrische Anordnung der Szene in Blender sowie die Präzision des integrierten Sonnenmodells für den gewählten Zeitpunkt.

Eine alternative Validierungsmethode bestünde in der Installation von Helligkeitssensoren an Fenstern des FOUR zur Erfassung realer Messwerte an wolkenlosen Tagen. Dieser Ansatz wurde aufgrund des den Rahmen dieser Arbeit übersteigenden messtechnischen Aufwands nicht weiter verfolgt.
#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("assets/webcam_foto.png", width: 100%),
    image("assets/blender_render.png", width: 100%)
  ),
  caption: [Validierung der Verschattungssimulation am Turm 1. Links: Webcam-Aufnahme vom 21.06.2025 (9:15 Uhr). Rechts: Simulationsergebnis zum identischen Zeitpunkt.],
  placement: none
) <fig-validierung_t1>

==== Validierung der skriptbasierten Simulation
Während die visuelle Validierung die Geometrie und das interne Sonnenmodell der Software bestätigt, erfordert das entwickelte Simulationsskript eine separate Überprüfung. Dieses Skript greift nicht auf das interne Sonnenstands-Plug-in von Blender zurück, sondern implementiert direkt den @noaa#[]-Algorithmus zur Berechnung des Sonnenstandes.

Zur Validierung des Skripts wird der Verschattungszustand für denselben Referenzzeitpunkt berechnet und in eine CSV-Datei exportiert. Ein separates Auswertungsskript visualisiert diese Daten, indem es die Fassadenelemente des FOUR basierend auf ihrem simulierten Verschattungsstatus einfärbt. Eine Rotfärbung indiziert dabei eine vollständige Verschattung des jeweiligen Fensters, definiert durch die Verdeckung aller vier Eckpunkte.

Wie in @fig-validierungSkript zu erkennen ist, liegen die als verschattet identifizierten Fensterelemente exakt innerhalb der optisch gerenderten Schattenflächen. Diese Deckungsgleichheit bestätigt die korrekte Implementierung des @noaa#[]-Algorithmus sowie die funktionale Zuverlässigkeit des entwickelten Skripts zur algorithmischen Bestimmung der Fassadenverschattung. Die erfolgreiche Kombination beider Validierungsmethoden bestätigt die hohe Präzision und Zuverlässigkeit der entwickelten Simulationsumgebung. Damit ist sichergestellt, dass die generierten Verschattungsdaten eine belastbare und sichere Grundlage für die informationstechnische Integration in die operative Gebäudeautomation darstellen.

#figure(
  box(
    width: 8cm, 
    height: 10cm, 
    clip: true,
    align(center + horizon)[
      #image("assets/ValidierungSkript.png", width: 200%)
    ]
  ),
  caption: [Detailansicht der Szene zur Überprüfung der Simulationsergebnisse. Rot eingefärbte Elemente markieren eine algorithmisch ermittelte vollständige Verschattung.],
  placement: none
) <fig-validierungSkript>