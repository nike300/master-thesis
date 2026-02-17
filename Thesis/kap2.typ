= Theoretische Grundlagen<Kap2>
== Physikalische und geometrische Grundlagen

In diesem Kapitel werden die astronomischen und geometrischen Gesetzmäßigkeiten hergeleitet, die für die Berechnung des Schattenwurfs maßgeblich sind. Zudem erfolgt eine Klassifizierung der aktorischen Komponenten und der zu optimierenden Zielgrößen.

=== Sonnenbahnmechanik
Für eine exakte Verschattungssimulation muss die Position der Sonne bekannt sein. Im Folgenden werden die Berechnungsgrundlagen für die Wahre Ortszeit, den Stundenwinkel sowie für Deklination, Höhenwinkel und Azimut dargelegt (siehe @fig-sonnenmodell).

#figure(
  image("assets/SonnenstandWinkelbezeichnung.png", width: 60%),
  caption: [
    Winkelbezeichnungen des Sonnenstandes @Quaschning
  ],
)<fig-sonnenmodell>

==== Wahre Ortszeit
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

=== Vergleich und Auswahl der Berechnungsverfahren
Die in den vorangegangenen Abschnitten dargestellten Formeln der DIN EN 17037 stellen die normative Grundlage für die Tageslichtplanung in Europa dar. Sie bieten eine für architektonische Entwürfe hinreichende Genauigkeit.

Für die Implementierung des Simulations-Prototyps (siehe Kapitel 4) wird jedoch auf den Algorithmus der *National Oceanic and Atmospheric Administration* (NOAA) zurückgegriffen. Dieser zeichnet sich durch folgende Merkmale aus:

- *Höhere Präzision:* Während einfache Näherungen Fehler von bis zu $1 degree$ aufweisen können, minimiert der NOAA-Algorithmus (basierend auf den Arbeiten von Jean Meeus @Meeus1998) die Abweichungen auf unter $0,0001 degree$.
- *Berücksichtigung atmosphärischer Effekte:* Der Algorithmus inkludiert Korrekturfaktoren für die atmosphärische Refraktion, was insbesondere bei flachen Sonnenständen (Morgen- und Abendstunden) für die Lamellennachführung in der Gebäudeautomation kritisch ist.

Auf eine detaillierte mathematische Herleitung der über 30 Korrekturterme des NOAA-Verfahrens wird an dieser Stelle verzichtet; die Berechnung folgt der dokumentierten Implementierung gemäß @NOAASolar2021.


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

Für eine differenzierte Betrachtung (z. B. 50% verschattet) wird die Fensterfläche in ein Raster aus Sub-Punkten unterteilt (Sampling). Der Verschattungsgrad $F_s$ ergibt sich dann aus dem Verhältnis der verschatteten Punkte $n_"schatten"$ zur Gesamtpunktzahl $N$:

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
???Da der primäre Energieeintrag durch direkte Solarstrahlung erfolgt und die Datengrundlage für Reflexionseigenschaften in Standard-IFC-Modellen oft unzureichend ist, fokussiert sich der entwickelte Prozess (@Kap4[Kapitel]) auf das geometrische *Raycasting*. Reflexionen werden als sekundärer Einflussfaktor betrachtet und im Ausblick (@Kap6[Kapitel]) diskutiert.

=== Klassifizierung steuerbarer Sonnenschutzsysteme
- Systeme mit einem Freiheitsgrad (z. B. Rollläden, Screens): Variable Position $h$ (0-100%).
- Systeme mit zwei Freiheitsgraden (z. B. Raffstore/Jalousien): Variablen Position $h$ und Lamellenwinkel $lambda$.
- Relevanz für die Automation: Je komplexer das System, desto wichtiger ist die präzise Simulation des Winkels.

=== Bauphysikalische und lichttechnische Zielgrößen
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
