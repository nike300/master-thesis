= Anforderungsanalyse und Konzeption des Integrationsprozesses<Kap3>

== Analyse der Ausgangssituation und Zieldefinition <AnalyseAusgangssituation>
- *Defizite konventioneller Verschattungsstrategien:* Analyse der Einschränkungen heutiger Systeme, insbesondere die fehlende Berücksichtigung von Fremdverschattung durch Nachbargebäude.
- *Anforderungsprofil an das Gesamtsystem:* Definition funktionaler Anforderungen (wie Präzision und Grad der Automatisierbarkeit) sowie nicht-funktionaler Anforderungen (Recheneffizienz und Systemkompatibilität).

== Auswahl der Simulationsumgebung <AuswahlSimulationsumgebung>
In der Simulationsumgebung findet die Zusammenstellung der Szene statt. Es muss eine Software gewählt werden, die den Import verschiedener 3D-Dateiformate zulässt. Zusätzlich sollte diese Software den Sonnenstand simulieren können und eine Möglichkeit bieten Raycasts zu generieren. 
Die Wahl fiel auf die kostenlose Open-Source-Software Blender@blender_org, die für die Erstellung von Animationsfilmen entwickelt wurde. Sie bietet in der jetzigen Version eine Vielzahl von Funktionalitäten, darunter auch die, zur Erfüllung der oben genannten Anforderungen. Außerdem bietet sie den Vorteil einer großen, aktiven Community, die eine Vielzahl an kostenlosen und kostenpflichtigen Plug-Ins entwickelt. Für diese Anwendung passende Alternativen standen nicht zur Auswahl.

/*
== Spezifikation der Datengrundlage (Input)
=== Analyse der BIM-Datengüte (IFC):
 Untersuchung der vorhandenen geometrischen Informationen und Identifikation fehlender Attribute, die für eine valide Simulation zwingend erforderlich sind.
 - Gebäudedaten (ifc) sollte haben:
  - richtige labels für gebäudeteile (IFC-Window-Klasse)
  - Auch schräge Fenster sollten als IFC-Window-Klasse definiert werden - Werden sie oft nicht, da sie schräg sind, in revit
  - Nur die Fassade sollte enthalten sein, um die Dateigröße zu minimieren
  - Die Fensterflächen sollten richtig _Face Normals_ (Flächenausrichtung)? für backwards Culling
  - Die Fassadenelemente sollten dem entsprechenden Geschoss zugeordnet sein.
  - Das Gebäude sollte in der ifc-Datei bereits auf der richtigen Z-Höhe und nach Norden ausgerichtet sein
  - Da das IFC-Modell auf den Zentimeter genau im Bezug auf die Umgebung verortet werden muss. Die genauen Koordinaten eines Referenzpunktes im Modell sollten in der IFC-Datei unter IfcSite als WGS84-Referenzsystem vorliegen@buildingsmart_ifcsite
  - Die Fenster sollten @aks  besitzen, der nach dem Schalenmodell @vdi3814-1 aufgebaut ist.
*/
== Spezifikation der Datengrundlage (Input) <SpezifikationDatengrundlage>
=== Analyse der BIM-Datengüte (IFC) <AnalyseBIMDatenguete>

Um einen fehlerfreien und automatisierten Datenfluss von der digitalen Planung in die Simulationsumgebung zu gewährleisten, muss das zugrundeliegende BIM-Modell spezifische geometrische und semantische Anforderungen erfüllen. Eine Untersuchung typischer IFC-Exporte (Industry Foundation Classes) offenbart häufige Defizite, die für eine valide Verschattungssimulation zwingend im Vorfeld korrigiert oder durch klare Modellierungsrichtlinien im BIM-Abwicklungsplan (BAP) definiert werden müssen:

- *Semantische Klassifizierung (IFC-Entitäten):* Die Zielflächen müssen zwingend als `IfcWindow` oder `IfcCurtainWall` deklariert sein, damit das Python-Skript sie automatisiert extrahieren kann. Eine häufige Fehlerquelle bei CAD-Exporten (z. B. aus Autodesk Revit) ist die Fehlklassifizierung von schrägen Fenstern oder Dachflächenfenstern als generische Bauteile (oft `IfcBuildingElementProxy` oder `IfcRoof`), wodurch sie von der Simulationslogik nicht als Sensorflächen erkannt werden.

- *Detaillierungsgrad (Level of Detail / LOD):* Für eine aussagekräftige Simulation der Gebäudehülle ist ein minimaler geometrischer Detaillierungsgrad zwingend erforderlich. Ein reines Volumen- oder Massenmodell (z. B. LOD 100), in dem Fensteröffnungen noch nicht ausmodelliert sind, ist für diesen Zweck unbrauchbar. Um den kritischen Effekt der Eigenverschattung (beispielsweise durch tiefe Fensterlaibungen, Stürze oder auskragende Fassadenelemente) physikalisch korrekt per Raycasting berechnen zu können, müssen die entsprechenden Bauteile mindestens im LOD 300 vorliegen.

- *Datenreduktion:* Um die Dateigröße und die Berechnungszeiten beim Import in die 3D-Engine (Blender) zu minimieren, muss das IFC-Modell um nicht-relevante Architekturdetails bereinigt werden. Für die geometrische Verschattungssimulation sind ausschließlich die Elemente der thermischen Gebäudehülle (Fassaden, Fenster) sowie potenziell eigenverschattende Bauteile (Balkone, Erker, Laibungen) erforderlich. Innenwände oder Inventar sind vor allem bei großen Gebäuden zwingend auszuschließen. Meist liegen diese Modelle als Fassadenteilmodelle vor.

- *Geometrische Ausrichtung (Face Normals):* Für eine performante und fehlerfreie Raycasting-Berechnung ist die konsistente Ausrichtung der Flächennormalen (Face Normals) der Fenster-Meshes entscheidend. Die Normalenvektoren der Fenster müssen nach außen zeigen. Ist dies nicht der Fall, kann die in 3D-Engines übliche Performance-Optimierung des _Backface Culling_ (siehe Kapitel 4, wo ich das backwards culling beschreibe) nicht angewandt werden.

- *Georeferenzierung und Ausrichtung:* Eine zentimetergenaue Überlagerung des Gebäudemodells mit den externen GIS-Umgebungsdaten (siehe Kapitel 4.3....) erfordert eine exakte Verortung. Das Gebäude muss auf der korrekten absoluten Z-Höhe (z. B. Höhe über NHN) modelliert und geografisch nach dem Wahren Norden ausgerichtet sein. Hierfür müssen die exakten Koordinaten des Projekt-Referenzpunktes unter der Entität `IfcSite` in einem globalen Referenzsystem (z. B. WGS84) hinterlegt vorliegen @buildingsmart_ifcsite.

- *Räumliche Zuordnung (Spatial Containment):* Für die spätere Integration in die Raumautomation müssen die Fensterelemente im IFC-Strukturbaum korrekt dem jeweiligen Geschoss (`IfcBuildingStorey`) logisch zugeordnet sein.

- *Eindeutige Identifikation (AKS):* Um die berechneten Verschattungsdaten nach der Simulation fehlerfrei an die operative Steuerungsebene zu übergeben, muss jedes Fensterobjekt zwingend mit einem Anlagenkennzeichnungssystem (AKS) versehen sein (beispielsweise im IFC-Attribut `Name` oder `Tag`). Dieses AKS sollte konsequent nach dem hierarchischen Schalenmodell der VDI 3814-1 aufgebaut sein, um das direkte Mapping auf die BACnet-Objekte der Automationsstation zu ermöglichen @vdi3814-1.

  - Weil oft von Architekten bei Hochhäusern auch Sonnenstudien durchgeführt werden oder Modelle für Marketingszwecke generiert werden, sind wahrscheinlich schon komplette Stadtmodelle vorhanden, die man weiterverwenden könnte
  

  HIER AUF CHECKLISTE IM ANHANG VERWEISEN FÜR ARCHITEKTEN
=== Analyse externer Geodaten <AnalyseExternerGeodaten>
// Notwendigkeit und Anforderungen an Umgebungsmodelle, beispielsweise der Detaillierungsgrad (LOD) der Nachbarbebauung aus GIS- oder OpenStreetMap-Daten.

Die Qualität der Daten der umgebenden Gebäude, Topografie und Vegetation bestimmt die Genauigkeit der Verschattungssimulation maßgeblich. Ungenaue Gebäudekanten oder fehlende Dachaufbauten in der Nachbarbebauung führen zwangsläufig zu fehlerhaften Schlagschatten auf der betrachteten Fassade. Meistens werden diese Datensätze in georeferenzierten Koordinatensystemen (z. B. UTM oder Gauß-Krüger) bereitgestellt, was eine Transformation in das lokale System des Gebäudemodells (BIM) erfordert.

Die Auswahl des geeigneten Datenanbieters für das Referenzprojekt erfolgt anhand folgender Kriterien:

- *Verfügbarkeit und Abdeckung:* Zunächst muss geprüft werden, welcher Anbieter Daten für den spezifischen Standort in der erforderlichen Dichte bereitstellt. Während globale Anbieter oft flächendeckende, aber detailarme Daten liefern, bieten kommunale Geoportale (z. B. Katasterämter) oft präzisere Datensätze an. Zu beachten sind hierbei lizenzrechtliche und technische Einschränkungen: So sind beispielsweise die photogrammetrischen 3D-Tiles der Google Maps Platform in der EU derzeit nur eingeschränkt für Simulationszwecke nutzbar @GoogleTilesAdjustments.

- *Level of Detail (LOD):* Der Detaillierungsgrad der Gebäudegeometrie ist der kritischste Parameter für die Simulation. Gemäß dem Standard der _Open Geospatial Consortium (OGC)_ für CityGML unterscheidet man:
  - *LOD1 (Blockmodell):* Das Gebäude wird als einfacher Kubus mit Flachdach dargestellt (Extrusion der Grundfläche). Dies ist für weit entfernte Verschattungsobjekte ausreichend, führt aber im Nahbereich zu Fehlern, da die tatsächliche Dachform ignoriert wird.
  - *LOD2 (Dachmodell):* Das Modell beinhaltet standardisierte Dachformen und grobe Dachaufbauten. Für die Verschattungssimulation stellt LOD 2 oft den optimalen Kompromiss aus Genauigkeit und Dateigröße dar, da die Schattenlänge durch die Dachfirsthöhe maßgeblich beeinflusst wird @Hessen3D.
  - *LOD3 (3D Mesh)* Detaillierte Gebäudehüllen werden mit Auskragungen, Fensterlaibungen und Texturen modelliert. LOD3 bietet einen sehr hohe Genauigkeit, die jedoch einen negativen Einfluss auf die spätere Rechenleistung hat.  
#figure(
  image("assets/LOD1-3.png", width: 80%),
  caption: [LOD 1-3 @ogcCityGeography]
)<fig-lod>

- *Datenformat und Interoperabilität:* Für den Import in die Simulationsumgebung (Blender) ist das Format entscheidend.
  - _Semantische Formate:_ *CityGML* oder *CityJSON* enthalten neben der Geometrie auch Attribute (Baujahr, Nutzung). Sie müssen jedoch oft erst geparst (konvertiert) werden.
  - _Geometrische Formate:_ *.obj*, *.gltf* oder *.fbx* enthalten reine 3D-Meshes. Diese lassen sich direkt und performant verarbeiten, verlieren aber oft den geodätischen Bezug.

- *Aktualität:* Die Daten müssen den aktuellen baulichen Bestand widerspiegeln. Insbesondere in dynamischen innerstädtischen Lagen (wie im Referenzprojekt Frankfurt) können veraltete Datensätze dazu führen, dass neu errichtete Hochhäuser in der Simulation fehlen und somit der Schattenwurf unterschätzt wird.

- *Kostenstruktur:* Es ist zwischen kostenpflichtigen kommerziellen Daten und Open-Data-Initiativen zu unterscheiden. Viele Bundesländer (darunter Hessen und NRW) stellen ihre 3D-Gebäudemodelle mittlerweile kostenfrei über Open-Data-Portale zur Verfügung, was die wirtschaftliche Hürde für die Integration in die Gebäudeautomation eliminiert.

==== Auswahl der Umgebungsszene
- Gebäude, die nördlich des Referenzgebäudes liegen, müssen theoretisch nicht in der Simulation berücksichtigt werden. Um den genauen Bereich herauszufinden, muss der minimale und maximale Azimut der Sonne während der Sommersonnenwende (21./22. Juni) ermittelt werden. In Frankfurt am Main geht die Sonne mit einem Azimut von 50° auf und mit 310° unter. Somit kann die Umgebung in einem Azimut von 310°-50° zum Referenzgebäude nie einen direkt Schatten auf dieses werfen und somit vernachlässigt werden.
  - bei sehr tiefliegender sonne sind auch weit entferne gebäude relevant
  - niedrige gebäude sind nur für die niedrigen etagen interessant (vielleicht simulationen so aufsplitten?)
- Topologie nur, wenn Berge, Hügel etc. das Gebäude verschatten könnten
=== Georeferenzierung und Zeitbasis <GeoreferenzierungZeitbasis>
 Definition der Anforderungen an die räumliche und zeitliche Einordnung, inklusive Koordinatensystemen und dem Handling von Zeitzonen.

=== Zeitliche Auflösung und Simulationsumfang <ZeitlicheAufloesungUmfang>

*Zeitliche Diskretisierung:* Die Wahl der zeitlichen Auflösung für die Verschattungsdaten hat maßgeblichen Einfluss auf das Verhältnis zwischen visuellem Komfort (Blendschutz) und der Tageslichtausbeute des Gebäudes. Da die Verschattungsinformation in der Steuerung eine binäre Freigabe (Schatten oder Sonne) darstellt, muss bei einer Reduktion der Datenauflösung zwingend eine Worst-Case-Annahme getroffen werden: Fällt innerhalb eines Simulationsintervalls auch nur für einen Bruchteil der Zeit Sonne auf das Fenster, muss der Sonnenschutz für das gesamte Intervall geschlossen werden, um temporäre Blendung auszuschließen. 

#figure(
  image("assets/AuflösungZeitstrahl.svg" ),
  caption: [Theoretischer Verschattungsverlauf an einem Referenzfenster mit beispielhafter Steuerung bei 5-, 15- und 60-minütiger Datenauflösung.],
  placement: none
)<fig-Zeitstrahl>


@fig-Zeitstrahl veranschaulicht diesen Effekt am Beispiel einer theoretischen Steuerung mit integrierten Verschattungsdaten in verschiedenen Auflösungen. Die Steuerungslogik definiert sich dabei wie folgt:
- *Fall offener Behang:* Die Steuerung detektiert für einen Zeitpunkt $t$, ob für den nächsten berechneten Zeitpunkt ($t+1$) Sonne auf das Fenster fällt. Falls ja, werden die Behänge präventiv geschlossen. 
- *Fall geschlossener Behang:* Die Steuerung detektiert für einen Zeitpunkt $t$, ob für den nächsten berechneten Zeitpunkt $t+1$ keine Sonne mehr auf das Fenster fällt und öffnet die Behänge erst zu diesem Zeitpunkt ($t+1$).

Dadurch wird garantiert, dass der Nutzer zu keinem Zeitpunkt einer Blendung ausgesetzt ist. Am beispielhaften Zeitstrahl verlässt der Schatten das Fenster um 10:23 Uhr. Bei einer groben stündlichen Diskretisierung hält die Steuerung den Behang jedoch schon ab 10:00 Uhr geschlossen, was zu 23 Minuten Verlust an natürlichem Tageslicht führt. Besonders gravierend wirkt sich diese zu grobe Abtastung bei schnellen, iterativen Verschattungsänderungen aus (beispielsweise in Großstädten mit dichter Hochhausbebauung). 

Im Gegensatz dazu ermöglicht eine feine Auflösung von 5 Minuten, die Behänge sehr nah am realen Schattenverlauf des Fensters zu führen. Sie bildet den realen Schattenverlauf exakt ab und erfasst auch kurze Sonneneinstrahlungen durch Lücken in der Nachbarbebauung. Werden diese schnellen Wechsel jedoch direkt als Fahrbefehle an die Motoren weitergegeben, sinkt der Nutzerkomfort erheblich. Eine sich ständig bewegende Jalousie lenkt visuell und akustisch ab und erhöht den Verschleiß der Motoren deutlich.

Um diesen Konflikt zu lösen, muss die Steuerung die präzisen Umgebungsdaten von den tatsächlichen Fahrbefehlen entkoppeln. In der Gebäudeautomation werden dafür Verzögerungszeiten, sogenannte Totzonen, oder Hysteresen eingesetzt. Dadurch reagiert der Sonnenschutz nicht mehr auf jede minimale und kurzzeitige Schattenänderung.

Eine hohe Datenauflösung bleibt somit das konzeptionelle Optimum. Voraussetzung ist lediglich, dass die technische Infrastruktur die großen Datenmengen verarbeiten kann und die Steuerungsprogrammierung ständige Fahrbewegungen zuverlässig dämpft.

*Zeitlicher Simulationsumfang:* Für die Konzeption der Simulation stellt sich zudem die Frage, wie viele Kalenderjahre berechnet werden müssen, um den realen Sonnenverlauf hinreichend abzubilden. Der Umlauf der Erde um die Sonne unterliegt zwar langperiodischen Schwankungen (Milanković-Zyklen@dwdMilanZyklen), diese sind für die Lebensdauer eines Gebäudes jedoch nicht relevant. Der berechnete Sonnenverlauf kann für den Betrachtungszeitraum als statisch angesehen werden. 

Da das kalendarische Jahr vom astronomischen Sonnenjahr (365,24 Tage) abweicht@astr04eduSonnenjahr, wird diese Differenz alle vier Jahre durch ein Schaltjahr korrigiert. Die hieraus resultierende zeitliche Verschiebung des Sonnenstandes am selben Kalendertag ist für einen simulierten Schattenwurf in @fig-schaltjahr beispielhaft dargestellt. 
#figure(
  image("assets/SchaltjahrUnterschied.png"), 
  caption: [Differenz des Schattenwurfs am 01.03. eines Normaljahres gegenüber einem Schaltjahr um 09:00 Uhr.],
  placement: auto
)<fig-schaltjahr>
Da sich die räumlichen Abweichungen des Schattens lediglich im Zentimeterbereich bewegen (roter Bereich), ist es für den Systemansatz ausreichend, die Simulation auf ein einzelnes Referenzjahr zu beschränken.

=== Räumliche Auflösung der Messpunkte <RaeumlicheAufloesung>

Die räumliche Abtastung der Fensterflächen bestimmt die Zuverlässigkeit der Simulation. Man muss festlegen, wie viele Testpunkte pro Fenster berechnet werden. Es werden drei verschiedene Optionen untersucht:

*1. Einpunkt-Messung (Fenstermittelpunkt):*
Es wird ein einzelner Raycast vom geometrischen Zentrum des Fensters zur Sonne berechnet. Dieser Ansatz hat den Vorteil, dass er die geringste Rechenzeit aufweist, allerdings anfällig für Situationen mit Teilverschattung ist: Verdeckt ein Schatten beispielsweise nur die untere Fensterhälfte, meldet der Mittelpunkt unter Umständen schon eine Verschattung des Fensters. Dabei ist die obere Fensterhälfte noch stark besonnt und verursacht Blendung.

*2. Vierpunkt-Messung (Eckpunkte):*
Die Simulation prüft die vier Extrempunkte der Fenstergeometrie. Sobald mindestens einer der vier Punkte direkte Sonneneinstrahlung detektiert, gilt das gesamte Fenster als besonnt. Teilverschattungen werden somit sicher erkannt, wodurch temporäre Blendungen verhindert werden. Der Nachteil ist eine ca. Verdopplung der Rechenzeit gegenüber der Einpunkt-Messung. Zudem können sehr schmale, vertikale Objekte (z. B. Masten), die schmaler als die Fensterbreite sind, theoretisch übersehen werden. Dies stellt im urbanen Kontext jedoch ein vernachlässigbares Restrisiko dar. In einzelnen Fällen, kann auch ein Schattenwurf, der nur die untere Fensterkante streift, zu einer nicht notwendigen Reaktion der Jalousie führen. Dies könnte mit dem Hochsetzen der unteren beiden Eckpunkte auf eine vertretbare Höhe verhindert werden.

*3. Raster-Messung:*
Ein feines Raster würde mehrere Punkte entlang der seitlichen Kanten des Fensters messen. Dies ermöglicht theoretisch eine genauere Steuerung der Behanghöhe, müsste allerdings in Kombination mit einer hohen zeitlichen Auflösung erfolgen. Ansonsten kann die Steuerung von der hohen örtlichen Datendichte nicht profitieren und müsste die zwischen den groben Zeitintervallen weit gewanderte Schattenkante in großen Sprüngen nachführen.
Der Nachteil wäre außerdem eine Vervielfachung der Rechenzeit und eine komplexere Datenstruktur.

== Konzeption der Simulationslogik (Processing) <KonzeptionSimulationslogik>
- *Methodenauswahl:* Begründung des gewählten geometrischen Raycasting-Verfahrens gegenüber alternativen Ansätzen wie Radiosity oder rein thermischen Simulationen.
- *Diskretisierungsstrategie:* Festlegung der zeitlichen Auflösung (Schrittweite der Jahressimulation) sowie der räumlichen Abtastung (Sampling-Raster) der Fensterflächen zur Ermittlung von Teilverschattungen.

== Definition der Systemarchitektur und Schnittstellen (Output) <DefinitionSystemarchitektur>

*Vorberechnung oder dynamisch?*
Hier geht es um die Grundsatzentscheidung: Handelt es sich um ein zustandsloses System, das einmalig einen Fahrplan (Schedule) generiert, oder um ein dynamisches System, das auf Veränderungen (beispielsweise neue Verschattungsobjekte durch Baustellen) reagieren kann. Du kannst hier begründen, warum du dich für den einen oder anderen Weg entschieden hast, bevor du in die Umsetzung gehst.

- *Workflow-Design:* Erstellung einer schematischen Darstellung des gesamten Datenflusses, ausgehend von der digitalen Planung bis hin zur Ansteuerung der Aktoren.
- *Datenschnittstelle zur Automation:* Spezifikation des Exportformats (z. B. CSV-Struktur) und Festlegung der zu übergebenden Steuergrößen wie Verschattungsgrad und Status.

- Auch die Frage: Auf welchem Rechner sollten die Daten gespeichert werden? Extern oder intern beim Kunden?
- Lieber status 0, -1. -2, -3, Winkel oder nur 0, 1
- *Mapping-Konzept:* Entwicklung einer Logik zur Verknüpfung der Simulationsergebnisse mit den physischen Datenpunkten der Gebäudeautomation (beispielsweise BACnet-Objekt-IDs).

/*
1. Problemstellung: Die Mehrdeutigkeit des 3D-Einfallswinkels

Kritik am Skalarprodukt: Die direkte Berechnung des Winkels zwischen Fensternormale und Sonnenvektor liefert einen absoluten 3D-Winkel.

Fehlende Spezifität: Ein berechneter Winkel von beispielsweise 65° ist mehrdeutig. Er kann entstehen durch einen sehr hohen Sonnenstand (Mittagszeit im Sommer) oder durch einen extrem flachen, seitlichen Lichteinfall (Morgens/Abends).

Steuerungsproblem: Für eine automatisierte Jalousiesteuerung (Blendschutz) ist diese Information unzureichend, da beide Szenarien völlig unterschiedliche Behanghöhen oder Lamellenwinkel erfordern würden.

2. Methodischer Lösungsansatz: Trennung von Azimut und Elevation

Vektorzerlegung: Die Sonnenposition wird nicht als einzelner 3D-Vektor betrachtet, sondern in ihre horizontalen (Sonnenazimut) und vertikalen (Sonnenhöhe/Elevation) Komponenten aufgeteilt.

Der relative Azimut: Berechnung der exakten Winkeldifferenz zwischen der Ausrichtung des Fensters (Fensternormalen-Azimut) und dem Sonnenazimut in der horizontalen Ebene.

Vorzeichen-Logik: Einführung von Vorzeichen (+/-) beim relativen Azimut, um die exakte Einfallsrichtung (linksseitig vs. rechtsseitig der Flächennormalen) zu definieren. Wichtig für asymmetrische Fassaden.

3. Anwendung in der Praxis: Der Profilwinkel und bauliche Eigenverschattung

Implementierung von Cut-Off-Winkeln: Festlegung von Grenzwerten (z. B. relative Azimut-Differenz > 75°), ab denen ein Sonneneinfall von der Steuerung ignoriert wird.

Berücksichtigung der Mikro-Geometrie: Bei extrem flachen seitlichen Winken wird die direkte Sonneneinstrahlung in der Realität oft durch bauliche Elemente (Fensterlaibungen, Rahmen, vorgelagerte Säulen oder Lisenen) geblockt, bevor sie das Glas trifft.

Nutzerkomfort & Energieeffizienz: Durch das bewusste Ignorieren dieser "harmlosen" Sonnenstrahlen bleiben Jalousien länger geöffnet. Das maximiert die Tageslichtautonomie im Raum und senkt den Bedarf an künstlicher Beleuchtung.

4. Datenökonomie und Systemarchitektur

Vermeidung von Redundanz: Die Sonnenhöhe (Elevation) ist zu einem bestimmten Zeitpunkt für das gesamte Gebäude (und somit für alle ~6000 Fenster) identisch.

Effiziente Speicherung: Statt die Elevation in jeder einzelnen Zelle der CSV-Datei mitzuschleifen, wird sie als globaler Parameter in einer separaten Tabelle oder Datenbankstruktur geloggt (1 Wert pro Zeitschritt statt 6000).

Performance-Gewinn: Deutliche Reduktion der Dateigröße der Simulationsergebnisse (CSV) und schnellere Lade- bzw. Abfragezeiten für nachgelagerte Tools oder Datenbanken.
*/

== Integration in die Gebäudeautomation