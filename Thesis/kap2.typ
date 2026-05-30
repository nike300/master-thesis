#import "template/lib.typ": *
= Theoretische Grundlagen<TheoretischeGrundlagen>
In diesem Kapitel werden die interdisziplinären Grundlagen erarbeitet, die für das Verständnis und die Entwicklung der Prozesskette erforderlich sind. Die Betrachtung umfasst die astronomische Sonnenbahnmechanik sowie die geometrischen Prinzipien der Schattenberechnung. Darauf aufbauend werden die informationstechnischen Standards digitaler Gebäudemodelle und städtischer Geodaten erläutert. Abschließend erfolgt eine Einordnung steuerbarer Sonnenschutzsysteme in die normativen und regulatorischen Rahmenbedingungen der Raumautomation.

== Astronomische und geometrische Grundlagen <GeometrischeGrundlagen>
Nachfolgend werden die astronomischen und geometrischen Gesetzmäßigkeiten hergeleitet, die für die Berechnung des Schattenwurfs maßgeblich sind. 

=== Sonnenbahnmechanik <Sonnenbahnmechanik>
Für eine exakte Verschattungssimulation muss die Position der Sonne bekannt sein. Im Folgenden werden die Berechnungsgrundlagen für die Wahre Ortszeit, den Stundenwinkel sowie für Deklination, Höhenwinkel und Azimut dargelegt (siehe @fig-sonnenmodell).

#figure(
  image("assets/SonnenstandWinkelbezeichnung.png", width: 60%),
  caption: [
    Winkelbezeichnungen des Sonnenstandes @Quaschning
  ],
)<fig-sonnenmodell>

==== Wahre Ortszeit <WahreOrtszeit>
Wie Duffie und Beckman~@Duffie2013 herleiten, sind für die Berechnung der Wahren Ortszeit ($t_"WOZ"$) folgende Parameter notwendig:

- $t_"std"$: Gesetzliche Ortszeit (Local Standard Time) in Stunden.
- $n$: Tag des Jahres (1 bis 365).
- $lambda_"loc"$: Geografischer Längengrad des Standorts (in Grad).
- $lambda_"std"$: Bezugslängengrad der Zeitzone (z. B. $15 degree$ für MEZ).
- $E$: Zeitgleichung (Equation of Time) in Minuten.

Die Wahre Ortszeit berechnet sich wie folgt #footnote[Vorzeichenkonvention gemäß ISO 6709 (Ost positiv). Duffie/Beckman verwenden hier invertierte Vorzeichen (West positiv).]:

$ t_"WOZ" = t_"std" + frac(4 dot (lambda_"loc" - lambda_"std") + E, 60) $

Der Divisor 60 ist notwendig, um die Zeitkorrekturen (Minuten) in das Format der Basiszeit (Stunden) zu überführen. Die Zeitgleichung $E$ (in Minuten) wird angenähert durch~@Duffie2013:

$ E &= 229.18 dot (0.000075 + 0.001868 cos(B) - 0.032077 sin(B) \
  &- 0.014615 cos(2B) - 0.040849 sin(2B)) $

mit dem Hilfswinkel $B$:
$ B &= (n - 1) dot frac(360 degree, 365) $

==== Stundenwinkel ($omega$) <Stundenwinkel>
Um die zeitliche Komponente in die geometrische Berechnung einzuführen, wird die Wahre Ortszeit ($t_"WOZ"$) in den Stundenwinkel $omega$ umgerechnet. Da die Erde sich um $15 degree$ pro Stunde dreht, gilt:

$ omega = (t_"WOZ" - 12) dot 15 degree $

Dabei entspricht $omega = 0 degree$ dem solaren Mittag (Sonne exakt im Süden). Vormittagswerte sind negativ, Nachmittagswerte positiv.

==== Sonnendeklination ($delta$) <Sonnendeklination>
$delta$ ist der Winkel zwischen der Verbindungslinie Erde-Sonne und der Äquatorebene. Sie beschreibt die Neigung der Erde in Relation zur Sonne und variiert im Jahresverlauf zwischen $-23,45 degree$ und $+23,45 degree$.

Für die Bestimmung der Sonnenposition wird das Berechnungsverfahren gemäß DIN EN 17037 (Tageslicht in Gebäuden) angewendet~@dinen17037. Ausgangsbasis für die Sonnendeklination $delta$ ist die bereits zuvor eingeführte Tageszahl $n$ und der daraus abgeleitete Jahreswinkel $n'$:

$ n' = 360 degree dot frac(n, 365) $

Die Deklination $delta(n)$ ergibt sich gemäß Gleichung D.3 der Norm:

$ delta(n) &= 0.3948 \
  &- 23.2559 dot cos(n' + 9.1 degree) \
  &- 0.3915 dot cos(2 dot n' + 5.4 degree) \
  &- 0.1764 dot cos(3 dot n' + 26.0 degree) $ <deklinationsgleichung>

// #block(inset: 8pt, fill: luma(240))[
//   *Hinweis zur Implementierung:*
//   Die Koeffizienten liefern das Ergebnis in Grad. Für die geometrische Weiterverarbeitung im Simulationsmodell erfolgt eine Umrechnung in das Bogenmaß (Radiant).
// ]

==== Sonnenhöhenwinkel ($gamma_s$) <Sonnenhoehenwinkel>
Der Sonnenhöhenwinkel beschreibt den vertikalen Winkel zwischen der Horizontalen und der Sonne. Er ist maßgeblich für die effektive Einstrahlung auf Fassadenflächen sowie für die Berechnung der Schattenlängen.

Basierend auf dem geografischen Breitengrad $phi$, der zuvor berechneten Deklination $delta$ und dem Stundenwinkel $omega$ ergibt sich der Höhenwinkel aus der grundlegenden Gleichung der sphärischen Astronomie:

$ sin(gamma_s) = sin(phi) dot sin(delta) + cos(phi) dot cos(delta) dot cos(omega) $

Durch Umstellung nach $gamma_s$ erhält man den expliziten Winkel:

$ gamma_s = arcsin(sin(phi) dot sin(delta) + cos(phi) dot cos(delta) dot cos(omega)) $

Dabei gelten folgende Randbedingungen:
- $gamma_s > 0 degree$: Die Sonne steht über dem Horizont (Tag).
- $gamma_s <= 0 degree$: Die Sonne steht unter dem Horizont (Nacht/Dämmerung).

// #block(inset: 8pt, fill: luma(240))[*Relevanz für die Simulation:*In der Prozesskette dient die Prüfung gamma_s > 0 als erster Filter ("Early Exit"). Ist der Wert negativ, muss kein aufwendiges Raycasting durchgeführt werden, da keine direkte Verschattung möglich ist.]

==== Sonnenazimut ($alpha_s$) <Sonnenazimut>
Der Sonnenazimut beschreibt die horizontale Himmelsrichtung der Sonne. In Übereinstimmung mit der Norm DIN 5034-1 ist der Bezugspunkt die geografische Nordrichtung. Der Winkel wird im Uhrzeigersinn von $0 degree$ (Nord) bis $359,99 degree$ gemessen.

Die Berechnung erfolgt abhängig von der Wahren Ortszeit @Quaschning:

$ alpha_s = cases(
  180 degree - arccos(frac(sin(gamma_s) dot sin(phi) - sin(delta), cos(gamma_s) dot cos(phi))) & "für" t_"WOZ" <= 12,
  180 degree + arccos(frac(sin(gamma_s) dot sin(phi) - sin(delta), cos(gamma_s) dot cos(phi))) & "für" t_"WOZ" > 12
) $

=== Vergleich und Auswahl der Berechnungsverfahren <VergleichAuswahlBerechnungsverfahren>
Die in den vorangegangenen Abschnitten dargestellten Formeln der DIN EN 17037 stellen die normative Grundlage für die Tageslichtplanung in Europa dar. Sie bieten eine hinreichende Genauigkeit.

Für die Implementierung des Simulations-Prototyps (siehe @Kap4) wird jedoch auf den Algorithmus der National Oceanic and Atmospheric Administration (@noaa) zurückgegriffen. Dieser zeichnet sich durch folgende Merkmale aus:

- *Höhere Präzision:* Während einfache Näherungen Fehler von bis zu $1 degree$ aufweisen können, minimiert der @noaa#[]-Algorithmus (basierend auf den Arbeiten von Jean Meeus @Meeus1998) die Abweichungen auf unter $0,0001 degree$.
- *Berücksichtigung atmosphärischer Effekte:* Der Algorithmus inkludiert Korrekturfaktoren für die atmosphärische Refraktion, was insbesondere bei flachen Sonnenständen (Morgen- und Abendstunden) für die Lamellennachführung in der @ga kritisch ist.

Auf eine detaillierte mathematische Herleitung der über 30 Korrekturterme des @noaa#[]-Verfahrens wird an dieser Stelle verzichtet; die Berechnung folgt gemäß der dokumentierten Implementierung~@NOAASolar2021.


=== Geometrie der Verschattung <GeometrieVerschattung>
Nachdem die Position der Sonne bestimmt wurde, muss im nächsten Schritt geprüft werden, ob die direkte Sichtlinie zwischen einem betrachteten Punkt auf der Fassade (z. B. Fenstermittelpunkt) und der Sonne durch Hindernisse unterbrochen wird.

Eine etablierte Methode zur Visualisierung dieser Umgebungsverschattung für einen spezifischen Referenzpunkt am Gebäude ist das Sonnenbahndiagramm (siehe @fig-Sonnenbahndiagramm). Dafür müssen für alle Hindernisse in der Umgebung der Höhen- und Azimutwinkel ausgemessen werden. Aus dieser zweidimensionalen Darstellung der Sonnenbahnen und der Umgebungssilhouette lassen sich Grenzwinkel (Azimut- und Sonnenhöhenwinkel) ableiten, ab denen ein externes Objekt einen Schatten auf den betrachteten Punkt wirft. 
#figure(
  image("assets/Sonnenstandsdiagramm.png", width: 70%),
  caption: [Sonnenbahndiagramm mit Umgebungssilhouette @Quaschning.],
  placement: auto
) <fig-Sonnenbahndiagramm>

==== Der Sonnenvektor <Sonnenvektor>
Für die geometrische Simulation in 3D-Umgebungen ist die Darstellung in Winkeln oft unpraktisch. Stattdessen wird die Sonnenposition als normierter Richtungsvektor $(S)$ im kartesischen Koordinatensystem definiert. 

Unter der Annahme eines Z-up-Koordinatensystems (z. B. in IFC-Modellen üblich, $Z$ zeigt zum Zenit, $Y$ nach Norden) berechnet sich der Sonnenvektor aus Azimut $alpha_s$ und Elevation $gamma_s$:

$ vec(S) = mat(
  sin(alpha_s) dot cos(gamma_s);
  cos(alpha_s) dot cos(gamma_s);
  sin(gamma_s)
) $

Dieser Vektor zeigt von einem beliebigen Punkt zur Sonne.

// ==== Klassifizierung der Verschattungstypen <KlassifizierungVerschattungstypen>
// Man unterscheidet in der Simulation zwei wesentliche Ursachen für den Schattenwurf:

// - *Fremdverschattung:* Verursacht durch Objekte außerhalb der eigenen Gebäudehülle, wie Nachbarbebauung, Vegetation oder Topografie. Diese Geometrien sind im Betrieb statisch, müssen aber im digitalen Modell (IFC/CityGML) präzise abgebildet sein.
// - *Eigenverschattung:* Verursacht durch die Gebäudegeometrie selbst, z. B. durch Fassadenvorsprünge, Balkone oder die Laibungstiefe des Fensters. Besonders die Laibungstiefe spielt bei steilen Sonnenständen eine kritische Rolle für das Vorausschauen des effektiven Lichteintrag.

=== Raycasting-Verfahren zur Kollisionserkennung
Das Raycasting (Strahlenverfolgung) ist ein grundlegendes Verfahren der 3D-Computergrafik, das primär zur Ermittlung von Sichtbarkeiten und geometrischen Schnittpunkten im dreidimensionalen Raum eingesetzt wird. Im Kontext der Gebäudeanalyse dient dieser Algorithmus dazu, Fremdverschattungen durch urbane Umgebungsstrukturen (wie Nachbargebäude oder Topografie) präzise zu detektieren.

Anders als in der physikalischen Realität, in der Lichtstrahlen von der Lichtquelle emittiert werden, arbeitet das hier angewandte Verfahren aus Gründen der Recheneffizienz invers (Backward Raytracing). Ausgehend von den zu untersuchenden Empfängerflächen -- in der Verschattungssimulation den Messpunkten der Fenster -- wird ein linearer Prüfstrahl (Ray) generiert. Dieser Strahl wird exakt entlang des berechneten Sonnenrichtungsvektors $vec(r)$ in den Raum projiziert. Der zugrundeliegende Computeralgorithmus berechnet anschließend mathematisch, ob dieser Strahl auf seinem Weg eine andere Polygonfläche (Mesh) schneidet. Registriert der Algorithmus eine Kollision mit einem Mesh, bevor der Strahl die theoretische Distanz zur Lichtquelle erreicht, gilt der ausgehende Fensterpunkt als durch ein Hindernis verschattet. Hat der Strahl hingegen freie Bahn, wird direkte Besonnung protokolliert.

=== Raytracing und Reflexionen <RaytracingReflexionen>

Während das zuvor beschriebene Raycasting-Verfahren primär die binäre Sichtbarkeit zwischen einem Messpunkt und der Lichtquelle prüft, erweitert das Raytracing dieses Prinzip um die rekursive Verfolgung von Lichtstrahlen nach deren erster Interaktion mit einer Oberfläche @tuwien_raytracing. Diese Methode ermöglicht die physikalisch korrekte Simulation komplexer optischer Phänomene im städtischen Kontext. Dazu zählen insbesondere Spiegelungen, die zu zusätzlichen Blendereignissen durch reflektierende Glasfassaden gegenüberliegender Gebäude führen können. Ebenso lässt sich die diffuse Streuung abbilden, welche eine Aufhellung von Innenräumen durch helle Umgebungsflächen bewirkt.

Für den operativen Einsatz stellt Raytracing jedoch eine Herausforderung dar. Zum einen steigt der erforderliche Rechenaufwand mit der Anzahl der simulierten Lichtsprünge exponentiell an, was die Anforderungen an die verwendete Hardware signifikant erhöht. Zum anderen scheitert die Umsetzung in der Praxis an der unzureichenden Datengrundlage. Für eine valide Berechnung müssen im gesamten 3D-Modell präzise Materialparameter wie Reflexionsgrad und Oberflächenrauheit hinterlegt sein. Wie die spätere Analyse der Gebäudemodelle in @Datenaufbereitung zeigt, fehlen diese spezifischen semantischen Informationen in IFC-Modellen und Städtemodellen in der Regel vollständig. Aus diesem Grund beschränkt sich die in dieser Arbeit entwickelte Prozesskette auf das binäre Raycasting zur Schattenermittlung.

// *Abgrenzung für diese Arbeit:*
// ???Da der primäre Energieeintrag durch direkte Solarstrahlung erfolgt und die Datengrundlage für Reflexionseigenschaften in 3D-Modellen oft unzureichend ist, fokussiert sich der entwickelte Prozess (@Kap4[Kapitel]) auf das geometrische Raycasting. Reflexionen werden als sekundärer Einflussfaktor betrachtet und im Ausblick (@Kap5[Kapitel]) diskutiert.

== Digitale Gebäudemodelle und Geoinformatik
=== Building Information Modeling und Austauschformate <kap-bim>

Der Datenaustausch im Bauwesen hat sich von analogen Plänen hin zu digitalen Methoden entwickelt. Während 2D-Grundrissdateien in Formaten wie DWG oder DXF weiterhin Anwendung finden, werden sie zunehmend durch objektbasierte 3D-Modelle abgelöst. Diese bieten eine höhere Dichte an geometrischen Informationen und erleichtern das räumliche Verständnis komplexer Strukturen.

Building Information Modeling (@bim) beschreibt einen durchgängigen, prozessorientierten Ansatz von der Planung bis zum Betrieb. @bim strukturiert die gewerkeübergreifende Zusammenarbeit und standardisiert den Informationsfluss. Der OpenBIM-Ansatz setzt hierbei auf herstellerneutrale Dateiformate, um Interoperabilität und Flexibilität bei der Softwareauswahl zu gewährleisten.

Das objektorientierte Austauschformat @ifc ermöglicht die Anreicherung der 3D-Geometrie mit semantischen Attributen. Innerhalb der entwickelten Prozesskette dient diese Struktur dazu, simulationsrelevante Bauteile automatisiert zu identifizieren. Während die Klasse `IfcSite` die Georeferenzierung ermöglicht, definiert die Klasse `IfcWindow` die betrachteten Fensterflächen.
// Maßgeblich für die Simulationsgüte ist ein adäquater Detaillierungsgrad (@lod), um Eigenverschattungen durch Laibungen oder Auskragungen im Raycasting-Verfahren präzise abzubilden.

Für die Abbildung des urbanen Kontextes dient das Format CityGML~@citygml_30 als internationaler Standard für semantische Stadtmodelle. In Ergänzung zur hohen Detailtiefe des IFC-Gebäudemodells liefert CityGML die notwendigen Umgebungsdaten zur Detektion von Fremdverschattung. Das effizientere Austauschformat CityJSON~@cityjson findet ebenfalls Anwendung. Auf die unterschiedlichen Modellierungstiefen wird im Folgenden eingegangen.

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

Für die Validität einer Verschattungssimulation ist die Definition der Modellierungstiefe entscheidend. Dabei muss begrifflich zwischen dem gebäudezentrierten Ansatz von @bim und dem stadtmodellzentrierten Ansatz der Geoinformatik unterschieden werden. Zur besseren Abgrenzung wird im Folgenden der Level of Development mit LOD und der Level of Detail mit LoD abgekürzt.

In der BIM-Methodik beschreibt der @lod sowohl den geometrischen Detaillierungsgrad (Level of Geometry) als auch den semantischen Informationsgehalt (Level of Information). Die Skala reicht üblicherweise von einer konzeptionellen Darstellung (@lod 100) bis hin zum dokumentierten As-Built-Zustand (@lod 500). Für die Untersuchung der Eigenverschattung ist ein @lod von mindestens 300 oder 350 erforderlich. Erst ab dieser Stufe sind Bauteile wie Fensterlaibungen, Stürze oder Fassadenrücksprünge geometrisch so exakt verortet, dass sie in einer Simulation als relevante Verschattungsobjekte fungieren können.

Wohingegen in der Geoinformatik und speziell im Kontext von CityGML der Begriff #gls("lodet", long: true) verwendet wird, um die Komplexität der äußeren Gebäudehülle im urbanen Raum zu definieren. Gemäß dem Standard des @ogc werden hierbei maßgeblich folgende Stufen unterschieden (siehe auch @fig-lod):

#figure(
  image("assets/LOD1-3.png", width: 100%),
  caption: [Darstellung der CityGML-#gls("lodet", long: true) 0 bis 3 @ogcCityGeography],
  placement: auto
)<fig-lod>

- @lodet#[]0 (Grundriss-/Geländemodell): Das Gebäude wird lediglich als zweidimensionaler Grundriss oder Dachumriss dargestellt. Da keine echte vertikale Volumenausdehnung vorhanden ist, ist dieser Detailgrad für eine dreidimensionale Verschattungssimulation ungeeignet.
- @lodet#[]1 (Blockmodell): Das Gebäude wird als einfacher Kubus mit Flachdach dargestellt, was einer Extrusion der Grundfläche entspricht. Diese Abstraktion ist für weit entfernte Verschattungsobjekte ausreichend, führt jedoch im Nahbereich zu Fehlern, da die tatsächliche Dachform ignoriert wird.
- @lodet#[]2 (Dachmodell): Das Modell beinhaltet standardisierte Gebäudeformen und grobe Dachaufbauten. Für die Verschattungssimulation stellt @lodet#[]2 oft den optimalen Kompromiss aus geometrischer Genauigkeit und Dateigröße dar @Hessen3D. Komplexe Gebäudefassaden werden vereinfacht dargestellt.
- @lodet#[]3 (3D Mesh): Hier werden detaillierte Gebäudehüllen mit Auskragungen, Fensterlaibungen und Texturen modelliert. @lodet#[]3 bietet eine sehr hohe Genauigkeit für die Simulation der Umgebungsverschattung, hat jedoch aufgrund der hohen Polygonanzahl einen negativen Einfluss auf die Rechenleistung.



Während der BIM-@lod den Fokus auf die interne Intelligenz und die präzise Konstruktion des betrachteten Objekts legt, dient der CityGML-@lodet der effizienten Repräsentation der Silhouette der Nachbarbebauung. Für eine durchgängige Prozesskette müssen beide Welten so miteinander verknüpft werden, dass das hochdetaillierte @bim#[]-Modell präzise in das Stadtmodell eingebettet werden kann.

=== Koordinatenreferenzsysteme<Koordinatenreferenzsysteme>

Die Georeferenzierung beschreibt die Zuweisung räumlicher Bezugsinformationen zu einem Datensatz. Für die dynamische Verschattungssimulation ist sie von zentraler Bedeutung, da das lokale Gebäudemodell (BIM) millimetergenau mit den Umgebungsdaten überlagert werden muss. Nur durch einen einheitlichen räumlichen Bezug lässt sich der korrekte solare Einfallswinkel auf die Fassade berechnen. In der Bauplanung und Geoinformatik wird dabei zwischen dem geodätischen Bezugssystem (dem Referenzrahmen) und dem Koordinatensystem (der Kartenprojektion) unterschieden.

==== Geodätische Bezugssysteme (WGS 84 und ETRS89)
Ein Bezugssystem definiert das mathematische Modell der Erdform, meist in Form eines Rotationsellipsoids. Das World Geodetic System 1984 (WGS~84) ist ein globales System und dient unter anderem als Grundlage für die satellitengestützte Positionsbestimmung~(@gps). Für Projekte innerhalb Europas wird stattdessen das European Terrestrial Reference System 1989 (ETRS89) verwendet. Im Gegensatz zum globalen WGS~84 ist ETRS89 fest mit der eurasischen Kontinentalplatte verbunden. Dies verhindert, dass sich Koordinaten durch die Kontinentaldrift gegenüber dem Boden verändern. In der BIM-Methodik werden diese Systeme genutzt, um den globalen Referenzpunkt innerhalb der Klasse `IfcSite` zu definieren. 

==== Kartenprojektionen (Gauß-Krüger und UTM)
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
  placement: none
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
  caption: [Gegenüberstellung geografischer und projizierter Koordinaten für das Referenzprojekt FOUR @koordinaten_umrechner],
  placement: none
) <tab:koordinaten_formate>


== Verschattungssysteme und Raumautomation <Verschattungssysteme>
=== Systematik steuerbarer Sonnenschutzsysteme

In der @ga werden Sonnenschutzsysteme primär nach der Anzahl ihrer mechanischen Freiheitsgrade klassifiziert. Diese technische Einteilung bestimmt die Flexibilität der Steuerung sowie das Potenzial zur Tageslichtnutzung.

Systeme mit einem Freiheitsgrad umfassen vorwiegend Rollläden und textile Screens, welche als vertikal geführte Stoffbahnen fungieren. Die einzige verfügbare Steuergröße bei diesen Systemen ist die prozentuale Behanghöhe. Da sie lediglich vertikal auf- und abgefahren werden können, bieten sie nur ein sehr begrenztes Potenzial zur Steuerung der Tageslichtqualität im Rauminneren. Sie finden vorwiegend im Wohnungsbau Anwendung.

Systeme mit zwei Freiheitsgraden, insbesondere außenliegende Raffstores beziehungsweise Jalousien#footnote[Zur besseren Lesbarkeit und Einheitlichkeit wird in der vorliegenden Arbeit im Folgenden durchgängig der Begriff der Jalousie verwendet.], bilden hingegen den Standard im modernen Büro- und Verwaltungsbau. Diese Anlagen verfügen über die beiden Steuergrößen Behanghöhe und Lamellenwinkel. Die Möglichkeit, die Neigung der einzelnen Lamellen anzupassen, ist die technologische Grundvoraussetzung für eine präzise Lichtlenkung. Aus diesem Grund fokussiert sich die vorliegende Arbeit exklusiv auf die Simulation und Steuerung dieser zweidimensional verstellbaren Jalousiesysteme.

Die physische Bewegung des Sonnenschutzes erfolgt in der Regel über integrierte Elektromotoren. Die Ansteuerung dieser Aktoren geschieht entweder dezentral über raumspezifische Controller oder zentralisiert über eine übergeordnete Automationsstation. 



=== Cut-off-Winkel und automatische Lamellennachführung <CutOffWinkelKapitel>

Ein zentraler steuerungstechnischer Mechanismus bei Jalousien ist die Einstellung des sogenannten Cut-off-Winkels. Hierbei wird der maximal geöffnete Neigungswinkel der Lamellen berechnet, bei dem "direkter Sonnenlichteintrag durch die Fassade gerade vermieden wird"~@dints18599_4_2025[S. 42]. Durch diese exakte Positionierung verbleibt ein maximaler Spalt zwischen den Lamellen, der den Eintritt von diffusem Himmelslicht in die Raumtiefe sowie den Sichtbezug nach außen ermöglicht. Abhängig von der Beschaffenheit und Geometrie der Lamellenoberfläche kann zudem ein Teil des einfallenden Lichts gezielt an die Raumdecke reflektiert werden (siehe @fig-cutoff). Dies stellt in der @ga eine ideale Balance zwischen Blendschutz, Sichtkontakt nach außen und Tageslichtautonomie dar.

Um diesen Zustand aufrechtzuerhalten, wird in der Raumautomation das Prinzip der automatischen Lamellennachführung angewendet. Dabei passt die Steuerung den Stellwinkel der Jalousie im Tagesverlauf kontinuierlich an den sich ändernden Sonnenstand an. Die geometrische Randbedingung für diesen Cut-off-Zustand ist erfüllt, wenn der direkte Sonnenstrahl exakt die Vorderkante der oberen Lamelle und die Hinterkante der darunterliegenden Lamelle tangiert (siehe @fig-CutOffWinkelDetail). In der Praxis wird auf den berechneten Stellwinkel oftmals noch eine sicherheitstechnische Marge addiert, um systembedingte Toleranzen zu kompensieren.

#figure(
  image("assets/CutOffWinkel.pdf", width: 60%),
  caption: [Darstellung von Jalousien mit eingestelltem Cut-off-Winkel und ins Rauminnere reflektierten Sonnenstrahlen],
  placement: auto
)<fig-cutoff>

#figure(
  image("assets/Cut-OffWinkelDetail.pdf", width: 60%),
  caption: [Detailschnitt zweier Lamellen einer Jalousie für die Berechnung des Cut-off-Winkels $beta$ mit einfallendem Lichtstrahl im Profilwinkel $alpha_p$ (in Anlehnung an Athienitis und Tzempelikos~@athienitis2002methodology)],
  placement: auto
)<fig-CutOffWinkelDetail>

Für die exakte Berechnung des erforderlichen Neigungswinkels $beta$ wird der Lichteinfall durch den solaren Profilwinkel $alpha_p$ beschrieben. Da horizontale Lamellen konstruktionsbedingt keine seitliche Abschattung bieten, ist der Profilwinkel der maßgebliche Wert für den Lichtdurchlass durch die Lamellen in den Raum. Wie Athienitis und Tzempelikos~@athienitis2002methodology[S. 276] darlegen, projiziert dieser Winkel den realen dreidimensionalen Sonnenstand auf eine zweidimensionale Schnittebene orthogonal zur Fensterfläche. Er bestimmt sich aus der tatsächlichen Sonnenhöhe $gamma_s$ und dem relativen Sonnenazimut $Delta alpha$ — also der horizontalen Winkeldifferenz zwischen dem Sonnenstand und der Fassadennormalen:

$ alpha_p = arctan(frac(tan(gamma_s), cos(Delta alpha))) $

Der Profilwinkel ist folglich stets größer oder gleich der tatsächlichen Sonnenhöhe. Fällt das Licht schräg von der Seite auf die Fassade, vergrößert sich der Profilwinkel, sodass die Sonnenstrahlen aus Sicht der horizontalen Lamellen steiler einfallen. Die mathematische Umsetzung des Cut-off-Betriebs stützt sich hierbei auf die von Athienitis und Tzempelikos~@athienitis2002methodology dargelegte geometrische Beziehung für den Strahlenverlauf innerhalb einer Jalousie. Überträgt man diese fundamentale Gleichung auf getrennte Variablen für den Lamellenabstand $d$ und die Lamellenbreite $w$, ergeben sich folgende geometrische Zusammenhänge:

Für die vertikale Gegenkathete gilt:
$ overline(B C) = d - w dot sin(beta) $

Für die horizontale Ankathete gilt:
$ overline(A C) = w dot cos(beta) $

Unter Anwendung der Tangensfunktion ergibt sich daraus der implizite Zusammenhang für den Profilwinkel:
$ tan(alpha_p) = frac(d - w dot sin(beta), w dot cos(beta)) $

Mithilfe der Anwendung trigonometrischer Additionstheoreme lässt sich diese Ausgangsgleichung auflösen, um den benötigten Stellwinkel $beta$ für die Implementierung auf der Automationsstation explizit zu berechnen (für die detaillierte mathematische Herleitung siehe @AnhangHerleitungCutOff):

$ beta = arcsin(frac(d, w) dot cos(alpha_p)) - alpha_p $

Durch die Bereitstellung eines fensterspezifischen Sonnenazimuts (Fensterazimut) und des globalen Sonnenhöhenwinkels kann sowohl der Profilwinkel als auch die daraus resultierende optimale Lamellenposition berechnet werden.


// === Cut-Off-Winkel und automatische Lamellennachführung
// Ein zentraler steuerungstechnischer Mechanismus bei Jalousien ist die Einstellung des sogenannten Cut-off-Winkels. Hierbei wird der maximal geöffnete Neigungswinkel der Lamellen berechnet, bei dem "direkter Sonnenlichteintrag durch die Fassade gerade vermieden wird"~@dints18599_4_2025[S. 42]. Gleichzeitig wird das direkte Sonnenlicht an die Decke reflektiert (siehe @fig-cutoff). Die Möglichkeit, das Sonnenlicht auf diese Weise effektiv in den Raum zu leiten, wird dabei maßgeblich durch die Breite, die Form und den Abstand der Lamellen bestimmt. Durch diese exakte Positionierung verbleibt ein maximaler Spalt zwischen den Lamellen, der den Eintritt von diffusem Himmelslicht in die Raumtiefe sowie den Sichtbezug nach außen ermöglicht. Dies stellt eine ideale Balance zwischen Blendschutz und Tageslichtautonomie dar.

// Um diesen Zustand aufrechtzuerhalten, wird in der Raumautomation das Prinzip der automatischen Lamellennachführung angewendet. Dabei passt die Steuerung den Cut-off Winkel im Tagesverlauf kontinuierlich an den sich ändernden Sonnenstand an. Für eine exakte Nachführung benötigt die Automationsstation Echtzeitdaten über den solaren Azimut- und Höhenwinkel. 

// #figure(
//   image("assets/Cut-OffWinkelDetail.pdf", width: 70%),
//   caption: [Detailschnitt zweier Lamellen einer Jalousie für die Berechnung des Cut-Off Winkels $beta$ mit einfallendem Lichtstrahl im Profilwinkel $alpha_P$ in Anlehnung an Athienitis und Tzempelikos~@athienitis2002methodology],
//   placement: auto
// )<fig-CutOffWinkelDetail>

// #figure(
//   image("assets/CutOffWinkel.pdf", width: 70%),
//   caption: [Darstellung von Jalousien mit eingestelltem Cut-off Winkel und ins Rauminnere reflektierte Sonnenstrahlen],
//   placement: auto
// )<fig-cutoff>

=== Bauphysikalische und lichttechnische Zielgrößen <kap-Zielgroessen>

Dynamische Sonnenschutzsysteme erfüllen in der modernen @ga wesentliche energetische und ergonomische Funktionen. Die primären Zielgrößen einer optimalen Steuerung definieren sich wie folgt:

- *Sommerlicher Wärmeschutz:* Ziel ist die Minimierung des solaren Energieeintrags in das Gebäude, um die anfallende Kühllast und den damit verbundenen Energieverbrauch der Klimatisierung effektiv zu senken. Intelligente Sonnenschutzsysteme können die benötigte Kühlenergie um 30% reduzieren @hutchins2015shading[S. 12].

- *Winterlicher Wärmeschutz:* Während der Nachtstunden oder außerhalb der Nutzungszeiten wird das Sonnenschutzsystem automatisiert geschlossen. Der Behang erzeugt eine zusätzliche thermische Schutzschicht vor der Verglasung, wodurch sich der gesamte Wärmedurchlasswiderstand des Fensters erhöht und der Transmissionswärmeverlust von innen nach außen effektiv minimiert wird.

- *Solarer Wärmegewinn (Winterfall):* Im Heizfall ist die in das Gebäude einfallende Solarstrahlung zu maximieren. Geöffnete Behänge ermöglichen einen hohen passiven solaren Energieeintrag. Dies verringert die erforderliche Gebäudeheizlast und den primärenergetischen Aufwand.

- *Visueller Komfort:* Hierbei steht die Vermeidung von ungewollter Direkt- und Reflexionsblendung an Arbeitsplätzen im Vordergrund. Dies kann durch eine direkte Blendung durch Sonneneinstrahlung, oder auch durch zu hohe Lichtdichten auf Flächen im Sichtfeld entstehen. Mithilfe einer präzisen Lamellennachführung soll die Sichtverbindung nach außen gemäß DIN EN 14501 weitestgehend erhalten bleiben, was den visuellen Komfort maßgeblich erhöht.

- *Thermischer Komfort:* Dieser wird wesentlich durch die operative Raumtemperatur $theta_"op"$ bestimmt, welche sich als Mittelwert aus der lokalen Lufttemperatur und der mittleren Strahlungstemperatur der Umfassungsflächen zusammensetzt. Sonnenschutzeinrichtungen leisten hier einen entscheidenden Beitrag, indem sie die direkte Bestrahlung von Personen blockieren und somit eine lokale Überhitzung im Sommer unterbinden.

- *Tageslichtversorgung:* Diese Zielgröße maximiert die relative Nutzungszeit des natürlichen Lichts, um den Einsatz von Kunstlicht zu minimieren @din5034-1. Dynamische Verschattungssteuerung kann den jährlichen Energieverbrauch der Beleuchtung in den Räumen um 14-42% reduzieren~@fernandes2021potential. Eine hohe Tageslichtautonomie wirkt sich zudem nachweislich positiv auf den circadianen Rhythmus sowie die psychische und physische Gesundheit der Gebäudenutzer aus~@dgnb1.4.

- *Reduktion von Lichtverschmutzung:* Durch das automatisierte Schließen der Behänge in den Nacht- oder frühen Morgenstunden wird verhindert, dass künstliches Licht störend in die Umgebung abstrahlt. Dies schützt umliegende Ökosysteme und die natürlichen Biorhythmen von Mensch und Natur @lichtverschmutzung.

- *Anlagenschutz (Selbstschutz):* Zum Schutz vor mechanischer Zerstörung bei Extremwetterereignissen (wie Sturm oder Frost) muss die Anlage in eine sichere Position gefahren werden. Dies erfordert die Auswertung externer Sensordaten, beispielsweise über eine lokale Dachwetterstation. Zudem verlängert eine gedämpfte, intervallbasierte Steuerung die Lebensdauer der verschleißanfälligen Elektroantriebe.

- *Objektschutz (Fremdschutz):* Bei Hagelschlag können geschlossene Metallbehänge die Fensterverglasung vor Schäden bewahren. Weiterhin erschweren geschlossene Anlagen außerhalb der Nutzungszeiten unbefugtes Eindringen in das Gebäude und leisten somit einen Beitrag zum mechanischen Einbruchschutz.

- *Privatsphäre:* Zuletzt leisten steuerbare Behänge durch die Unterbrechung der Sichtachse von außen nach innen einen essenziellen Beitrag zur Wahrung der Privatsphäre der Gebäudenutzer.

Diese bauphysikalischen und ergonomischen Zielgrößen stehen in der Praxis häufig in direkter Konkurrenz zueinander. So erfordert ein maximaler sommerlicher Wärmeschutz das Schließen des Behanges, was wiederum der Maximierung der Tageslichtautonomie widerspricht. Die Programmierung der Raumautomation muss folglich definieren, in welcher Hierarchie diese Funktionen priorisiert werden.

Neben den dargelegten Vorteilen ergeben sich in der praktischen Anwendung auch betriebstechnische Herausforderungen. Ein wesentlicher Aspekt ist die akustische Beeinträchtigung durch die integrierten Elektromotoren. Sowohl die vertikale Positionierung des Behanges als auch die kontinuierliche Nachführung der Lamellenwinkel verursachen motorische Betriebsgeräusche, die insbesondere in konzentrierten Arbeitsumgebungen als störend empfunden werden können. Zudem resultiert aus der mechanischen Konstruktion vieler Jalousien ein temporärer Verlust an visuellem Komfort: Während der Auf- oder Abwärtsbewegung schließen sich die Lamellen bauartbedingt meist vollständig, was zu einer kurzzeitigen Verdunkelung des Raumes und einer Unterbrechung der Sichtverbindung nach außen führt. Ein weiteres kritisches Risiko stellt die mechanische Belastung dar: Eine zu hohe Taktung und permanente Fahrbewegungen bei wechselnden Lichtverhältnissen führen zu einem erhöhten Verschleiß der Elektromotoren. Dies hat häufig vorzeitige Systemausfälle und hohe Wartungskosten zur Folge. Diese negativen Begleiterscheinungen unterstreichen die Relevanz einer vorausschauenden Steuerungslogik, welche unnötige Verstellvorgänge durch die Integration präziser Verschattungsdaten vermeidet und die Fahrbefehle auf ein funktional notwendiges Minimum reduziert.

== Normative und regulatorische Rahmenbedingungen<NormativeGrundlagen>
=== Tageslichtversorgung und Blendschutz<kap-17037>
Die DIN EN 17037~@dinen17037 der zentrale europäische Standard für die Tageslichtplanung in Gebäuden. Sie definiert vier wesentliche Bewertungskriterien: die Tageslichtversorgung, die Sichtverbindung nach außen, die Besonnung sowie den Blendschutz. Ziel der Norm ist es, ein angemessenes Niveau an natürlichem Licht im Rauminneren sicherzustellen und den visuellen Komfort der Nutzer zu gewährleisten. 

In der Planungspraxis wird die Norm primär von Architekten und Lichtplanern genutzt, um die Geometrie von Räumen, die Dimensionierung von Fensterflächen sowie die Notwendigkeit und Art von Sonnenschutzsystemen zu bemessen. Die Qualität der Tageslichtversorgung wird dabei in die Stufen gering, mittel und hoch eingeteilt. Um eine hohe Klassifizierung zu erreichen, sind in der Regel großflächige Verglasungen erforderlich.

Diese Forderung nach maximalem Tageslichteintrag steht jedoch in einem systembedingten Konflikt mit den Anforderungen des sommerlichen Wärmeschutzes, welcher zur Vermeidung von Kühllasten tendenziell kleinere Fensterflächen und damit einen reduzierten solaren Energieeintrag präferiert. 

Intelligente, automatisierte Jalousiesysteme bilden die technische Lösung dieses Zielkonflikts. Durch eine präzise Steuerung von Behanghöhe und Lamellenwinkel können sie die Tageslichtversorgung, den Blendschutz und den Wärmeschutz dynamisch in Einklang bringen. Besonderes Potenzial weisen hierbei Systeme auf, die nicht nur den globalen Sonnenstand, sondern auch die reale Umgebungsverschattung durch benachbarte Gebäude oder topografische Elemente in ihre Steuerungslogik integrieren. Erst durch die Berücksichtigung dieser Fremdverschattung lässt sich die natürliche Belichtung maximieren, ohne Abstriche beim thermischen oder visuellen Komfort in Kauf nehmen zu müssen.

=== Energieeffizienz der Gebäudeautomation
Die primäre Motivation für die Implementierung komplexer Raumautomationsfunktionen liegt in der Optimierung der Gebäudeenergieeffizienz. Den europäischen regulatorischen Rahmen hierfür bildet die Norm DIN EN ISO 52120-1~@dineniso52120_1_2025, welche die DIN~EN~15232~@dinen15232_1_2017 ablöst. Hier werden Automationssysteme in die Effizienzklassen A bis D unterteilt. Um die höchste Klasse A zu erreichen, fordert diese Norm den Einsatz von Raumautomationssystemen, die den Sonnenschutz in Abhängigkeit der solaren Einstrahlung steuern. Konkret wird dabei jedoch lediglich eine binäre Aktivierung des Sonnenschutzes bei Überschreitung eines globalen Grenzwertes von 130 W/m² verlangt~@dineniso52120_1_2025[S.74], was messtechnisch über ein Pyranometer erfasst werden kann.

Deutlich höhere Anforderungen formuliert die nationale Normenreihe DIN/TS 18599. In Teil 11~@dints18599_11_2025, welcher den Einfluss der @ga auf den Energiebedarf bewertet, wird für das Erreichen des höchsten Automatisierungsgrades A eine von zwei technischen Ausführungen explizit gefordert: entweder eine kombinierte Regelung von Beleuchtung, Sonnenschutzeinrichtungen und HLK-Anlagen -- obgleich die exakte informationstechnische Interaktion dieser Systeme normativ unbestimmt bleibt -- oder ein automatisch betriebener Sonnenschutz mit integrierter Lamellennachführung (siehe @fig-18599Ausschnit). Der Einsatz einer solchen kontinuierlichen Nachführung wirkt sich gemäß DIN/TS 18599 Teil 4~@dints18599_4_2025 unmittelbar positiv auf den Tageslichtversorgungsfaktor des Gebäudes aus. Für die steuerungstechnische Umsetzung dieser adaptiven Nachführung konstituieren präzise Daten über den lokalen Sonnenstand eine fundamentale Voraussetzung. Insbesondere im dicht bebauten urbanen Kontext lässt sich die Tageslichtversorgung durch die Integration hochauflösender Verschattungsdaten weiter optimieren: Detektiert das System eine temporäre Fremdverschattung der Fassade, können die Sonnenschutzbehänge oder Lamellen gezielt geöffnet werden. Dies ermöglicht eine maximale Ausnutzung des diffusen Tageslichts.
#figure(
  image("assets/18599Ausschnitt.png"),
  caption: [Übersicht zu den Automationsgraden für die Regelung bzw. Steuerung des Sonnenschutzes~@dints18599_11_2025[S. 32 - 33]]
)<fig-18599Ausschnit>

Die methodischen Verfahren zur Berechnung des resultierenden Energiebedarfs für Heizung und Kühlung werden international in der Norm EN ISO 52016-1~@dineniso52120_1_2025 definiert. Diese berücksichtigt explizit den solaren Energieeintrag durch transparente Gebäudehüllen sowie dessen Reduktion durch Sonnenschutzsysteme. Obwohl die vorliegende Arbeit nicht auf die Durchführung einer thermischen Gebäudesimulation abzielt, verdeutlicht die Norm die bauphysikalische Relevanz des entwickelten Prozesses: Nur wenn die variierende Fremdverschattung auf der Fassade präzise ermittelt wird, kann der resultierende Energieeintrag akkurat berechnet werden.

=== Raumautomationsfunktionen<kap-vdi3813>
In der VDI-Richtlinie 3813 Blatt 2~@vdi3813-2 werden normierte Funktionsblöcke definiert, um komplexe Raumautomationsfunktionen herstellerneutral und einheitlich darzustellen. Hierbei werden die einzelnen Funktionsblöcke informationstechnisch miteinander verknüpft, sodass Steuersignale generiert, modifiziert und in einer Kaskade weitergegeben werden können. Die programmtechnische Berechnung erfolgt meist auf Ebene der @as oder @rae.

An dieser Stelle ist anzumerken, dass die VDI 3813 im Zuge der Harmonisierung der nationalen Regelwerke formal durch die aktuelle Richtlinienreihe VDI 3814 Blatt 3.1~@vdi3814_3.1 abgelöst wurde. Da die Nachfolgenorm in ihrer aktuellen Fassung jedoch keine spezifischen Funktionsblöcke für die Verschattungskorrektur sowie die adaptive Lamellennachführung explizit ausweist, verbleibt die VDI 3813 Blatt 2 für die informationstechnische Modellierung dieser Gewerke die maßgebliche Referenz. Aus diesem Grund stützen sich die im Folgenden behandelten Funktionsmakros und deren informationstechnische Modifikationen weiterhin auf die methodischen Grundlagen der VDI 3813.


==== Funktionsblock Thermoautomatik
Die in @kap-Zielgroessen definierten Ziele des sommerlichen und winterlichen Wärmeschutzes werden durch den Funktionsblock der Thermoautomatik abgebildet. Dieser Funktionsblock wertet Parameter wie die Raum- und Außentemperatur aus. Im Winterfall soll er garantieren, dass in unbelegten Räumen der solare Wärmeeintrag durch geöffnete Behänge maximiert wird, um die Heizlast zu senken. Im Sommerfall hingegen erzwingt der Block das Schließen des Sonnenschutzes bei zu hoher Raumtemperatur, um den solaren Energieeintrag und damit die Kühllast zu minimieren. 

==== Funktionsblock Verschattungskorrektur
Gemäß VDI 3813-2 dient dieser Funktionsblock (siehe @fig-FunktionsblockThermo) als logischer Filter, der intern berechnet, „ob ein Fenster oder eine Gruppe von Fenstern [...] temporär durch umliegende Bebauung oder eigene Gebäudeteile verschattet werden“. Im Signalfluss empfängt der Block über den Eingang #emph("S_AUTO") den initialen Stellbefehl der vorgelagerten Automatikfunktionen. Konventionell gleicht der Algorithmus den aktuellen Sonnenstand (Azimut und Elevation) mit den im Parameter #emph("PAR_SHAD") hinterlegten statischen Verschattungsgrenzen ab. Detektiert die Logik eine Verschattung, wird der Schließbefehl blockiert und stattdessen eine definierte Parkposition an den Ausgang übergeben. 

#figure(
  image("assets/FunktionsblockVerschattungAlt.png", width: 50%),
  caption: [Funktionsblock für die Verschattungskorrektur@vdi3813-2.],
  placement: auto
)<fig-FunktionsblockThermo>

Da die in dieser Arbeit entwickelte 3D-Simulation den Verschattungsstatus jedoch bereits extern und hochauflösend ermittelt, wird die interne Winkelkalkulation dieses normierten Blocks obsolet. Die Simulation ersetzt somit nicht nur den statischen Parameter #emph("PAR_SHAD"), sondern macht deutlich, dass die Architektur des gesamten Funktionsblocks im Kontext einer datengetriebenen, simulationsbasierten @ga konzeptionell neu gedacht werden muss (siehe @kap-neuerFunktionsblock).

==== Funktionsblock Lamellennachführung
Dieser Funktionsblock dient primär der Sicherstellung des visuellen Komforts für den Gebäudenutzer. Sobald direkte Sonnenstrahlung auf die Fassade trifft -- und die Verschattungskorrektur keinen Fremdschatten meldet -- berechnet der Block anhand der aktuellen Sonnenelevation, Fensterazimut und Lamellengeometrie den optimalen Cut-off Winkel der Jalousielamellen (vgl. @CutOffWinkelKapitel). Ziel ist es, direkte Blendung an den Arbeitsplätzen konsequent zu verhindern, gleichzeitig jedoch ein Maximum an diffusem Tageslicht in die Raumtiefe zu lenken, um die Tageslichtautonomie zu steigern.

==== Funktionsblock Dämmerungsautomatik
Zur Reduktion von Lichtverschmutzung steuert dieser Block die Fassade in den Abend- und Nachtstunden. Nach dem rechnerischen oder sensorgestützten Sonnenuntergang erzwingt der Funktionsblock das Schließen der Behänge. Dies verhindert das störende Abstrahlen von künstlichem Raumlicht in die Umgebung.

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