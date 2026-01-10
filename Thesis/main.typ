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
  supervisor: (ref: "Prof. Dr.-Ing. Martin Höttecke", co-ref: "Matthias Meier"),
  university: "FH Münster - University of Applied Sciences",
  university-short: "h_da",
)

// Edit this content to your liking

= Einleitung
Die VDI 6011-1 @vdi6011-1 beschreibt die Grundlagen und allgemeinen Anforderungen für die Lichttechnik, insbesondere im Hinblick auf die Optimierung von Tageslichtnutzung und künstlicher Beleuchtung.
"tageslichtorientierte Planung" (siehe https://gebaeudedigital.de/schwerpunkt/licht-und-schatten/sonnenschutz-und-licht-zusammen-gedacht/)

= Einführung in die Jahresverschattung
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
Vielleicht aufteilen in innen und außenliegende systeme?
*Vertikalmarkisen:*
Ausfahrbare, wetterfeste Textilbahnen, die vertikal an der Außenseite von Fenstern angebracht werden. Sie bieten Schutz vor direkter Sonneneinstrahlung und reduzieren den Wärmeertrag im Innenraum.

*Rollläden:*
Bestehen aus horizontalen Lamellen, die sich zu einer kompakten Einheit aufrollen lassen. Sie bieten sowohl Sonnenschutz als auch Einbruchschutz und können manuell oder motorisiert betrieben werden.

*Jalousien:*
Bestehen aus horizontalen oder vertikalen Lamellen, die in ihrem Winkel verstellt werden können, um die Lichtmenge zu regulieren. Sie ermöglichen eine flexible Steuerung des Lichteinfalls und der Privatsphäre.

*Raffstores:*
Ähnlich wie Jalousien, jedoch mit robusteren Lamellen aus Metall oder Kunststoff. Sie bieten eine effektive Kontrolle über Licht und Wärme und sind besonders langlebig.


*Weitere Systeme:*
z.B. Außenrollos, Screens, Gardinen, Großlamellen

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

Thermischer Komfort: Gesamtenergiedurchlassgrad (g tot), der angibt, wie viel Sonnenenergie durch das Fenster-Sonnenschutz-System ins Rauminnere gelangt.

Visueller Komfort: Lichttransmissionsgrad (τ v), Blendschutz (Klassen 0-4), Sichtverbindung nach draußen.
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

Im diesem Kapitel wird eine #gls("Softwareschnittstelle") beschrieben. Man spricht in diesem Zusammenhang auch von einem #gls("API"). Die Schnittstelle nutzt Technologien wie das #gls("http").

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
- Gemini 3.0 Pro
- Perplexity AI: Recherche zu Normen und technischen Grundlagen