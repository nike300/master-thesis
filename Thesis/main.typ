#import "template/lib.typ": *
#import "glossary.typ": glossary-entries

#show: clean-hda.with(
  title: "Dynamische Verschattungssysteme zur Jahresverschattung in der Gebäudeautomation",
//  subtitle: "Untertitel für einer Arbeit",
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
  supervisor: (ref: "Prof. Dr.-Ing. Martin Höttecke", co-ref: "Matthias Fabian"),
  university: "Hochschule Darmstadt - University of Applied Sciences",
  university-location: "Darmstadt",
  university-short: "h_da",
)

// Edit this content to your liking

= Einleitung
Die VDI 6011-1 @vdi6011-1 beschreibt die Grundlagen und allgemeinen Anforderungen für die Lichttechnik, insbesondere im Hinblick auf die Optimierung von Tageslichtnutzung und künstlicher Beleuchtung.
"tageslichtorientierte Planung" (siehe https://gebaeudedigital.de/schwerpunkt/licht-und-schatten/sonnenschutz-und-licht-zusammen-gedacht/)

= Einführung in die Jahresverschattung
== Glossar

Jahresverschattung
: Gesamtheit der Maßnahmen und Effekte, die über ein Jahr hinweg den solaren Eintrag in ein Gebäude beeinflussen; berücksichtigt saisonale Sonnenstände und äußere Einflüsse.

Lamellennachführung
: Steuerstrategie beweglicher Lamellen (z. B. Raffstores), die Lamellenstellung dynamisch an Sonnenstand, Tageslichtbedarf und Blendungsbegrenzung anpasst.

Tageslichtverorgungsfaktor (TDF)
: Verhältnis der in einem Innenraum erzielten Tageslichtbeleuchtungsstärke zur außen gemessenen Beleuchtungsstärke; dient zur Bewertung der Tageslichtversorgung.

Verschattung durch unbewegliche Bauteile
: Abschattungseffekte durch architektonische Elemente wie Überhänge, Vordächer, Fensterlaibungen oder Brüstungen.

Verschattung durch Topographie
: Abschattung infolge Geländeformen und Vegetation (Hügel, Bäume) in der Umgebung eines Gebäudes.

Verschattung durch andere Gebäude
: Reduktion des direkten Sonnenlichts durch benachbarte Bauwerke, relevant für städtische Lagen.

Vertikalmarkisen
: Außen angebrachte Stoffbehänge, die vertikal heruntergezogen werden; primär Sonnenschutz, eingeschränkte Blick- und Wärmeregulierung.

Rollläden
: Dichte, häufig opake Verschluss-Systeme aus Lamellen oder Platten; gut für Wärmedämmung und Einbruchschutz, eingeschränkter Tageslichtnutzen.

Raffstores
: Verstellbare Lamellen-Systeme (außen oder innen) zur gezielten Lichtlenkung, kombinieren Blendschutz und Sichtverbindung.

Außenjalousien
: Außen montierte Raffstore-ähnliche Systeme; hohe Wirksamkeit bei sommerlichem Wärmeschutz und Blendreduktion.

Innenjalousien
: Im Raum platzierte Lamellen; gute Sicht- und Lichtsteuerung, geringer Einfluss auf Gebäudeargonomie bezüglich Wärmeschutz.

Zwischenraumjalousien
: In Verglasung integrierte, geschützte Lamellen (zwischen zwei Glasflächen); wartungsarm, guter Blend- und Wärmeschutz.

Gardinen und Textilrollos
: Weiche, diffuse Verrichtung des Lichts; primär für Sicht- und Blendkomfort, geringer sommerlicher Wärmeschutz.

Kombinierte Verschattungssysteme
: Integration mehrerer Systeme (z. B. Außenraffstore + textile Innenscreens) zur Optimierung von Licht, Sicht und Energie.

Blendschutz
: Maßnahmen zur Reduktion unangenehmer visueller Blendungen durch direkte oder reflektierte Sonnenstrahlung.

Energetischer Nutzen
: Einfluss von Verschattung auf Heiz- und Kühlenergiebedarf; Verringerung sommerlicher Kühllasten, mögliches Reduzieren passiver solare Gewinne im Winter.

Lichtnutzen
: Maximierung der nutzbaren Tageslichtanteile im Raum bei gleichzeitigem Erhalt visuellen Komforts.

Solarkonstante und Globalstrahlung
: Solarkonstante: mittlere Einstrahlungsleistung der Sonne außerhalb der Atmosphäre (~1361 W/m²). Globalstrahlung: auf die Erdoberfläche eintreffende summe aus direkter und diffuser Strahlung.

Sonnenstand
: Position der Sonne am Himmel (Azimut und Zenitwinkel), Funktion von Datum, Uhrzeit und Standort; Grundlage für Verschattungsberechnungen.

Einfallswinkel der Sonnenstrahlung
: Winkel zwischen einfallender Sonnenstrahlung und der Normalen einer Fläche; beeinflusst Transmission, Reflexion und Absorption.

Berechnung der Verschattungswirkung
: Geometrische Projektion von Hindernissen auf Fassaden/öffentliche Flächen; kombiniert Sonnenbahn, Gebäudegeometrie und Systemstellung.

Normen (Relevante Auszüge)
: Kurze Übersicht zu geltenden Normen wie GEG, DIN 4108-2, DIN EN 14501, VDI 6011-1 und DIN EN 17037 — regeln Anforderungen an Wärmeschutz, Produktmessungen und Tageslichtqualität.

GA-Tools (Gebäudeautomation)
: Software-Module und Steuerlogiken zur Integration von Verschattung, Licht- und Klimaregelung in Gebäudeautomationssysteme.

Simulationssoftware
: Programme zur Jahres- und tagesauflösenden Berechnung von Strahlung, Energieströmen und Tageslicht (z. B. Energie-, CFD- und Lichtsimulationen).

Marktanalyse (Kurz)
: Bewertung von Herstellern, Produktklassen und angebotenen Leistungsdaten (z. B. g_tot, τv, Blendklassen) als Entscheidungsgrundlage.

Installation und Betrieb
: Aspekte zur Montage, Wartung, Anbindung an Automationssysteme und Life-Cycle-Kosten.

Steuerungsstrategien
: Regeln für manuelle, zeit- oder sensorbasierte sowie prädiktive Steuerung (z. B. wetter- oder belegtbasierte Nachführung).

Kennwerte zur Produktbewertung
: Gesamtenergiedurchlassgrad (g_tot), Lichttransmissionsgrad (τv), Blendreduktionsklassen — meist in Herstellerdatenblättern angegeben.

Quellen und weiterführende Literatur
: Normen, Herstellerdokumentationen und einschlägige Fachartikel zur vertiefenden Recherche.
== Begrifflichkeiten
=== Jahresverschattung
=== Lamellennachführung
=== Tageslichtverorgungsfaktor

== Arten der Verschattung
=== Verschattung durch unbewegliche Bauteile
z.B. Fensterbänke, Vordächer, Überhänge
=== Verschattung durch Topographie
z.B. Hügel, Bäume, andere natürliche Elemente
=== Verschattung durch andere Gebäude

== Arten von beweglichen Verschattungssystemen
Rolläden und Vertikalmarkisen können auch einen Teil der Funktionalität eines Raffstores bereitstellen, ihnen fehlt allerdings die Möglichkeit zur Lichsteuerung durch bewegliche Lamellenelemente.
=== Vertikalmarkisen
Ausfahrbare Stoffbahnen, die vertikal an der Außenseite von Fenstern angebracht sind.
=== Rollläden
...mit Elementen, die meist aus Metall oder Kunststoff bestehen.
=== Raffstores
Unterscheidung Jalousien und Raffstores
==== Außenjalousien
was ist das, vorteile nachteile

==== Innenjalousien
==== Zwischenraumjalousien
=== Weitere Verschattungssysteme
Gardinen, kombinierte Verschattungssysteme, Textilrollos

== Nutzen von Verschattungssystemen
"Das Ziel ist dabei immer, die Tageslichtausbeute im Raum bei minimaler Blendung zu maximieren und gleichzeitig ein unnötiges Aufheizen des Raumes zu verhindern" https://gebaeudedigital.de/schwerpunkt/licht-und-schatten/sonnenschutz-und-licht-zusammen-gedacht/

Herausarbeiten, welche Vorteile vor allem dem Eigentümer, Betreiber und Nutzer der Anlage etwas bringen.
=== Blendschutz
=== Energetischer Nutzen
=== Lichtnutzen

== Mathematische Grundlagen und solare Geometrie
=== Solarkonstante und Globalstrahlung
=== Sonnenstand
=== Winkel der Sonnenstrahlung
=== Berechnung der Verschattungswirkung

== Normenübersicht
=== GEG
Gesetz zur Einsparung von Energie und zur Nutzung erneuerbarer Energien zur Wärme- und Kälteerzeugung in Gebäuden (Gebäudeenergiegesetz - GEG)
§ 14 Sommerlicher Wärmeschutz
(1) Ein Gebäude ist so zu errichten, dass der Sonneneintrag durch einen ausreichenden baulichen sommerlichen Wärmeschutz nach den anerkannten Regeln der Technik begrenzt wird. Bei der Ermittlung eines ausreichenden sommerlichen Wärmeschutzes nach den Absätzen 2 und 3 bleiben die öffentlich-rechtlichen Vorschriften über die erforderliche Tageslichtversorgung unberührt.
(2) Ein ausreichender sommerlicher Wärmeschutz nach Absatz 1 liegt vor, wenn die Anforderungen nach DIN 4108-2: 2013-02 Abschnitt 8 eingehalten werden und die rechnerisch ermittelten Werte des Sonnenenergieeintrags über transparente Bauteile in Gebäude (Sonneneintragskennwert) die in DIN 4108-2: 2013-02 Abschnitt 8.3.3 festgelegten Anforderungswerte nicht überschreiten. Der Sonneneintragskennwert des zu errichtenden Gebäudes ist nach dem in DIN 4108-2: 2013-02 Abschnitt 8.3.2 genannten Verfahren zu bestimmen.
(3) Ein ausreichender sommerlicher Wärmeschutz nach Absatz 1 liegt auch vor, wenn mit einem Berechnungsverfahren nach DIN 4108-2: 2013-02 Abschnitt 8.4 (Simulationsrechnung) gezeigt werden kann, dass unter den dort genannten Randbedingungen die für den Standort des Gebäudes in DIN 4108-2: 2013-02 Abschnitt 8.4 Tabelle 9 angegebenen Übertemperatur-Gradstunden nicht überschritten werden.
(4) Wird bei Gebäuden mit Anlagen zur Kühlung die Berechnung nach Absatz 3 durchgeführt, sind bauliche Maßnahmen zum sommerlichen Wärmeschutz gemäß DIN 4108-2: 2013-02 Abschnitt 4.3 insoweit vorzusehen, wie sich die Investitionen für diese baulichen Maßnahmen innerhalb deren üblicher Nutzungsdauer durch die Einsparung von Energie zur Kühlung unter Zugrundelegung der im Gebäude installierten Anlagen zur Kühlung erwirtschaften lassen.
(5) Auf Berechnungen nach den Absätzen 2 bis 4 kann unter den Voraussetzungen des Abschnitts 8.2.2 der DIN 4108-2: 2013-02 verzichtet werden.
=== DIN V 18599

=== VDI 6011-1
=== DIN EN 17037
=== Weitere Normen
DIN EN ISO 7730: Ergonomie der thermischen Umgebung

Relevanz: Diese Norm ist der Standard für die Bewertung des thermischen Komforts.

Kernpunkte: Sie definiert Indizes wie den PMV (Predicted Mean Vote) und den PPD (Predicted Percentage of Dissatisfied), um die thermische Behaglichkeit zu quantifizieren. Die Jahresverschattung hat einen direkten Einfluss darauf, indem sie den Strahlungseintrag durch die Sonne und damit die operative Temperatur im Raum steuert.


DIN EN 14501: Abschlüsse und Jalousien - Thermischer und visueller Komfort - Leistungs- und Klassifizierungseigenschaften

Relevanz: Dies ist die wichtigste Produktnorm für Sonnenschutz. Sie definiert, wie die Leistung von Jalousien, Rollläden etc. gemessen und in Leistungsklassen eingeteilt wird.

Kernpunkte: Sie klassifiziert Produkte anhand von Kennwerten wie:

Thermischer Komfort: Gesamtenergiedurchlassgrad (g 
tot
​
 ), der angibt, wie viel Sonnenenergie durch das Fenster-Sonnenschutz-System ins Rauminnere gelangt.

Visueller Komfort: Lichttransmissionsgrad (τ 
v
​
 ), Blendschutz (Klassen 0-4), Sichtverbindung nach draußen.
Die Datenblätter von Herstellern wie Warema, Somfy etc. basieren auf den Messverfahren dieser Norm.


= Marktanalyse
== GA-Tools
== Simulationssoftware

= Überlegungsansätze


= Toolentwicklung
== Modul 1
== Modul 2
== Modul 3

= Vorlage

Im folgenden werden einige nützliche Elemente und Funktionen zum Erstellen von Typst-Dokumenten mit diesem Template erläutert.

== Ausdrücke und Abkürzungen

Verwende die `gls`-Funktion, um Ausdrücke aus dem Glossar einzufügen, die dann dorthin verlinkt werden. Ein Beispiel dafür ist: 

Im diesem Kapitel wird eine #gls("Softwareschnittstelle") beschrieben. Man spricht in diesem Zusammenhang auch von einem #gls("API"). Die Schnittstelle nutzt Technologien wie das #gls("HTTP").

Das Template nutzt das `glossarium`-Package für solche Glossar-Referenzen. In der zugehörigen #link("https://typst.app/universe/package/glossarium/", "Dokumentation") werden noch weitere Varianten für derartige Querverweise gezeigt. Dort ist auch im Detail erläutert, wie das Glossar aufgebaut werden kann.


== Listen

Es gibt Aufzählungslisten oder nummerierte Listen:

- Dies
- ist eine
- Aufzählungsliste

+ Und
+ hier wird
+ alles nummeriert.

== Abbildungen und Tabellen

Abbildungen und Tabellen (mit entsprechenden Beschriftungen) werden wie folgt erstellt.

=== Abbildungen


=== Tabellen

#figure(
  caption: "Eine Tabelle",
  table(
    columns: (1fr, 50%, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [],
      [*Area*],
      [*Parameters*],
    ),

    text("cylinder.svg"),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    text("tetrahedron.svg"), $ sqrt(2) / 12 a^3 $, [$a$: edge length],
  ),
)<table>

== Programm Quellcode

Quellcode mit entsprechender Formatierung wird wie folgt eingefügt:

#figure(
  caption: "Ein Stück Quellcode",
  sourcecode[```ts
    const ReactComponent = () => {
      return (
        <div>
          <h1>Hello World</h1>
        </div>
      );
    };

    export default ReactComponent;
    ```],
)


== Verweise

Für Literaturverweise verwendet man die `cite`-Funktion oder die Kurzschreibweise mit dem \@-Zeichen:
- `#cite(form: "prose", <iso18004>)` ergibt: \ #cite(form: "prose", <iso18004>)
- Mit `@iso18004` erhält man: @iso18004

Tabellen, Abbildungen und andere Elemente können mit einem Label in spitzen Klammern gekennzeichnet werden (die Tabelle oben hat z.B. das Label `<table>`). Sie kann dann mit `@table` referenziert werden. Das ergibt im konkreten Fall: @table

= Fazit
= KI-Disclaimer
- Gemini 2.5 Pro Deep Research: Recherche für Marktanalyse; Vorschläge für Technologiestack der Anwendung