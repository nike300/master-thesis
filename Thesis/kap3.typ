= Anforderungsanalyse und Konzeption des Integrationsprozesses<Kap3>

== Analyse der Ausgangssituation und Zieldefinition
- *Defizite konventioneller Verschattungsstrategien:* Analyse der Einschränkungen heutiger Systeme, insbesondere die fehlende Berücksichtigung von Fremdverschattung durch Nachbargebäude.
- *Anforderungsprofil an das Gesamtsystem:* Definition funktionaler Anforderungen (wie Präzision und Grad der Automatisierbarkeit) sowie nicht-funktionaler Anforderungen (Recheneffizienz und Systemkompatibilität).

== Spezifikation der Datengrundlage (Input)
=== Analyse der BIM-Datengüte (IFC):
 Untersuchung der vorhandenen geometrischen Informationen und Identifikation fehlender Attribute, die für eine valide Simulation zwingend erforderlich sind.
 - Gebäudedaten (ifc) sollte haben:
  - richtige labels für gebäudeteile (IFC-Window-Klasse)
  - Nur Fassadenelemente
  - Die Fensterflächen sollten richtig _Face Normals_ (Flächenausrichtung)? für backwards Culling
  - Auch schräge Fenster sollten als IFC-Window-Klasse definiert werden
  - Das Gebäude sollte in der ifc-Datei bereits auf der richtigen Z-Höhe und nach Norden ausgerichtet sein
  - Die Fenster sollten @aks  besitzen, der nach dem Schalenmodell @vdi3814-1 aufgebaut ist.
=== Analyse externer Geodaten
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



==== überlegung zur auswahl der szene
  - Gebäude im norden vom gebäude müssen nicht geladen werden, da sie nicht das gebäuude verschatten können
  - bei sehr tiefliegender sonne sind auch weit entferne gebäude relevant
  - niedrige gebäude sind nur für die niedrigen etagen interessant (vielleicht simulationen so aufsplitten?)


=== Georeferenzierung und Zeitbasis
 Definition der Anforderungen an die räumliche und zeitliche Einordnung, inklusive Koordinatensystemen und dem Handling von Zeitzonen.

== Konzeption der Simulationslogik (Processing)
- *Methodenauswahl:* Begründung des gewählten geometrischen Raycasting-Verfahrens gegenüber alternativen Ansätzen wie Radiosity oder rein thermischen Simulationen.
- *Diskretisierungsstrategie:* Festlegung der zeitlichen Auflösung (Schrittweite der Jahressimulation) sowie der räumlichen Abtastung (Sampling-Raster) der Fensterflächen zur Ermittlung von Teilverschattungen.

== Definition der Systemarchitektur und Schnittstellen (Output)
- *Workflow-Design:* Erstellung einer schematischen Darstellung des gesamten Datenflusses, ausgehend von der digitalen Planung bis hin zur Ansteuerung der Aktoren.
- *Datenschnittstelle zur Automation:* Spezifikation des Exportformats (z. B. CSV-Struktur) und Festlegung der zu übergebenden Steuergrößen wie Verschattungsgrad und Status.
- *Mapping-Konzept:* Entwicklung einer Logik zur Verknüpfung der Simulationsergebnisse mit den physischen Datenpunkten der Gebäudeautomation (beispielsweise BACnet-Objekt-IDs).