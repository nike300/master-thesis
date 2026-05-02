#import "template/lib.typ": *
= Theoretische Grundlagen<TheoretischeGrundlagen>
== Astronomische und Geometrische Grundlagen <GeometrischeGrundlagen>

In diesem Kapitel werden die astronomischen und geometrischen Gesetzmäßigkeiten hergeleitet, die für die Berechnung des Schattenwurfs maßgeblich sind. 

=== Sonnenbahnmechanik <Sonnenbahnmechanik>
Für eine exakte Verschattungssimulation muss die Position der Sonne bekannt sein. Im Folgenden werden die Berechnungsgrundlagen für die Wahre Ortszeit, den Stundenwinkel sowie für Deklination, Höhenwinkel und Azimut dargelegt (siehe @fig-sonnenmodell).

#figure(
  image("assets/SonnenstandWinkelbezeichnung.png", width: 60%),
  caption: [
    Winkelbezeichnungen des Sonnenstandes @Quaschning
  ],
)<fig-sonnenmodell>

==== Wahre Ortszeit <WahreOrtszeit>
Wie Duffie und Beckman @Duffie2013 herleiten, sind für die Berechnung der Wahren Ortszeit ($t_"WOZ"$) folgende Parameter notwendig:

- $t_"std"$: Gesetzliche Ortszeit (Local Standard Time) in Stunden.
- $n$: Tag des Jahres (1 bis 365).
- $lambda_"loc"$: Geografischer Längengrad des Standorts (in Grad).
- $lambda_"std"$: Bezugslängengrad der Zeitzone (z. B. $15 degree$ für MEZ).
- $E$: Zeitgleichung (Equation of Time) in Minuten.

Die Wahre Ortszeit berechnet sich wie folgt #footnote[Vorzeichenkonvention gemäß ISO 6709 (Ost positiv). Duffie/Beckman verwenden hier invertierte Vorzeichen (West positiv).]:

$ t_"WOZ" = t_"std" + frac(4 dot (lambda_"loc" - lambda_"std") + E, 60) $

Der Divisor 60 ist notwendig, um die Zeitkorrektionen (Minuten) in das Format der Basiszeit (Stunden) zu überführen. Die Zeitgleichung $E$ (in Minuten) wird angenähert durch:

$ E &= 229.18 dot (0.000075 + 0.001868 cos(B) - 0.032077 sin(B) \
  &- 0.014615 cos(2B) - 0.040849 sin(2B)) $

mit dem Hilfswinkel $B$:
$ B &= (n - 1) dot frac(360, 365) $

==== Stundenwinkel ($omega$) <Stundenwinkel>
Um die zeitliche Komponente in die geometrische Berechnung einzuführen, wird die Wahre Ortszeit ($t_"WOZ"$) in den Stundenwinkel $omega$ umgerechnet. Da die Erde sich um $15 degree$ pro Stunde dreht, gilt:

$ omega = (t_"WOZ" - 12) dot 15 degree $

Dabei entspricht $omega = 0 degree$ dem solaren Mittag (Sonne exakt im Süden). Vormittagswerte sind negativ, Nachmittagswerte positiv.

==== Sonnendeklination ($delta$) <Sonnendeklination>
$delta$ ist der Winkel zwischen der Verbindungslinie Erde-Sonne und der Äquatorebene. Sie beschreibt die Neigung der Erde in Relation zur Sonne und variiert im Jahresverlauf zwischen $-23,45 degree$ und $+23,45 degree$.

Für die Bestimmung der Sonnenposition wird das Berechnungsverfahren gemäß DIN EN 17037 (Tageslicht in Gebäuden) angewendet @dinen17037.
Ausgangsbasis für die Sonnendeklination $delta$ ist die Tageszahl $J$ (1 für 1. Januar bis 365 für 31. Dezember) und der daraus abgeleitete Jahreswinkel $J'$:

$ J' = 360 degree dot frac(J, 365) $

Die Deklination $delta(J)$ ergibt sich gemäß Gleichung D.3 der Norm:

$ delta(J) &= 0.3948 \
  &- 23.2559 dot cos(J' + 9.1 degree) \
  &- 0.3915 dot cos(2 dot J' + 5.4 degree) \
  &- 0.1764 dot cos(3 dot J' + 26.0 degree) $ <deklinationsgleichung>

// #block(inset: 8pt, fill: luma(240))[
//   *Hinweis zur Implementierung:*
//   Die Koeffizienten liefern das Ergebnis in Grad. Für die geometrische Weiterverarbeitung im Simulationsmodell (siehe kapitel 5???) erfolgt eine Umrechnung in das Bogenmaß (Radiant).
// ]

==== Sonnenhöhenwinkel ($gamma_s$) <Sonnenhoehenwinkel>
Der Sonnenhöhenwinkel beschreibt den vertikalen Winkel zwischen der horizontalen und der Sonne. Er ist maßgeblich für die effektive Einstrahlung auf Fassadenflächen sowie für die Berechnung der Schattenlängen.

Basierend auf dem geografischen Breitengrad $phi$, der zuvor berechneten Deklination $delta$ und dem Stundenwinkel $omega$ ergibt sich der Höhenwinkel aus der grundlegenden Gleichung der sphärischen Astronomie:

$ sin(gamma_s) = sin(phi) dot sin(delta) + cos(phi) dot cos(delta) dot cos(omega) $

Durch Umstellung nach $gamma_s$ erhält man den expliziten Winkel:

$ gamma_s = arcsin(sin(phi) dot sin(delta) + cos(phi) dot cos(delta) dot cos(omega)) $

Dabei gelten folgende Randbedingungen:
- $gamma_s > 0 degree$: Die Sonne steht über dem Horizont (Tag).
- $gamma_s <= 0 degree$: Die Sonne steht unter dem Horizont (Nacht/Dämmerung).

// #block(inset: 8pt, fill: luma(240))[*Relevanz für die Simulation:*In der Prozesskette (Kapitel 5) dient die Prüfung $gamma_s > 0$ als erster Filter ("Early Exit"). Ist der Wert negativ, muss kein aufwendiges Raycasting durchgeführt werden, da keine direkte Verschattung möglich ist.]

==== Sonnenazimut ($alpha_s$) <Sonnenazimut>
Der Sonnenazimut beschreibt die horizontale Himmelsrichtung der Sonne. In Übereinstimmung mit der Norm DIN 5034-1 ist der Bezugspunkt die geografische Nordrichtung. Der Winkel wird im Uhrzeigersinn von $0 degree$ (Nord) bis $360 degree$ gemessen.

Die Berechnung erfolgt abhängig von der Wahren Ortszeit @Quaschning:

$ alpha_s = cases(
  180 degree - arccos(frac(sin(gamma_s) dot sin(phi) - sin(delta), cos(gamma_s) dot cos(phi))) & "für" t_"WOZ" <= 12,
  180 degree + arccos(frac(sin(gamma_s) dot sin(phi) - sin(delta), cos(gamma_s) dot cos(phi))) & "für" t_"WOZ" > 12
) $

//#block(inset: 8pt, fill: luma(240))[ *Vorteil für die Simulation:* Diese Definition (Nord = $0 degree$, im Uhrzeigersinn) entspricht dem Koordinatensystem gängiger 3D-Software und GIS-Daten.]

=== Vergleich und Auswahl der Berechnungsverfahren <VergleichAuswahlBerechnungsverfahren>
Die in den vorangegangenen Abschnitten dargestellten Formeln der DIN EN 17037 stellen die normative Grundlage für die Tageslichtplanung in Europa dar. Sie bieten eine hinreichende Genauigkeit.

Für die Implementierung des Simulations-Prototyps (siehe Kapitel 4) wird jedoch auf den Algorithmus der National Oceanic and Atmospheric Administration (@noaa) zurückgegriffen. Dieser zeichnet sich durch folgende Merkmale aus:

- Höhere Präzision: Während einfache Näherungen Fehler von bis zu $1 degree$ aufweisen können, minimiert der @noaa#[]-Algorithmus (basierend auf den Arbeiten von Jean Meeus @Meeus1998) die Abweichungen auf unter $0,0001 degree$.
- Berücksichtigung atmosphärischer Effekte: Der Algorithmus inkludiert Korrekturfaktoren für die atmosphärische Refraktion, was insbesondere bei flachen Sonnenständen (Morgen- und Abendstunden) für die Lamellennachführung in der Gebäudeautomation kritisch ist.

Auf eine detaillierte mathematische Herleitung der über 30 Korrekturterme des @noaa#[]-Verfahrens wird an dieser Stelle verzichtet; die Berechnung folgt der dokumentierten Implementierung gemäß @NOAASolar2021.


=== Geometrie der Verschattung <GeometrieVerschattung>
Nachdem die Position der Sonne bestimmt wurde, muss im nächsten Schritt geprüft werden, ob die direkte Sichtlinie zwischen einem betrachteten Punkt auf der Fassade (z. B. Fenstermittelpunkt) und der Sonne durch Hindernisse unterbrochen wird.

Eine etablierte Methode zur Visualisierung dieser Umgebungsverschattung für einen spezifischen Referenzpunkt am Gebäude ist das Sonnenbahndiagramm (siehe @fig-Sonnenbahndiagramm). Dafür müssen für alle hindernisse in der Umgebung der Höhenwinkel und Azimutwinkel ausgemessen werden. Aus dieser zweidimensionalen Darstellung der Sonnenbahnen und der Umgebungssilhouette lassen sich Grenzwinkel ableiten, ab denen ein externes Objekt einen Schatten auf den betrachteten Punkt wirft. 
#figure(
  image("assets/Sonnenstandsdiagramm.png", width: 70%),
  caption: [Sonnenbahndiagramm mit Umgebungssilhouette @Quaschning.],
  placement: auto
) <fig-Sonnenbahndiagramm>

==== Der Sonnenvektor <Sonnenvektor>
Für die geometrische Simulation in 3D-Umgebungen ist die sphärische Darstellung (Winkel) oft unpraktisch. Stattdessen wird die Sonnenposition als normierter Richtungsvektor $vec(S)$ im kartesischen Koordinatensystem definiert. 

Unter der Annahme eines Z-up-Koordinatensystems (z. B. in IFC-Modellen üblich, $Z$ zeigt zum Zenit, $Y$ nach Norden) berechnet sich der Sonnenvektor aus Azimut $alpha_s$ und Elevation $gamma_s$:

$ vec(S) = mat(
  sin(alpha_s) dot cos(gamma_s);
  cos(alpha_s) dot cos(gamma_s);
  sin(gamma_s)
) $

Dieser Vektor zeigt vom Ursprung zur Sonne. Für die Verschattungsberechnung wird der Vektor invertiert ($-vec(S)$), um die Einstrahlungsrichtung zu simulieren.

// ==== Klassifizierung der Verschattungstypen <KlassifizierungVerschattungstypen>
// Man unterscheidet in der Simulation zwei wesentliche Ursachen für den Schattenwurf:

// - *Fremdverschattung:* Verursacht durch Objekte außerhalb der eigenen Gebäudehülle, wie Nachbarbebauung, Vegetation oder Topografie. Diese Geometrien sind im Betrieb statisch, müssen aber im digitalen Modell (IFC/CityGML) präzise abgebildet sein.
// - *Eigenverschattung:* Verursacht durch die Gebäudegeometrie selbst, z. B. durch Fassadenvorsprünge, Balkone oder die Laibungstiefe des Fensters. Besonders die Laibungstiefe spielt bei steilen Sonnenständen eine kritische Rolle für das Vorausschauen des effektiven Lichteintrag.

=== Raycasting-Verfahren zur Kollisionserkennung
Das Raycasting (Strahlenverfolgung) ist ein grundlegendes Verfahren der 3D-Computergrafik, das primär zur Ermittlung von Sichtbarkeiten und geometrischen Schnittpunkten im dreidimensionalen Raum eingesetzt wird. Im Kontext der Gebäudeanalyse dient dieser Algorithmus dazu, Fremdverschattungen durch urbane Umgebungsstrukturen (wie Nachbargebäude oder Topografie) präzise zu detektieren.

Anders als in der physikalischen Realität, in der Lichtstrahlen von der Lichtquelle emittiert werden, arbeitet das hier angewandte Verfahren aus Gründen der Recheneffizienz invers (Backward Raytracing). Ausgehend von den zu untersuchenden Empfängerflächen – in der Verschattungssimulation den Messpunkten der Fenster – wird ein linearer Prüfstrahl (Ray) generiert. Dieser Strahl wird exakt entlang des berechneten Sonnenrichtungsvektors $vec(r)$ in den Raum projiziert. Die zugrundeliegende Engine berechnet anschließend mathematisch, ob dieser Strahl auf seinem Weg eine andere Polygonfläche (Mesh) schneidet. Registriert der Algorithmus eine Kollision mit einer Objektgeometrie (Intersection), bevor der Strahl die theoretische Distanz zur Lichtquelle erreicht, gilt der ausgehende Fensterpunkt als durch ein Hindernis verschattet. Hat der Strahl hingegen freie Bahn, wird direkte Besonnung protokolliert.

=== Raytracing und Reflexionen <RaytracingReflexionen>

Während das zuvor beschriebene Raycasting-Verfahren primär die binäre Sichtbarkeit zwischen einem Messpunkt und der Lichtquelle prüft, erweitert das Raytracing dieses Prinzip um die rekursive Verfolgung von Lichtstrahlen nach deren erster Interaktion mit einer Oberfläche @tuwien_raytracing. Diese Methode ermöglicht die physikalisch korrekte Simulation komplexer optischer Phänomene im städtischen Kontext. Dazu zählen insbesondere Spiegelungen, die zu zusätzlichen Blendereignissen durch reflektierende Glasfassaden gegenüberliegender Gebäude führen können. Ebenso lässt sich die diffuse Streuung abbilden, welche eine Aufhellung von Innenräumen durch helle Umgebungsflächen bewirkt.

Für den operativen Einsatz stellt Raytracing jedoch eine Herausforderung dar. Zum einen steigt der erforderliche Rechenaufwand mit der Anzahl der simulierten Lichtsprünge exponentiell an, was der Anforderung an die verwendete Hardware signifikant erhöht. Zum anderen scheitert die Umsetzung in der Praxis an der unzureichenden Datengrundlage. Für eine valide Berechnung müssen im gesamten 3D-Modell präzise Materialparameter wie Reflexionsgrad und Oberflächenrauheit hinterlegt sein. Wie die spätere Analyse der Gebäudemodelle in Kapitel @Datenaufbereitung zeigt, fehlen diese spezifischen semantischen Informationen in IFC-Modellen und Städtemodellen in der Regel vollständig. Aus diesem Grund beschränkt sich die in dieser Arbeit entwickelte Prozesskette auf das binäre Raycasting zur Schattenermittlung.

// *Abgrenzung für diese Arbeit:*
// ???Da der primäre Energieeintrag durch direkte Solarstrahlung erfolgt und die Datengrundlage für Reflexionseigenschaften in 3D-Modellen oft unzureichend ist, fokussiert sich der entwickelte Prozess (@Kap4[Kapitel]) auf das geometrische Raycasting. Reflexionen werden als sekundärer Einflussfaktor betrachtet und im Ausblick (@Kap5[Kapitel]) diskutiert.

== Digitale Gebäudemodelle und Geoinformatik
=== Building Information Modeling und Austauschformate <kap-bim>

Der Datenaustausch im Bauwesen hat sich von analogen Plänen hin zu digitalen Methoden entwickelt. Während 2D-Grundrissdateien in Formaten wie DWG oder DXF weiterhin Anwendung finden, werden sie zunehmend durch objektbasierte 3D-Modelle abgelöst. Diese bieten eine höhere Dichte an geometrischen Informationen und erleichtern das räumliche Verständnis komplexer Strukturen.

Building Information Modeling (@bim) beschreibt einen durchgängigen, prozessorientierten Ansatz von der Planung bis zum Betrieb. BIM strukturiert die gewerkeübergreifende Zusammenarbeit und standardisiert den Informationsfluss. Der OpenBIM-Ansatz setzt hierbei auf herstellerneutrale Dateiformate, um Interoperabilität und Flexibilität bei der Softwareauswahl zu gewährleisten.

Das objektorientierte Austauschformat @ifc (Industry Foundation Classes) ermöglicht die Anreicherung der Geometrie mit semantischen Attributen. Innerhalb der entwickelten Prozesskette dient diese Struktur dazu, simulationsrelevante Bauteile automatisiert zu identifizieren. Während die Klasse IfcSite die Georeferenzierung ermöglicht, definieren Klassen wie IfcWindow die betrachteten Fensterflächen. Maßgeblich für die Simulationsgüte ist ein adäquater Detaillierungsgrad (@lod), um Eigenverschattungen durch Laibungen oder Auskragungen im Raycasting-Verfahren präzise abzubilden.

Für die Abbildung des urbanen Kontextes dient das Format CityGML als internationaler Standard für semantische Stadtmodelle. In Ergänzung zur hohen Detailtiefe des IFC-Gebäudemodells liefert CityGML die notwendigen Umgebungsdaten zur Detektion von Fremdverschattung. Das effizientere Austauschformat CityJSON findet ebenfalls Anwendung. Im makroskopischen Bereich bildet das Level of Detail 2 (Dachmodell) den optimalen Kompromiss, um Verschattungsfehler durch vereinfachte Blockmodelle zu vermeiden.

// BIM, IFC, Simulationswerkzeuge (Überblick).
// Folgende Dateiformate werden verwendet:
// .ifc
// .dwg
// .JSON
// .dxf
// .blend
// .gml
// .csv

=== Spezifikation der Modellierungstiefe (LOD / LoD)

Für die Validität einer Verschattungssimulation ist die Definition der Modellierungstiefe entscheidend. Dabei muss begrifflich zwischen dem gebäudezentrierten Ansatz des Building Information Modeling und dem stadtmodellzentrierten Ansatz der Geoinformatik unterschieden werden. Zur besseren Abgrenzung wird im Folgenden der Level of Development mit LOD und der Level of Detail mit LoD abgekürzt.

In der BIM-Methodik beschreibt der @lod sowohl den geometrischen Detaillierungsgrad (Level of Geometry) als auch den semantischen Informationsgehalt (Level of Information). Die Skala reicht üblicherweise von einer konzeptionellen Darstellung (@lod 100) bis hin zum dokumentierten As-Built-Zustand (@lod 500). Für die Untersuchung der Gebäudeautomation und insbesondere der Eigenverschattung ist ein @lod von mindestens 300 oder 350 erforderlich. Erst ab dieser Stufe sind Bauteile wie Fensterlaibungen, Stürze oder Fassadenrücksprünge geometrisch so exakt verortet, dass sie in einer Simulation als relevante Verschattungsobjekte fungieren können.

In der Geoinformatik und speziell im Kontext von CityGML wird der Begriff #gls("lodet", long: true) verwendet, um die Komplexität der äußeren Gebäudehülle im urbanen Raum zu definieren. Gemäß dem Standard des @ocg werden hierbei maßgeblich folgende Stufen unterschieden:

- @lodet#[]0 (Grundriss-/Geländemodell): Das Gebäude wird lediglich als zweidimensionaler Grundriss oder Dachumriss dargestellt. Da keine echte vertikale Volumenausdehnung vorhanden ist, ist dieser Detailgrad für eine dreidimensionale Verschattungssimulation ungeeignet.
- @lodet#[]1 (Blockmodell): Das Gebäude wird als einfacher Kubus mit Flachdach dargestellt, was einer Extrusion der Grundfläche entspricht. Diese Abstraktion ist für weit entfernte Verschattungsobjekte ausreichend, führt jedoch im Nahbereich zu Fehlern, da die tatsächliche Dachform ignoriert wird.
- @lodet#[]2 (Dachmodell): Das Modell beinhaltet standardisierte Dachformen und grobe Dachaufbauten. Für die Verschattungssimulation stellt @lod#[]2 oft den optimalen Kompromiss aus geometrischer Genauigkeit und Dateigröße dar @Hessen3D.
- @lodet#[]3 (3D Mesh): Hier werden detaillierte Gebäudehüllen mit Auskragungen, Fensterlaibungen und Texturen modelliert. @lod#[]3 bietet eine sehr hohe Genauigkeit für die Simulation der Umgebungsverschattung, hat jedoch aufgrund der hohen Polygonanzahl einen negativen Einfluss auf die Rechenleistung.

#figure(
  image("assets/LOD1-3.png", width: 100%),
  caption: [Darstellung der CityGML-#gls("lodet", long: true) 0 bis 3 @ogcCityGeography]
)<fig-lod>

Während der BIM-@lod den Fokus auf die interne Intelligenz und die präzise Konstruktion des betrachteten Objekts legt, dient der CityGML-@lodet der effizienten Repräsentation der Umgebungssilhouette. Für eine durchgängige Prozesskette müssen beide Welten so miteinander verknüpft werden, dass das hochdetaillierte @bim#[]-Modell präzise in das Stadtmodell eingebettet werden kann.

=== Koordinatenreferenzsysteme<Koordinatenreferenzsysteme>

Die Georeferenzierung beschreibt die Zuweisung räumlicher Bezugsinformationen zu einem Datensatz. Für die dynamische Verschattungssimulation ist sie von zentraler Bedeutung, da das lokale Gebäudemodell (BIM) millimetergenau mit den Umgebungsdaten überlagert werden muss. Nur durch einen einheitlichen räumlichen Bezug lässt sich der korrekte solare Einfallswinkel auf die Fassade berechnen. In der Bauplanung und Geoinformatik wird dabei zwischen dem geodätischen Bezugssystem (dem Referenzrahmen) und dem Koordinatensystem (der Kartenprojektion) unterschieden.

==== Geodätische Bezugssysteme (WGS 84 und ETRS89)
Ein Bezugssystem definiert das mathematische Modell der Erdform, meist in Form eines Rotationsellipsoids. Das World Geodetic System 1984 (WGS 84) ist ein globales System und dient unter anderem als Grundlage für die satellitengestützte Positionsbestimmung (GPS). Für Projekte innerhalb Europas wird stattdessen das European Terrestrial Reference System 1989 (ETRS89) verwendet. Im Gegensatz zum globalen WGS 84 ist ETRS89 fest mit der eurasischen Kontinentalplatte verbunden. Dies verhindert, dass sich Koordinaten durch die Kontinentaldrift gegenüber dem Boden verändern. In der BIM-Methodik werden diese Systeme genutzt, um den globalen Referenzpunkt innerhalb der Entität IfcSite zu definieren. 

==== Kartenprojektionen (Gauß-Krüger und UTM):
Eine Projektion stellt die mathematische Rechenvorschrift dar, um die Koordinaten eines gekrümmten geodätischen Bezugssystems auf eine zweidimensionale, ebene Fläche zu übertragen. Das Gauß-Krüger-Koordinatensystem (GK) ist ein historisch gewachsenes deutsches System, das klassischerweise auf dem Bessel-Ellipsoid basiert, jedoch auch mit dem modernen ETRS89 kombiniert werden kann. Es unterteilt das Gebiet in 3 Grad breite Meridianstreifen (siehe @fig-koordinatensysteme links). Das Universal Transverse Mercator System (UTM) bildet den heutigen internationalen Standard für projizierte Koordinaten. Ein wesentlicher Vorteil des UTM-Systems ist seine Flexibilität gegenüber dem zugrunde liegenden Referenzrahmen; es kann sowohl auf dem globalen WGS 84 als auch auf dem für Europa stabilen ETRS89 aufsetzen. Durch die Aufteilung der Erde in 6 Grad breite Zonen (siehe @fig-koordinatensysteme rechts) bietet UTM eine weltweit einheitliche und verzerrungsarme Darstellung. Zur Veranschaulichung sind in @tab:koordinaten_formate die entsprechenden Koordinaten des Referenzstandorts FOUR in Frankfurt am Main für die verschiedenen Systeme zusammenfassend gegenübergestellt.
#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    image("assets/GaußKrüger.png", width: 100%),
    image("assets/UTM.png", width: 100%)
  ),
  caption: [Vergleich der Meridianstreifen von Gauß-Krüger (links) und UTM (rechts) @computerworks_gis_gk_utm],
  placement: auto
) <fig-koordinatensysteme>


#figure(
  table(
    columns: (auto, 1fr),
    align: left,
    inset: (y: 6pt, x: 8pt),
    stroke: (x, y) => (
      left: none,
      right: none,
      top: if y > 0 { 0.5pt } else { none },
      bottom: none,
    ),
    [*Format*], [*Koordinatenwert*],
    [Dezimalgrad], [N 50.1126° / E 8.6747°],
    [Grad Minuten], [N 50° 6.756' / E 8° 40.482'],
    [Grad Minuten Sekunden], [N 50° 6' 45.36'' / E 8° 40' 28.92''],
    [Gauß Krüger], [GK3 R 3476770 H 5552976],
    [UTM], [32U E 476703 N 5551194]
  ),
  caption: [Gegenüberstellung geografischer und projizierter Koordinaten für das Referenzprojekt FOUR@koordinaten_umrechner],
  placement: auto
) <tab:koordinaten_formate>


== Verschattungssysteme und Raumautomation <Verschattungssysteme>
=== Systematik steuerbarer Sonnenschutzsysteme

In der Gebäudeautomation werden Sonnenschutzsysteme primär nach der Anzahl ihrer mechanischen Freiheitsgrade klassifiziert. Diese technische Einteilung bestimmt maßgeblich die Flexibilität der Steuerung sowie das Potenzial zur Tageslichtnutzung.

Systeme mit einem Freiheitsgrad umfassen vorwiegend Rollläden und textile Screens, welche als vertikal geführte Stoffbahnen fungieren. Die einzige verfügbare Steuergröße bei diesen Systemen ist die prozentuale Behanghöhe. Da sie lediglich vertikal auf- und abgefahren werden können, bieten sie nur ein sehr begrenztes Potenzial zur Steuerung der Tageslichtqualität im Rauminneren. Sie finden vorwiegend im Wohnungsbau Anwendung.

Systeme mit zwei Freiheitsgraden, insbesondere außenliegende Raffstores beziehungsweise Jalousien, bilden hingegen den Standard im modernen Büro- und Verwaltungsbau. Diese Anlagen verfügen über die beiden Steuergrößen Behanghöhe und Lamellenwinkel. Die Möglichkeit, die Neigung der einzelnen Lamellen anzupassen, ist die technologische Grundvoraussetzung für eine präzise Lichtlenkung. Aus diesem Grund fokussiert sich die vorliegende Arbeit exklusiv auf die Simulation und Steuerung dieser zweidimensional verstellbaren Jalousiesysteme.

Die physische Bewegung des Sonnenschutzes erfolgt in der Regel über integrierte Elektromotoren. Die Ansteuerung dieser Aktoren geschieht entweder dezentral über raumspezifische Controller oder zentralisiert über eine übergeordnete Automationsstation. 

Ein zentraler steuerungstechnischer Mechanismus bei Jalousien ist die Einstellung des sogenannten Cut-off-Winkels. Hierbei wird der maximal geöffnete Neigungswinkel der Lamellen berechnet, bei dem "direkter Sonnenlichteintrag durch die Fassade gerade vermieden wird" @dints18599_4_2025[S.42]. Gleichzeitig wird das direkte Sonnenlicht an die Decke reflektiert (siehe @fig-cutoff). Außerdem verbleibt ein maximaler Spalt zwischen den Lamellen, um den Eintritt von diffusem Himmelslicht in die Raumtiefe und den Blick nach außen zu ermöglichen. Dies stellt eine ideale Balance zwischen Blendschutz und Tageslichtautonomie dar.

Um diesen Zustand aufrechtzuerhalten, wird in der Raumautomation das Prinzip der automatischen Lamellennachführung angewendet. Dabei passt die Steuerung den Cut-off-Winkel im Tagesverlauf kontinuierlich an den sich ändernden Sonnenstand an. Für eine exakte Nachführung benötigt die Automationsstation Echtzeitdaten über den solaren Azimut- und Höhenwinkel. Der Höhenwinkel ist konstant für den Standort, wobei der Azimutwinkel von der Ausrichtung der Fensterfläche abhängt.

#figure(
  image("assets/CutOffWinkel.png"),
  caption: [erer],
  placement: auto
)<fig-cutoff>

=== Bauphysikalische und lichttechnische Zielgrößen <kap-Zielgroessen>

Dynamische Sonnenschutzsysteme erfüllen in der modernen Gebäudeautomation wesentliche energetische und ergonomische Funktionen. Die primären Zielgrößen einer optimalen Steuerung definieren sich wie folgt:

- Sommerlicher Wärmeschutz: Ziel ist die Minimierung des solaren Energieeintrags in das Gebäude, um die anfallende Kühllast und den damit verbundenen Energieverbrauch der Klimatisierung effektiv zu senken. Intelligente Sonnenschutzsysteme können die benötigte Kühlenergie um 30% reduzieren@hutchins2015shading[S. 12].

- Winterlicher Wärmeschutz: Im Heizfall ist die durch transparente Hüllflächen in das Gebäude gelangende Solarstrahlung zu maximieren, um die Heizlast und den primärenergetischen Aufwand zu verringern. Zeitgleich minimieren geschlossene Behänge während der Nachtstunden den Transmissionswärmeverlust von innen nach außen.

- Visueller Komfort: Hierbei steht die Vermeidung von ungewollter Direkt- und Reflexblendung an Arbeitsplätzen im Vordergrund. Durch eine präzise Lamellennachführung soll die Sichtverbindung nach außen gemäß DIN EN 14501 weitestgehend erhalten bleiben, was den visuellen Komfort maßgeblich erhöht.

- Thermischer Komfort: Dieser wird wesentlich durch die operative Raumtemperatur $theta_"op"$ bestimmt, welche sich als Mittelwert aus der lokalen Lufttemperatur und der mittleren Strahlungstemperatur der Umfassungsflächen zusammensetzt. Sonnenschutzeinrichtungen leisten hier einen entscheidenden Beitrag, indem sie die direkte Bestrahlung von Personen blockieren und somit eine lokale Überhitzung im Sommer unterbinden.

- Tageslichtversorgung: Diese Zielgröße maximiert die relative Nutzungszeit des natürlichen Lichts, um den Einsatz von Kunstlicht zu minimieren@din5034-1. Dynamische Verschattung kann den jährlichen Energieverbrauch der Beleuchtung in den Räumen um 14-42% reduzieren@fernandes2021potential. Eine hohe Tageslichtautonomie wirkt sich zudem nachweislich positiv auf den circadianen Rhythmus sowie die psychische und physische Gesundheit der Gebäudenutzer aus@dgnb1.4.

- Reduktion von Lichtverschmutzung: Durch das automatisierte Schließen der Behänge in den Nacht- oder frühen Morgenstunden wird verhindert, dass künstliches Licht störend in die Umgebung abstrahlt. Dies schützt umliegende Ökosysteme und natürliche Biorhythmen von Mensch und Natur@lichtverschmutzung.

- Anlagenschutz (Selbstschutz): Zum Schutz vor mechanischer Zerstörung bei Extremwetterereignissen (wie Sturm oder Frost) muss die Anlage in eine sichere Position gefahren werden. Dies erfordert die kontinuierliche Auswertung externer Sensordaten, beispielsweise über eine lokale Dachwetterstation. Zudem verlängert eine gedämpfte, intervallbasierte Steuerung die Lebensdauer der verschleißanfälligen Elektroantriebe.

- Objektschutz (Fremdschutz): Bei Hagelschlag können geschlossene Metallbehänge die Fensterverglasung vor Schäden bewahren. Weiterhin erschweren geschlossene Anlagen außerhalb der Nutzungszeiten unbefugtes Eindringen in das Gebäude und leisten somit einen Beitrag zum mechanischen Einbruchschutz.

- Privatsphäre: Zuletzt bieten steuerbare Behänge durch die Unterbrechung der Sichtachse von außen nach innen einen essenziellen Beitrag zur Wahrung der Privatsphäre der Gebäudenutzer.

Diese bauphysikalischen und ergonomischen Zielgrößen stehen in der Praxis häufig in direkter Konkurrenz zueinander. So erfordert ein maximaler sommerlicher Wärmeschutz das Schließen des Behanges, was wiederum der Maximierung der Tageslichtautonomie widerspricht. Die Programmierung der Raumautomation muss folglich definieren, in welcher Hierarchie diese Funktionen priorisiert werden.

== Normative und regulatorische Rahmenbedingungen<NormativeGrundlagen>
=== Tageslichtversorgung und Blendschutz (DIN EN 17037) <kap-17037>
Die DIN EN 17037 ist der zentrale europäische Standard für die Tageslichtplanung in Gebäuden. Sie definiert vier wesentliche Bewertungskriterien: die Tageslichtversorgung, die Sichtverbindung nach außen, die Besonnung sowie den Blendschutz. Ziel der Norm ist es, ein angemessenes Niveau an natürlichem Licht im Rauminneren sicherzustellen und den visuellen Komfort der Nutzer zu gewährleisten. 

In der Planungspraxis wird die Norm primär von Architekten und Lichtplanern genutzt, um die Geometrie von Räumen, die Dimensionierung von Fensterflächen sowie die Notwendigkeit und Art von Sonnenschutzsystemen zu bemessen. Die Qualität der Tageslichtversorgung wird dabei in die Stufen gering, mittel und hoch eingeteilt. Um eine hohe Klassifizierung zu erreichen, sind in der Regel großflächige Verglasungen erforderlich.

Diese Forderung nach maximalem Tageslichteintrag steht jedoch in einem systembedingten Konflikt mit den Anforderungen des sommerlichen Wärmeschutzes, welcher zur Vermeidung von Kühllasten tendenziell kleinere Fensterflächen und damit einen reduzierten solaren Energieeintrag präferiert. 

Intelligente, automatisierte Jalousiesysteme bilden die technische Lösung dieses Zielkonflikts. Durch eine präzise Steuerung von Behanghöhe und Lamellenwinkel können sie die Tageslichtversorgung, den Blendschutz und den Wärmeschutz dynamisch in Einklang bringen. Besonderes Potenzial weisen hierbei Systeme auf, die nicht nur den globalen Sonnenstand, sondern auch die reale Umgebungsverschattung durch benachbarte Gebäude oder topografische Elemente in ihre Steuerungslogik integrieren. Erst durch die Berücksichtigung dieser Fremdverschattung lässt sich die natürliche Belichtung maximieren, ohne Abstriche beim thermischen oder visuellen Komfort in Kauf nehmen zu müssen.

=== Energieeffizienz der Gebäudeautomation
Die primäre Motivation für die Implementierung komplexer Raumautomationsfunktionen liegt in der Optimierung der Gebäudeenergieeffizienz. Den europäischen regulatorischen Rahmen hierfür bildet die Norm EN 15232, welche Automationssysteme in die Effizienzklassen A bis D unterteilt. Um die höchste Klasse A zu erreichen, fordert diese Norm den Einsatz von Raumautomationssystemen, die den Sonnenschutz in Abhängigkeit der solaren Einstrahlung steuern. Konkret wird dabei jedoch lediglich eine binäre Aktivierung des Sonnenschutzes bei Überschreitung eines globalen Grenzwertes von 130 Watt pro Quadratmeter verlangt@dinen15232_1_2017[S.69], was messtechnisch über ein Pyranometer erfasst werden kann.

Eine deutlich höhere Anforderung stellt die nationale Normenreihe DIN V 18599. Der Teil 11 dieser Norm, welcher den Einfluss der Gebäudeautomation auf den Energiebedarf bewertet, fordert für den höchsten Automatisierungsgrad A explizit einen automatisch betriebenen Sonnenschutz mit integrierter Lamellennachführung (siehe @fig-18599Ausschnit). Der Einsatz einer solchen kontinuierlichen Nachführung der Jalousien wirkt sich gemäß DIN V 18599 Teil 4 direkt positiv auf den Tageslichtversorgungsfaktor des Gebäudes aus. Für die steuerungstechnische Umsetzung einer derartigen Nachführung sind präzise Daten über den lokalen Sonnenstand eine zwingende Grundvoraussetzung. Insbesondere in dicht bebauten urbanen Gebieten lässt sich die Tageslichtversorgung durch die Integration hochauflösender Verschattungsdaten weiter steigern: Detektiert das System eine temporäre Fremdverschattung der Fassade, können die Behänge/Lamellen gezielt geöffnet werden. Dies ermöglicht eine maximale Ausnutzung des diffusen Sonnenlichts.
#figure(
  image("assets/18599Ausschnitt.png"),
  caption: [@din18599-1[S. 46]]
)<fig-18599Ausschnit>

Die methodischen Verfahren zur Berechnung des resultierenden Energiebedarfs für Heizung und Kühlung werden international in der Norm EN ISO 52016-1 definiert. Diese berücksichtigt explizit den solaren Energieeintrag durch transparente Gebäudehüllen sowie dessen Reduktion durch Sonnenschutzsysteme. Obwohl die vorliegende Arbeit nicht auf die Durchführung einer thermischen Gebäudesimulation abzielt, verdeutlicht die Norm die bauphysikalische Relevanz des entwickelten Prozesses: Nur wenn die variierende Fremdverschattung auf der Fassade präzise ermittelt wird, kann der resultierende Energieeintrag akkurat berechnet werden.

=== Raumautomationsfunktionen (VDI 3813)<kap-vdi3813>
In der VDI-Richtlinie 3813 Blatt 2 werden normierte Funktionsblöcke definiert, um komplexe @ra#[]-Funktionen herstellerneutral und einheitlich darzustellen. Hierbei werden die einzelnen Funktionsblöcke informationstechnisch miteinander verknüpft, sodass Steuersignale generiert, logisch modifiziert und in einer Kaskade weitergegeben werden können. Die programmtechnische Berechnung erfolgt meist auf Ebene der @as.

==== Funktionsblock Thermoautomatik
Die in @kap-Zielgroessen definierten Ziele des sommerlichen und winterlichen Wärmeschutzes werden durch den Funktionsblock der Thermoautomatik abgebildet. Dieser Funktionsblock wertet Parameter wie die Raum- und Außentemperatur aus. Im Winterfall soll er garantieren, dass in unbelegten Räumen der solare Wärmeeintrag durch geöffnete Behänge maximiert wird, um die Heizlast zu senken. Im Sommerfall hingegen erzwingt der Block das Schließen des Sonnenschutzes bei zu hoher Raumtemperatur, um den solaren Energieeintrag und damit die Kühllast zu minimieren. 

==== Funktionsblock Verschattungskorrektur
Gemäß VDI 3813-2 dient dieser Funktionsblock (siehe @fig-FunktionsblockThermo) als logischer Filter, der intern berechnet, „ob ein Fenster oder eine Gruppe von Fenstern [...] temporär durch umliegende Bebauung oder eigene Gebäudeteile verschattet werden“. Im Signalfluss empfängt der Block über den Eingang #emph("S_AUTO") den initialen Stellbefehl der vorgelagerten Automatikfunktionen. Konventionell gleicht der Algorithmus den aktuellen Sonnenstand (Azimut und Elevation) mit den im Parameter #emph("PAR_SHAD") hinterlegten statischen Verschattungsgrenzen ab. Detektiert die Logik eine Verschattung, wird der Schließbefehl blockiert und stattdessen eine definierte Parkposition an den Ausgang übergeben. 

#figure(
  image("assets/FunktionsblockVerschattungAlt.png", width: 50%),
  caption: [Funktionsblock für die Verschattungskorrektur@vdi3813-2.],
  placement: auto
)<fig-FunktionsblockThermo>

Da die in dieser Arbeit entwickelte 3D-Simulation den Verschattungsstatus jedoch bereits prozessorausgelagert (extern) und hochauflösend ermittelt, wird die interne Winkelkalkulation dieses normierten Blocks obsolet. Die Simulation ersetzt somit nicht nur den statischen Parameter #emph("PAR_SHAD"), sondern macht deutlich, dass die Architektur des gesamten Funktionsblocks im Kontext einer datengetriebenen, simulationsbasierten Gebäudeautomation konzeptionell neu gedacht werden muss.

==== Funktionsblock Lamellennachführung (Blendschutz-Automatik)
Dieser Funktionsblock dient primär der Sicherstellung des visuellen Komforts für den Gebäudenutzer. Sobald direkte Sonnenstrahlung auf die Fassade trifft – und die Verschattungskorrektur keinen Fremdschatten meldet – berechnet der Block anhand der aktuellen Sonnenelevation den optimalen Neigungswinkel der Jalousielamellen. Ziel ist es, direkte Blendung an den Arbeitsplätzen konsequent zu verhindern, gleichzeitig jedoch ein Maximum an diffusem Tageslicht in die Raumtiefe zu lenken, um die Tageslichtautonomie zu steigern.

==== Funktionsblock Dämmerungsautomatik
Zur Erfüllung der Schutzziele bezüglich der Reduktion von Lichtverschmutzung steuert dieser Block die Fassade in den Abend- und Nachtstunden. Nach dem rechnerischen oder sensorgestützten Sonnenuntergang erzwingt der Funktionsblock das Schließen der Behänge. Dies verhindert einerseits das störende Abstrahlen von künstlichem Raumlicht in die urbane Umgebung und bietet den Nutzern andererseits einen effektiven Sichtschutz.

==== Funktionsblock Witterungsschutz
Der Witterungsschutz bildet die oberste sicherheitstechnische Instanz der Raumautomation. Er wertet kontinuierlich externe Wetterparameter wie Windgeschwindigkeit, Niederschlag oder Eisbildung aus. Bei Überschreitung kritischer Grenzwerte zwingt dieser Block die externen Sonnenschutzeinrichtungen unmittelbar in eine mechanisch sichere Endlage (in der Regel den eingefahrenen Zustand). Dies dient dem Schutz der Anlage vor mechanischer Zerstörung.

==== Funktionsblock Prioritätensteuerung
Die in der VDI 3813 beschriebene Automationslogik basiert auf einem strikten Kaskaden- und Prioritätenprinzip. Die Steuerungssignale werden hierarchisch ausgewertet, wobei übergeordnete Blöcke die Befehle nachgelagerter Funktionen überschreiben können. Die fundamentale Prioritätenfolge lautet: Sicherheit (Witterungsschutz) steht über der Nutzerbedienung (manueller Eingriff), welche wiederum über der Raumautomation (Verschattungskorrektur, Blendschutz, Thermoautomatik) steht. Energetische und visuelle Automatikfunktionen greifen somit nur dann, wenn weder sicherheitskritische Ereignisse vorliegen noch der Nutzer das System manuell übersteuert hat.

// Siehe @fig-FunktionsblockVersch  
// #figure(
//   image("assets/FunktionsblockVerschattung3813.png"),
//   caption: [Funktionsblock für die Verschattungskorrektur@vdi3813-2]
// )<fig-FunktionsblockVersch>
// 
// 
/*
=== Jahresverschattung... <Jahresverschattung>
Nutzen für Eigentümer/Mieter:
- Reduzierte Energiekosten durch geringeren Kühl- und Heizbedarf
- Attraktiveres Gebäude durch verbesserten Komfort
- Erfüllung von Nachhaltigkeitszielen und Zertifizierungen
Nutzen für Betreiber:
- Einfachere Wartung und Steuerung durch Automatisierung
- Längere Lebensdauer der Gebäudekomponenten durch Schutz vor UV-Strahlung
Nutzen für Nutzer:
- Verbesserter visueller Komfort durch reduzierte Blendung
- Angenehmes Raumklima durch reduzierte Überhitzung
Die Rolle von Verschattungssystemen in der Gebäudeautomation. Das Zusammenspiel von Energieeffizienz und Nutzerkomfort.

#let definition(title, body) = {
  block(
    fill: luma(240),
    stroke: (left: 1pt + black, right: 1pt + black),
    inset: 1em,
    width: 100%,
    radius: (right: 5pt),
    [
      #text(weight: "bold")[#title] \
      #body
    ]
  )
}

#definition("Jahresverschattung")[
  Die Jahresverschattung bezeichnet die zeitabhängige Veränderung der solaren Exposition auf der Gebäudehülle im Verlauf eines meteorologischen Jahres. Sie ist das Resultat der Interaktion zwischen dem dynamischen Sonnenstand, der Gebäudeorientierung sowie der umgebenden Bebauung und Vegetation. Im Kontext der Gebäudeautomation definiert sie die zeitlichen und räumlichen Randbedingungen, unter denen ein variabler Sonnenschutz agieren muss...
]
Begriff wird von WAREMA übernommen, ist allerdings nirgends richtig definiert.

Die Jahresverschattungssimulation bezeichnet ein simulationsgestütztes Verfahren zur Analyse und Steuerung des solaren Energie- und Lichteintrags in ein Gebäude über den Zeitraum eines vollständigen meteorologischen Jahres. Im Gegensatz zu statischen Verschattungselementen oder reinen Echtzeit-Helligkeitsregelungen basiert sie auf der zeitabhängigen Interaktion zwischen dem astronomischen Sonnenstand, der Gebäudegeometrie sowie der umgebenden Bebauung. Ziel ist die Ermittlung optimaler Positionierungsstrategien für variable Sonnenschutzsysteme, um ein Gleichgewicht zwischen der Minimierung thermischer Lasten (sommerlicher Wärmeschutz), der Maximierung solarer Gewinne (winterlicher Heizbedarf) und der Gewährleistung des visuellen Komforts (Blendfreiheit bei maximaler Tageslichtnutzung) sicherzustellen....
// Physikalische Prinzipien und Ziele (Energie vs. Komfort).
*/