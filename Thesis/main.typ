#import "template/lib.typ": *
#import "glossary.typ": glossary-entries

#show: clean-hda.with(
  title: "Entwicklung einer durchgängigen Prozesskette zur Integration dynamischer Verschattungssimulationen in die Gebäudeautomation",
  subtitle: "Von der Anforderungsdefinition bis zum operativen Betrieb.",
  authors: (
    (name: "Niklas Wittkämper", student-id: "1382664", course-of-studies: "Gebäudeautomation", 
    // course: " ", 
    city:"Darmstadt", company: ((name: "Schneider Electric GmbH", city: "Berlin"))),
  ),
  type-of-thesis: "Masterarbeit",
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary-entries, // displays the glossary terms defined in "glossary.typ"
  language: "de", // en, de
  supervisor: (ref: "Prof. Dr.-Ing. Martin Höttecke", co-ref: "Matthias Meier"),
  university: "FH Münster - University of Applied Sciences",
  university-short: "h_da",
)

// Edit this content to your liking

= Einleitung
Die VDI 6011-1 @vdi6011-1 beschreibt die Grundlagen und allgemeinen Anforderungen für die Lichttechnik, insbesondere im Hinblick auf die Optimierung von Tageslichtnutzung und künstlicher Beleuchtung.
"tageslichtorientierte Planung" (siehe https://gebaeudedigital.de/schwerpunkt/licht-und-schatten/sonnenschutz-und-licht-zusammen-gedacht/)

= Einführung
== Begrifflichkeiten
=== Jahresverschattung
=== Lamellennachführung
=== Tageslichtverorgungsfaktor
=== Cut-Off-WInkel
Cut-Off bezeichnet die ideale Lamellenstellung, bei der die direkte Sonneneinstrahlung abgehalten wird, aber dennoch genügend diffuses Tageslicht zur Raumbeleuchtung genutzt wird


=== Meteorologische Einflüsse (Atmosphärische Dämpfung)
Im Gegensatz zu den geometrischen Hindernissen stellen Wolken keine feste Barriere dar, sondern wirken als Filter. Sie reduzieren die direkte Solarstrahlung und wandeln sie in diffuse Strahlung um. Dieser Vorgang ist hochdynamisch und schwer vorhersehbar. Für die Steuerung von Verschattungssystemen bedeutet dies, dass nicht nur die Position der Sonne, sondern auch die aktuelle Intensität der Strahlung (Meteorologie) kontinuierlich erfasst werden muss, um unnötiges Schließen der Behänge bei Bewölkung zu vermeiden.

== Arten von dynamischen Verschattungssystemen

/ Vertikalmarkisen: bestehen aus wetterfesten Stoffbahnen, die senkrecht vor dem Fenster geführt werden. Je nach Dichte und Farbe des Gewebes lässt sich die Sonneneinstrahlung reduzieren, wobei oft noch eine Sichtverbindung nach draußen möglich bleibt. Sie eignen sich gut, um ein Aufheizen der Räume zu verringern.

/ Rollläden: setzen sich aus miteinander verbundenen Profilstäben zusammen, die auf eine Welle aufgewickelt werden. Im geschlossenen Zustand bieten sie eine sehr gute Abdunkelung und Wärmedämmung. Für eine genaue Lichtlenkung sind sie jedoch weniger geeignet, da sie den Lichteinfall kaum dosieren können, sondern das Fenster meist nur freigeben oder verschließen.

/ Innenliegende Jalousien: zeichnen sich durch wendbare Lamellen aus, die eine präzise Dosierung des Lichteinfalls ermöglichen. Sie dienen vorwiegend dem Blendschutz. Aus energetischer Sicht sind sie jedoch weniger effizient als außenliegende Lösungen, da die solare Strahlung erst innerhalb der thermischen Gebäudehülle absorbiert oder reflektiert wird.

/ Außenliegende Jalousien (Raffstores): müssen den Witterungen außerhalb der Gebäudehülle standhalten und sind in der Gebäudeautomation  besonders wichtig, da sich ihre Lamellen dem Sonnenstand anpassen lassen. Dies ermöglicht es, Funktionalitäten im Bezug auf Nutzerkomfort und Energieeffizienz zu gewährleisten.


/ Weitere Systeme: z.B. Außenrollos, Screens, elektrochromes Glas, Gardinen, Großlamellen etc.

== Nutzen von Verschattungssystemen

Der funktionale Mehrwert von Verschattungssystemen innerhalb der Gebäudeautomation lässt sich primär in die Kategorien Energieeffizienz und Nutzerkomfort unterteilen.

Hinsichtlich der Energieeinsparung agiert die Verschattung als zentrales Regulativ für den energetischen Fußabdruck des Gebäudes. Durch eine effektive Tageslichtsteuerung kann der Bedarf an künstlicher Beleuchtung reduziert werden (Daylight Harvesting). Thermisch betrachtet senkt das Abfangen solarer Strahlung im Sommer die Kühllast signifikant, indem der Wärmeeintrag in das Gebäudeinnere minimiert wird. Im Winterbetrieb hingegen kann ein dynamisches System durch gezielte Nutzung solarer Gewinne (bei geöffneter Verschattung) oder durch Verhindern des Abstrahlens der Wärme in der Nacht zur Reduktion der Heizlast beitragen.

Parallel dazu steht die Komfortsteigerung für die Nutzer im Fokus. Ein effektiver Blendschutz gewährleistet die visuelle Ergonomie, insbesondere an Bildschirmarbeitsplätzen, während die Regulierung der operativen Raumtemperatur den thermischen Komfort stabilisiert. Ergänzend erfüllen Verschattungssysteme eine Funktion zur Wahrung der Privatsphäre, indem sie bei Bedarf visuellen Sichtschutz bieten.
== Nutzen von Verschattungssystemen
- Energieeinsparung
  - durch Tageslichtnutzung
  - Reduzierung der Kühllast im Sommer
  - Reduzierung der Heizlast im Winter
- Komfortsteigerung
  - Blendschutz
  - Thermischer Komfort
- Privatsphäre
- Minderung der Lichtverschmutzung

"Das Ziel ist dabei immer, die Tageslichtausbeute im Raum bei minimaler Blendung zu maximieren und gleichzeitig ein unnötiges Aufheizen des Raumes zu verhindern" https://gebaeudedigital.de/schwerpunkt/licht-und-schatten/sonnenschutz-und-licht-zusammen-gedacht/

Herausarbeiten, welche Vorteile vor allem dem Eigentümer, Betreiber und Nutzer der Anlage etwas bringen.

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
=== Blendschutz
=== Energetischer Nutzen
=== Lichtnutzen

== Mathematische Grundlagen und solare Geometrie
=== Solarkonstante und Globalstrahlung
=== Sonnenstand
=== Berechnungsgrundlagen der Sonnenposition

Für die algorithmische Bestimmung der Verschattungsposition ist die Transformation von der lokalen Zeit $t_("loc")$ in die Wahre Ortszeit ($t_("WOZ")$) notwendig. Die Korrektur erfolgt unter Berücksichtigung der Zeitgleichung $E$ und der geographischen Länge $lambda$:

$ t_("WOZ") = t_("loc") + E + 4 dot (lambda - lambda_("ref")) $

Wobei $lambda_("ref")$ den Referenzmeridian der Zeitzone beschreibt. Die Berechnung der Sonnenhöhe $gamma_s$ erfolgt anschließend über sphärische Trigonometrie:

$ sin(gamma_s) = sin(phi) dot sin(delta) + cos(phi) dot cos(delta) dot cos(omega) $

Hierbei stehen:
- $phi$ für die geographische Breite des Standorts
- $delta$ für die Deklination der Sonne
- $omega$ für den Stundenwinkel

Für die praktische Implementierung in der Gebäudeautomation wird in dieser Arbeit der Algorithmus nach Grena (source) verwendet, da dieser eine für die Ansteuerung von Jalousieaktoren hinreichende Genauigkeit bei reduzierter Rechenkomplexität bietet.
=== Winkel der Sonnenstrahlung
=== Berechnung der Verschattungswirkung
für tageslichtnutzung muss nichts berechnet werden, da man einfach über einen Helligkeitssensor geht. Es wäre allerdings theoretisch möglich mithilfe von mathematischen Modellen die Strahlung zu berechnen, um damit das licht zu steuern oder???

= Einleitung
== Problemstellung
//Die Gebäudeautomation hat ein Problem bei der Simulation und Integration von Verschattungsberechnungen in Gebäuden: Der Engineering-Aufwand ist sehr hoch... Da in der Zukunft allerdings immer weniger personelle Ressourcen zur Verfügung stehen werden und der Sonnenschutz im Zuge des Klimawandels eine immer bedeutendere Rolle einnehmen wird, ist es notwendig die gesamte Prozesskette neu zu betrachten. Es gilt, integrierte Lösungen zu finden, damit der Datenfluss vom Gebäudemodell des Architekten bis hin zur Systemintegration
//  der Verschattungsdaten gut funktioniert. 
// "Urbaner Kontext" benutzen? 

Die Steuerung automatisierter Fassadensysteme erfolgt in der heutigen Gebäudepraxis überwiegend reaktiv auf Basis lokaler Sensorik. Helligkeits- und Strahlungssensoren erfassen den Ist-Zustand der Umgebung, können jedoch komplexe geometrische Situationen wie den Schattenwurf durch Nachbarbebauung oder die Eigenverschattung der Fassade nur unzureichend abbilden. Dies führt im Betrieb häufig zu ineffizienten Fahrbewegungen der Behänge, die weder den visuellen Komfort noch den sommerlichen Wärmeschutz optimal bedienen.

Um diese Defizite auszugleichen, bieten moderne softwaregestützte Methoden die Möglichkeit, den Schattenwurf präzise vorauszuberechnen. Die praktische Anwendung scheitert jedoch derzeit an massiven Ineffizienzen innerhalb der digitalen Prozesskette, die sich sowohl in der Datenbeschaffung als auch in der Datenverwertung manifestieren.

Ein vorgelagertes Hindernis besteht in der mangelnden Simulationsfähigkeit der architektonischen Ausgangsdaten. Zwar liegen zunehmend digitale Bauwerksmodelle (BIM) vor, diese sind jedoch häufig für visuelle oder konstruktive Zwecke optimiert und entsprechen nicht den Anforderungen einer geometrischen Verschattungssimulation. Inkonsistente Geometrien, fehlende semantische Informationen oder ein unpassender Detaillierungsgrad (Level of Information Need) erzwingen eine zeitintensive manuelle Aufbereitung und Bereinigung der Modelle, bevor eine Berechnung überhaupt möglich ist.

Das nachgelagerte Problem betrifft die fehlende Prozessdefinition für die Datenintegration der Ergebnisse: Selbst wenn validierte Simulationsdaten vorliegen, existiert kein standardisierter Workflow, um diese ohne manuellen Mehraufwand direkt in die Steuerungslogik der Raumautomation zu überführen. Der derzeitige Engineering-Prozess sieht in der Regel nicht vor, dass die Simulationssoftware bereits das finale Datenformat für die Automationsstation bereitstellt.

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
Die vorliegende Arbeit gliedert sich in sieben Kapitel, die den Prozess von der theoretischen Analyse bis zur praktischen Validierung abbilden.

*Kapitel 2* legt die theoretischen Grundlagen. Hier werden die physikalischen Prinzipien der dynamischen Jahresverschattung erläutert sowie die relevanten Standards der digitalen Planung (BIM, IFC) und der Gebäudeautomation (VDI 3814, BACnet) definiert. Ein besonderer Fokus liegt auf der Diskrepanz zwischen geometrischer Simulation und operativer Steuerungstechnik.

*Kapitel 3* analysiert den Informationsbedarf vor der Simulation (Phase 1). Es wird untersucht, welche geometrischen und semantischen Anforderungen an digitale Bauwerksmodelle gestellt werden müssen, um eine automatisierte Weiterverarbeitung zu ermöglichen. Dabei werden Kriterien wie der Detaillierungsgrad (LOD) und die Qualität der Umgebungsdaten betrachtet.

*Kapitel 4* widmet sich den Anforderungen an die Simulationsergebnisse (Phase 2). Ziel ist die Definition einer standardisierten Schnittstelle, die festlegt, welche Steuergrößen (z. B. Lamellenwinkel, Verschattungsgrad) in welcher zeitlichen und räumlichen Auflösung an die Automation übergeben werden müssen.

*Kapitel 5* bildet den Kern der Arbeit und beschreibt die Konzeption und prototypische Umsetzung des Integrationsprozesses (Phase 3). Auf Basis der erarbeiteten Anforderungen wird ein Workflow entwickelt, der unter Verwendung von Open-Source-Technologien (Blender, Python) die Extraktion, Berechnung und den Export der Verschattungsdaten demonstriert.

*Kapitel 6* leitet aus den Erkenntnissen des Prototyps konkrete Handlungsempfehlungen für die Inbetriebnahme ab. Es werden Prüfmechanismen und Checklisten vorgestellt, die Systemintegratoren bei der Validierung externer Simulationsdaten unterstützen.

*Kapitel 7* fasst die Ergebnisse zusammen, diskutiert die Limitationen des entwickelten Ansatzes und gibt einen Ausblick auf weiterführende Forschungsfelder im Bereich der adaptiven Fassadensteuerung.

= Theoretische Grundlagen
== Physikalische und geometrische Grundlagen

In diesem Kapitel werden die astronomischen und geometrischen Gesetzmäßigkeiten hergeleitet, die für die Berechnung des Schattenwurfs maßgeblich sind. Zudem erfolgt eine Klassifizierung der aktorischen Komponenten und der zu optimierenden Zielgrößen.

=== Sonnenbahnmechanik
Für eine exakte Verschattungssimulation muss die Position der Sonne bekannt sein. Im Folgenden werden die Berechnungsgrundlagen für die Wahre Ortszeit, den Stundenwinkel sowie für Deklination, Höhenwinkel und Azimut dargelegt (siehe @fig-sonne).

#figure(
  image("assets/SonnenstandWinkelbezeichnung.png", width: 60%),
  caption: [
    Winkelbezeichnungen des Sonnenstandes @Quaschning
  ],
)<fig-sonne>

==== Wahre Ortszeit
Wie Duffie und Beckman @Duffie2013 herleiten, sind für die Berechnung der Wahren Ortszeit ($t_"WOZ"$) folgende Parameter notwendig:

- $t_"std"$: Gesetzliche Ortszeit (Local Standard Time) in Stunden.
- $n$: Tag des Jahres (1 bis 365).
- $lambda_"loc"$: Geografischer Längengrad des Standorts (in Grad).
- $lambda_"std"$: Bezugslängengrad der Zeitzone (z. B. $15 degree$ für MEZ).
- $E$: Zeitgleichung (Equation of Time) in Minuten.

Die Wahre Ortszeit berechnet sich wie folgt #footnote[Vorzeichenkonvention gemäß ISO 6709 (Ost positiv). Duffie/Beckman verwenden hier invertierte Vorzeichen (West positiv).]:

$ t_"WOZ" = t_"std" + frac(4 dot (lambda_"loc" - lambda_"std") + E, 60) $

Der Divisor 60 ist notwendig, um die Zeitkorrekturen (Minuten) in das Format der Basiszeit (Stunden) zu überführen. Die Zeitgleichung $E$ (in Minuten) wird angenähert durch:

$ E &= 229.18 dot (0.000075 + 0.001868 cos(B) - 0.032077 sin(B) \
  &- 0.014615 cos(2B) - 0.040849 sin(2B)) $

mit dem Hilfswinkel $B$:
$ B &= (n - 1) dot frac(360, 365) $

==== Stundenwinkel ($omega$)
Um die zeitliche Komponente in die geometrische Berechnung einzuführen, wird die Wahre Ortszeit ($t_"WOZ"$) in den Stundenwinkel $omega$ umgerechnet. Da die Erde sich um $15 degree$ pro Stunde dreht, gilt:

$ omega = (t_"WOZ" - 12) dot 15 degree $

Dabei entspricht $omega = 0 degree$ dem solaren Mittag (Sonne exakt im Süden). Vormittagswerte sind negativ, Nachmittagswerte positiv.

==== Sonnendeklination ($delta$)
$delta$ ist der Winkel zwischen der Verbindungslinie Erde-Sonne und der Äquatorebene. Sie beschreibt die Neigung der Erde in Relation zur Sonne und variiert im Jahresverlauf zwischen $-23,45 degree$ und $+23,45 degree$.

Für die Bestimmung der Sonnenposition wird das Berechnungsverfahren gemäß DIN EN 17037 (Tageslicht in Gebäuden) angewendet @dinen17037.
Ausgangsbasis für die Sonnendeklination $delta$ ist die Tageszahl $J$ (1 für 1. Januar bis 365 für 31. Dezember) und der daraus abgeleitete Jahreswinkel $J'$:

$ J' = 360 degree dot frac(J, 365) $

Die Deklination $delta(J)$ ergibt sich gemäß Gleichung D.3 der Norm:

$ delta(J) &= 0.3948 \
  &- 23.2559 dot cos(J' + 9.1 degree) \
  &- 0.3915 dot cos(2 dot J' + 5.4 degree) \
  &- 0.1764 dot cos(3 dot J' + 26.0 degree) $ <deklinationsgleichung>

#block(inset: 8pt, fill: luma(240))[
  *Hinweis zur Implementierung:*
  Die Koeffizienten liefern das Ergebnis in Grad. Für die geometrische Weiterverarbeitung im Simulationsmodell (siehe kapitel 5???) erfolgt eine Umrechnung in das Bogenmaß (Radiant).
]

==== Sonnenhöhenwinkel ($gamma_s$)
Der Sonnenhöhenwinkel beschreibt den vertikalen Winkel zwischen der horizontalen Ebene und dem Mittelpunkt der Sonnenscheibe. Er ist maßgeblich für die effektive Einstrahlung auf Fassadenflächen sowie für die Berechnung der Schattenlängen.

Basierend auf dem geografischen Breitengrad $phi$, der zuvor berechneten Deklination $delta$ und dem Stundenwinkel $omega$ ergibt sich der Höhenwinkel aus der grundlegenden Gleichung der sphärischen Astronomie:

$ sin(gamma_s) = sin(phi) dot sin(delta) + cos(phi) dot cos(delta) dot cos(omega) $

Durch Umstellung nach $gamma_s$ erhält man den expliziten Winkel:

$ gamma_s = arcsin(sin(phi) dot sin(delta) + cos(phi) dot cos(delta) dot cos(omega)) $

Dabei gelten folgende Randbedingungen:
- $gamma_s > 0 degree$: Die Sonne steht über dem Horizont (Tag).
- $gamma_s <= 0 degree$: Die Sonne steht unter dem Horizont (Nacht/Dämmerung).

#block(inset: 8pt, fill: luma(240))[
  *Relevanz für die Simulation:*
  In der Prozesskette (Kapitel 5) dient die Prüfung $gamma_s > 0$ als erster Filter ("Early Exit"). Ist der Wert negativ, muss kein aufwendiges Raycasting durchgeführt werden, da keine direkte Verschattung möglich ist.
]

==== Sonnenazimut ($alpha_s$)
Der Sonnenazimut beschreibt die horizontale Himmelsrichtung der Sonne. In Übereinstimmung mit der Norm DIN 5034-1 ist der Bezugspunkt die geografische Nordrichtung. Der Winkel wird im Uhrzeigersinn von $0 degree$ (Nord) bis $360 degree$ gemessen.

Die Berechnung erfolgt abhängig von der Wahren Ortszeit @Quaschning:

$ alpha_s = cases(
  180 degree - arccos(frac(sin(gamma_s) dot sin(phi) - sin(delta), cos(gamma_s) dot cos(phi))) & "für" t_"WOZ" <= 12,
  180 degree + arccos(frac(sin(gamma_s) dot sin(phi) - sin(delta), cos(gamma_s) dot cos(phi))) & "für" t_"WOZ" > 12
) $

#block(inset: 8pt, fill: luma(240))[
  *Vorteil für die Simulation:*
  Diese Definition (Nord = $0 degree$, im Uhrzeigersinn) entspricht dem Koordinatensystem gängiger 3D-Software und GIS-Daten.
]




=== Geometrie der Verschattung
Nachdem die Position der Sonne bestimmt wurde, muss im nächsten Schritt geprüft werden, ob die direkte Sichtlinie zwischen einem betrachteten Punkt auf der Fassade (z. B. Fenstermittelpunkt) und der Sonne durch Hindernisse unterbrochen wird.

==== Der Sonnenvektor
Für die geometrische Simulation in 3D-Umgebungen ist die sphärische Darstellung (Winkel) oft unpraktisch. Stattdessen wird die Sonnenposition als normierter Richtungsvektor $vec(S)$ im kartesischen Koordinatensystem definiert. 

Unter der Annahme eines Z-up-Koordinatensystems (z. B. in IFC-Modellen üblich, $Z$ zeigt zum Zenit, $Y$ nach Norden) berechnet sich der Sonnenvektor aus Azimut $alpha_s$ und Elevation $gamma_s$:

$ vec(S) = mat(
  sin(alpha_s) dot cos(gamma_s);
  cos(alpha_s) dot cos(gamma_s);
  sin(gamma_s)
) $

Dieser Vektor zeigt vom Ursprung zur Sonne. Für die Verschattungsberechnung wird der Vektor invertiert ($-vec(S)$), um die Einstrahlungsrichtung zu simulieren.

==== Klassifizierung der Verschattungstypen
Man unterscheidet in der Simulation zwei wesentliche Ursachen für den Schattenwurf:

- *Fremdverschattung:* Verursacht durch Objekte außerhalb der eigenen Gebäudehülle, wie Nachbarbebauung, Vegetation oder Topografie. Diese Geometrien sind im Betrieb statisch, müssen aber im digitalen Modell (IFC/CityGML) präzise abgebildet sein.
- *Eigenverschattung:* Verursacht durch die Gebäudegeometrie selbst, z. B. durch Fassadenvorsprünge, Balkone oder die Laibungstiefe des Fensters. Besonders die Laibungstiefe spielt bei steilen Sonnenständen eine kritische Rolle für das Vorausschauen des effektiven Lichteintrag.

==== Das Raycasting-Verfahren
Zur Ermittlung des Verschattungsstatus wird in modernen Simulationstools das *Raycasting* (Strahlenverfolgung) eingesetzt. Dabei wird ein theoretischer Sehstrahl $R(t)$ vom Referenzpunkt $P_0$ (z. B. Fenstermitte) in Richtung der Sonne gesendet:

$ R(t) = P_0 + t dot vec(S) quad "mit" t > 0 $

Der Algorithmus prüft, ob dieser Strahl ein beliebiges Polygon der Umgebungsszene (Mesh) schneidet (Intersection Test).

$ S_"status" = cases(
  1 & "wenn Schnittpunkt existiert (Schatten)",
  0 & "wenn kein Schnittpunkt existiert (Sonne)"
) $

Für eine differenzierte Betrachtung (z. B. "50% verschattet") wird die Fensterfläche in ein Raster aus Sub-Punkten unterteilt (Sampling). Der Verschattungsgrad $F_s$ ergibt sich dann aus dem Verhältnis der verschatteten Punkte $n_"schatten"$ zur Gesamtpunktzahl $N$:

$ F_s = frac(n_"schatten", N) $

==== Raytracing und Reflexionen
Während das Raycasting primär die binäre Sichtbarkeit (Schatten/Sonne) prüft, erweitert das *Raytracing* dieses Prinzip um die rekursive Verfolgung von Lichtstrahlen nach deren Interaktion mit Oberflächen.

Dies ist relevant für die Simulation von:
- *Spiegelungen:* Zusätzlicher Energieeintrag durch reflektierende Glasfassaden gegenüberliegender Gebäude.
- *Diffuse Streuung:* Aufhellung von Räumen durch helle Umgebungsflächen.

Für die Gebäudeautomation stellt echtes Raytracing jedoch eine Herausforderung dar:
1.  *Rechenaufwand:* Die Komplexität steigt mit der Anzahl der "Bounces" (Lichtsprünge) exponentiell an.
2.  *Datenqualität:* Für eine "korrekte Berechnung sind physikalische Materialparameter (Reflexionsgrad, Rauheit) im gesamten 3D-Modell notwendig, die in der Praxis oft fehlen (siehe Kapitel ???).

*Abgrenzung für diese Arbeit:*
???Da der primäre Energieeintrag durch direkte Solarstrahlung erfolgt und die Datengrundlage für Reflexionseigenschaften in Standard-IFC-Modellen oft unzureichend ist, fokussiert sich der entwickelte Prozess (Kapitel 5) auf das geometrische *Raycasting*. Reflexionen werden als sekundärer Einflussfaktor betrachtet und im Ausblick (Kapitel 7) diskutiert.

=== 2.1.3 Klassifizierung steuerbarer Sonnenschutzsysteme
- Systeme mit einem Freiheitsgrad (z. B. Rollläden, Screens): Variable Position $h$ (0-100%).
- Systeme mit zwei Freiheitsgraden (z. B. Raffstore/Jalousien): Variablen Position $h$ und Lamellenwinkel $lambda$.
- Relevanz für die Automation: Je komplexer das System, desto wichtiger ist die präzise Simulation des Winkels.

=== 2.1.4 Bauphysikalische und lichttechnische Zielgrößen
- Sommerlicher Wärmeschutz (Energieeintrag minimieren).
- Visueller Komfort (Blendung vermeiden).
- Tageslichtautonomie (Kunstlicht minimieren).
- Konfliktpotenzial: Erläuterung der konkurrierenden Ziele (z. B. Blendschutz vs. Tageslicht) und warum eine dynamische Simulation hier besser ist als eine starre Regelung.


== Dynamische Jahresverschattung
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
  Die Jahresverschattung bezeichnet die zeitabhängige Veränderung der solaren Exposition auf der Gebäudehülle im Verlauf eines meteorologischen Jahres. Sie ist das Resultat der Interaktion zwischen dem dynamischen Sonnenstand, der Gebäudeorientierung sowie der umgebenden Bebauung und Vegetation. Im Kontext der Gebäudeautomation definiert sie die zeitlichen und räumlichen Randbedingungen, unter denen ein variabler Sonnenschutz agieren muss.
]
Die Jahresverschattungssimulation bezeichnet ein simulationsgestütztes Verfahren zur Analyse und Steuerung des solaren Energie- und Lichteintrags in ein Gebäude über den Zeitraum eines vollständigen meteorologischen Jahres. Im Gegensatz zu statischen Verschattungselementen oder reinen Echtzeit-Helligkeitsregelungen basiert sie auf der zeitabhängigen Interaktion zwischen dem astronomischen Sonnenstand, der Gebäudegeometrie sowie der umgebenden Bebauung. Ziel ist die Ermittlung optimaler Positionierungsstrategien für variable Sonnenschutzsysteme, um ein Gleichgewicht zwischen der Minimierung thermischer Lasten (sommerlicher Wärmeschutz), der Maximierung solarer Gewinne (winterlicher Heizbedarf) und der Gewährleistung des visuellen Komforts (Blendfreiheit bei maximaler Tageslichtnutzung) sicherzustellen.
// Physikalische Prinzipien und Ziele (Energie vs. Komfort).
== Digitale Planungsmethoden (Datenformate?)
Wenn früher vor allem Papierpläne zum Datenkommunikationsaustausch im Planungsprozess verwendet wurden, gibt es mittlerweile eine Vielzahl an digitalen Möglichkeiten. Etabliert über die letzten Jahrzehnte, haben sich vor allem 2D-Grundrissdateien, die z.B. im proprietären Austauschformat dwg zwischen Architekten und Ingenieuren geteilt wurden. Während diese Methode heutzutage noch weite Anwendung findet, greifen die auf 3D-Modellen basierenden Austauschformate weiter um sich. Bereits einfache 3D-Modelle bieten große Vorteile bei der Verständlichkeit und Dichte der übermittelnden geometrischen Informationen. Zusätzlich ist es möglich im Rahmen eines BIM-Modells semantische Daten mit zu übermitteln. Das hierfür benutzte Austauschformat IFC bietet wichtige Funktionalitäten, um für die Verschattungssimulation relevante Daten zu  teilen.

// BIM, IFC, Simulationswerkzeuge (Überblick).
== Standards der Gebäudeautomation
// VDI 3814 (Schwerpunkt: Datenpunkte & Raumautomation), BACnet (Objekte).
=== GEG
Gesetz zur Einsparung von Energie und zur Nutzung erneuerbarer Energien zur Wärme- und Kälteerzeugung in Gebäuden (Gebäudeenergiegesetz - GEG)
§ 14 Sommerlicher Wärmeschutz
(1) Ein Gebäude ist so zu errichten, dass der Sonneneintrag durch einen ausreichenden baulichen sommerlichen Wärmeschutz nach den anerkannten Regeln der Technik begrenzt wird. Bei der Ermittlung eines ausreichenden sommerlichen Wärmeschutzes nach den Absätzen 2 und 3 bleiben die öffentlich-rechtlichen Vorschriften über die erforderliche Tageslichtversorgung unberührt.
(2) Ein ausreichender sommerlicher Wärmeschutz nach Absatz 1 liegt vor, wenn die Anforderungen nach DIN 4108-2: 2013-02 Abschnitt 8 eingehalten werden und die rechnerisch ermittelten Werte des Sonnenenergieeintrags über transparente Bauteile in Gebäude (Sonneneintragskennwert) die in DIN 4108-2: 2013-02 Abschnitt 8.3.3 festgelegten Anforderungswerte nicht überschreiten. Der Sonneneintragskennwert des zu errichtenden Gebäudes ist nach dem in DIN 4108-2: 2013-02 Abschnitt 8.3.2 genannten Verfahren zu bestimmen.
(3) Ein ausreichender sommerlicher Wärmeschutz nach Absatz 1 liegt auch vor, wenn mit einem Berechnungsverfahren nach DIN 4108-2: 2013-02 Abschnitt 8.4 (Simulationsrechnung) gezeigt werden kann, dass unter den dort genannten Randbedingungen die für den Standort des Gebäudes in DIN 4108-2: 2013-02 Abschnitt 8.4 Tabelle 9 angegebenen Übertemperatur-Gradstunden nicht überschritten werden.
(4) Wird bei Gebäuden mit Anlagen zur Kühlung die Berechnung nach Absatz 3 durchgeführt, sind bauliche Maßnahmen zum sommerlichen Wärmeschutz gemäß DIN 4108-2: 2013-02 Abschnitt 4.3 insoweit vorzusehen, wie sich die Investitionen für diese baulichen Maßnahmen innerhalb deren üblicher Nutzungsdauer durch die Einsparung von Energie zur Kühlung unter Zugrundelegung der im Gebäude installierten Anlagen zur Kühlung erwirtschaften lassen.
(5) Auf Berechnungen nach den Absätzen 2 bis 4 kann unter den Voraussetzungen des Abschnitts 8.2.2 der DIN 4108-2: 2013-02 verzichtet werden.
=== DIN V 18599
hier bezug auf die automatisierungsgrade nehmen
=== VDI 6011-1
=== DIN EN 17037
=== Weitere Normen
DIN EN ISO 7730: Ergonomie der thermischen Umgebung

Relevanz: Diese Norm ist der Standard für die Bewertung des thermischen Komforts.

Kernpunkte: Sie definiert Indizes wie den PMV (Predicted Mean Vote) und den PPD (Predicted Percentage of Dissatisfied), um die thermische Behaglichkeit zu quantifizieren. Die Jahresverschattung hat einen direkten Einfluss darauf, indem sie den Strahlungseintrag durch die Sonne und damit die operative Temperatur im Raum steuert.


DIN EN 14501: Abschlüsse und Jalousien - Thermischer und visueller Komfort - Leistungs- und Klassifizierungseigenschaften

Relevanz: Dies ist die wichtigste Produktnorm für Sonnenschutz. Sie definiert, wie die Leistung von Jalousien, Rollläden etc. gemessen und in Leistungsklassen eingeteilt wird.

Kernpunkte: Sie klassifiziert Produkte anhand von Kennwerten wie:

Thermischer Komfort: @g-wert, der angibt, wie viel Sonnenenergie durch das Fenster-Sonnenschutz-System ins Rauminnere gelangt.

Visueller Komfort: Lichttransmissionsgrad (τ v), Blendschutz (Klassen 0-4), Sichtverbindung nach draußen.
Die Datenblätter von Herstellern wie Warema, Somfy etc. basieren auf den Messverfahren dieser Norm.

= Analyse des Informationsbedarfs

// NEU:  (Phase 1 Vor der Simulation) Hier gehst du darauf ein, was die Software überhaupt braucht.
- Zugriff auf Datensätzen von umliegenden Gebäuden und Strukturen. Diese können z.B. über Open-Source-Angebote bereitgestellt werden (Google Maps, Open Street Maps, etc.)
== Geometrische Anforderungen
Die auf die Gebäudehülle treffende Solarstrahlung wird nicht nur durch den Sonnenstand, sondern maßgeblich durch feste und variable Hindernisse im Strahlengang beeinflusst. Für die Auslegung und Regelung von dynamischen Verschattungssystemen ist es notwendig, diese Einflussfaktoren zu kategorisieren. Dabei wird primär zwischen gebäudeseitigen (Eigenverschattung), umgebungsbedingten (Fremdverschattung) und meteorologischen Faktoren unterschieden.

=== Unbewegliche Bauteile (Eigenverschattung)
Die Eigenverschattung resultiert aus der Geometrie des Baukörpers selbst. Feste architektonische Elemente blockieren die direkte Sonneneinstrahlung in Abhängigkeit vom Einstrahlwinkel. Zu diesen Elementen zählen:

- Auskragungen wie Vordächer, Balkone oder Gesimse.
- Die Fensterlaibung (die Tiefe des Fensters in der Wand), welche insbesondere bei steilen Einstrahlwinkeln relevant wird.
- Vertikale Elemente wie Lisenen oder Fassadenschwerter.

Diese Art der Verschattung ist statisch und durch die Architektur festgelegt. Sie wirkt oft saisonal selektiv: Ein gut dimensionierter Dachüberstand kann beispielsweise die hochstehende Sommersonne abschirmen (Wärmeschutz), lässt aber die flachstehende Wintersonne zur passiven solaren Erwärmung passieren.

=== Umliegende Topographie und Bebauung (Fremdverschattung)
Die Fremdverschattung umfasst alle Hindernisse, die nicht Teil des betrachteten Gebäudes sind, aber den Horizontverlauf verändern. Diese Faktoren sind standortspezifisch und müssen in der Regelung als externe Randbedingungen betrachtet werden. 

==== Topographie und Vegetation
Natürliche Erhebungen wie Hügel oder Berge verkürzen die effektive Sonnenscheindauer, indem sie den sichtbaren Horizont anheben. Vegetation (Bäume, Hecken) nimmt eine Sonderrolle ein: Während Nadelbäume als statische Hindernisse betrachtet werden können, variiert die Transparenz von Laubbäumen saisonal. Im Sommer bieten sie hohen Strahlungsschutz, im Winter lassen sie nach Laubabwurf mehr Licht und Wärme passieren.

==== Umliegende Bebauung
In städtischen Kontexten wird der solare Ertrag maßgeblich durch Nachbargebäude reduziert. Diese werfen Schlagschatten, die je nach Tages- und Jahreszeit über die Fassade wandern. Für die Gebäudeautomation ist dies relevant, da Sensoren am Dach möglicherweise Sonne registrieren, während das Erdgeschoss bereits im Schatten des Nachbarhauses liegt.

// Detaillierungsgrad des 3D-Modells (LOD), Relevanz von Nachbargebäuden/Bäumen.
- Umgebungsdaten
- Gebäudedaten (ifc) sollte haben:
  - richtige labels für gebäudeteile (IFC-Window-Klasse)
  - Nur Fassadenelemente
  - Die Fensterflächen sollten richtig _Face Normals_ (Flächenausrichtung)? für backwards Culling
  - Die Fenster sollten guten BMKZ haben
  - Das Gebäude sollte auf der richtigen Z-Höhe sein
  - Das Gebäude sollte nach Norden ausgerichtet sein



= Definition der Schnittstellenanforderungen (Phase 2: Simulationsergebnisse)
// Was kommt aus der Simulation heraus?
== Identifikation relevanter Steuergrößen
(z.B. Lamellenwinkel, Behanghöhe, Verschattungsfaktor).
== Zeitliche und räumliche Auflösung
// Pro Fenster? Pro Fassade? 15-Minuten-Werte vs. Echtzeitberechnung.
== Anforderungen an das Datenformat für den Export
// CSV, XML, IFC-Properties - was ist lesbar für die GA?

= Konzeption des Integrationsprozesses (Phase 3: Nach der Simulation)
// Wie kommen die Daten von Phase 2 in die Steuerung?
== Prozessmodell für den Datenaustausch
// Wer liefert wann was? (Rollen: Architekt -> Simulant -> Systemintegrator).
== Daten-Mapping und Adressierung
// Wie ordnet man den Simulationswert dem richtigen Aktor zu? (Naming Conventions, AKS/BKS).
== Statische oder dynamische Daten?
// Werden Tabellen in die SPS geladen oder sollte es eine kontinuierliche Datenverbindung geben?
Vorteile von geladener Daten auf MBE-Ebene überwiegen.
- Modell ist mittelfristig statisch (bis umliegende Bebauung sich ändert, bzw. die eigene Fassade angepasst wird)
- Keine Datenverbindung zu externem System notwendig
== Datenintegration in Steuerungslogik der Behänge
Hier vlt. Flowchart oder Diagramm Funktionsblöcke von Steuerung der Behänge

= POC
// Vorstellung Four (Turm 1)
Das FOUR sind vier zusammenhängende Türme in der Innenstadt von Frankfurt am Main.  
== Import Umgebungsdaten
  === Überlegung zur wahl des datenanbieter:
  - osm ziemlich gut
  - 3D-Tiles von google nicht mehr erlaubt in EU (https://developers.google.com/maps/comms/eea/map-tiles)
  - daten von stadt frankfurt?

=== überlegung zur auswahl der szene
  - Gebäude im norden vom gebäude müssen nicht geladen werden, da sie nicht das gebäuude verschatten können
  - bei sehr tiefliegender sonne sind auch weit entferne gebäude relevant
  - niedrige gebäude sind nur für die niedrigen etagen interessant (vielleicht simulationen so aufsplitten?)

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


= Diskussion und Fazit
== Zusammenfassung der Ergebnisse
== Grenzen des entwickelten Prozesses
== Ausblick

= Literaturverzeichnis


= Fazit
= KI-Disclaimer

- Gemini 2.5 Pro Deep Research: Recherche für Marktanalyse; Vorschläge für Technologiestack der Anwendung
- Gemini 3.0 Pro: Sparringpartner, Recherche, Entwicklung der Forschungsfrage, Generierung von Ideen
- Perplexity AI: Recherche zu Normen und technischen Grundlagen

Es wird ausdrücklich darauf hingewiesen, dass die endgültige Verantwortung für die inhaltliche Richtigkeit, die kritische Reflexion und die Interpretation der Ergebnisse beim Autor/der Autorin dieser Arbeit liegt.

Die KI diente lediglich als Werkzeug und nicht als Ersatz für das kritische und analytische Denken des Forschenden.