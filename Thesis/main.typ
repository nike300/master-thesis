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
// Diskrepanz zwischen Planung (Simulation) und Realisierung (Automation).
== Zielsetzung
// Entwicklung einer durchgängigen Prozesskette (Data Workflow).
== Forschungsfrage

= Theoretische Grundlagen
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
In städtischen Kontexten (Urban Canyons) wird der solare Ertrag maßgeblich durch Nachbargebäude reduziert. Diese werfen Schlagschatten, die je nach Tages- und Jahreszeit über die Fassade wandern. Für die Gebäudeautomation ist dies relevant, da Sensoren am Dach möglicherweise Sonne registrieren, während das Erdgeschoss bereits im Schatten des Nachbarhauses liegt.

// Detaillierungsgrad des 3D-Modells (LOD), Relevanz von Nachbargebäuden/Bäumen.
- Umgebungsdaten
- Gebäudedaten

== Meteorologische Daten
// Wetterdatensätze (TRY - Test Reference Years), Strahlungsdaten.
== Materialtechnische Parameter
// Transmissionsgrade, Reflexionsgrade der Lamellen/Textilien.

= Definition der Schnittstellenanforderungen (Phase 2: Simulationsergebnisse)
// Was kommt aus der Simulation heraus?
== Identifikation relevanter Steuergrößen
(z.B. Lamellenwinkel, Behanghöhe, Verschattungsfaktor).
== Zeitliche und räumliche Auflösung
// Pro Fenster? Pro Fassade? 15-Minuten-Werte vs. Echtzeitberechnung.
== Anforderungen an das Datenformat für den Export
// CSV, XML, IFC-Properties - was ist lesbar für die GA?

= Konzeption der Integrationsprozesses (Phase 3: Der Workflow)
// Das Kernstück deiner Arbeit: Wie kommen die Daten von Phase 2 in die Steuerung?
== Prozessmodell für den Datenaustausch
// Wer liefert wann was? (Rollen: Architekt -> Simulant -> Systemintegrator).
== Daten-Mapping und Adressierung
// Wie ordnet man den Simulationswert dem richtigen Aktor zu? (Naming Conventions, AKS/BKS).
== Umgang mit dynamischen vs. statischen Daten
Es stellt sich die Frage, wie die Verschattungsdaten sinnvoll in die Programme für die Behänge integriert werden.
// Werden Tabellen in die SPS geladen oder Parameter fest parametriert?

= Handlungsempfehlung für die Inbetriebnahme (Reduziert)
// Statt "Betrieb" fokusieren wir uns auf den "Handover".
== Checkliste für den Systemintegrator
// Wie prüft man, ob die importierten Daten plausibel sind? (Sanity Check).
== Fallback-Strategien
// Was passiert, wenn die Simulationsdaten fehlen oder fehlerhaft sind?

= POC
== Import Umgebungsdaten
== Import IFC
== Positionierung IFC
Problem der Georeferenzierung. Ungenauigkeit. Eine Verschiebung um 50 cm oder eine Drehung um 1 Grad kann bei einem Hochhaus dazu führen, dass der Schattenwurf in 100 m Entfernung um Meter falsch berechnet wird. Das ist ein wichtiger Punkt für deine "Diskussion der Ergebnisse".
- Schwierig höhe z richtig zu bekommmen
- Bereinigung von Redundanzen im Kontextmodell (Bestehendes Gebäude aus OSM löschen)
- Mittelpunkt fenster setzen in blender
- Style blocker benutzen
- Problem: Simulation dauert sehr lange für Gebäude
  - Lösungsoptionen: 
  - vlt. Umgebungsdaten eingrenzen
  - vlt. 
- Problem Fenster sind random benannt
  - Lösung:
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