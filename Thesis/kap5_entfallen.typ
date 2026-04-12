= Integration in die Gebäudeautomation<Kap5>

In diesem Kapitel wird das Konzept zur technischen Überführung der Simulationsergebnisse in die operative Steuerungsebene dargelegt. Ziel ist es, die in Kapitel 4 generierten Datenströme so aufzubereiten und zu übertragen, dass sie von Standard-Automationsstationen verarbeitet werden können.

== Datenstruktur und Schnittstellendefinition
- *Datenformat Output:*
  - Erstmal csv-Dateien, da einfach les- und schreibbar
  - wie csv aufgebaut ist (Zeilen- und Spaltenüberschriften)
  - nur 0,1 oder doch mehr information mitgeben?
// 
- *Mapping von Simulations-IDs auf AKS von GA:* Entwicklung einer Zuordnungsmatrix, um die im Modell verwendeten Fenster-IDs eindeutig mit den entsprechenden BACnet-Objektinstanzen (z. B. *Analog Output* für den Verschattungsgrad) zu verknüpfen.
//Vielleicht eher in Kapitel 3? Oder ist das hier seperat zu betrachten?

== Kommunikationsarchitektur und Datenübertragung
- *Konzepte zum Datei-Import auf AS-Ebene:* Untersuchung verschiedener Übertragungswege wie mittels MQTT direkt in die Automationsstation.

== Steuerungsstrategie und Funktionslogik
- Konzeption der Programmlogik zum zyklischen Auslesen und Interpretieren der tabellarischen Verschattungsdaten.
- Die geometrische Simulation dient lediglich als Freigabe- oder Blockade-Bedingung
//- *Interpolationsverfahren für zeitliche Zwischenwerte:* Implementierung von Algorithmen zur Glättung der Steuerbefehle zwischen den diskreten Simulationszeitpunkten (z. B. lineare Interpolation zwischen den 15-Minuten-Stützstellen).
- *Jalousiensteuerung:* Entwicklung einer kompletten, mit den Verschattungsdaten optimierter Steuerung der Behänge? Vielleicht nur optional?