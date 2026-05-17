= Einleitung<Kap1>
== Problemstellung
Die Integration dynamischer Verschattungssimulationen in die Gebäudeautomation gewinnt aufgrund steigender Energiekosten und wachsender Ansprüche an den thermischen sowie visuellen Nutzerkomfort zunehmend an Bedeutung. Da die künstliche Beleuchtung in reinen Bürogebäuden bis zu 50 Prozent der Stromkosten ausmacht @michelau_effiziente_beleuchtung, ist eine maximale Ausnutzung des Tageslichts geboten. Eine hocheffiziente Verschattungssteuerung erfordert daher präzise Daten über den lokalen Schattenwurf. Nur so lässt sich die Tageslichtautonomie von Gebäuden maximieren, während gleichzeitig Kühllasten und Blendeffekte minimiert werden.

In der aktuellen Praxis der Gebäudeautomation stellt jedoch die informationstechnische und planungsseitige Umsetzung solcher Systeme eine erhebliche Herausforderung dar. Die konventionelle Parametrierung von Sonnenschutzsteuerungen erfolgt in der Regel noch über die manuelle Eingabe statischer Grenzwinkel in die Automationsstation. Dieser Ansatz bedingt oftmals eine stark konservative Parametrierung und führt in komplexen urbanen Umgebungen unweigerlich zu einer suboptimalen Anlagenregelung, da die reale Fremdverschattung durch Nachbargebäude oder Topografie nur unzureichend abgebildet wird.

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

Darauf aufbauend erfolgt die Entwicklung und softwaretechnische Implementierung eines @poc anhand eines hochkomplexen Referenzprojekts. Innerhalb dieses @poc werden die optimalen Parameter für die räumliche und zeitliche Diskretisierung der Verschattungssimulation untersucht. Es gilt, das ideale Verhältnis zwischen Rechenaufwand, generiertem Datenvolumen und der Qualität der Steuerungsdaten zu identifizieren. Resultierend daraus wird die optimale informationstechnische Struktur für den Datenoutput festgelegt.

Den Abschluss bildet die konzeptionelle Integration der Simulationsergebnisse in die normative Logik der Gebäudeautomation. Hierfür wird ein modifizierter Funktionsblock für die Verschattungskorrektur in Anlehnung an die Richtlinie VDI 3813 entwickelt. Dieser Entwurf soll demonstrieren, wie die konventionelle, rein winkelbasierte Regelungslogik der Raumautomation durch eine datengetriebene Architektur effizient ersetzt werden kann.

== Wirtschaftliches Potenzial und Marktabgrenzung

Die wirtschaftliche und ökologische Relevanz intelligenter Verschattungslösungen zeigt sich insbesondere bei großen, prestigeträchtigen Immobilien in zentraler Lage. 
// Da diese oft eine hohe verglaste Fläche aufweisen. 
Exemplarisch verdeutlicht dies die Stadt Frankfurt am Main, in der bis zum Jahr 2040 die Errichtung von 14 neuen Hochhäusern mit einer Höhe von über 60 Metern geplant ist~@frankfurt_hep_2024_anhang2. Das Marktpotenzial für umgebungsabhängige Verschattungssimulationen beschränkt sich jedoch nicht auf Hochhäuser. Generell profitieren sämtliche Zweckgebäude mit großen Fensterflächen und einer zentralen Gebäudeautomation von diesen Technologien. In aktuellen Ausschreibungen wird eine prädiktive und intelligente Verschattung zunehmend als Standard gefordert. Gebäudeeigentümer verzeichnen dadurch einen erhöhten Gebäudewert, der aus einer gesteigerten Energieeffizienz und Nutzerzufriedenheit resultiert. Gleichzeitig profitieren Systemintegratoren von dem in dieser Arbeit angestrebten Prozess, da er eine kostengünstigere und effizientere Umsetzung der Verschattungssimulation ermöglicht.

Um das technische Potenzial des hier konzipierten Workflows einzuordnen, ist ein Abgleich mit dem Status quo am Markt sinnvoll. Etablierte Sonnenschutzhersteller, wie beispielsweise WAREMA, bieten die Berechnung der Jahresverschattung derzeit primär als kostenpflichtige Dienstleistung an. Eine Analyse gängiger Angebotstexte @warema_jahresverschattung_basispreis offenbart dabei signifikante prozessuale Defizite, welche durch den in dieser Arbeit fokussierten Open-Source-Ansatz gelöst werden sollen:

- Medienbrüche und manuelle Datenaufbereitung: Kommerzielle Dienstleister fordern häufig proprietäre CAD-Formate (wie Revit oder DWG) mit strikten Dateigrößenlimits von beispielsweise 250 Megabyte. Ein durchgängiger, IFC-basierter Workflow zielt hingegen darauf ab, relevante Entitäten wie `IfcWindow` oder `IfcCurtainWall` automatisiert aus dem Open@bim#[]-Modell auszulesen, ohne durch Dateigrößen limitiert zu sein.

- Integration von Umgebungsdaten: Bei konventionellen Dienstleistern muss die Umgebung häufig manuell im 3D-Modell nachgebaut werden. Fehlen in den übermittelten CAD-Plänen detaillierte Höhenangaben zur Nachbarbebauung, resultiert dies in kostenpflichtigen Nachvermessungen. Der hier vorgestellte Prozess setzt stattdessen auf die direkte Integration frei verfügbarer CityGML- beziehungsweise CityJSON-Daten in die Simulationsumgebung.

- Kostenstruktur und räumliche Granularität: Das Preismodell kommerzieller Anbieter basiert in der Regel auf der Anzahl der zu berechnenden Verschattungszonen. Aus wirtschaftlichen Gründen werden in der Praxis daher oft große Fassadenbereiche zu einer einzigen Zone zusammengefasst, was ebenfalls zu konservativen Annahmen auf Kosten der Tageslichtautonomie führt. Ein softwaregestützter Eigenbauansatz eliminiert diese Restriktion: Die Iteration über alle Fenster des Gebäudes verursacht eine höhere Rechenzeit, jedoch keine personellen Zusatzkosten, wodurch eine fenstergenaue Simulation auch bei Großprojekten realisierbar wird.

- Herstellerunabhängigkeit: Während kommerzielle Herstellerlösungen die errechneten Schattenverläufe meist über firmeneigene Software in herstellerspezifische Controller laden, ist der Output des hier konzipierten @poc herstellerneutral. Die generierten Verschattungsdaten werden in einem offenen Format (CSV) bereitgestellt und können über standardisierte Schnittstellen in beliebige Automationsstationen integriert werden.

Zusammenfassend motivieren diese Marktbeschränkungen die Zielsetzung der vorliegenden Arbeit. Der angestrebte Workflow soll die Ermittlung der Jahresverschattung von einer manuellen, fehleranfälligen und oft proprietären Dienstleistung in einen transparenten, skalierbaren und herstellerunabhängigen Engineering-Prozess überführen.

== Aufbau der Arbeit

Die vorliegende Arbeit gliedert sich in fünf aufeinander aufbauende Kapitel, die den Entwicklungsprozess systematisch von der theoretischen Fundierung bis zur praktischen Integration abbilden.

Das erste Kapitel dient der Einführung in die Thematik. Es skizziert die Problemstellung im Kontext konventioneller Verschattungssteuerungen, definiert die Zielsetzung der Untersuchung, analysiert das wirtschaftliche Potenzial sowie die Marktabgrenzung und erläutert den methodischen Aufbau der Arbeit.

Im zweiten Kapitel werden die theoretischen Grundlagen erarbeitet. Der inhaltliche Fokus liegt dabei auf der Sonnenbahnmechanik und der Geometrie der Verschattung. Ergänzend werden steuerbare Sonnenschutzsysteme klassifiziert sowie die relevanten normativen Rahmenbedingungen und digitalen Planungsmethoden im BIM-Kontext dargelegt.

Das dritte Kapitel befasst sich mit der Anforderungsanalyse und der methodischen Konzeption des Integrationsprozesses. In diesem Teil wird die Auswahl der Simulationsumgebung begründet und die notwendige Güte der Eingangsdaten spezifiziert. Darauf aufbauend wird die zugrunde liegende Systemarchitektur für die Simulationslogik definiert und ein Integrationskonzept für die Gebäudeautomation entworfen.

Die softwaretechnische Implementierung des Proof of Concept wird im vierten Kapitel dokumentiert. Am Beispiel des Referenzprojekts FOUR in Frankfurt am Main wird der gesamte Workflow von der Datenaufbereitung über den Modellaufbau bis zur Durchführung der raycastingbasierten Simulation beschrieben und die Genauigkeit der Ergebnisse validiert.

Den Abschluss der Arbeit bildet das fünfte Kapitel mit einer kritischen Diskussion der Ergebnisse und einem zusammenfassenden Fazit. Neben der Zusammenfassung der Erkenntnisse werden die Grenzen des entwickelten Prozesses aufgezeigt und ein Ausblick auf zukünftige Optimierungsmöglichkeiten gegeben.