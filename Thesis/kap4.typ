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
