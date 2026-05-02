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

#show: clean-hda.with(
  title: "Entwicklung einer durchgängigen Prozesskette zur Integration dynamischer Verschattungssimulationen in die Gebäudeautomation",
  subtitle: "Softwaregestützte Umsetzung und Validierung eines Workflows vom BIM-Modell bis zur operativen Steuerung.",
  // Optionaler Untertitelalternative: Konzeption und prototypische Umsetzung eines softwaregestützten Workflows
  authors:
  ((name: "Niklas Wittkämper", 
      student-id: "1382664", 
      signature: image("assets/signatur-bewerber.png", height: 3.5em), course-of-studies: "Gebäudeautomation", 
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
  appendix: include "anhang.typ"
)

// Chapter Includes
#include "kap1.typ"
#include "kap2.typ"
#include "kap3.typ"
#include "kap4.typ"
#include "kap5.typ"

= Arbeitsplan Masterarbeit (Verbleibende Phasen)

== Phase 2: Konzeption und Einleitung (03. Mai bis 07. Mai)
- Transformation der Stichpunkte in Kapitel 3 (Systemarchitektur, MQTT, Schnittstellen) in einen akademischen Fließtext.
- Vollständige Ausformulierung von Kapitel 1 (Problemstellung und Zielsetzung) zur Fixierung des roten Fadens.

== Phase 3: Diskussion und Synthese (08. Mai bis 11. Mai)
- Ausarbeitung von Kapitel 5 (Zusammenfassung der Ergebnisse, Grenzen des Prozesses, Ausblick).
- Entfernung obsoleter Abschnitte, wie der Marktpotenzialanalyse.

== Phase 4: Formalia und Abschluss (12. Mai bis 17. Mai)
- Verfassen des Abstracts in deutscher und englischer Sprache.
- Abgleich des Inhaltsverzeichnisses mit den tatsächlichen Überschriften.
- Überprüfung der Zitationen und des Literaturverzeichnisses.
- Pufferzeit für den abschließenden Lesefluss und die typografische Formatierung.
