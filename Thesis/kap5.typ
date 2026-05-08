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
== Marktanalyse und wirtschaftliches Potenzial
=== Marktbeschreibung und Marktgröße
Ein großes Interesse an intelligenten Verschattungslösungen existiert vor allem für große, prestigeträchtige Immobilien, wie Hochhäuser in zentraler Lage. Alleine in der Stadt Frankfurt sollen bis 2040 14 Hochhäuser (Gebäude über 60m) errichtet werden@frankfurt_hep_2024_anhang2. Der Markt für umgebungsabhängige Verschattungssimulationen beschränkt sich nicht nur auf Hochhäuser. Generell profitieren Zweckgebäude mit zentraler GA und großen Fensterflächen hiervon. Vermehrt wird in Ausschreibungen eine intelligente Verschattung gefordert.
Gebäudeeigentümer profitieren von einem erhöhten Gebäudewert durch höhere Nutzerzufriedenheit und Energieeffizienz. Aber auch Systemintegratoren profitieren von einem kostengünstigen, effizienten Prozess die Verschattungssimulation umzusetzen.

=== Marktanalyse: Abgrenzung zu Wettbewerbslösungen
Um das wirtschaftliche und technische Potenzial des entwickelten Workflows einzuordnen, wird ein Vergleich mit dem aktuellen Status Quo am Markt angestellt. Etablierte Sonnenschutzhersteller (wie beispielsweise WAREMA) bieten die Berechnung der Jahresverschattung derzeit primär als kostenpflichtige Dienstleistung an. Die Analyse der Angebotstexte@warema_jahresverschattung_basispreis offenbart dabei signifikante prozessuale Defizite, die durch den in dieser Arbeit vorgestellten Open-Source-Ansatz gelöst werden:

- *Medienbrüche und manuelle Datenaufbereitung:* Kommerzielle Dienstleister fordern häufig proprietäre CAD-Formate (wie Revit oder DWG) mit strikten Dateigrößenlimits (z. B. 250 MB). Zudem muss der Fachplaner das Modell manuell bereinigen (Entfernung von Innenwänden und Inventar), bevor es übermittelt wird. Der entwickelte IFC-basierte Workflow liest die relevanten Entitäten (`IfcWindow`, `IfcCurtainWall`) hingegen automatisiert und standardisiert aus dem Open@bim#[]-Modell aus und ist nicht auf eine Dateigröße begrenzt.

- *Integration von Umgebungsdaten:* Umgebungsdaten müssen bei konventionellen Dienstleistern manuell im 3D-Modell erstellt werden. Fehlen in den übermittelten CAD-Plänen detaillierte Höhenangaben zur Nachbarbebauung, müssen diese kostenpflichtig nachvermessen werden. Der hier vorgestellte Prozess integriert stattdessen frei verfügbare CityGML-Daten direkt in die Blender-Umgebung.

- *Kostenstruktur und räumliche Granularität:* Das Preismodell kommerzieller Anbieter basiert in der Regel auf der Anzahl der zu berechnenden Verschattungszonen. Um Kosten zu sparen, werden in der Praxis oft große Fassadenbereiche zu einer Zone zusammengefasst, was zu Lasten der Tageslichtautonomie geht. Die Iteration über alle Fenster in der Simulation verursacht außer einer erhöhten Rechendauer keinen Zusatzaufwand, wodurch eine fenstergenaue Simulation auch bei Großprojekten umsetzbar ist.

- *Herstellerunabhängigkeit:* Während Herstellerlösungen die errechneten Schattenverläufe meist über firmeneigene Software in herstellerspezifische Controller laden, ist der Output dieses Proof of Concepts (CSV/JSON) systemunabhängig. Die Verschattungsdaten können...
// auf Standard-BACnet-Objekte gemappt und von Automationsstationen beliebiger Fabrikate verarbeitet werden.)))

Zusammenfassend transformiert der entwickelte Workflow die Jahresverschattung von einer manuellen, fehleranfälligen und ungenauen Dienstleistung hin zu einem transparenten und skalierbaren Engineering-Prozess.

=== Marktpotenzialanalyse (entfällt)
== Grenzen des entwickelten Prozesses
Trotz der erfolgreichen Validierung und des nachgewiesenen Mehrwerts unterliegt der entwickelte Workflow verschiedenen methodischen, datentechnischen und physikalischen Limitationen. Eine wesentliche Herausforderung stellt die mangelnde Automatisierbarkeit des Gesamtprozesses dar. Da jedes Bauprojekt stark individuelle Rahmenbedingungen aufweist -- etwa hinsichtlich der topografischen Gegebenheiten oder der Verfügbarkeit hochauflösender Umgebungsdaten --, bedarf es stets einer manuellen Anpassung der Simulationsumgebung. Dieser Umstand geht mit einem personellen und zeitlichen Aufwand einher. Zudem setzt die erfolgreiche Durchführung fundierte Kompetenzen im Umgang mit der 3D-Software Blender voraus, welche im klassischen Berufsbild der Systemintegration bislang kaum verankert sind.

Eng verknüpft mit dem manuellen Aufwand ist die starke Abhängigkeit von der Qualität der Eingangsdaten. Sowohl die architektonischen IFC-Modelle als auch die städtischen Umgebungsdaten liegen in der Praxis in stark variierender Detaillierung und semantischer Güte vor. Darüber hinaus bildet das genutzte 3D-Modell lediglich einen statischen Ist-Zustand ab. Zukünftige städtebauliche Veränderungen, wie beispielsweise die Errichtung neuer Nachbarbebauungen, werden nicht automatisch erfasst. Solche Modifikationen im Lebenszyklus des Gebäudes erfordern eine manuelle Ergänzung des Modells sowie eine erneute, rechenintensive Durchführung der gesamten Verschattungssimulation.

Auf bauphysikalischer Ebene weist der gewählte Raycasting-Ansatz ebenfalls spezifische Grenzen auf. Da die Methode primär auf direkten geometrischen Sichtlinien basiert, werden Blendwirkungen, die durch spiegelnde Reflexionen an gegenüberliegenden Glasfassaden entstehen, nicht detektiert. Ebenso besteht die methodische Unschärfe, dass Sonnenlicht in der Realität durch transparente Gebäudekanten oder verglaste Vorbauten fallen kann, was in der binären Kollisionsabfrage der Modellgeometrie als undurchlässiger Schattenwurf interpretiert wird.

*Schließlich findet die zeitlich hochauflösende Präzision der digitalen Simulation ihre Grenze in der mechanischen Realität der Anlagensteuerung. Obwohl der Algorithmus sehr exakte Verschattungsübergänge liefert, wird die nachgelagerte Jalousiesteuerung diese nicht 1 zu 1 in Fahrbefehle umsetzen. Um die Elektromotoren vor übermäßigem Verschleiß durch zu häufiges Takten zu schützen und die Gebäudenutzer nicht durch permanente motorische Betriebsgeräusche oder visuelle Unruhe abzulenken, müssen in der Gebäudeautomation zwingend Totzeiten und Hysteresen programmiert werden. Diese notwendige mechanische Trägheit dämpft den theoretischen Detailgrad der Simulationsdaten im operativen Betrieb zwangsläufig ab und führt zu einer verminderten Tageslichtausbeute.*
// == Grenzen des entwickelten Prozesses...
// - es ist schwierig den prozess der verschattungssimulation zu automatisieren, da jedes Projekt unterschiedlich ist (Topografie Ja/Nein, Gute Umgebungsdaten vorhanden Ja/Nein etc.)
// - umgebungsdaten und ifc-modelle liegen in unterschiedlicher qualität vor
// - blendungen durch spiegelung werden nicht detektiert 
// - Problem dass Licht auch durch transparente Gebäudekanten gehen kann
// - um diesen prozess durchzuführen, müssen kompetenzen in blender vorhanden sein
// - es ist immer noch aufwendig. 
// - zukünftige Nachbarbebauungen müssen manuell ergänzt werden und die simulation neu durchgeführt wreden
// - Simulation liefert sehr exakte werte. Die jalousiesteuerung wird allerdings hysteresen beinhalten, um motoren zu schonen und nutzer nicht durch motorengeräusche und fahrbewegungen abzulenken.

== Ausblick...
- Topographie berücksichtigen
- Raytracing probieren - Um spiegelungen mit zu berücksichtigen
  - Da der Rechenaufwand um ein vielfaches höher ist, müsste hier die wahrscheinlich parallel zum Betrieb laufen und es wird immer nur der nächste Tag berechnet
- Man könnte eine Exceltabelle entwickeln, die die vorliegenden IFC-Daten bewertet und daraus einen zusätzlichen Arbeitsaufwand berechnet. Dies könnte für die Angebotserstellung als Entscheidungsgrundlage herangezogen werden.
- da architekten bereits simulationen machen für 17037, marketing etc. wäre es vlt. auch möglich den architekten mit der vorleistung zur bereitstellung dieser daten zu beauftragen.

