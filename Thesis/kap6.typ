= Diskussion und Fazit<Kap5>
== Zusammenfassung der Ergebnisse

Die vorliegende Arbeit demonstriert erfolgreich die Konzeption und praktische Umsetzung eines durchgängigen Workflows zur Integration dreidimensionaler Verschattungssimulationen in die moderne Gebäudeautomation. Obwohl das zugrunde liegende IFC-Modell des Referenzprojektes FOUR anfänglich signifikante geometrische und semantische Defizite aufwies, konnten diese durch strukturierte Aufbereitungsschritte vollständig behoben werden, sodass eine fehlerfreie Durchführung der Simulation gewährleistet wurde. Aus diesem Prozess lässt sich die maßgebliche Erkenntnis ableiten, dass spezifische Anforderungen an die Modellqualität zwingend frühzeitig im @bim#[]-Abwicklungsplan (BAP) verankert werden müssen, um zeitintensive Nachbearbeitungen in der Systemintegration zu vermeiden.

Ein zentrales Ergebnis der Arbeit ist zudem der Nachweis, dass hochkomplexe Verschattungssimulationen im dichten urbanen Kontext nicht den Einsatz teurer, proprietärer Softwarelizenzen erfordern. Insgesamt kamen im Verlauf des entwickelten Workflows 16 verschiedene Open-Source-Softwarelösungen, Plug-ins und frei verfügbare Datenquellen zum Einsatz (siehe @OpenSourceListe). Für das architektonisch äußerst anspruchsvolle Projekt FOUR beanspruchte die vollständige Berechnung eine Rechenzeit von drei Tagen und 16 Stunden. Dies stellt für eine einmalige Simulation einen absolut annehmbaren und praktikablen Bereich dar. Für konventionelle Bauprojekte mit geringerer Fassadenkomplexität, Fensteranzahl und verschattenden Gebäuden wird sich die Simulationsdauer auf einen Bruchteil dieser Zeit reduzieren.

Die generierten Simulationsergebnisse wurden abschließend erfolgreich validiert und zeichnen sich durch eine neuartige Datenstruktur aus. Durch den differenzierten Output, welcher anstelle eines rein binären Signals die Zustände Nacht, Rückseitenverschattung, Fremdverschattung sowie bei direkter Besonnung den Azimutwinkel ausgibt, wird der Systemintegration eine maximale Flexibilität eingeräumt. Um diese Daten steuerungstechnisch effizient verarbeiten zu können, wurde ein neuer Funktionsblock konzipiert, der die traditionelle Automationslogik ablöst. Das Zusammenspiel aus hochauflösender Simulation und angepasster Steuerungsarchitektur befähigt die Gebäudeautomation letztlich dazu, den komplexen normativen Spagat zwischen der Maximierung der Tageslichtversorgung, der Gewährleistung des strikten Blendschutzes und der Optimierung der Energieeffizienz gemäß den aktuellen Richtlinien nachweislich zu erfüllen.
// - obwohl das ifc-modell viele fehler hatte wurden alle probleme behoben und die simulation konnte erfolgreich durchgeführt werden
// - der differenzierte Output (N, R, V, Azimut) ist sehr hilfreich für die systemintegration, da sie maximale Flexibilität bietet
// - der entwickelte workflow erfüllt normen zur tageslichtversorgung/blendschutz und energieeffizienz 
// - simulation dauert 3 tage 16 stunden (annehmbarer Bereich) für ein sehr großes und kompliziertes projekt für das four. für üblichere kleiner projekt wird simulationsdauer ein bruchteil davon sein.
// - ergebnisse wurden erfolgreich validiert
// - es muss schon früh im @bim#[]-Abwicklungsplan (BAP) anforderungen an @bim#[]-Modell gestellt werden, um komplizierte aufbereitung zu vermeiden
// - Es wurden 12 Open Source-Software, -Plug-ins und -Datenquellen verwendet im Verlauf der Arbeit (siehe @OpenSourceListe).
//   - beweist, dass hochkomplexe Verschattungssimulationen nicht zwingend teure, proprietäre Softwarelizenzen erfordern
// - es wurde ein neuer funktionsblock beschrieben, der für die verarbeitung der Ergebnisdaten aus verschattungssimulationen konzipiert ist
// 
// == Marktanalyse und wirtschaftliches Potenzial
// === Marktbeschreibung und Marktgröße
// Ein großes Interesse an intelligenten Verschattungslösungen existiert vor allem für große, prestigeträchtige Immobilien, wie Hochhäuser (Gebäude über 60 m) in zentraler Lage. Alleine in der Stadt Frankfurt sollen bis 2040 14 davon errichtet werden @frankfurt_hep_2024_anhang2. Der Markt für umgebungsabhängige Verschattungssimulationen beschränkt sich nicht nur auf Hochhäuser. Generell profitieren Zweckgebäude mit zentraler GA und großen Fensterflächen hiervon. Vermehrt wird in Ausschreibungen eine intelligente Verschattung gefordert.
// Gebäudeeigentümer profitieren von einem erhöhten Gebäudewert durch höhere Nutzerzufriedenheit und Energieeffizienz. Aber auch Systemintegratoren profitieren von einem kostengünstigen, effizienten Prozess die Verschattungssimulation umzusetzen.

// === Marktanalyse: Abgrenzung zu Wettbewerbslösungen
// Um das wirtschaftliche und technische Potenzial des entwickelten Workflows einzuordnen, wird ein Vergleich mit dem aktuellen Status Quo am Markt angestellt. Etablierte Sonnenschutzhersteller (wie beispielsweise WAREMA) bieten die Berechnung der Jahresverschattung derzeit primär als kostenpflichtige Dienstleistung an. Die Analyse der Angebotstexte @warema_jahresverschattung_basispreis offenbart dabei signifikante prozessuale Defizite, die durch den in dieser Arbeit vorgestellten Open-Source-Ansatz gelöst werden:

// - *Medienbrüche und manuelle Datenaufbereitung:* Kommerzielle Dienstleister fordern häufig proprietäre CAD-Formate (wie Revit oder DWG) mit strikten Dateigrößenlimits (z. B. 250 MB). Zudem muss der Fachplaner das Modell manuell bereinigen (Entfernung von Innenwänden und Inventar), bevor es übermittelt wird. Der entwickelte IFC-basierte Workflow liest die relevanten Entitäten (`IfcWindow`, `IfcCurtainWall`) hingegen automatisiert und standardisiert aus dem Open@bim#[]-Modell aus und ist nicht auf eine Dateigröße begrenzt.

// - *Integration von Umgebungsdaten:* Umgebungsdaten müssen bei konventionellen Dienstleistern manuell im 3D-Modell erstellt werden. Fehlen in den übermittelten CAD-Plänen detaillierte Höhenangaben zur Nachbarbebauung, müssen diese kostenpflichtig nachvermessen werden. Der hier vorgestellte Prozess integriert stattdessen frei verfügbare CityGML-Daten direkt in die Blender-Umgebung.

// - *Kostenstruktur und räumliche Granularität:* Das Preismodell kommerzieller Anbieter basiert in der Regel auf der Anzahl der zu berechnenden Verschattungszonen. Um Kosten zu sparen, werden in der Praxis oft große Fassadenbereiche zu einer Zone zusammengefasst, was zu Lasten der Tageslichtautonomie geht. Die Iteration über alle Fenster in der Simulation verursacht außer einer erhöhten Rechendauer keinen Zusatzaufwand, wodurch eine fenstergenaue Simulation auch bei Großprojekten umsetzbar ist.

// - *Herstellerunabhängigkeit:* Während Herstellerlösungen die errechneten Schattenverläufe meist über firmeneigene Software in herstellerspezifische Controller laden, ist der Output dieses Proof of Concepts (CSV/JSON) systemunabhängig. Die Verschattungsdaten können...
// // auf Standard-BACnet-Objekte gemappt und von Automationsstationen beliebiger Fabrikate verarbeitet werden.)))

// Zusammenfassend transformiert der entwickelte Workflow die Jahresverschattung von einer manuellen, fehleranfälligen und ungenauen Dienstleistung hin zu einem transparenten und skalierbaren Engineering-Prozess.

== Grenzen des entwickelten Prozesses
Trotz der erfolgreichen Validierung und des nachgewiesenen Mehrwerts unterliegt der entwickelte Workflow verschiedenen methodischen, datentechnischen und physikalischen Limitationen. Eine wesentliche Herausforderung stellt die mangelnde Automatisierbarkeit des Gesamtprozesses dar. Da jedes Bauprojekt stark individuelle Rahmenbedingungen aufweist -- etwa hinsichtlich der topografischen Gegebenheiten oder der Verfügbarkeit hochauflösender Umgebungsdaten --, bedarf es stets einer manuellen Anpassung der Simulationsumgebung. Dieser Umstand geht mit einem personellen und zeitlichen Aufwand einher. Zudem setzt die erfolgreiche Durchführung fundierte Kompetenzen im Umgang mit der 3D-Software Blender voraus, welche im klassischen Berufsbild der Systemintegration bislang kaum verankert sind.

Eng verknüpft mit dem manuellen Aufwand ist die starke Abhängigkeit von der Qualität der Eingangsdaten. Sowohl die architektonischen IFC-Modelle als auch die städtischen Umgebungsdaten liegen in der Praxis in stark variierender Detaillierung und semantischer Güte vor. Darüber hinaus bildet das genutzte 3D-Modell lediglich einen statischen Ist-Zustand ab. Zukünftige städtebauliche Veränderungen, wie beispielsweise die Errichtung neuer Nachbarbebauungen, werden nicht automatisch erfasst. Solche Modifikationen im Lebenszyklus des Gebäudes erfordern eine manuelle Ergänzung des Modells sowie eine erneute, rechenintensive Durchführung der gesamten Verschattungssimulation.

Auf bauphysikalischer Ebene weist der gewählte Raycasting-Ansatz ebenfalls spezifische Grenzen auf. Da die Methode primär auf direkten geometrischen Sichtlinien basiert, werden Blendwirkungen, die durch spiegelnde Reflexionen an gegenüberliegenden Glasfassaden entstehen, nicht detektiert. Ebenso besteht die methodische Unschärfe, dass Sonnenlicht in der Realität durch transparente Gebäudekanten oder verglaste Vorbauten fallen kann, was in der binären Kollisionsabfrage der Modellgeometrie als undurchlässiger Schattenwurf interpretiert wird.

(Schließlich findet die zeitlich hochauflösende Präzision der digitalen Simulation ihre Grenze in der mechanischen Realität der Anlagensteuerung. Obwohl der Algorithmus sehr exakte Verschattungsübergänge liefert, wird die nachgelagerte Jalousiesteuerung diese nicht 1 zu 1 in Fahrbefehle umsetzen. Um die Elektromotoren vor übermäßigem Verschleiß durch zu häufiges Takten zu schützen und die Gebäudenutzer nicht durch permanente motorische Betriebsgeräusche oder visuelle Unruhe abzulenken, müssen in der Gebäudeautomation zwingend Totzeiten und Hysteresen programmiert werden. Diese notwendige mechanische Trägheit dämpft den theoretischen Detailgrad der Simulationsdaten im operativen Betrieb zwangsläufig ab und führt zu einer verminderten Tageslichtausbeute.) - neu schreiben
// == Grenzen des entwickelten Prozesses...
// - es ist schwierig den prozess der verschattungssimulation zu automatisieren, da jedes Projekt unterschiedlich ist (Topografie Ja/Nein, Gute Umgebungsdaten vorhanden Ja/Nein etc.)
// - umgebungsdaten und ifc-modelle liegen in unterschiedlicher qualität vor
// - blendungen durch spiegelung werden nicht detektiert 
// - Problem dass Licht auch durch transparente Gebäudekanten gehen kann
// - um diesen prozess durchzuführen, müssen kompetenzen in blender vorhanden sein
// - es ist immer noch aufwendig. 
// - zukünftige Nachbarbebauungen müssen manuell ergänzt werden und die simulation neu durchgeführt wreden
// - Simulation liefert sehr exakte werte. Die jalousiesteuerung wird allerdings hysteresen beinhalten, um motoren zu schonen und nutzer nicht durch motorengeräusche und fahrbewegungen abzulenken.

== Ausblick
Basierend auf den Erkenntnissen und identifizierten Grenzen der vorliegenden Arbeit ergeben sich vielfältige Anknüpfungspunkte für zukünftige Forschungs- und Entwicklungsbemühungen. Ein essenzieller nächster Schritt besteht in der detaillierten Beschreibung und praktischen Erprobung der exakten Datenintegration in die Gebäudeautomation. Die theoretisch konzipierte Verschattungssteuerung muss an physischen Automationsstationen unter realen Bedingungen validiert werden, um das Zusammenspiel der generierten multimodalen Datensätze mit der realen Aktorik und den notwendigen Hysteresen abschließend zu bewerten.

Parallel dazu bietet die Erweiterung des räumlichen und meteorologischen Kontextes großes Optimierungspotenzial. Zukünftige Iterationen des Workflows sollten die systematische Integration von Topografiedaten untersuchen, um festzustellen, welche Geodatensätze hierfür am besten geeignet sind und wie diese in die 3D-Umgebung eingebunden werden können. Eine Verschmelzung der Verschattungsdaten mit prädiktiven Echtzeitinformationen, beispielsweise durch die Anbindung von Wetter-APIs oder lokalen Wolkenkameras, würde zudem den Übergang zu einer echten vorausschauenden Regelung ermöglichen.

Um bauphysikalische Phänomene wie komplexe Spiegelungen an Nachbarfassaden abbilden zu können, ist die Evaluation von echten Raytracing-Verfahren geboten. Es müsste untersucht werden, welche Möglichkeiten zur Vorbereitung der 3D-Szene benötigt wären. Da der hierfür benötigte Rechenaufwand um ein Vielfaches höher ist als bei dem angewandten Raycasting, ließe sich dies operativ durch eine parallel zum Gebäudebetrieb laufende Berechnung lösen. In einem solchen Szenario würde das System beispielsweise in den lastarmen Nachtstunden iterativ die exakten optischen Bedingungen für den jeweils darauffolgenden Tag berechnen.

Aus einer wirtschaftlichen  Perspektive empfiehlt sich die Entwicklung eines standardisierten Evaluierungswerkzeugs, etwa in Form einer parametrisierten Excel-Tabelle. Diese könnte die semantische und geometrische Qualität vorliegender IFC-Modelle systematisch bewerten und daraus den zu erwartenden Arbeitsaufwand für die Modellaufbereitung kalkulieren. Ein solches Instrument würde Systemintegratoren in der Angebotsphase eine belastbare Entscheidungsgrundlage zur Kostenkalkulation bieten.

Zu guter Letzt kann der Gesamtprozess durch eine bessere Aufgabenverteilung optimiert werden. Architekturbüros führen für Normen wie die DIN EN 17037 oder für Präsentationszwecke ohnehin häufig detaillierte 3D-Simulationen durch. Es ist daher sinnvoll, schon im BIM-Abwicklungsplan festzulegen, dass die Architekten die 3D-Szene oder sogar die Verschattungsdaten direkt als Vorleistung bereitstellen. Das erspart der Systemintegration eine eigene, zeitintensive Simulation und verhindert effektiv, dass Arbeitsschritte im Projekt doppelt ausgeführt werden.


... wäre auch interessant hier noch zu berechnen, wieviel energie (Beleuchtung, kühlung etc.) gespart werden kann mit jahresverschattung?
// == Ausblick...
// - die genaue Integration der Daten in die GA mit der eigentlichen Verschattungssteuerung beschreiben
// - Topographie mit berücksichtigen: welche datensätze stehen zur Verfügung; wie bindet man sie am besten ein
// - Raytracing probieren - Um spiegelungen mit zu berücksichtigen
//   - Da der Rechenaufwand um ein vielfaches höher ist, müsste hier die Simulation wahrscheinlich parallel zum Betrieb laufen und es wird immer nur der nächste Tag berechnet
// - Man könnte eine Exceltabelle entwickeln, die die vorliegenden IFC-Daten bewertet und daraus den zusätzlichen Arbeitsaufwand für die Aufbereitung berechnet. Dies könnte für die Angebotserstellung als Entscheidungsgrundlage herangezogen werden.
// - da architekten bereits simulationen machen für DIN 17037, marketing etc. wäre es vlt. auch möglich den architekten mit der vorleistung zur bereitstellung dieser daten zu beauftragen.
// - Integration von Wetterdaten oder lokalen wolkenkameras

