= POC<Kap4>
// Vorstellung Four (Turm 1)
Das FOUR sind vier zusammenhängende Türme in der Innenstadt von Frankfurt am Main.  
== Import Umgebungsdaten
  Die Qualität der Daten der umgebenden Gebäude, Topografie und Natur bestimmt die Genauigkeit der Verschattungsdaten fundamental. Ungenaue Gebäudekanten ...
  === Überlegung zur Wahl des Datenanbieters
Die Wahl des Anbieters für die Bereitstellung der Umgebungsdaten des Referenzgebäudes hängt von verschiedenen Kriterien ab:
- *Verfügbarkeit:* Es muss geprüft werden, welcher Anbieter die Daten zur Verfügung stellen kann für den benötigten Bereich. Manche Anbieter spezialisieren sich auf die möglichst genaue Darstellungen von großen Städten, während andere sich auf die Topografische Visualisierung fokussieren. Es gibt auch Datenquellen, auf die in der EU nicht zugegriffen werden kann, wie zum Beispiel die 3D-Tiles von Google Maps @googleTilesAdjustments.

- *Preis:* Während es Plattformen gibt, die Ihre Daten kostenlos im Internet bereitstellen, wie z.B. OpenStreetMaps oder 



  - osm ziemlich gut
  - 3D-Tiles von google nicht mehr erlaubt in EU (https://developers.google.com/maps/comms/eea/map-tiles)
  - daten von stadt frankfurt?

=== überlegung zur auswahl der szene
  - Gebäude im norden vom gebäude müssen nicht geladen werden, da sie nicht das gebäuude verschatten können
  - bei sehr tiefliegender sonne sind auch weit entferne gebäude relevant
  - niedrige gebäude sind nur für die niedrigen etagen interessant (vielleicht simulationen so aufsplitten?)

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

=== Überlegung zur zeitlichen Auflösung
// Hier Bild von Unterschied des Schattenverlaufs an einem Punkt über 4 Jahre. Auf Schaltjahr eingehen. Ergebnis: 1 Jahr berechnet reicht aus (aber welches Jahr?).

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
