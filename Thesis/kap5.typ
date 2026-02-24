= Integration in die Gebäudeautomation<Kap5>

In diesem Kapitel wird das Konzept zur technischen Überführung der Simulationsergebnisse in die operative Steuerungsebene dargelegt. Ziel ist es, die in Kapitel 4 generierten Datenströme so aufzubereiten und zu übertragen, dass sie von Standard-Automationsstationen verarbeitet werden können.

== Datenstruktur und Schnittstellendefinition
- *Generierung maschinenlesbarer Formate:* Festlegung der Exportparameter zur Erzeugung von CSV- oder JSON-Dateien, die eine effiziente Parsbarkeit auf ressourcenbeschränkten Automationsstationen (SPS) ermöglichen.
// 
- *Mapping von Simulations-IDs auf BACnet-Objekte:* Entwicklung einer Zuordnungsmatrix, um die im Modell verwendeten Fenster-IDs eindeutig mit den entsprechenden BACnet-Objektinstanzen (z. B. *Analog Output* für den Verschattungsgrad) zu verknüpfen.
//Vielleicht eher in Kapitel 3? Oder ist das hier seperat zu betrachten?

== Kommunikationsarchitektur und Datenübertragung
- *Konzepte zum Datei-Import auf DDC-Ebene:* Untersuchung verschiedener Übertragungswege wie der lokale Import via SD-Karte oder die automatisierte Bereitstellung mittels FTP/SFTP direkt in das Dateisystem der Automationsstation.
- *Konnektivität und Cloud-Anbindung:* Diskussion moderner IoT-Schnittstellen (wie MQTT oder REST-API) für eine dynamische Datenaktualisierung in Cloud-basierten Managementsystemen.

== Steuerungsstrategie und Funktionslogik
- *Entwurf eines Funktionsbausteins:* Konzeption der Programmlogik (z. B. in Anlehnung an IEC 61131-3) zum zyklischen Auslesen und Interpretieren der tabellarischen Verschattungsdaten.
- Die geometrische Simulation dient lediglich als Freigabe- oder Blockade-Bedingung (Enable/Disable)
//- *Interpolationsverfahren für zeitliche Zwischenwerte:* Implementierung von Algorithmen zur Glättung der Steuerbefehle zwischen den diskreten Simulationszeitpunkten (z. B. lineare Interpolation zwischen den 15-Minuten-Stützstellen).
- *Fallback-Strategien und Übersteuerung:* Definition von Sicherheitslogiken bei Datenverlust (z. B. Rückfall auf lokale Helligkeitssensoren) sowie Regelungen zur Priorisierung manueller Benutzereingaben gegenüber den Simulationsvorgaben.