#import "template/lib.typ": *
#import "glossary.typ": glossary-entries

#show: clean-hda.with(
  title: "Entwicklung einer durchgängigen Prozesskette zur Integration dynamischer Verschattungssimulationen in die Gebäudeautomation",
  subtitle: "Softwaregestützte Umsetzung und Validierung eines Workflows vom BIM-Modell bis zur operativen Steuerung.",
  // Optionaler Untertitelalternative: Konzeption und prototypische Umsetzung eines softwaregestützten Workflows
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

// Chapter Includes
#include "kap1.typ"
#include "kap2.typ"
#include "kap3.typ"
#include "kap4.typ"
#include "kap5.typ"
#include "kap6.typ"
