= Einleitung<Kap1>
== Problemstellung
//Die Gebäudeautomation hat ein Problem bei der Simulation und Integration von Verschattungsberechnungen in Gebäuden: Der Engineering-Aufwand ist sehr hoch... Da in der Zukunft allerdings immer weniger personelle Ressourcen zur Verfügung stehen werden und der Sonnenschutz im Zuge des Klimawandels eine immer bedeutendere Rolle einnehmen wird, ist es notwendig die gesamte Prozesskette neu zu betrachten. Es gilt, integrierte Lösungen zu finden, damit der Datenfluss vom Gebäudemodell des Architekten bis hin zur Systemintegration
//  der Verschattungsdaten gut funktioniert. 
// "Urbaner Kontext" benutzen? 

Die Steuerung automatisierter Fassadensysteme erfolgt in der heutigen Gebäudepraxis überwiegend reaktiv auf Basis lokaler Sensorik. Helligkeits- und Strahlungssensoren erfassen den Ist-Zustand der Umgebung, können jedoch komplexe geometrische Situationen wie den Schattenwurf durch Nachbarbebauung oder die Eigenverschattung der Fassade nur unzureichend abbilden. Dies führt im Betrieb häufig zu ineffizienten Fahrbewegungen der Behänge, die weder den visuellen Komfort noch den sommerlichen Wärmeschutz optimal bedienen.

Um diese Defizite auszugleichen, bieten moderne softwaregestützte Methoden die Möglichkeit, den Schattenwurf präzise vorauszuberechnen. Die praktische Anwendung scheitert jedoch derzeit an massiven Ineffizienzen innerhalb der digitalen Prozesskette, die sich sowohl in der Datenbeschaffung als auch in der Datenverwertung manifestieren.

Ein vorgelagertes Hindernis besteht in der mangelnden Simulationsfähigkeit der architektonischen Ausgangsdaten. Zwar liegen zunehmend digitale Bauwerksmodelle (BIM) vor, diese sind jedoch häufig für visuelle oder konstruktive Zwecke optimiert und entsprechen nicht den Anforderungen einer geometrischen Verschattungssimulation. Inkonsistente Geometrien, fehlende semantische Informationen oder ein unpassender Detaillierungsgrad erzwingen eine zeitintensive manuelle Aufbereitung und Bereinigung der Modelle, bevor eine Berechnung überhaupt möglich ist.

Die eigentliche Simulation 

Das nachgelagerte Problem betrifft die fehlende Prozessdefinition für die Datenintegration der Ergebnisse: Selbst wenn validierte Simulationsdaten vorliegen, existiert keine standardisierte Prozesskette, um diese ohne manuellen Mehraufwand direkt in die Steuerungslogik der Raumautomation zu überführen. Der derzeitige Engineering-Prozess sieht in der Regel nicht vor, dass die Simulationssoftware bereits das finale Datenformat für die Automationsstation bereitstellt.

Angesichts sinkender personeller Ressourcen im Engineering und der steigenden Notwendigkeit, Gebäude klimaresilient zu betreiben, stellen diese Medienbrüche an beiden Enden der Simulationsphase ein kritisches Hemmnis dar. Es ist daher notwendig, die Prozesskette ganzheitlich zu betrachten und Lösungen zu entwickeln, die den Datenfluss vom Gebäudemodell des Architekten bis hin zur Systemintegration der Verschattungsdaten durchgängig und aufwandsarm gestalten.

== Zielsetzung
// Entwicklung einer durchgängigen Prozesskette (Data Workflow).
Das übergeordnete Ziel dieser Arbeit ist die Entwicklung einer durchgängigen Prozesskette zur Integration dynamischer Verschattungssimulationen in die Gebäudeautomation. Es soll ein strukturierter Workflow definiert werden, der den Informationsfluss von der digitalen Planung (BIM) bis zur operativen Steuerungsebene der Raumautomation automatisiert und standardisiert.

Um die technische Machbarkeit und den praktischen Nutzen dieses Ansatzes zu validieren, verfolgt die Arbeit folgende Teilziele:

1.  *Analyse der Schnittstellen:* Identifikation der notwendigen Datenpunkte und Formate auf Basis der VDI 3814 (Gebäudeautomation) und IFC (Industry Foundation Classes).
2.  *Entwicklung eines Proof of Concept (PoC):* Implementierung eines prototypischen Simulations-Workflows unter Verwendung von Open-Source-Technologien (Blender, Python). Dieser Prototyp soll demonstrieren, wie geometrische Verschattungsdaten automatisiert aus einem IFC-Modell extrahiert, berechnet und in ein maschinenlesbares Format für Automationsstationen überführt werden können.
3.  *Ableitung von Handlungsempfehlungen:* Erstellung eines Leitfadens für Fachplaner und Systemintegratoren, der die notwendigen Datenanforderungen und Prüfschritte für die Inbetriebnahme beschreibt.

Die Arbeit schließt somit die Lücke zwischen theoretischem Simulationspotenzial und praktischer Anwendung, indem sie nicht nur das "Was", sondern durch den softwaretechnischen Demonstrator auch das "Wie" der Integration beantwortet.
== Aufbau der Arbeit
Die vorliegende Arbeit gliedert sich in ..... mit ki hier noch generieren