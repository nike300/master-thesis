= Anforderungsanalyse und Konzeption des Integrationsprozesses <Kap3>
Ziel dieses Kapitels ist es, einen methodischen Ansatz aufzuzeigen, wie unter dem ausschließlichen Einsatz von Open-Source-Software und frei verfügbaren Datensätzen eine präzise Verschattungssimulation realisiert werden kann. Hierfür wird im Folgenden zunächst die Auswahl einer geeigneten Simulationsumgebung begründet. Anschließend erfolgt die Spezifikation der notwendigen Datengrundlage, bestehend aus der @bim#[]-Datengüte und externen Geodaten. Darauf aufbauend werden die räumlichen und zeitlichen Auflösungen festgelegt sowie die informationstechnische Konzeption der Simulationslogik definiert. Den Abschluss bildet der Entwurf der Systemarchitektur, in welcher die generierten Daten über einen modifizierten Funktionsblock nach VDI 3813 in die @ga integriert werden. 

== Analyse der Ausgangssituation und Zieldefinition <AnalyseAusgangssituation>

In der aktuellen Praxis der @ga weist die konventionelle Einbindung von Verschattungsdaten signifikante Defizite auf. Die automatisierte Sonnenschutzsteuerung stützt sich im Regelfall primär auf meteorologische Echtzeitdaten, die über globale Helligkeits- und Strahlungssensoren auf dem Gebäudedach erfasst werden. Eine differenzierte Berücksichtigung von Fremdverschattungen, beispielsweise durch umliegende Bebauung oder topografische Gegebenheiten, findet über diese rein messwertbasierten Systeme standardmäßig nicht statt. Um temporäre Schattenwürfe dennoch abzubilden, wird in erweiterten Steuerungsansätzen vereinzelt mit statischen Grenzwinkeln gearbeitet. Dabei werden geometrische Verschattungsgrenzen für einzelne Fenster, Fenstergruppen oder ganze Fassadenabschnitte manuell ermittelt und als feste Parameter in der Jalousiesteuerung der @ga#[]-Software hinterlegt (siehe @fig-jalousiesteuerung). Aufgrund des immensen Engineering-Aufwands kommt dieses Verfahren in der Praxis jedoch nur selten zum Einsatz. Zudem erfolgt die Definition dieser Grenzwinkel meist nur approximativ und erfordert fehleranfällige, empirische Korrekturen im laufenden Betrieb.

Im operativen Betrieb berechnet die @as fortlaufend den aktuellen Sonnenstand und gleicht diesen mit den definierten Grenzwinkeln ab. Auf Basis dieses Abgleichs entscheidet die Logik, ob der entsprechende Punkt zum gegebenen Zeitpunkt verschattet ist oder direkter Sonneneinstrahlung ausgesetzt sein kann.

#figure(
  image("assets/JalousiesteuerungAlt.png", width: 100%),
  caption: [Screenshot der Parametereingabe für eine winkelbasierte Jalousiesteuerung in der @ebo #[]@se_ebo.],
  placement: auto
) <fig-jalousiesteuerung>

Dieser Ansatz zwingt die Systemintegration jedoch zu pauschalen Annahmen. Da ein einzelner Referenzpunkt in der Regel stellvertretend für größere Fassadenbereiche genutzt wird, muss der Sonnenschutz geschlossen werden, sobald auch nur ein Teilbereich der Zone potenziell besonnt ist. Eine hohe räumliche Genauigkeit und damit eine optimale Tageslichtnutzung ist mit dieser statischen Zonenbildung kaum realisierbar.

Für Gebäude mit einfacher architektonischer Geometrie und einer weitläufigen, wenig verbauten Umgebung bietet diese winkelbasierte Methode eine funktionale und ausreichende Lösung. Sobald jedoch Bauwerke mit komplexen Fassadenstrukturen in dichten urbanen Kontexten betrachtet werden, stößt dieser Ansatz an seine technischen Grenzen und erfordert eine dreidimensionale Betrachtungsweise.

Verschattungssimulationen basierend auf 3D-Daten halten heutzutage zunehmend Einzug in die @ga. Erste Hersteller, wie beispielsweise Warema oder Sauter, bieten die Berechnung der Jahresverschattung bereits als Dienstleistung an. Aufgrund ihres Mehrwerts für die Tageslichtautonomie und Energieeffizienz wird die Integration derartiger Daten in zukünftigen Bauprojekten vermehrt gefordert werden.

== Spezifikation der Werkzeuge und Datengrundlage
=== Auswahl der Simulationsumgebung <AuswahlSimulationsumgebung>
In der Simulationsumgebung findet die Zusammenstellung der Szene statt. Es muss eine Software gewählt werden, die den Import verschiedener 3D-Dateiformate zulässt. Zusätzlich sollte diese Software den Sonnenstand simulieren können und eine Möglichkeit bieten Raycasts zu generieren. Schlussendlich muss es möglich sein, Skripte einzubinden, um komplexe Algorithmen auszuführen.
Die Wahl fällt auf die kostenlose Open-Source-Software Blender, die für die Erstellung von Animationsfilmen entwickelt wurde~@blender_org. Sie bietet in der jetzigen Version eine Vielzahl von Funktionalitäten, darunter auch jene zur Erfüllung der oben genannten Anforderungen. Außerdem bietet sie den Vorteil einer großen, aktiven Community, die eine Vielzahl an kostenlosen und kostenpflichtigen Plug-Ins entwickelt. Für diese Anwendung passende Alternativen standen nicht zur Auswahl.

=== Anforderungen an das BIM-Modell <AnforderungBIM>
Um einen fehlerfreie und automatisierte Verschattungssimulation zu gewährleisten, muss das zugrundeliegende @bim#[]-Modell spezifische geometrische und semantische Anforderungen erfüllen. Eine Untersuchung typischer @ifc#[]-Exporte offenbart häufige Defizite, die für eine valide Verschattungssimulation zwingend im Vorfeld korrigiert oder bereits durch klare Modellierungsrichtlinien im @bap definiert werden müssen:

*Datenreduktion:* Um die Dateigröße und die Berechnungszeiten beim Import in die 3D-Software zu minimieren, muss das @ifc#[]-Modell um nicht-relevante Architekturdetails bereinigt werden. Für die geometrische Verschattungssimulation sind ausschließlich die Elemente der Gebäudehülle (Fassaden, Fenster) sowie potenziell eigenverschattende Bauteile (Balkone, Erker, Laibungen) erforderlich. Innenwände oder Inventar sind vor allem bei großen Gebäuden zwingend auszuschließen. Meist liegt das Gebäude bereits als Fassadenteilmodell vor.

*Semantische Klassifizierung (@ifc#[]-Klassen):* Die Fensterobjekte sollten als `IfcWindow` deklariert sein, damit das Python-Skript sie automatisiert extrahieren kann. Eine häufige Fehlerquelle bei CAD-Exporten (z. B. aus Autodesk Revit) ist die Fehlklassifizierung von schrägen Fenstern oder Dachflächenfenstern als generische Bauteile (oft `IfcBuildingElementProxy` oder `IfcRoof`), was eine korrekte Filterung erschwert.

*Detaillierungsgrad (@lod):* Für eine aussagekräftige Simulation der Gebäudehülle ist ein minimaler geometrischer Detaillierungsgrad zwingend erforderlich.  Um den kritischen Effekt der Eigenverschattung (bspw. durch tiefe Fensterlaibungen, Stürze oder auskragende Fassadenelemente) physikalisch korrekt per Raycasting berechnen zu können, müssen die entsprechenden Bauteile mindestens im @lod 300 vorliegen.

*Georeferenzierung und Ausrichtung:* Eine zentimetergenaue Überlagerung des Gebäudemodells mit den externen Gebäude-Umgebungsdaten (siehe @kap-ImportUmgebungsdaten) erfordert eine exakte Verortung. Das Gebäude muss auf der korrekten absoluten Z-Höhe modelliert und geografisch nach dem Wahren Norden ausgerichtet sein. Hierfür sollten die exakten Koordinaten des Projekt-Referenzpunktes unter der Entität `IfcSite` im globalen Referenzsystem WGS84 vorliegen~@buildingsmart_ifcsite.

*@bks:* Um die berechneten Verschattungsdaten nach der Simulation fehlerfrei an die @ga zu übergeben, sollte jedes Fensterobjekt mit einem eindeutigen @aks nach VDI 3814 Blatt 4.1~@vdi3814_4.1 versehen sein. Dieses Kennzeichnungssystem sollte konsequent nach dem hierarchischen Schalenmodell der VDI 3814-1 aufgebaut sein @vdi3814-1. Die Adressierung muss hier bis auf die unterste Betriebsmitttelebene -- also das individuelle Fenster beziehungsweise den zugehörigen Aktor -- heruntergebrochen werden. Nur durch diese hohe Granularität des @bks ist ein direktes und automatisiertes Mapping der fensterspezifischen Simulationsdaten in der @as möglich.

*Etagenweise Zuordnung:* Für die spätere Übersichtlichkeit im Modell sollten die Fensterelemente im @ifc#[]-Strukturbaum dem jeweiligen Geschoss (`IfcBuildingStorey`) korrekt zugeordnet sein.

In der Planungspraxis werden diese strukturellen und semantischen Anforderungen an die IFC-Datenqualität oftmals nicht vollumfänglich erfüllt. Dies erzwingt in der Konsequenz eine manuelle und ressourcenintensive Bearbeitung des Gebäudemodells vor dem eigentlichen Simulationsstart.

Um diesen Aufwand zu minimieren, sollten frühzeitig Synergieeffekte im integralen Planungsprozess geprüft werden. Insbesondere bei innerstädtischen Groß- und Hochhausprojekten erstellen Architekturbüros für Genehmigungsverfahren oder Marketingzwecke häufig eigene Sonnenstudien. Die hierfür bereits aggregierten digitalen Stadtmodelle stellen eine wertvolle Datenquelle dar. Deren Nachnutzung für den Workflow der Verschattungssimulation kann eine erneute Modellierung oder externe Datenbeschaffung obsolet machen.

// OPTIONAL: HIER AUF CHECKLISTE IM ANHANG VERWEISEN FÜR ARCHITEKTEN

=== Externe Geodaten und Georeferenzierung<kap-externeDaten>
Die Datenqualität der umgebenden Gebäude, Topografie und Vegetation bestimmt die Genauigkeit der Verschattungssimulation maßgeblich. Ungenaue Gebäudekanten oder fehlende Dachaufbauten in der Nachbarbebauung führen zwangsläufig zu fehlerhaften Schattenwürfen auf der betrachteten Fassade. Meistens werden diese Datensätze in georeferenzierten Koordinatensystemen (z. B. UTM oder Gauß-Krüger) bereitgestellt, was eine Transformation in das lokale System des Gebäudemodells (@bim#[]) erfordert.
Die Auswahl des geeigneten Datenanbieters für das Referenzprojekt erfolgt anhand folgender Kriterien:

*Verfügbarkeit und Abdeckung:* Zunächst muss geprüft werden, welcher Anbieter Daten für den spezifischen Standort in der erforderlichen Qualität bereitstellt. Während globale Anbieter (z. B. OpenStreetMaps oder Google Maps) oft flächendeckende, aber detailarme Daten liefern, bieten kommunale Geoportale (z. B. Vermessungsämter) meist präzisere Datensätze an. Zu beachten sind hierbei lizenzrechtliche Einschränkungen: So sind beispielsweise die photorealistischen 3D-Tiles der Google Maps Platform in der EU derzeit nur eingeschränkt nutzbar @GoogleTilesAdjustments.

*Level of Detail:* Um einen korrekten Schattenwurf in der Simulation zu gewährleisten, sollten die verwendeten Gebäudemodelle mindestens im @lodet#[]2 vorliegen. Bei Gebäuden mit einer komplexen Außenhülle (siehe exemplarisch @fig-JengaTower) ist hingegen mindestens ein @lodet#[]3 erforderlich.

*Datenformat:* Die Wahl des Datenformats ist maßgeblich für den Import der Kontextmodelle. Formate wie CityGML oder CityJSON enthalten neben der Geometrie auch Attribute wie absolute Koordinaten, erfordern für die Verarbeitung in gängigen 3D-Engines jedoch meist eine vorherige Konvertierung. Rein geometrische Formate wie OBJ, glTF oder FBX bestehen hingegen ausschließlich aus 3D-Polygonnetzen. Sie ermöglichen eine direkte und performante Verarbeitung in der Simulationsumgebung, erfordern aufgrund der fehlenden Metadaten jedoch eine manuelle Georeferenzierung.

#figure(
  image("assets/JengaTower.jpg", width: 80%),
  caption: [Das als "Jenga Tower" bekannte Gebäude\ in 56 Leonard Street in New York City, USA @jenga_tower_penthouse],
  placement: bottom
)<fig-JengaTower>

*Aktualität:* Die Daten müssen den aktuellen baulichen Bestand widerspiegeln. Insbesondere in dynamischen innerstädtischen Lagen (wie im Referenzprojekt Frankfurt) können veraltete Datensätze dazu führen, dass neu errichtete Hochhäuser in der Simulation fehlen oder bereits abgerissene Gebäude noch vorhanden sind.

*Kostenstruktur:* Es ist zwischen kostenpflichtigen kommerziellen Daten und Open-Data-Initiativen zu unterscheiden. Viele Bundesländer (darunter Hessen und NRW) stellen ihre 3D-Gebäudemodelle in @lodet#[]2 mittlerweile kostenfrei über Open-Data-Portale zur Verfügung, was eine wirtschaftliche Hürde für die Integration in die @ga eliminiert.

Basierend auf den zuvor genannten Kriterien erfolgt die Auswahl des geeigneten Datensatzes. Es empfiehlt sich, primär die Aktualität und Vollständigkeit der amtlichen Geodaten lokaler Vermessungsämter zu prüfen. Sollten in diesen Datensätzen relevante Gebäude fehlen, können die Geometrien durch externe Datenquellen ergänzt werden. Voraussetzung ist eine exakte Georeferenzierung der Objekte, um die reale Situation im digitalen Modell präzise abzubilden.


// ==== Auswahl der Umgebungsszene
// - Gebäude, die nördlich des Referenzgebäudes liegen, müssen theoretisch nicht in der Simulation berücksichtigt werden. Um den genauen Bereich herauszufinden, muss der minimale und maximale Azimut der Sonne während der Sommersonnenwende (21./22. Juni) ermittelt werden. In Frankfurt am Main geht die Sonne mit einem Azimut von 50° auf und mit 310° unter. Somit kann die Umgebung in einem Azimut von 310°-50° zum Referenzgebäude nie einen direkt Schatten auf dieses werfen und somit vernachlässigt werden.
//   - bei sehr tiefliegender sonne werfen auch weit entferne gebäude schatten, dies ist allerdings vernachlässigbar, da die schattenkanten sich auch schnell bewegen
//   - gebäude sind nur  interessant, wenn sie einen schatten auf das referenzgebäude werfen können. somit sind gebäude in zweiter und dritter reihe nicht mehr zu berücksichtigen
// - Topographie muss nur importiert werden, wenn Berge, Hügel etc. das Gebäude verschatten könnten
// 
==== Auswahl der Umgebungsszene <AuswahlUmgebungsszene>
Die Auswahl der zu importierenden Umgebungsszene orientiert sich an der potenziellen Verschattungsrelevanz für das Referenzgebäude. Umliegende Bebauungen in zweiter oder dritter Reihe, deren Schattenwurf bereits durch näherstehende Objekte verdeckt wird, können vor der Simulation entfernt werden. Gleiches gilt für topografische Gegebenheiten: Ein Import von digitalen Geländemodellen ist nur dann erforderlich, wenn signifikante Erhebungen das betrachtete Gebäude in der Realität verschatten könnten.

Eine weitere Maßnahme zur Reduktion der Rechenlast und Datenmenge ist die Beschränkung auf relevante Himmelsrichtungen anhand der lokalen Sonnenbahn. Objekte, die sich nördlich des Referenzgebäudes befinden, können systematisch vernachlässigt werden. Die exakte Eingrenzung dieses Bereichs erfolgt über den minimalen und maximalen Sonnenazimut zum Zeitpunkt der Sommersonnenwende (21. bzw. 22. Juni). Für den Standort Frankfurt am Main beispielsweise liegt der Sonnenaufgang an diesem Tag bei einem Azimut von etwa 50° und der Sonnenuntergang bei 310°. Demzufolge kann die Umgebung im nördlichen Kreissektor zwischen 310° und 50° physikalisch zu keinem Zeitpunkt im Jahr einen direkten Schatten auf das Referenzgebäude werfen und bleibt im Modell unberücksichtigt. 
//HIER VLT NOCH KLEINE ZEICHNUNG DAZU ODER BILD ZUR VERANSCHAULICHUNG?:::

Zwar können weit entfernte Gebäude bei einer sehr tief stehenden Sonne (in den Morgen- oder Abendstunden) theoretisch einen Schattenwurf auf die Referenzfassade verursachen. Dieser Effekt ist im Kontext der @ga jedoch vernachlässigbar, da sich die resultierenden Schattenkanten aufgrund des flachen Einfallswinkels sehr schnell über die Fassade bewegen und somit keine relevante Tageslichtnutzung durch öffnen der Behänge erzielt werden könnte.

== Konzeption der Systemarchitektur und Simulationslogik
Aufbauend auf der definierten Datengrundlage widmet sich dieser Abschnitt der methodischen Umsetzung. Ziel ist der Entwurf einer Systemarchitektur, die komplexe 3D-Geometriedaten in verwertbare Steuerungsdaten für die operative Gebäudeautomation übersetzt. Hierfür wird zunächst die räumliche und zeitliche Diskretisierung der Simulation festgelegt, um das Datenvolumen und die Rechenzeit zu optimieren. Anschließend werden die eingesetzten Algorithmen zur fehlerfreien Strahlenverfolgung erläutert. Den Abschluss bildet die Definition der informationstechnischen Schnittstellen, welche den Datentransfer von der Simulationsumgebung bis in die Feldebene strukturieren.
=== Diskretisierung und Simulationsumfang <ZeitlicheAufloesungUmfang>
==== Zeitliche Diskretisierung
 Die Wahl der zeitlichen Auflösung für die Verschattungsdaten hat maßgeblichen Einfluss auf die Tageslichtausbeute des Gebäudes. 
 Im Folgenden wird untersucht, wie sich verschiedene zeitliche Auflösungen auf die Jalousiesteuerung auswirken würden. Generell muss die Steuerung vorausschauend agieren, um jederzeit den Blendschutz zu gewährleisten.

@fig-Zeitstrahl veranschaulicht diesen Effekt am Beispiel einer theoretischen Steuerung mit integrierten Verschattungsdaten in verschiedenen Auflösungen. Die Steuerungslogik definiert sich dabei wie folgt:
- *Fall offener Behang:* Die Steuerung detektiert für einen Zeitpunkt $t$, ob für den nächsten berechneten Zeitpunkt ($t+1$) Sonne auf das Fenster fällt. Falls ja, werden die Behänge präventiv geschlossen. 
- *Fall geschlossener Behang:* Die Steuerung detektiert für einen Zeitpunkt $t$, ob für den nächsten berechneten Zeitpunkt $t+1$ keine Sonne mehr auf das Fenster fällt und öffnet die Behänge erst zu diesem Zeitpunkt ($t+1$).

#figure(
  image("assets/AuflösungZeitstrahl.svg", width: 105% ),
  caption: [Theoretischer Verschattungsverlauf an einem Referenzfenster mit beispielhafter Steuerung bei 5-, 15- und 60-minütiger Datenauflösung.],
  placement: auto
)<fig-Zeitstrahl>

Dadurch wird garantiert, dass der Nutzer zu keinem Zeitpunkt einer Blendung ausgesetzt ist. Am beispielhaften Zeitstrahl verlässt der Schatten das Fenster um 10:23 Uhr. Bei einer groben stündlichen Diskretisierung hält die Steuerung den Behang jedoch schon ab 10:00 Uhr geschlossen, was zu 23 Minuten Verlust an natürlichem Tageslicht führt. Besonders gravierend wirkt sich diese zu grobe Abtastung bei schnellen, iterativen Verschattungsänderungen aus (beispielsweise in Großstädten mit dichter Hochhausbebauung). 

// #block(inset: 8pt, fill: luma(240))[
// Eine höhere Auflösung ermöglicht eine bessere Tageslichtautonomie...
// ]

Im Gegensatz dazu ermöglicht eine feine Auflösung von 5 Minuten, die Behänge sehr nah am realen Schattenverlauf des Fensters zu führen. Sie bildet den realen Schattenverlauf exakt ab und erfasst auch kurze Sonneneinstrahlungen durch Lücken in der Nachbarbebauung. Werden diese schnellen Wechsel jedoch direkt als Fahrbefehle an die Motoren weitergegeben, sinkt der Nutzerkomfort erheblich. Eine sich ständig bewegende Jalousie lenkt visuell und akustisch ab und erhöht den Verschleiß der Motoren.

Um diesen Konflikt zu lösen, muss die Steuerung die präzisen Umgebungsdaten von den tatsächlichen Fahrbefehlen entkoppeln. In der @ga werden dafür Verzögerungszeiten, sogenannte Hysteresen eingesetzt. Dadurch reagiert der Sonnenschutz nicht auf jede minimale und kurzzeitige Schattenänderung.

Eine hohe Datenauflösung bleibt somit das konzeptionelle Optimum. Voraussetzung ist allerdings, dass die technische Infrastruktur die großen Datenmengen verarbeiten kann und die Steuerungsprogrammierung ständige Fahrbewegungen zuverlässig unterbindet.

Um den Berechnungsaufwand und das resultierende Datenvolumen weiter zu optimieren, wurde im Rahmen der zeitlichen Diskretisierung ergänzend untersucht, ob die Simulation eines repräsentativen Tages pro Kalenderwoche für die steuerungstechnischen Anforderungen ausreichend ist. Für diese Evaluation wurden exemplarisch der 17. und der 24. März verglichen. Die Wahl dieses Zeitraums begründet sich durch die astronomische Tag-und-Nacht-Gleiche (Äquinoktium) am 20. März. In dieser Phase weist die Deklination der Sonne ihre maximale tägliche Änderungsrate auf, weshalb der gewählte Zeitraum den ungünstigsten Fall für abweichende Sonnenstände innerhalb einer Kalenderwoche darstellt.

Wie in @fig-panorama_vergleich dargestellt, ergeben sich bei einer isolierten Betrachtung eines Fensters um 09:30 Uhr visuelle Diskrepanzen: Während das markierte Referenzfenster am 17. März zu diesem Zeitpunkt noch unverschattet ist, liegt es exakt eine Woche später bereits im Schatten der Umgebungsbebauung. Eine Analyse des Simulationsmodells zeigt jedoch, dass die harte Schattenkante lediglich etwa sechs Minuten benötigt, um vollständig von der rechten zur linken Fensterkante zu wandern. 

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    
    // Linkes Bild
    box(width: 100%, clip: true)[
      #align(center)[
        #image("assets/VergleichWoche1.png", width: 140%)
      ]
    ],
    
    // Rechtes Bild
    box(width: 100%, clip: true)[
      #align(center)[
        #image("assets/VergleichWoche2.png", width: 140%)
      ]
    ]
  ),
  caption: [Schattenkante am Fenster FL39_W045 um 9:30 am 17. März (links) und am 24. März (rechts)],
  placement: auto
)<fig-panorama_vergleich>


*Setzt man diese physikalische Übergangszeit in Relation zu der zuvor definierten zeitlichen Auflösung der @ga von 15 Minuten, wird die Relevanz dieser Abweichung stark relativiert. Die zeitliche Verschiebung des Schattenwurfs, die durch den einwöchigen Sprung des Sonnenstandes entsteht, ist geringer als das gewählte Diskretisierungsintervall der Steuerung. Demzufolge wird die Ungenauigkeit einer wöchentlichen Zusammenfassung von dem 15-minütigen Raster der Automationsstation absorbiert. Aus dieser Erkenntnis lässt sich ableiten, dass die Berechnung eines repräsentativen Tages pro Woche die Speicherkapazitäten der Feldebene drastisch schont, ohne dabei steuerungstechnisch signifikante Einbußen in der Genauigkeit des Blendschutzes zu verursachen...*

==== Zeitlicher Simulationsumfang
Für die Konzeption der Simulation stellt sich zudem die Frage, wie viele Kalenderjahre berechnet werden müssen, um den realen Sonnenverlauf hinreichend abzubilden. Der Umlauf der Erde um die Sonne unterliegt zwar langperiodischen Schwankungen (Milanković-Zyklen), diese sind für die Lebensdauer eines Gebäudes jedoch nicht relevant. Der berechnete Sonnenverlauf kann für den Betrachtungszeitraum als statisch angesehen werden. 

Da das kalendarische Jahr vom astronomischen Sonnenjahr (365,24 Tage) abweicht @astr04eduSonnenjahr, wird diese Differenz alle vier Jahre durch ein Schaltjahr korrigiert. Die hieraus resultierende zeitliche Verschiebung des Sonnenstandes am selben Kalendertag ist für einen simulierten Schattenwurf in @fig-schaltjahr beispielhaft dargestellt. 

Da sich die räumlichen Abweichungen des Schattens lediglich im Zentimeterbereich bewegen (roter Bereich), ist es für den Systemansatz ausreichend, die Simulation auf ein einzelnes Referenzjahr zu beschränken.

#figure(
  image("assets/SchaltjahrUnterschied.png"), 
  caption: [Differenz des Schattenwurfs am 01.03. eines Normaljahres (2026) gegenüber einem Schaltjahr (2028) um 09:00 Uhr.],
  placement: none
)<fig-schaltjahr>
// - anschließend wird untersucht, ob es auch reicht, nur für jede Woche einen Tag zu berechnen
// - dafür wird der 17. und 24. märz verglichen. sie werden verglichen, da am 20.03. die tag-nacht-gleiche ist und damit der sonnenstand sich am meisten verändert in dieser periode
// - wie man in @fig-panorama_vergleich erkennt, ist am 17.03. um 9:30 das rot markierte fenster noch nicht verschattet, eine woche darauf jedoch schon
// - eine woche
// - durch analyse der simulation kommt raus, dass allerdings nur ca. 6 minuten braucht, bis die schattenkante von rechts nach links über das gesamte fenster gewandert ist
// - das ist ja weniger, als die 15 minutüige auflösung. also sehr wahrscheinlich könnte man mit einer einwöchigen auflösung trotdem noch ein hohe genauigkeit erzielen
// - es wäre vertretbar nur jeden zweiten tag zu berechnen, da 
==== Räumliche Auflösung der Messpunkte <RaeumlicheAufloesung>
Die räumliche Abtastung der Fensterflächen bestimmt die Genauigkeit der Verschattungsdaten. Man muss festlegen, wie viele Testpunkte pro Fenster berechnet werden. Es werden zwei verschiedene Optionen untersucht:

*1. Einpunkt-Messung (Fenstermittelpunkt):*
Es wird ein einzelner Raycast vom geometrischen Zentrum des Fensters zur Sonne berechnet. Dieser Ansatz hat den Vorteil, dass er die geringste Rechenzeit aufweist, allerdings anfällig für Situationen mit Teilverschattung ist: Verdeckt ein Schatten beispielsweise nur die untere Fensterhälfte inklusive der Fenstermitte, meldet der Algorithmus bereits eine Verschattung des Fensters. Dabei ist die obere Fensterhälfte noch stark besonnt und verursacht Blendung.

*2. Vierpunkt-Messung (Eckpunkte):*
Die Simulation prüft die vier Extrempunkte der Fenstergeometrie. Sobald mindestens einer der vier Punkte direkte Sonneneinstrahlung detektiert, gilt das gesamte Fenster als besonnt. Teilverschattungen werden somit sicher erkannt, wodurch temporäre Blendungen verhindert werden. Der Nachteil ist eine ca. Verdopplung der Rechenzeit gegenüber der Einpunkt-Messung. Zudem können sehr schmale, vertikale Objekte (z. B. Masten), die schmaler als die Fensterbreite sind, theoretisch übersehen werden. Dies stellt jedoch ein vernachlässigbares Restrisiko dar. In einzelnen Fällen kann auch ein Schattenwurf, der nur die untere Fensterkante streift, zu einer nicht notwendigen Reaktion der Jalousie führen. Dies könnte mit dem Hochsetzen der unteren beiden Eckpunkte auf eine vertretbare Höhe verhindert werden.

// *3. Raster-Messung:*
// Ein feines Raster würde mehrere Punkte entlang der seitlichen Kanten des Fensters messen. Dies ermöglicht theoretisch eine genauere Steuerung der Behanghöhe, müsste allerdings in Kombination mit einer hohen zeitlichen Auflösung erfolgen. Ansonsten kann die Steuerung von der hohen örtlichen Datendichte nicht profitieren und müsste die zwischen den groben Zeitintervallen weit gewanderte Schattenkante in großen Sprüngen nachführen.
// Der Nachteil wäre außerdem eine Vervielfachung der Rechenzeit und eine komplexere Datenstruktur.


=== Algorithmische Verfahren und Fehlervermeidung<kap-algVerfahren>
==== Front-Face Check<kap-frontface>
Um die Rechenzeit des Algorithmus signifikant zu reduzieren und unnötige Raycasts zu vermeiden, wird den eigentlichen Kollisionsabfragen ein Filterverfahren vorgeschaltet. Dieser Schritt basiert auf der mathematischen Logik des aus der 3D-Computergrafik stammenden Back-Face Cullings, fungiert im physikalischen Kontext der Gebäudeanalyse jedoch als Eigenschatten-Prüfung (Front-Face Check). Das Prinzip stellt sicher, dass Fensterflächen, die auf der abgewandten Schattenseite des Gebäudes liegen, frühzeitig identifiziert und von der weiteren Berechnung ausgeschlossen werden. Die technische Umsetzung erfolgt über die Auswertung des Skalarprodukts zwischen dem Normalenvektor der Fensterfläche und dem Richtungsvektor der Solarstrahlung (Strahl vom Fenster zur Sonne). 
Wie in @fig-normalsCheck vereinfacht dargestellt, erkennt man eine Gebäudeecke in der Draufsicht mit Fenstern an der Außenseite. Es werden Strahlen horizontal von den Mittelpunkten der Fenster in Richtung der Sonne dargestellt.

#figure(
  image("assets/Back_Face_Culling.png", width: 70%),
  caption: [Draufsicht einer Gebäudeecke mit der Sonne zugewandten und abgewandten Fenstern],
  placement: auto
)<fig-normalsCheck>

Die Entscheidung, ob eine Fläche der Sonne zugewandt ist, hängt vom Winkel $alpha$ zwischen diesen beiden Vektoren ab:
- *Fenster A (zugewandt)*: Da der Winkel $alpha_A$ weniger als 90° beträgt, weisen die Vektoren in dieselbe Richtungen (das Skalarprodukt ist positiv). Das System erkennt, dass die Fensterfläche der Sonne zugewandt ist und eine Verschattungsprüfung stattfinden muss.
- *Fenster B (abgewandt)*: Da der Winkel $alpha_B$ mehr als 90° beträgt, zeigen die Vektoren in die entgegengesetzte Richtung --- der Strahl entspringt also von der Rückseite der Fensterfläche. Das Skalarprodukt ist in diesem Fall negativ, und die Geometrie wird durch den Front-Facing Check ignoriert.
Um Fehlkalkulationen in diesem Schritt auszuschließen, sollte garantiert sein, dass alle Flächennormalen im 3D-Modell konsistent nach außen gerichtet sind.

==== Vermeidung von Selbstverschattung
Bei der Konzeption der auf Raycasting basierenden Simulationsarchitektur muss eine bekannte Problematik der 3D-Simulation berücksichtigt werden: sogenannte Self-Intersection-Fehler (Selbstverschattungen). Da Fenster in @bim#[]- und @ifc#[]-Modellen häufig als Volumenkörper modelliert sind, kann ein direkt an der Glasfläche startender Teststrahl aufgrund von minimalen mathematischen Rundungsfehlern (Floating-Point-Ungenauigkeiten) sofort mit der Innenseite oder dem Rahmen der eigenen Geometrie kollidieren. Das Fenster würde sich somit selbst verschatten.

Um dies zu verhindern wird in der Simulationslogik ein Start-Offset definiert. Der geometrische Ursprung des Prüfstrahls wird dabei nicht exakt auf der Glasfläche platziert, sondern entlang des Richtungsvektors um ein definiertes Maß (beispielsweise 10~cm) in den Außenraum verschoben. Die eigentliche Kollisionsprüfung beginnt somit sicher außerhalb der eigenen Fenstergeometrie, was die Robustheit der Simulation erhöht.

=== Systemarchitektur und Schnittstellen <DefinitionSystemarchitektur>

Die informationstechnische Konzeption der Systemarchitektur definiert maßgeblich, wie die generierten Simulationsdaten effizient und fehlerfrei in die reale @ga überführt werden. Bei dem hier entwickelten Workflow handelt es sich um ein System, welches die Verschattungssituation im Vorfeld einmalig für ein vollständiges Kalenderjahr berechnet und als statische Daten bereitstellt. Die Wahl dieser Systemarchitektur begründet sich durch die konsequente Entkopplung der Simulationsumgebung von der operativen Datenverarbeitung. Dieser Aufbau ermöglicht es, die Ergebnisse in einem einfachen Datenformat (wie CSV) bereitzustellen, wodurch eine Installation der Simulationssoftware und deren Abhängigkeiten auf dem Projektserver entfällt. Darüber hinaus wird durch diesen Ansatz die Betriebssicherheit gesteigert: Der Rückgriff auf statische, im Vorfeld validierte Datensätze ist gegenüber einer dynamischen Echtzeitsimulation deutlich weniger fehleranfällig und vermeidet Risiken durch potenzielle Softwareinstabilitäten während der Programmlaufzeit.

Da die benachbarten Gebäude in der Regel statisch sind, stellt die Vorabberechnung in der Praxis keinen Nachteil dar. Sollte es dennoch zu baulichen Veränderungen in der Umgebung kommen, gibt es zwei Fälle die eintreten können: Entsteht ein neues Nachbargebäude, welches im vorliegenden Datensatz noch nicht erfasst ist, geht die Steuerung fälschlicherweise weiterhin von direkter Besonnung aus und schließt die Behänge. Dies führt zwar zu einer suboptimalen Tageslichtausbeute, der kritische Blendschutz für die Nutzer bleibt jedoch vollständig gewahrt. Eine Herausforderung stellt lediglich der umgekehrte Fall dar: Entfällt ein schattenspendendes Gebäude (beispielsweise durch Abriss), würde die Anlage den Behang öffnen und eine starke Blendung bei klarem Himmel zulassen. In einem solchen Szenario muss der Datensatz durch eine erneute Simulation zwingend aktualisiert werden.

Um die zu übertragenden Datenmengen und die Bus-Auslastung zu minimieren, wird eine strikte Trennung zwischen globalen und lokalen Daten vorgenommen. Die Sonnenhöhe (Elevationswinkel) ist zu einem spezifischen Zeitpunkt für das gesamte Gebäude und somit für alle Fenster identisch. Um redundante Daten zu vermeiden, wird die Elevation nicht pro Fenster in der Simulationsdatei gespeichert. Stattdessen kann dieser globale Wert entweder zyklisch von einer zentralen Dachwetterstation empfangen oder durch einen standardisierten Algorithmus direkt auf der Automationsstation berechnet werden.

Der fensterspezifische Datensatz beschränkt sich somit auf den diskreten Verschattungszustand beziehungsweise den horizontalen Einfallswinkel der Sonne. Die Ausgabe differenziert dabei zwischen folgenden Zuständen:

- *R (Rückseitenverschattung):* Die Sonne befindet sich hinter der Fassadenebene des Fensters.
- *V (Verschattung durch Fremdobjekte):* Die Sonne wird durch umliegende Gebäude oder Topografie blockiert.
- *N (Nacht):* Die Sonne befindet sich unterhalb des Horizonts.
- *Azimutwinkel:* Numerischer Wert bei direkter Besonnung in -90° bis +90°.


Der übergebene Azimutwinkel beschreibt den relativen horizontalen Einfallswinkel der Sonnenstrahlen auf die Fensternormale. Da die Berechnungen auf dem mathematischen Einheitskreis basieren, werden Winkel gegen den Uhrzeigersinn positiv und im Uhrzeigersinn negativ abgebildet. In @fig-fensterazimut wird exemplarisch ein Fenster mit Süd-Ost-Ausrichtung und den resultierenden Azimutwinkeln bei verschiedenen Sonnenständen dargestellt. Ein Winkel von 0° bedeutet dabei, dass die Sonne frontal vor dem Fenster steht, der horizontale Lichteinfall also orthogonal zur Fassadenebene erfolgt.

Die differenzierte Ausgabe dieser Zustände bietet eine hohe Flexibilität für die Steuerungslogik und erleichtert der Systemintegration bei der Inbetriebnahme die Fehleranalyse sowie die Nachvollziehbarkeit des Anlagenverhaltens.

Hinsichtlich der Datenspeicherung und Verteilung stellt sich die Frage der Hardwareallokation. Da die Automationsstationen der Feldebene in der Regel nur über begrenzte Speicherkapazitäten verfügen, ist es nicht praktikabel, die Jahresdatensätze von tausenden Fenstern lokal zu hinterlegen. Es bietet sich stattdessen an, die vollständigen CSV--Dateien zentral auf dem Server der @mbe zu speichern. Die @mbe kann die aktuellen Zustände zyklisch (beispielsweise im 5-Minuten-Takt) auslesen und die jeweils relevanten Datenpunkte über standardisierte Protokolle (wie z. B. BACnet) an die zuständigen Raumautomationsstationen übertragen.

#figure(
  image("assets/Fensterazimut.pdf", width: 70%),
  caption: [Angabe des Fensterazimutwinkels für beispielhaftes Fenster mit Süd-Ost-Ausrichtung],
  placement: auto
) <fig-fensterazimut>

// === Systemarchitektur und Schnittstellen<DefinitionSystemarchitektur>
// - die Simulation wird einmalig für ein ganzes Jahr durchgeführt, da... 
// - Handelt es sich um ein zustandsloses System, das einmalig einen Fahrplan (Schedule) generiert, oder um ein dynamisches System, das auf Veränderungen (beispielsweise neue Verschattungsobjekte durch Baustellen) reagieren kann.
//   - nicht kritisch, wenn neues gebäude dazukommt, da der wichtige blendschutz weiterhin gegeben ist
//   - wenn allerdings ein gebäude entfällt und die steuerung die Behänge öffnet, weil sie denkt, dass das fenster verschattet ist, kommt es zu einer blendung bei klarem himmel
// - Tabelle mit Elevationswinkel könnte mitgegeben oder auf AS oder wetterstation berechnet werden(Vermeidung von Redundanz: Die Sonnenhöhe (Elevation) ist zu einem bestimmten Zeitpunkt für das gesamte Gebäude (und somit für alle 6000 Fenster) identisch.) 
// - Status R, V, N - Azimut erklären
//   - R = Rücksseite von Fenster
//   - V = Verschattet durch umgebendes Gebäude
//   - N = Nacht (Sonne steht unter dem Horizont)
//   - Azimutwinkel von fensternormale zu sonne bei direkter besonnung
//   - Skript benutzt math.atan2(). dieses benutzt den mathematischen einheitskreis, der gegen den Uhrzeigersinn gemessen wird. Deswegen ist der Wert rechts von der mitte negativ (siehe skizze)
//   - verschiedenen ergebniswerte haben vorteil für debugging, nachvollziehbarkeit der daten und steuerungsfunktionalität
// - Auch die Frage: Auf welchem Rechner sollten die Daten gespeichert werden? es bietet sich wahrscheinlich an, die daten auf dem rechner der @mbe zu speichern

== Integrationskonzepte für die Gebäudeautomation
=== Systematische Integration der Daten <IntegrationGebaeudeautomation>


Die Integration hochauflösender Simulationsdaten in die operative @ga wird in der Praxis maßgeblich durch die Hardware-Restriktionen der Feldebene limitiert. Eine @ras, welche die unmittelbare Steuerung der Jalousieaktorik übernimmt, verfügt systembedingt nur über stark begrenzte Speicherkapazitäten und Rechenressourcen. Die lokale Implementierung eines vollständigen Jahresdatensatzes mit kurzen Zeitintervallen für mehrere Fenster würde den nutzbaren Speicher dieser Controller unverhältnismäßig belasten oder diesen sogar vollständig erschöpfen. Eine direkte und vollständige Übertragung der Simulationsergebnisse auf die unterste Steuerungsebene ist demnach informationstechnisch nicht realisierbar.

Um diesen Kapazitätsengpass zu umgehen, bedarf es einer entkoppelten Systemarchitektur. Die vollständigen Verschattungsdaten werden hierfür zentral auf der @mbe oder einem übergeordneten Server vorgehalten. Ein praxisnaher Ansatz zur Verteilung der Daten besteht in einer asynchronen Übertragung. Anstatt die Raum-Controller kontinuierlich mit neuen Werten zu überschreiben, wird lediglich der spezifische Fahrplan für den jeweils darauffolgenden Tag generiert und an die Feldebene gesendet. Diese Übermittlung erfolgt sequenziell während der nächtlichen Schwachlastzeiten. Diese Methodik stellt sicher, dass die stark limitierten Netzwerk- und Kommunikationsbusse während des regulären operativen Gebäudebetriebs am Tag nicht durch große Datenpakete überlastet werden.

Nach der erfolgreichen Übermittlung und temporären Speicherung des Tagesdatensatzes auf der lokalen Automationsstation werden die Informationen von den dortigen Raumautomationsprogrammen verarbeitet. Die empfangenen Verschattungszustände und Azimutwinkel dienen den Funktionsblöcken als direkte Eingangsgröße, um die nachgelagerte Jalousieaktorik präzise zu steuern. Durch diesen Ansatz wird die rechen- und speicherintensive Datenhaltung auf leistungsstarke Server ausgelagert, während die reaktionskritische Ausführung der Fahrbefehle dezentral und ausfallsicher auf der Feldebene verbleibt.


// - auf die extremen Kapazitätsproblemen eingehen bezüglich Datenspeicher und CPU-Auslastung

// - asynchrone Datenübertragung: Ein praxisnaher Ansatz besteht darin, die aggregierten Verschattungsdaten für den jeweils folgenden Tag während der nächtlichen Schwachlastzeiten sequenziell zu verteilen. Dies verhindert Netz- und Busüberlastungen während des regulären operativen Gebäudebetriebs.

// - Nach erfolgreicher Übermittlung und temporärer Speicherung werden die Daten von den Programmen der Raumautomation verarbeitet. Sie dienen dort als direkte Eingangsgröße für die präzise und automatisierte Steuerung der Jalousieaktorik.

=== Vorschlag eines modifizierten Funktionsblocks nach VDI 3813...(nicht fertig)<kap-neuerFunktionsblock>
Basierend auf der Analyse der VDI 3813-2 (vgl. @kap-vdi3813) wird für die entwickelte Systemarchitektur ein modifizierter Funktionsblock konzipiert (siehe @fig-NeuerFunktionsblock). Dieser wird im Gegensatz zur Richtlinie, dem Funktionsblock der Lamellennachführung vorangestellt. Ziel ist es, sowohl die rechenintensive geometrische Kollisionsprüfung als auch die Verwaltung der fassadenspezifischen Ausrichtungswinkel in die Simulation auszulagern. 

#figure(
  image("assets/FunktionsblockNeu.png", width: 60%),
  caption: [Konzept des modifizierten Funktionsblocks für eine simulationsbasierte Verschattungskorrektur],
  placement: auto
)<fig-NeuerFunktionsblock>

Der standardisierte Funktionsblock zur Verschattungskorrektur verarbeitet den globalen Sonnenstand, der in der Automationsstation für jede Fassadenseite mit einem lokalen Offset (Azimut) verrechnet werden muss. 
Der hier konzipierte Funktionsblock empfängt stattdessen über den Dateneingang (`SIM_DATA`) einen Datensatz, der fensterspezifische Parameter enthält, und routet diese als Steuergrößen an die nachgelagerten Instanzen.

Die interne Steuerungslogik wertet den eintreffenden Datentyp aus und schaltet die Signale:

- *Zustände V, R, N:*  Empfängt der Block eines der definierten Strings für Fremdverschattung (V), Rückseiten-Ausblendung (R) oder Nacht (N), wird ein anliegender Schließbefehl der Thermoautomatik blockiert. Der Block überschreibt das Stellsignal (`S_AUTO`) mit der parametrierten Parkposition (`PAR_PARK`). Zeitgleich wird über den binären Ausgang (`B_ON = FALSE`) die nachgelagerte Lamellennachführung deaktiviert, da ohne direkte Besonnung kein aktiver Blendschutz erforderlich ist. Dies integriert und vereinfach ebenfalls die Funktion der Dämmerungsautomatik.

- *Sonnenazimut:* Registriert der Eingang einen numerischen Gleitkommawert, wird dies vom System als direkte Besonnung gewertet. Das Stellsignal (`S_AUTO`) wird in diesem Fall unverändert durchgereicht und die Blendschutz-Automatik aktiviert (`B_ON = TRUE`). Der empfangene Zahlenwert entspricht dem in der Simulation berechneten Einfallswinkel der Sonne relativ zur Fensternormale. Dieser Wert wird über den Ausgang `A_SUN_AZ` direkt an die Lamellennachführung übergeben.

Generell muss die Steuerung vorausschauend arbeiten, d.h. die Daten für den nächsten Zeitabschnitt geladen werden, um Blendungen, die vor dem nächsten berechnetet Zeitpunkt anfangen, abzufangen (wie bereits in @ZeitlicheAufloesungUmfang aufgezeigt). Der für die Lamellennachführung benötigte Höhenwinkel (`A_SUN_EL`) kann von einer intelligenten Wetterstation oder einer externen Datenquelle bereitgestellt werden.  

Der Vorteil für die Systemintegration ist, dass durch diese Architektur es nicht mehr erforderlich ist, die fenster- oder fassadenspezifischen Gebäudegeometrien in der @as zu hinterlegen. Die statische Parametrierung von Grenzwinkeln bei der Systemintegration entfällt, was die Fehleranfälligkeit verringert und den Inbetriebnahmeaufwand der Automationslösung reduziert.





// Aus informationstechnischer Sicht (Separation of Concerns) wird die zeitliche Auswertung der generierten Verschattungsdaten (Array-Handling) von der logischen Verschattungskorrektur getrennt. Ein übergeordnetes Zeitprogramm (beispielsweise ein BACnet Schedule Object) gleicht die interne Systemuhr mit dem importierten CSV-Datensatz ab und übergibt lediglich den aktuellen, binären Verschattungsstatus an den modifizierten Funktionsblock. Der Block selbst benötigt somit keine Echtzeituhr (RTC), was ihn hardware-schonend und echtzeitfähig macht."

// - Die Steuerung funktioniert nur in Kombination mit einer Wetterstation auf dem Dach, da der Behang bei starker bewölkung offen bleiben kann
//  - Man müsste dort die direkte und indirekte strahlung messung können
// - Der Datenoutput mit N, R, V und Azimutwinkel  ermöglicht maximalen Kontext für die  Steuerung und ermöglicht hohe Flexibilität

// - Mit Azimut können sehr flache einfallende Sonnenstrahlen toleriert werden, wenn z.B. Säulen zwischen den Fenstern aufgestellt sind -> auch wenn säulen da sind, würden diese vielleicht sehr stark angeleuchtet und könnten unangenehm sein
//- Negative Seiten von Jalousien: laute fahrbewegungen, visuell störend durch sich bewegende (auch bei Änderung Winkel lamelle) behänge und durch starkes abdunkeln während fahrbewegungen. 
//  - beispiel von echtzeit tradern, die keine Jalousiebewegungen tolerieren und somit nur morgens