#import "@preview/codly:1.3.0": *
= Anhang<Anhang>
== Digitale Anlage...<DigitaleAnlage>
In der digitalen Anlage befinden sich die drei wichtigsten Skripte für diese Arbeit:
- MainVerschattungssimulation.py
- GenerateTempAKS.py
- MatchingAKS.py
== Verwendete Hilfsmittel <OpenSourceListe>
Im Verlauf dieser Arbeit kamen insgesamt 16 verschiedene Open-Source-Softwarelösungen, Plug-ins, Entwicklertools und frei verfügbare Datenquellen zum Einsatz. Die nachfolgende Übersicht kategorisiert die verwendeten Hilfsmittel nach ihrem jeweiligen Anwendungsbereich. Werkzeuge und Datenquellen, die mit einem Sternchen~(\*) gekennzeichnet sind, wurden während der Konzeptionsphase evaluiert, sind jedoch nicht in den final integrierten Prozess eingeflossen. Für die in der Arbeit enthaltenen Skizzen und Zeichnungen, sowie für den in @AKSZuordnungAnhang beschriebenen Prozess, ist AutoCAD verwendet worden, welches nicht kostenlos verfügbar ist.

*Software und Plattformen*
- Blender (3D-Modellierung und Simulationsumgebung)
- Typst (Textsatzsystem zur Erstellung der vorliegenden Arbeit)
- GitHub (Versionskontrolle und Code-Management)
- CityJSON Tools (Kommandozeilenwerkzeuge zur Verarbeitung von Stadtmodellen)
- Mermaid.ai (Erstellung von Flussdiagrammen)

*Plug-ins und Erweiterungen*
- Bonsai (Blender-Add-on für die BIM- und IFC-Integration)
- Sun Position (Integriertes Blender-Add-on zur astronomischen Sonnenstandsberechnung)
- Import DXF / Export DXF (Integriertes Blender-Add-on)
- Tinymist (Erweiterung für Visual Studio Code zur Typst-Kompilierung)
- Blender Development (Erweiterung für Visual Studio Code zur Python-Skriptentwicklung)
- CityJSONEditor (Blender-Add-on für den Import von CityJSON-Daten)
- Blosm\* (Blender-Add-on für den Import von OpenStreetMap-Daten)
- Blender-GIS\* (Blender-Add-on für den Import von OpenStreetMap-Daten)

*Datenquellen*
- 3D-Stadtmodell des Hessischen Landesamtes für Bodenmanagement und Geoinformation 
- OpenStreetMap\* (öffentliche Gebäudemodell-Daten)

== Mathematische Herleitung des verallgemeinerten Cut-Off-Winkels <AnhangHerleitungCutOff>

Die Herleitung des verallgemeinerten Cut-Off-Winkels $beta$ basiert auf der geometrischen Blockadebedingung für direkte Sonnenstrahlung zwischen zwei horizontalen Jalousielamellen. Die mathematische Verknüpfung des solaren Profilwinkels $alpha_p$, der Lamellenbreite $w$ und des vertikalen Lamellenabstands $d$ ist durch die grundlegende Tangensrelation der Schnittgeometrie definiert:

$ tan(alpha_p) = frac(d - w dot sin(beta), w dot cos(beta)) $

Um den für die Automationsstation benötigten Stellwinkel $beta$ explizit als Funktion der bekannten geometrischen Parameter und des Sonnenstandes darzustellen, wird diese implizite Gleichung nachfolgend schrittweise aufgelöst.

*Schritt 1: Auflösung des Hauptnenners* \
Zur Beseitigung des Bruchs wird die gesamte Gleichung mit dem Nennerterm $w dot cos(beta)$ multipliziert:
$ w dot cos(beta) dot tan(alpha_p) = d - w dot sin(beta) $

*Schritt 2: Isolation der winkelabhängigen Variablen* \
Durch Addition von $w dot sin(beta)$ werden alle Terme, welche die gesuchte Zielvariable $beta$ enthalten, auf die linke Seite der Gleichung überführt:
$ w dot sin(beta) + w dot cos(beta) dot tan(alpha_p) = d $

*Schritt 3: Reduktion des gemeinsamen Skalierungsfaktors* \
Da die Lamellenbreite $w$ als gemeinsamer Koeffizient auf der linken Gleichungsseite auftritt, wird die Gleichung durch $w$ dividiert:
$ sin(beta) + cos(beta) dot tan(alpha_p) = frac(d, w) $

*Schritt 4: Substitution der Tangensfunktion* \
Unter Ausnutzung der trigonometrischen Grundbeziehung $tan(alpha_p) = frac(sin(alpha_p), cos(alpha_p))$ wird der verbleibende Tangensterm ersetzt:
$ sin(beta) + cos(beta) dot frac(sin(alpha_p), cos(alpha_p)) = frac(d, w) $

*Schritt 5: Überführung auf einen gemeinsamen Hauptnenner* \
Um das mathematische Fundament für die Anwendung eines Additionstheorems zu schaffen, wird die gesamte Gleichung mit $cos(alpha_p)$ multipliziert:
$ sin(beta) dot cos(alpha_p) + cos(beta) dot sin(alpha_p) = frac(d, w) dot cos(alpha_p) $

*Schritt 6: Transformation mittels trigonometrischem Additionstheorem* \
Die Struktur der linken Gleichungsseite entspricht exakt dem Theorem für die Sinusfunktion von Summen, welches allgemein als $sin(x) dot cos(y) + cos(x) dot sin(y) = sin(x + y)$ definiert ist. Durch Substitution mit $x = beta$ und $y = alpha_p$ vereinfacht sich der komplexe Ausdruck zu einem singulären Term:
$ sin(beta + alpha_p) = frac(d, w) dot cos(alpha_p) $

*Schritt 7: Anwendung der Umkehrfunktion und finale Freistellung* \
Durch die Anwendung des Arcussinus ($arcsin$) auf beide Seiten der Gleichung wird das Argument der Sinusfunktion freigestellt:
$ beta + alpha_p = arcsin(frac(d, w) dot cos(alpha_p)) $

Die anschließende Subtraktion des Profilwinkels $alpha_p$ liefert die finale, explizite Bestimmungsgleichung zur Berechnung des optimalen Cut-Off-Stellwinkels:
$ beta = arcsin(frac(d, w) dot cos(alpha_p)) - alpha_p $

== Zuweisung des Anlagenkennzeichnungsschlüssels<AKSZuordnungAnhang>
Da die Fenster vom Fassadenbauer mit einem Typenkennzeichnungsschlüssel bezeichnet wurden, um die Zuordnung auf der Baustelle zu ermöglichen, ist es nicht möglich, von dem Fenster auf den zuständigen Jalousieaktor zu schließen. Somit muss eine alternative Zuordnung gefunden werden.
Um die @ga zu planen, wurde die Engineering-Software eConfigure von Schneider Electric eingesetzt. Die Planung war zum Zeitpunkt der Arbeit schon komplett abgeschlossen. Bei der Planung wurden Grundrisse der Etagen hinterlegt und alle Komponenten der Raumautomation verortet (siehe @fig-eConfigure). Hierbei gibt es mehrere Symbole für Jalousien, die zum einen den außenliegenden Sonnenschutz und zum anderen den innenliegenden Blendschutz beschreiben. Der Text neben den Symbolen beinhaltet den erforderlichen @aks.
#figure(
  image("assets/AusschnittEConfigure.png"),
  caption: [Ausschnitt der Raumautomation aus eConfigure vom FOUR in Frankfurt],
  placement: none
)<fig-eConfigure>

Für die Zuordnung muss also eine Übertragung des Anlagenkennzeichnungssystems (AKS) der Jalousieaktoren auf die Fensterelemente im BIM-Modell erfolgen.
Im Folgenden wird ein vorläufiger Prozess stichpunktartig beschrieben:



+ *Referenzexport*: Der betroffene Geschossgrundriss wird aus der 3D-Umgebung (Blender) als zweidimensionale Referenz exportiert.
+ *Planvorbereitung*: Im Projektierungstool eConfigure werden Hilfslinien entlang der Fassadenkontur erstellt, um eine spätere Skalierung und Positionierung der Pläne zu ermöglichen.
+ *Datenexport*: Die Grundrisse der vier Mietbereiche werden aus eConfigure in das etablierte CAD-Austauschformat DWG exportiert.
+ *Aufbereitung und Referenzierung*: In AutoCAD werden die Teilgrundrisse zusammengeführt, bereinigt, maßstäblich skaliert und räumlich positioniert.
+ *Überlagerung*: Die geometrischen Referenzdaten aus Blender und die Planungsdaten aus eConfigure werden visuell überlagert.
+ *Datenreduktion*: Sämtliche Planinhalte mit Ausnahme der textuellen @aks#[]-Bezeichner werden entfernt.
+ *Reimport in die 3D-Umgebung*: Die bereinigte DWG-Datei wird in Blender importiert. Die textuellen Bezeichner befinden sich nun räumlich exakt entlang der Fassadenlinie (siehe @fig-AKSumFenster).
+ *Algorithmische Zuweisung*: Ein Python-Skript iteriert über alle Fensterelemente und identifiziert für jedes Fenster das räumlich nächstgelegene Textobjekt (Nearest-Neighbor-Suche). Der ausgelesene String wird als Attribut in das Fensterobjekt geschrieben. Dieses Attribut dient in der anschließenden Verschattungssimulation als eindeutiger, auslesbarer Identifikator.
#figure(
  image("assets/PositionierungAKS.png", width: 60%),
  caption: [Draufsicht von FOUR Turm 1 mit an den Fenstern platzierten AKS-Texten für Etage 45 in Blender],
  placement: none
)<fig-AKSumFenster>
Da dieser prototypische Weg sehr zeitaufwendig ist, wird im Rahmen dieser Arbeit nur ein Geschoss bearbeitet. Für die spätere Simulation wird der im Abschnitt davor festgelegte, temporäre @aks für die Bezeichnung der Fenster verwendet.


== Konfiguration der Verschattungssimulation<kap-code-konfiguration>
#codly(offset: 11, zebra-fill: none)
#codly(number-format: (n) => box(fill: luma(240), height: 1.5em, outset: 0.5em)[#text(luma(100), size: 0.8em)[#str(n)]])
#figure(
```python
# Schalter & Export
OUTPUT_ANGLE = True      # True: Gibt Azimut aus | False: Gibt nur '0' aus
WEEKLY_FULL_YEAR = True  # True: wöchentlich fürs Jahr | False: Nur ein Tag
# Datum für Einzel-Simulation (wird nur genutzt, wenn WEEKLY_FULL_YEAR = False)
SINGLE_DAY = 21
SINGLE_MONTH = 6
# Zeit & Auflösung
YEAR = 2026
START_HOUR = 5           # Startzeit in Stunden (z.B. 5 = 05:00 Uhr)
END_HOUR = 22            # Endzeit in Stunden (z.B. 22 = 22:00 Uhr)
MINUTES_STEP = 15        # Zeitschritt in Minuten (z.B. 15, 30, 60)
# Geografische Koordinaten
LATITUDE = 50.1126
LONGITUDE = 8.67472
```,
caption: [Konfiguration der Verschattungssimulation],
placement: none)<code-konfiguration>

