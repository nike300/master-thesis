= 3 Anforderungsanalyse und Konzeption des Integrationsprozesses <Kap3>
== 3.1 Analyse der Ausgangssituation und Zieldefinition <AnalyseAusgangssituation>

In der aktuellen Praxis der Gebäudeautomation weist die konventionelle Einbindung von Verschattungsdaten signifikante Defizite auf. Die Berücksichtigung von Fremdverschattung durch umliegende Bebauung oder Topografie erfolgt oftmals über manuelle und fehleranfällige Prozesse. Dabei werden statische Verschattungsdaten in Form von Grenzwinkeln für einzelne Fenster, Fenstergruppen oder ganze Fassadenabschnitte händisch in der Jalousiesteuerung der BMS-Software hinterlegt (siehe @fig-jalousiesteuerung). Diese Winkel werden in der Praxis oftmals nur approximativ eingestellt und durch empirische Anpassungen im Nachhinein korrigiert.

Im operativen Betrieb berechnet die @as fortlaufend den aktuellen Sonnenstand und gleicht diesen mit den definierten Grenzwinkeln ab. Auf Basis dieses Abgleichs entscheidet die Logik, ob der entsprechende Punkt zum gegebenen Zeitpunkt verschattet ist oder direkter Sonneneinstrahlung ausgesetzt sein kann.

#figure(
  image("assets/JalousiesteuerungAlt.png", width: 80%),
  caption: [Screenshot der Parametereingabe für eine konventionelle, winkelbasierte Jalousiesteuerung in der @ebo #[]@se_ebo.],
  placement: auto
) <fig-jalousiesteuerung>

Dieser Ansatz zwingt die Systemintegration jedoch zu Worst-Case-Annahmen. Da ein einzelner Referenzpunkt in der Regel stellvertretend für größere Fassadenbereiche genutzt wird, muss der Sonnenschutz geschlossen werden, sobald auch nur ein Teilbereich der Zone potenziell besonnt ist. Eine hohe räumliche Genauigkeit und damit eine optimale Tageslichtnutzung ist mit dieser statischen Zonenbildung kaum realisierbar.

Für Gebäude mit einfacher architektonischer Geometrie und einer weitläufigen, wenig verbauten Umgebung bietet diese winkelbasierte Methode eine funktionale und ausreichende Lösung. Sobald jedoch Bauwerke mit komplexen Fassadenstrukturen in dichten urbanen Kontexten betrachtet werden, stößt dieser Ansatz an seine technischen Grenzen und erfordert eine dreidimensionale Betrachtungsweise.

Verschattungssimulationen basierend auf 3D-Daten finden heutzutage zunehmend Einzug in die Gebäudeautomation. Erste Hersteller, wie beispielsweise Warema oder Sauter, bieten die Berechnung der Jahresverschattung bereits als Dienstleistung an. Aufgrund ihres Mehrwerts für die Tageslichtautonomie und Energieeffizienz wird die Integration derartiger Daten in zukünftigen Bauprojekten vermehrt gefordert werden.

Ziel dieses Kapitels ist es, einen methodischen Ansatz aufzuzeigen, wie unter dem ausschließlichen Einsatz von Open-Source-Software und frei verfügbaren Datensätzen eine präzise Verschattungssimulation realisiert werden kann. Hierfür wird im Folgenden zunächst die Auswahl einer geeigneten Simulationsumgebung begründet. Anschließend erfolgt die Spezifikation der notwendigen Datengrundlage, bestehend aus der @bim#[]-Datengüte und externen Geodaten. Darauf aufbauend werden die räumlichen und zeitlichen Auflösungen festgelegt sowie die informationstechnische Konzeption der Simulationslogik definiert. Den Abschluss bildet der Entwurf der Systemarchitektur, in welcher die generierten Daten über einen modifizierten Funktionsblock nach VDI 3813 in die Gebäudeautomation integriert werden.

== Spezifikation der Werkzeuge und Datengrundlage
=== Auswahl der Simulationsumgebung <AuswahlSimulationsumgebung>
In der Simulationsumgebung findet die Zusammenstellung der Szene statt. Es muss eine Software gewählt werden, die den Import verschiedener 3D-Dateiformate zulässt. Zusätzlich sollte diese Software den Sonnenstand simulieren können und eine Möglichkeit bieten Raycasts zu generieren. Schlussendlich muss es möglich sein, Skripte auszuführen, um komplexe Algorithmen auszuführen.
Die Wahl fällt auf die kostenlose Open-Source-Software Blender, die für die Erstellung von Animationsfilmen entwickelt wurde@blender_org. Sie bietet in der jetzigen Version eine Vielzahl von Funktionalitäten, darunter auch die, zur Erfüllung der oben genannten Anforderungen. Außerdem bietet sie den Vorteil einer großen, aktiven Community, die eine Vielzahl an kostenlosen und kostenpflichtigen Plug-Ins entwickelt. Für diese Anwendung passende Alternativen standen nicht zur Auswahl.

=== Anforderungen an das @bim#[]-Modell <AnforderungBIM>
Um einen fehlerfreien und automatisierten Datenfluss von der digitalen Planung in die Simulationsumgebung zu gewährleisten, muss das zugrundeliegende @bim#[]-Modell spezifische geometrische und semantische Anforderungen erfüllen. Eine Untersuchung typischer @ifc#[]-Exporte offenbart häufige Defizite, die für eine valide Verschattungssimulation zwingend im Vorfeld korrigiert oder durch klare Modellierungsrichtlinien im @bap definiert werden müssen:

*Datenreduktion:* Um die Dateigröße und die Berechnungszeiten beim Import in die 3D-Software zu minimieren, muss das @ifc#[]-Modell um nicht-relevante Architekturdetails bereinigt werden. Für die geometrische Verschattungssimulation sind ausschließlich die Elemente der thermischen Gebäudehülle (Fassaden, Fenster) sowie potenziell eigenverschattende Bauteile (Balkone, Erker, Laibungen) erforderlich. Innenwände oder Inventar sind vor allem bei großen Gebäuden zwingend auszuschließen. Meist liegt das Gebäude bereits als Fassadenteilmodell vor.

*Semantische Klassifizierung (@ifc#[]-Klassen):* Die Fensterobjekte sollten als `IfcWindow`deklariert sein, damit das Python-Skript sie automatisiert extrahieren kann. Eine häufige Fehlerquelle bei CAD-Exporten (z. B. aus Autodesk Revit) ist die Fehlklassifizierung von schrägen Fenstern oder Dachflächenfenstern als generische Bauteile (oft `IfcBuildingElementProxy` oder `IfcRoof`), was eine korrekte Filterung erschwert.

*Detaillierungsgrad (@lod):* Für eine aussagekräftige Simulation der Gebäudehülle ist ein minimaler geometrischer Detaillierungsgrad zwingend erforderlich.  Um den kritischen Effekt der Eigenverschattung (bspw. durch tiefe Fensterlaibungen, Stürze oder auskragende Fassadenelemente) physikalisch korrekt per Raycasting berechnen zu können, müssen die entsprechenden Bauteile mindestens im @lod 300 vorliegen.


*Geometrische Ausrichtung (Face Normals):* Für eine performante und fehlerfreie Raycasting-Berechnung ist die konsistente Ausrichtung der Flächennormalen (Face Normals) der Fenster-Meshes entscheidend. Die Normalenvektoren der Fenster müssen nach außen zeigen. Ist dies nicht der Fall, kann die in 3D-Engines übliche Performance-Optimierung des _Backface Culling_ (siehe @kap-algVerfahren) nur mit zusätzlichem Aufwand angewandt werden.

*Georeferenzierung und Ausrichtung:* Eine zentimetergenaue Überlagerung des Gebäudemodells mit den externen Gebäude-Umgebungsdaten (siehe @kap-ImportUmgebungsdaten) erfordert eine exakte Verortung. Das Gebäude muss auf der korrekten absoluten Z-Höhe modelliert und geografisch nach dem Wahren Norden ausgerichtet sein. Hierfür sollten die exakten Koordinaten des Projekt-Referenzpunktes unter der Entität `IfcSite` im globalen Referenzsystem WGS84 vorliegen@buildingsmart_ifcsite.

*Anlagenkennzeichnungsschlüssel*: Um die berechneten Verschattungsdaten nach der Simulation fehlerfrei an die @ga zu übergeben, sollte jedes Fensterobjekt mit einem @aks versehen sein (beispielsweise im @ifc#[]-Attribut `Name` oder `Tag`). Das Anlagenkennzeichnungssystem sollte konsequent nach dem hierarchischen Schalenmodell der VDI 3814-1 aufgebaut sein, um das direkte Mapping in der @as zu ermöglichen @vdi3814-1. Dabei sollten die Fenster auch ihrem jeweiligen Raumsegment zugeordnet werden.

*Etagenweise Zuordnung:* Für die spätere Übersichtlichkeit im Modell sollten die Fensterelemente im @ifc#[]-Strukturbaum dem jeweiligen Geschoss (`IfcBuildingStorey`) korrekt zugeordnet sein.

In der Planungspraxis werden diese strukturellen und semantischen Anforderungen an die IFC-Datenqualität oftmals nicht vollumfänglich erfüllt. Dies erzwingt in der Konsequenz eine manuelle und ressourcenintensive Vorverarbeitung des Gebäudemodells vor dem eigentlichen Simulationsstart.

Um diesen Aufwand zu minimieren, sollten frühzeitig Synergieeffekte im integralen Planungsprozess geprüft werden. Insbesondere bei innerstädtischen Groß- und Hochhausprojekten erstellen Architekturbüros für Genehmigungsverfahren oder Marketingzwecke häufig eigene Sonnenstudien. Die hierfür bereits aggregierten digitalen Stadtmodelle stellen eine wertvolle Datenquelle dar. Deren Nachnutzung für den Workflow der Verschattungssimulation kann eine erneute Modellierung oder externe Datenbeschaffung obsolet machen.

// OPTIONAL: HIER AUF CHECKLISTE IM ANHANG VERWEISEN FÜR ARCHITEKTEN

=== Externe Geodaten und Georeferenzierung
==== Analyse externer Geodaten <AnalyseExternerGeodaten>
Die Qualität der Daten der umgebenden Gebäude, Topografie und Vegetation bestimmt die Genauigkeit der Verschattungssimulation maßgeblich. Ungenaue Gebäudekanten oder fehlende Dachaufbauten in der Nachbarbebauung führen zwangsläufig zu fehlerhaften Schattenwürfen auf der betrachteten Fassade. Meistens werden diese Datensätze in georeferenzierten Koordinatensystemen (z.B. UTM oder Gauß-Krüger) bereitgestellt, was eine Transformation in das lokale System des Gebäudemodells (@bim#[]) erfordert.
Die Auswahl des geeigneten Datenanbieters für das Referenzprojekt erfolgt anhand folgender Kriterien:

*Verfügbarkeit und Abdeckung:* Zunächst muss geprüft werden, welcher Anbieter Daten für den spezifischen Standort in der erforderlichen Qualität bereitstellt. Während globale Anbieter (z.B. OpenStreetMaps oder Google Maps) oft flächendeckende, aber detailarme Daten liefern, bieten kommunale Geoportale (z.B. Vermessungsämter) oft präzisere Datensätze an. Zu beachten sind hierbei lizenzrechtliche Einschränkungen: So sind beispielsweise die photorealistischen 3D-Tiles der Google Maps Platform in der EU derzeit nur eingeschränkt für Simulationszwecke nutzbar @GoogleTilesAdjustments.

*Level of Detail:* Gebäudemodelle sollten mindestens in @lodet 2 vorliegen, um einen korrekten Schattenwurf in der Simulation zu generieren.

*Datenformat:* Die Wahl des Datenformats ist maßgeblich für den Import der Kontextmodelle. Semantische Formate wie CityGML oder CityJSON enthalten neben der Geometrie auch Attribute wie absolute Koordinaten, erfordern für die Verarbeitung in gängigen 3D-Engines jedoch meist eine vorherige Konvertierung. Rein geometrische Formate wie OBJ, glTF oder FBX bestehen hingegen ausschließlich aus 3D-Polygonnetzen. Sie ermöglichen eine direkte und performante Verarbeitung in der Simulationsumgebung, erfordern aufgrund der fehlenden Metadaten jedoch eine manuelle Georeferenzierung.

*Aktualität:* Die Daten müssen den aktuellen baulichen Bestand widerspiegeln. Insbesondere in dynamischen innerstädtischen Lagen (wie im Referenzprojekt Frankfurt) können veraltete Datensätze dazu führen, dass neu errichtete Hochhäuser in der Simulation fehlen und somit der Schattenwurf unterschätzt wird.

*Kostenstruktur:* Es ist zwischen kostenpflichtigen kommerziellen Daten und Open-Data-Initiativen zu unterscheiden. Viele Bundesländer (darunter Hessen und NRW) stellen ihre 3D-Gebäudemodelle in @lodet 2 mittlerweile kostenfrei über Open-Data-Portale zur Verfügung, was die wirtschaftliche Hürde für die Integration in die Gebäudeautomation eliminiert.

Basierend auf den zuvor genannten Kriterien erfolgt die Auswahl des geeigneten Datensatzes. Es empfiehlt sich, primär die Aktualität und Vollständigkeit der amtlichen Geodaten lokaler Vermessungsämter zu prüfen. Sollten in diesen Datensätzen relevante Gebäude fehlen, können die Geometrien durch externe Datenquellen ergänzt werden. Voraussetzung ist eine exakte Georeferenzierung der ergänzten Objekte, um die reale Situation im digitalen Modell präzise abzubilden.


// ==== Auswahl der Umgebungsszene
// - Gebäude, die nördlich des Referenzgebäudes liegen, müssen theoretisch nicht in der Simulation berücksichtigt werden. Um den genauen Bereich herauszufinden, muss der minimale und maximale Azimut der Sonne während der Sommersonnenwende (21./22. Juni) ermittelt werden. In Frankfurt am Main geht die Sonne mit einem Azimut von 50° auf und mit 310° unter. Somit kann die Umgebung in einem Azimut von 310°-50° zum Referenzgebäude nie einen direkt Schatten auf dieses werfen und somit vernachlässigt werden.
//   - bei sehr tiefliegender sonne werfen auch weit entferne gebäude schatten, dies ist allerdings vernachlässigbar, da die schattenkanten sich auch schnell bewegen
//   - gebäude sind nur  interessant, wenn sie einen schatten auf das referenzgebäude werfen können. somit sind gebäude in zweiter und dritter reihe nicht mehr zu berücksichtigen
// - Topologie muss nur importiert werden, wenn Berge, Hügel etc. das Gebäude verschatten könnten
// 
==== Auswahl der Umgebungsszene <AuswahlUmgebungsszene>
Die Auswahl der zu importierenden Umgebungsszene orientiert sich an der potenziellen Verschattungsrelevanz für das Referenzgebäude. Umliegende Bebauungen in zweiter oder dritter Reihe, deren Schattenwurf bereits durch näherstehende Objekte verdeckt wird, können vor der Simulation entfernt werden. Gleiches gilt für topografische Gegebenheiten: Ein Import von digitalen Geländemodellen ist nur dann erforderlich, wenn signifikante Erhebungen das betrachtete Gebäude in der Realität verschatten könnten.

Eine weitere Maßnahme zur Reduktion der Rechenlast und Datenmenge ist die Beschränkung auf relevante Himmelsrichtungen anhand der lokalen Sonnenbahn. Objekte, die sich nördlich des Referenzgebäudes befinden, können systematisch vernachlässigt werden. Die exakte Eingrenzung dieses Bereichs erfolgt über den minimalen und maximalen Sonnenazimut zum Zeitpunkt der Sommersonnenwende (21. beziehungsweise 22. Juni). Zum Beispiel für den Standort Frankfurt am Main liegt der Sonnenaufgang an diesem Tag bei einem Azimut von etwa 50° und der Sonnenuntergang bei 310°. Demzufolge kann die Umgebung im nördlichen Kreissektor zwischen 310° und 50° physikalisch zu keinem Zeitpunkt im Jahr einen direkten Schatten auf das Referenzgebäude werfen und bleibt im Modell unberücksichtigt. 
//HIER VLT NOCH KLEINE ZEICHNUNG DAZU ODER BILD ZUR VERANSCHAULICHUNG?:::

Zwar können weit entfernte Gebäude bei einer sehr tief stehenden Sonne (in den Morgen- oder Abendstunden) theoretisch einen Schattenwurf auf die Referenzfassade verursachen. Dieser Effekt ist im Kontext der Gebäudeautomation jedoch vernachlässigbar, da sich die resultierenden Schattenkanten aufgrund des flachen Einfallswinkels sehr schnell über die Fassade bewegen und somit keine relevante Tageslichtnutzung durch öffnen der Behänge erzielt werden könnte.

== Konzeption der Systemarchitektur und Simulationslogik
=== Räumliche und zeitliche Diskretisierung und Simulationsumfang <ZeitlicheAufloesungUmfang>

==== Zeitliche Diskretisierung:
 Die Wahl der zeitlichen Auflösung für die Verschattungsdaten hat maßgeblichen Einfluss auf das Verhältnis zwischen visuellem Komfort (Blendschutz) und der Tageslichtausbeute des Gebäudes. Da die Verschattungsinformation in der Steuerung eine binäre Freigabe (Schatten oder Sonne) darstellt, muss bei einer Reduktion der Datenauflösung zwingend eine Worst-Case-Annahme getroffen werden: Fällt innerhalb eines Simulationsintervalls auch nur für einen Bruchteil der Zeit Sonne auf das Fenster, muss der Sonnenschutz für das gesamte Intervall geschlossen werden, um temporäre Blendung auszuschließen. 

#figure(
  image("assets/AuflösungZeitstrahl.svg" ),
  caption: [Theoretischer Verschattungsverlauf an einem Referenzfenster mit beispielhafter Steuerung bei 5-, 15- und 60-minütiger Datenauflösung.],
  placement: none
)<fig-Zeitstrahl>


@fig-Zeitstrahl veranschaulicht diesen Effekt am Beispiel einer theoretischen Steuerung mit integrierten Verschattungsdaten in verschiedenen Auflösungen. Die Steuerungslogik definiert sich dabei wie folgt:
- *Fall offener Behang:* Die Steuerung detektiert für einen Zeitpunkt $t$, ob für den nächsten berechneten Zeitpunkt ($t+1$) Sonne auf das Fenster fällt. Falls ja, werden die Behänge präventiv geschlossen. 
- *Fall geschlossener Behang:* Die Steuerung detektiert für einen Zeitpunkt $t$, ob für den nächsten berechneten Zeitpunkt $t+1$ keine Sonne mehr auf das Fenster fällt und öffnet die Behänge erst zu diesem Zeitpunkt ($t+1$).

Dadurch wird garantiert, dass der Nutzer zu keinem Zeitpunkt einer Blendung ausgesetzt ist. Am beispielhaften Zeitstrahl verlässt der Schatten das Fenster um 10:23 Uhr. Bei einer groben stündlichen Diskretisierung hält die Steuerung den Behang jedoch schon ab 10:00 Uhr geschlossen, was zu 23 Minuten Verlust an natürlichem Tageslicht führt. Besonders gravierend wirkt sich diese zu grobe Abtastung bei schnellen, iterativen Verschattungsänderungen aus (beispielsweise in Großstädten mit dichter Hochhausbebauung). 

#block(inset: 8pt, fill: luma(240))[
Eine höhere Auflösung ermöglicht eine bessere Tageslichtautonomie...
]

Im Gegensatz dazu ermöglicht eine feine Auflösung von 5 Minuten, die Behänge sehr nah am realen Schattenverlauf des Fensters zu führen. Sie bildet den realen Schattenverlauf exakt ab und erfasst auch kurze Sonneneinstrahlungen durch Lücken in der Nachbarbebauung. Werden diese schnellen Wechsel jedoch direkt als Fahrbefehle an die Motoren weitergegeben, sinkt der Nutzerkomfort erheblich. Eine sich ständig bewegende Jalousie lenkt visuell und akustisch ab und erhöht den Verschleiß der Motoren deutlich.

Um diesen Konflikt zu lösen, muss die Steuerung die präzisen Umgebungsdaten von den tatsächlichen Fahrbefehlen entkoppeln. In der Gebäudeautomation werden dafür Verzögerungszeiten, sogenannte Totzonen, oder Hysteresen eingesetzt. Dadurch reagiert der Sonnenschutz nicht mehr auf jede minimale und kurzzeitige Schattenänderung.

Eine hohe Datenauflösung bleibt somit das konzeptionelle Optimum. Voraussetzung ist lediglich, dass die technische Infrastruktur die großen Datenmengen verarbeiten kann und die Steuerungsprogrammierung ständige Fahrbewegungen zuverlässig dämpft.

==== Zeitlicher Simulationsumfang:
Für die Konzeption der Simulation stellt sich zudem die Frage, wie viele Kalenderjahre berechnet werden müssen, um den realen Sonnenverlauf hinreichend abzubilden. Der Umlauf der Erde um die Sonne unterliegt zwar langperiodischen Schwankungen (Milanković-Zyklen@dwdMilanZyklen), diese sind für die Lebensdauer eines Gebäudes jedoch nicht relevant. Der berechnete Sonnenverlauf kann für den Betrachtungszeitraum als statisch angesehen werden. 

Da das kalendarische Jahr vom astronomischen Sonnenjahr (365,24 Tage) abweicht@astr04eduSonnenjahr, wird diese Differenz alle vier Jahre durch ein Schaltjahr korrigiert. Die hieraus resultierende zeitliche Verschiebung des Sonnenstandes am selben Kalendertag ist für einen simulierten Schattenwurf in @fig-schaltjahr beispielhaft dargestellt. 
#figure(
  image("assets/SchaltjahrUnterschied.png"), 
  caption: [Differenz des Schattenwurfs am 01.03. eines Normaljahres gegenüber einem Schaltjahr um 09:00 Uhr.],
  placement: auto
)<fig-schaltjahr>
Da sich die räumlichen Abweichungen des Schattens lediglich im Zentimeterbereich bewegen (roter Bereich), ist es für den Systemansatz ausreichend, die Simulation auf ein einzelnes Referenzjahr zu beschränken.

Zur weiteren Reduktion von Datenmenge und Rechenzeit ließe sich die Simulation auf jeden zweiten oder dritten Tag eines Jahres beschränken. Da die geometrischen Abweichungen des Sonnenstandes zwischen aufeinanderfolgenden Tagen marginal ausfallen, stellt dies einen methodisch vertretbaren Ansatz dar.

==== Räumliche Auflösung der Messpunkte <RaeumlicheAufloesung>

Die räumliche Abtastung der Fensterflächen bestimmt die Zuverlässigkeit der Simulation. Man muss festlegen, wie viele Testpunkte pro Fenster berechnet werden. Es werden drei verschiedene Optionen untersucht:

*1. Einpunkt-Messung (Fenstermittelpunkt):*
Es wird ein einzelner Raycast vom geometrischen Zentrum des Fensters zur Sonne berechnet. Dieser Ansatz hat den Vorteil, dass er die geringste Rechenzeit aufweist, allerdings anfällig für Situationen mit Teilverschattung ist: Verdeckt ein Schatten beispielsweise nur die untere Fensterhälfte, meldet der Mittelpunkt unter Umständen schon eine Verschattung des Fensters. Dabei ist die obere Fensterhälfte noch stark besonnt und verursacht Blendung.

*2. Vierpunkt-Messung (Eckpunkte):*
Die Simulation prüft die vier Extrempunkte der Fenstergeometrie. Sobald mindestens einer der vier Punkte direkte Sonneneinstrahlung detektiert, gilt das gesamte Fenster als besonnt. Teilverschattungen werden somit sicher erkannt, wodurch temporäre Blendungen verhindert werden. Der Nachteil ist eine ca. Verdopplung der Rechenzeit gegenüber der Einpunkt-Messung. Zudem können sehr schmale, vertikale Objekte (z. B. Masten), die schmaler als die Fensterbreite sind, theoretisch übersehen werden. Dies stellt im urbanen Kontext jedoch ein vernachlässigbares Restrisiko dar. In einzelnen Fällen, kann auch ein Schattenwurf, der nur die untere Fensterkante streift, zu einer nicht notwendigen Reaktion der Jalousie führen. Dies könnte mit dem Hochsetzen der unteren beiden Eckpunkte auf eine vertretbare Höhe verhindert werden.

*3. Raster-Messung:*
Ein feines Raster würde mehrere Punkte entlang der seitlichen Kanten des Fensters messen. Dies ermöglicht theoretisch eine genauere Steuerung der Behanghöhe, müsste allerdings in Kombination mit einer hohen zeitlichen Auflösung erfolgen. Ansonsten kann die Steuerung von der hohen örtlichen Datendichte nicht profitieren und müsste die zwischen den groben Zeitintervallen weit gewanderte Schattenkante in großen Sprüngen nachführen.
Der Nachteil wäre außerdem eine Vervielfachung der Rechenzeit und eine komplexere Datenstruktur.


=== Algorithmische Verfahren und Fehlervermeidung<kap-algVerfahren>
==== Front-Face Check<kap-frontface>
Um die Rechenzeit des Algorithmus signifikant zu reduzieren und unnötige Raycasts zu vermeiden, wird den eigentlichen Kollisionsabfragen ein Filterverfahren vorgeschaltet. Dieser Schritt basiert auf der mathematischen Logik des aus der 3D-Computergrafik stammenden Back-Face Cullings, fungiert im physikalischen Kontext der Gebäudeanalyse jedoch als Eigenschatten-Prüfung (Front-Face Check). Das Prinzip stellt sicher, dass Fensterflächen, die auf der abgewandten Schattenseite des Gebäudes liegen, frühzeitig identifiziert und von der weiteren Berechnung ausgeschlossen werden. Die technische Umsetzung erfolgt über die Auswertung des Skalarprodukts zwischen dem Normalenvektor der Fensterfläche $vec(n)$ und dem Richtungsvektor der Solarstrahlung $vec(r)$ (Strahl vom Fenster zur Sonne). 
Wie in @fig-normalsCheck vereinfacht dargestellt, erkennt man eine Gebäudeecke in der Draufsicht mit Fenstern an der Außenseite. Es werden Strahlen (Rays) horizontal vom Mittelpunkt des Fensters in Richtung der Sonne dargestellt.

#figure(
  image("assets/Back_Face_Culling.png", width: 70%),
  caption: [Draufsicht einer Gebäudeecke mit der Sonne zugewandten und abgewandten Fenstern],
  placement: auto
)<fig-normalsCheck>

Die Entscheidung, ob eine Fläche der Sonne zugewandt ist, hängt vom Winkel $alpha$ zwischen diesen beiden Vektoren ab:
- *Fenster A (zugewandt)*: Da der Winkel $alpha_A$ weniger als 90° beträgt, weisen die Vektoren in die selbe Richtungen (das Skalarprodukt ist positiv). Das System erkennt, dass die Fensterfläche der Sonne zugewandt ist und eine Verschattungsprüfung stattfinden muss.
- *Fenster B (abgewandt)*: Da der Winkel $alpha_B$ mehr als 90° beträgt, zeigen die Vektoren in die entgegengesetzte Richtung --- der Strahl entspringt also von der Rückseite der Fensterfläche. Das Skalarprodukt ist in diesem Fall negativ, und die Geometrie wird durch das den Front-Facing check ignoriert.
Um Fehlkalkulationen in diesem Schritt auszuschließen, muss garantiert sein, dass alle Flächennormalen im 3D-Modell konsistent nach außen gerichtet sind.

==== Vermeidung von Selbstverschattung
Bei der Konzeption der auf Raycasting basierenden Simulationsarchitektur (vgl. Grundlagen in Kapitel 2.x) muss eine bekannte Problematik der 3D-Simulation berücksichtigt werden: sogenannte Self-Intersection-Fehler (Selbstverschattungen). Da Fenster in @bim#[]- und @ifc#[]-Modellen häufig als Volumenkörper modelliert sind, kann ein direkt an der Glasfläche startender Teststrahl aufgrund von minimalen mathematischen Rundungsfehlern (Floating-Point-Ungenauigkeiten) sofort mit der Innenseite oder dem Rahmen der eigenen Geometrie kollidieren. Das Fenster würde sich algorithmisch somit selbst verschatten.

Um dies zu verhindern, ohne auf rechenintensive Auswertungen der getroffenen Flächennormalen zurückgreifen zu müssen, wird in der Simulationslogik ein Start-Offset (Ray Bias) definiert. Der geometrische Ursprung des Prüfstrahls wird dabei nicht exakt auf der Glasfläche platziert, sondern entlang des Richtungsvektors virtuell um ein definiertes Maß (beispielsweise 10cm) in den Außenraum verschoben. Die eigentliche Kollisionsprüfung beginnt somit sicher außerhalb der eigenen Fenster- und Laibungsgeometrie, was die Robustheit der Gesamtsimulation signifikant erhöht.

=== Systemarchitektur und Schnittstellen<DefinitionSystemarchitektur>

*Vorberechnung oder dynamisch?*
Hier geht es um die Grundsatzentscheidung: Handelt es sich um ein zustandsloses System, das einmalig einen Fahrplan (Schedule) generiert, oder um ein dynamisches System, das auf Veränderungen (beispielsweise neue Verschattungsobjekte durch Baustellen) reagieren kann. Du kannst hier begründen, warum du dich für den einen oder anderen Weg entschieden hast, bevor du in die Umsetzung gehst.

- *Workflow-Design:* Hier vlt. Flow-Chart mit gesamter Prozesskette von @ifc#[]-Modell bis Integration in GA
- Tabelle mit Elevationswinkel könnte mitgegeben oder auf AS berechnet werden(Vermeidung von Redundanz: Die Sonnenhöhe (Elevation) ist zu einem bestimmten Zeitpunkt für das gesamte Gebäude (und somit für alle ~6000 Fenster) identisch.) 
- Status R, V, N - Azimut erklären
  - hat auch vorteil für debugging oder nachvollziehbarkeit der daten
- *Mapping-Konzept:* Entwicklung einer Logik zur Verknüpfung der Simulationsergebnisse mit den physischen Datenpunkten der Gebäudeautomation (beispielsweise BACnet-Objekt-IDs).
- Auch die Frage: Auf welchem Rechner sollten die Daten gespeichert werden? Extern oder intern beim Kunden?

== Integrationskonzepte für die Gebäudeautomation
=== Vorschlag eines modifizierten Funktionsblock nach VDI 3813

Basierend auf der Analyse der VDI 3813-2 (vgl. @kap-vdi3813) wird für die entwickelte Systemarchitektur ein modifizierter Funktionsblock konzipiert. Ziel ist es, sowohl die rechenintensive geometrische Kollisionsprüfung als auch die Verwaltung der fassadenspezifischen Ausrichtungswinkel in die vorgelagerte Simulation auszulagern. 

Standardisierte Funktionsblöcke zur Lamellennachführung verarbeiten üblicherweise den globalen Sonnenstand, der in der Automationsstation für jede Fassadenachse mit einem lokalen Offset verrechnet werden muss. Der hier konzipierte Funktionsblock empfängt stattdessen über den Dateneingang (`SIM_DATA`) einen multimodalen Datensatz, der fensterspezifische, relative Parameter enthält, und routet diese als Steuergrößen an die nachgelagerten Instanzen.

Die interne Steuerungslogik wertet den eintreffenden Datentyp aus und schaltet die Signale nach folgenden Kriterien:

- *Prioritäre Überschreibung (Zustände V, R, N):* Empfängt der Block eines der definierten alphanumerischen Zeichen für Fremdverschattung (V), Rückseiten-Ausblendung (R) oder Nacht (N), wird ein anliegender Schließbefehl der Thermoautomatik blockiert. Der Block überschreibt das Stellsignal (`S_AUTO`) mit der parametrierten Parkposition (`PAR_PARK`). Zeitgleich wird über den binären Ausgang (`B_ON = FALSE`) die nachgelagerte Lamellennachführung deaktiviert, da ohne direkte Besonnung kein aktiver Blendschutz erforderlich ist.
- *Signalweitergabe und Nachführung (Numerischer Wert):* Registriert der Eingang einen numerischen Gleitkommawert, wird dies vom System als direkte Besonnung gewertet. Das Stellsignal (`S_AUTO`) wird in diesem Fall unverändert durchgereicht und die Blendschutz-Automatik aktiviert (`B_ON = TRUE`). Der empfangene Zahlenwert entspricht dem in der Simulation berechneten Einfallswinkel der Sonne relativ zur Fensternormale. Dieser Wert wird über den Ausgang `A_SUN_AZ` direkt an die Lamellennachführung übergeben. 

*Vorteile für die Systemintegration:* Durch diese Architektur ist es nicht mehr erforderlich, die fassadenspezifischen Gebäudegeometrien in der @as zu hinterlegen. Die statische Parametrierung von Grenzwinkeln und Fassaden-Azimuten bei der Systemintegration entfällt, was die Fehleranfälligkeit verringert und den softwaretechnischen Inbetriebnahmeaufwand der Automationslösung reduziert.
#figure(
  image("assets/FunktionsblockNeu.png", width: 60%),
  caption: [Konzept des modifizierten Funktionsblocks für eine simulationsbasierte Verschattungskorrektur]
)<fig-NeuerFunktionsblock>



// Aus informationstechnischer Sicht (Separation of Concerns) wird die zeitliche Auswertung der generierten Verschattungsdaten (Array-Handling) von der logischen Verschattungskorrektur getrennt. Ein übergeordnetes Zeitprogramm (beispielsweise ein BACnet Schedule Object) gleicht die interne Systemuhr mit dem importierten CSV-Datensatz ab und übergibt lediglich den aktuellen, binären Verschattungsstatus an den modifizierten Funktionsblock. Der Block selbst benötigt somit keine Echtzeituhr (RTC), was ihn hardware-schonend und echtzeitfähig macht."


=== Überlegung zur Integration in die Gebäudeautomation...
- Daten könnten per MQTT oder andere Schnittstelle übergeben werden
- Daten werden von Programmen der Raumautomation zur Jalousiensteuerung genutzt
  - Stuerung muss vorausschauend funktionieren (wie in @ZeitlicheAufloesungUmfang aufgezeigt)
- Die Steuerung funktioniert nur in Kombination mit einer Wetterstation auf dem Dach
  - Man müsste dort die direkte und indirekte strahlung messung können
- Der Datenoutput mit N, R, V und Azimutwinkel  ermöglicht maximale Flexibilität um verschiedene Steuerung zu ermöglichen
- Cut-Off-Angle kann definiert werden mit Höhenwinkel
- Mit Azimut können sehr flache einfallende Sonnenstrahlen toleriert werden, wenn z.B. Säulen zwischen den Fenstern aufgestellt sind
- Negative Seiten von Beschattung: laute fahrbewegungen, visuell störend durch sich bewegende (auch bei Änderung Winkel lamelle) behänge und durch starkes abdunkeln während fahrbewegungen. 
