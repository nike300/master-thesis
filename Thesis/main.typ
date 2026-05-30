#import "template/lib.typ": *
#import "glossary.typ": glossary-entries
#import "@preview/codly:1.3.0": *
#import "@preview/mmdr:0.2.1": mermaid

#show: codly-init.with()
#codly(
  languages: (
    python: (name: "Python", color: rgb("#3572A5")),
  ),
)
#show raw.where(block: true): set text(size: 8pt)

#show "z. B.": [z.~B.]
#show "u. a.": [u.~a.]
#show "d. h.": [d.~h.]
#show "i. d. R.": [i.~d.~R.]

#show: clean-hda.with(
  title: "Methodik zur Erstellung und Integration umgebungsabhängiger Verschattungsdaten in die Raumautomation",
  subtitle: "Konzeption, Umsetzung und Validierung einer Verschattungssimulation am Beispiel eines Hochhaus-Referenzprojekts",
  // Optionaler Untertitelalternative: Konzeption und prototypische Umsetzung eines softwaregestützten Workflows
  authors:
  ((name: "Niklas Wittkämper", 
      student-id: "1382664", 
      signature: image("assets/signatur-bewerber.png", height: 3em), course-of-studies: "Gebäudeautomation", 
      // course: " ", 
      city:"Darmstadt", 
      company: 
        ((name: "Schneider Electric GmbH", city: "Berlin"))
),),
  type-of-thesis: "Masterarbeit",
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary-entries, // displays the glossary terms defined in "glossary.typ"
  language: "de", // en, de
  supervisor: (ref: "Prof. Dr.-Ing. Martin Höttecke", co-ref: "Matthias Meier"),
  university: "FH Münster - University of Applied Sciences",
  university-short: "fh_m",
  appendix: include "anhang.typ",
  show-abstract: true,
  abstract: [
Die Integration dynamischer Verschattungssimulationen in die Gebäudeautomation gewinnt aufgrund steigender Energiekosten und dem Streben nach maximaler Tageslichtautonomie und Komfort zunehmend an Bedeutung. Konventionelle Sonnenschutzsteuerungen stützen sich in der Praxis zumeist auf Helligkeitswerte oder statische Grenzwinkel, was insbesondere in dicht bebauten urbanen Kontexten zu konservativen Annahmen der Automatik führt. Der flächendeckende Einsatz präziser dreidimensionaler Simulationen scheitert bisher oftmals am immensen Engineering-Aufwand, proprietären Softwarelösungen und der mangelhaften Qualität digitaler Planungsdaten.

Diese Masterarbeit adressiert diese Problematik durch die Konzeption und Validierung einer durchgängigen, softwaregestützten Prozesskette, welche die Lücke zwischen der digitalen Gebäudeplanung und der operativen Gebäudeautomation schließt. Um eine hohe wirtschaftliche Skalierbarkeit und leichte Zugänglichkeit zu gewährleisten, basiert die entwickelte Methodik auf Open-Source-Software und frei verfügbaren Datensätzen.

Den Ausgangspunkt des Workflows bildet die informationstechnische Analyse und Aufbereitung der Datengrundlage. Hierbei werden architektonische Building Information Modeling Modelle im herstellerneutralen IFC-Format mit urbanen Geodaten im Format CityGML beziehungsweise CityJSON zu einer kohärenten Simulationsszene zusammengeführt. Die softwaretechnische Implementierung und Validierung der Prozesskette erfolgt anhand eines Proof of Concept am komplexen Hochhaus-Referenzprojekt FOUR in Frankfurt am Main.

Die Verschattungssimulation wird in der 3D-Software Blender mittels eines eigens entwickelten Python-Skripts ausgeführt. Der Algorithmus berechnet den astronomischen Sonnenstand hochpräzise auf Basis des NOAA-Verfahrens und ermittelt die fassadenspezifische Fremd- und Eigenverschattung über ein Vierpunkt-Raycasting in diskreten 15-Minuten-Intervallen, ein mal wöchentlich für ein gesamtes Referenzjahr.

Die abschließende visuelle und algorithmische Validierung der Simulationsergebnisse belegt die hohe Genauigkeit des berechneten Schattenwurfs. Die Arbeit demonstriert, dass der konzipierte Workflow eine herstellerunabhängige, transparente und wirtschaftlich tragfähige Alternative zu kommerziellen Dienstleistungen darstellt. Die Methodik ermöglicht eine automatisierte Parametrierung von Sonnenschutzsystemen, wodurch die Tageslichtausbeute maximiert und der thermische sowie visuelle Nutzerkomfort nachhaltig gesteigert wird.],

  abstract-en: [
The integration of dynamic shading simulations into building automation is gaining increasing importance due to rising energy costs and the pursuit of maximum daylight autonomy and comfort. In practice, conventional solar shading controls mostly rely on brightness values or static limit angles, which leads to conservative assumptions by the automation system, especially in densely built urban contexts. The widespread implementation of precise three-dimensional simulations often fails due to immense engineering efforts, proprietary software solutions, and the poor quality of digital planning data.

This master's thesis addresses this issue through the conceptualization and validation of a continuous, software-supported process chain that bridges the gap between digital building planning and operative building automation. To ensure high economic scalability and easy accessibility, the developed methodology is based on open-source software and freely available datasets.

The starting point of the workflow is the information technology analysis and preparation of the data foundation. Here, architectural Building Information Modeling models in the vendor-neutral IFC format are merged with urban spatial data in CityGML or CityJSON format to create a coherent simulation scene. The software implementation and validation of the process chain are carried out using a proof of concept on the complex high-rise reference project FOUR in Frankfurt am Main.

The shading simulation is executed in the 3D software Blender using a specifically developed Python script. The algorithm calculates the astronomical sun position with high precision based on the NOAA method and determines the facade-specific external and self-shading via four-point raycasting in discrete 15-minute intervals, once a week for an entire reference year.

The final visual and algorithmic validation of the simulation results proves the high accuracy of the calculated shadows. The work demonstrates that the conceptualized workflow represents a vendor-independent, transparent, and economically viable alternative to commercial services. The methodology enables an automated parameterization of solar shading systems, thereby maximizing daylight yield and sustainably increasing the thermal and visual comfort of the users.]
)

// Chapter Includes
#include "kap1.typ"
#include "kap2.typ"
#include "kap3.typ"
#include "kap4.typ"
// #include "kap5.typ"
#include "kap6.typ"

// = Arbeitsplan Masterarbeit (Verbleibende Phasen)

// == Phase 2: Konzeption und Einleitung (03. Mai bis 07. Mai)
// - Transformation der Stichpunkte in Kapitel 3 (*Systemarchitektur*, MQTT, Schnittstellen) in einen akademischen Fließtext.
// - Vollständige Ausformulierung von Kapitel 1 (Problemstellung und Zielsetzung) zur Fixierung des roten Fadens.

// == Phase 3: Diskussion und Synthese (08. Mai bis 11. Mai)
// - Ausarbeitung von Kapitel 5 (Zusammenfassung der Ergebnisse, Grenzen des Prozesses, *Ausblick*).
// - *Marktanalyse überarbeiten*.

// == Phase 4: Formalia und Abschluss (12. Mai bis 17. Mai)
// - Rechtschreibprüfung von Kapitel 5
// - Verfassen des Abstracts in deutscher und englischer Sprache.
// - Überprüfung der Zitationen und des Literaturverzeichnisses.
// - Pufferzeit für den abschließenden Lesefluss und die typografische Formatierung.
