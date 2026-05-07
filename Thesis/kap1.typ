= Einleitung<Kap1>
== Problemstellung


Die Integration dynamischer Verschattungssimulationen in die Gebäudeautomation gewinnt aufgrund steigender Energiekosten und wachsender Ansprüche an den thermischen sowie visuellen Nutzerkomfort zunehmend an Bedeutung. Eine hocheffiziente Verschattungssteuerung erfordert präzise Daten über den lokalen Schattenwurf, um die Tageslichtautonomie von Gebäuden zu maximieren und gleichzeitig Kühllasten sowie Blendeffekte systematisch zu minimieren.

In der aktuellen Praxis der Gebäudeautomation stellt jedoch die informationstechnische und planungsseitige Umsetzung solcher Systeme eine erhebliche Herausforderung dar. Die konventionelle Parametrierung von Sonnenschutzsteuerungen erfolgt in der Regel noch über die manuelle Eingabe statischer Grenzwinkel in die Automationsstation. Dieser Ansatz erfordert Worst-Case-Annahmen und führt in komplexen urbanen Umgebungen *unweigerlich zu systembedingten Fehlentscheidungen der Automatik*, da die reale Fremdverschattung durch Nachbargebäude oder Topografie nur unzureichend abgebildet wird.

Der Einsatz dreidimensionaler Verschattungssimulationen bietet theoretisch die notwendige Grundlage zur Lösung dieses Konflikts. Dem steht jedoch in der Praxis ein immenser Engineering-Aufwand gegenüber. Die Erstellung und Integration derartiger Simulationen ist oftmals sehr kostenintensiv und scheitert zudem zunehmend an sinkenden personellen Ressourcen bei den ausführenden Systemintegratoren und Fachplanern. Ein weiteres wesentliches Hindernis für einen automatisierten Workflow ist die in der Praxis oft mangelhafte Qualität der zur Verfügung stehenden digitalen Planungsdaten. 

Darüber hinaus sind die normativen und informationstechnischen Grundlagen der aktuellen Raumautomation nicht auf die Verarbeitung dieser hochauflösenden Simulationsdaten ausgelegt. Die etablierten Standards, insbesondere die Funktionsblöcke nach VDI 3813, basieren primär auf der Auswertung des globalen Sonnenstandes in Kombination mit lokalen, fest hinterlegten Parametern. Sie sind in ihrer aktuellen Architektur nicht darauf vorbereitet, dynamisch generierte, externe Verschattungsdaten aus einer vorgelagerten 3D-Simulation effizient zu integrieren. 

Aus dieser Diskrepanz zwischen bauphysikalischem Bedarf und planungspraktischer Realität ergibt sich die Notwendigkeit, eine automatisierte und wirtschaftlich tragfähige Methodik zu entwickeln, welche die Lücke zwischen der digitalen Gebäudeplanung und der operativen Gebäudeautomation schließt.
// - Verschattungssimulationen sind wahrscheinlich sehr aufwändig im Engineering
// - Sie sind meistens teuer
// - Oft wird in der Steuerung noch händisch Winkel eingetragen, bei denen es zu einer Blendung/Verschattung kommt
// - Sinkende personelle Ressourcen
// - Steigender Anspruch an Komfort und Energieeinsparungen
// - Verschattungsdaten sind ein wichtiger Baustein für eine hocheffiziente Verschattungssteuerung
// - Es liegen Daten in mangelhafter Qualität vor
// - Energiekosten hoch -> Tageslichtautonomie maximieren
// - VDI 3813 Funktionsblöcke sind nicht auf Simulationsdaten vorbereitet

// == Zielsetzung
//   - Identifikation der notwendigen Datenqualität des IFC-Modell
//   - Anforderungen an BIM-Modelle für die Umsetzung einer verschattungslösung
//   - Auswahlkriterien von Open Source Datensätzen
//   - Nur Einsatz von Open Source Daten
//   - Entwicklung eines Proof of Concept (PoC) für Verschattungssimulationen anhand eines hochkomplexen Referenzprojekts mithilfe von kostenlosen tools
//     - Analyse der optimalen Parameter (zeitliche und räumliche Komponenten)
//     - Beste Output struktur der Daten festlegen
//   - Es soll die zum Teil mangelhafte Datenqualität aufgezeigt werden und wie damit umgegangen werden kann
//   - Entwicklung eines angepassten Funktionsblocks für die Verschattungskorrektur nach VDI 3813
// 
== Zielsetzung

Das primäre Ziel dieser Arbeit besteht in der Konzeption und Validierung einer durchgängigen, softwaregestützten Prozesskette zur Integration dynamischer Verschattungsdaten in die Gebäudeautomation. Um die wirtschaftliche Skalierbarkeit und Zugänglichkeit des Ansatzes zu gewährleisten, fokussiert sich die Methodik auf den exklusiven Einsatz von Open-Source-Software und frei verfügbaren Datensätzen.

Zur Erreichung dieses Hauptziels werden spezifische Teilziele definiert, die sich am chronologischen Ablauf des Engineering-Prozesses orientieren. Zunächst wird die informationstechnische Datengrundlage analysiert. Dies umfasst die Definition der notwendigen Datenqualität von IFC-Modellen, die für die Umsetzung einer simulationsbasierten Verschattungslösung erforderlich sind. Parallel dazu werden Auswahlkriterien für externe Open-Source-Geodatensätze erarbeitet. Da digitale Planungsdaten in der Praxis häufig Defizite aufweisen, wird diese mangelhafte Datenqualität gezielt aufgezeigt. Die Arbeit erarbeitet methodische Lösungsansätze, wie mit geometrischen und semantischen Inkonsistenzen umgegangen werden kann, um eine valide Simulation zu sichern.

Darauf aufbauend erfolgt die Entwicklung und softwaretechnische Implementierung eines Proof of Concept (PoC) anhand eines hochkomplexen Referenzprojekts. Innerhalb dieses PoC werden die optimalen Parameter für die räumliche und zeitliche Diskretisierung der Verschattungssimulation untersucht. Es gilt, das ideale Verhältnis zwischen Rechenaufwand, generiertem Datenvolumen und der Qualität der Steuerungsdaten zu identifizieren. Resultierend daraus wird die optimale informationstechnische Struktur für den Datenoutput festgelegt.

Den Abschluss bildet die konzeptionelle Integration der Simulationsergebnisse in die normative Logik der Gebäudeautomation. Hierfür wird ein modifizierter Funktionsblock für die Verschattungskorrektur in Anlehnung an die Richtlinie VDI 3813 entwickelt. Dieser Entwurf soll demonstrieren, wie die konventionelle, rein winkelbasierte Regelungslogik der Raumautomation durch eine datengetriebene Architektur effizient ersetzt werden kann.

=== Aufbau der Arbeit <AufbauArbeit>

Die vorliegende Arbeit gliedert sich in sechs Kapitel, die den Entwicklungsprozess systematisch von der theoretischen Fundierung bis zur praktischen Integration abbilden. 

Das erste Kapitel dient der Einführung in die Thematik. Es skizziert die Problemstellung im Kontext konventioneller Verschattungssteuerungen, definiert die Zielsetzung der Untersuchung und erläutert den methodischen Aufbau der Arbeit.

Im zweiten Kapitel werden die theoretischen Grundlagen erarbeitet. Der Fokus liegt dabei auf der Sonnenbahnmechanik und der Geometrie der Verschattung. Ergänzend werden steuerbare Sonnenschutzsysteme klassifiziert sowie die relevanten normativen Rahmenbedingungen und digitalen Planungsmethoden im BIM-Kontext dargelegt.

Das dritte Kapitel befasst sich mit der Anforderungsanalyse und der methodischen Konzeption des Integrationsprozesses. Hier werden die Auswahl der Simulationsumgebung begründet, die notwendige Güte der Eingangsdaten spezifiziert und die zugrundeliegende Systemarchitektur für den Datentransfer definiert.

Die softwaretechnische Implementierung und die Validierung des Proof of Concept werden im vierten Kapitel dokumentiert. Am Beispiel des Referenzprojekts FOUR in Frankfurt am Main wird der gesamte Workflow von der Datenaufbereitung bis zur Durchführung der raycastingbasierten Simulation beschrieben und die Genauigkeit der Ergebnisse verifiziert.

Kapitel fünf widmet sich der operativen Integration der Simulationsergebnisse in die Gebäudeautomation. Dabei werden die Kommunikationsarchitektur, die notwendigen Schnittstellendefinitionen sowie die daraus resultierenden Steuerungsstrategien für die Praxis betrachtet.

Den Abschluss der Arbeit bildet das sechste Kapitel mit einer kritischen Diskussion der Ergebnisse und einem zusammenfassenden Fazit. Neben einer Analyse des wirtschaftlichen Marktpotenzials werden die Grenzen des entwickelten Prozesses aufgezeigt und ein Ausblick auf zukünftige Optimierungsmöglichkeiten gegeben.
// == 1.3 Aufbau der Arbeit

// Die vorliegende Masterarbeit ist in fünf aufeinander aufbauende Kapitel untergliedert, die den vollständigen Entwicklungsprozess – von der theoretischen Fundierung über die informationstechnische Konzeption bis hin zur softwarebasierten Validierung – detailliert nachzeichnen.

// - *Kapitel 1* führt zunächst in die Thematik ein und motiviert die Arbeit anhand der Defizite aktueller, rein winkelbasierter Verschattungssteuerungen in dicht bebauten urbanen Kontexten. Darauf aufbauend werden die konkrete Problemstellung formuliert und die primären Zielsetzungen der Arbeit definiert, insbesondere die Entwicklung einer durchgängigen, auf Open-Source-Software basierenden Prozesskette zur Integration dreidimensionaler Simulationsdaten.

// - *Kapitel 2* schafft das notwendige theoretische Fundament für diese interdisziplinäre Aufgabenstellung. Es beleuchtet zunächst die astronomischen und geometrischen Berechnungsgrundlagen der Sonnenbahn (unter Anwendung des NOAA-Algorithmus) sowie die Prinzipien der Raycasting-Verfahren. Anschließend werden die informationstechnischen Grundlagen digitaler Gebäudemodelle (BIM), relevanter Austauschformate wie IFC und CityGML sowie geodätische Koordinatenreferenzsysteme erläutert. Ein weiterer Fokus liegt auf den Verschattungssystemen der Raumautomation und den zugehörigen normativen Rahmenbedingungen, insbesondere der DIN EN 17037 und den Richtlinien der VDI 3813.

// - *Kapitel 3* widmet sich der systematischen Anforderungsanalyse und der Konzeption des Integrationsprozesses. Nach der Spezifikation der Simulationsumgebung (Blender) und der qualitativen Anforderungen an BIM- und externe Geodaten wird die Architektur der Simulationslogik entwickelt. Dabei werden Entscheidungen zur räumlichen und zeitlichen Diskretisierung sowie Algorithmen zur Performanceoptimierung und Fehlervermeidung (wie der Front-Face Check) getroffen. Abschließend wird ein modifiziertes Funktionsblock-Konzept nach VDI 3813 entworfen, das die berechneten Verschattungsdaten effizient in die Gebäudeautomation überführt.

// - *Kapitel 4* dokumentiert die softwaretechnische Implementierung und Validierung des Proof of Concepts (PoC). Als Referenzobjekt dient das hochkomplexe innerstädtische Bauprojekt „FOUR“ in Frankfurt am Main. Das Kapitel beschreibt detailliert die praktische Datenaufbereitung, einschließlich IFC-Import, Modellbereinigung, Georeferenzierung und der Zuweisung des Anlagenkennzeichnungsschlüssels (AKS). Darauf folgt die Durchführung der Python-basierten Jahresverschattungssimulation. Abgeschlossen wird das Kapitel mit einer Evaluierung des Berechnungsaufwands sowie der visuellen und algorithmischen Validierung der Ergebnisse anhand historischer Webcam-Aufnahmen.

// - *Kapitel 5* fasst die zentralen Erkenntnisse der Arbeit zusammen und ordnet diese kritisch ein. Eine Marktanalyse grenzt den entwickelten Open-Source-Ansatz von bestehenden, kommerziellen Dienstleistungslösungen ab und bewertet dessen wirtschaftliches Potenzial. Die Arbeit schließt mit einer transparenten Diskussion der aktuellen Systemgrenzen sowie einem Ausblick auf zukünftige Forschungsmöglichkeiten, wie beispielsweise der Berücksichtigung komplexer Reflexionen durch den Einsatz von Raytracing.