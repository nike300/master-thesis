= Anforderungsanalyse und Konzeption des Integrationsprozesses<Kap3>

== Analyse der Ausgangssituation und Zieldefinition
- *Defizite konventioneller Verschattungsstrategien:* Analyse der Einschränkungen heutiger Systeme, insbesondere die fehlende Berücksichtigung von Fremdverschattung durch Nachbargebäude.
- *Anforderungsprofil an das Gesamtsystem:* Definition funktionaler Anforderungen (wie Präzision und Grad der Automatisierbarkeit) sowie nicht-funktionaler Anforderungen (Recheneffizienz und Systemkompatibilität).

== Spezifikation der Datengrundlage (Input)
- *Analyse der BIM-Datengüte (IFC):* Untersuchung der vorhandenen geometrischen Informationen und Identifikation fehlender Attribute, die für eine valide Simulation zwingend erforderlich sind.
- *Integration externer Geodaten:* Notwendigkeit und Anforderungen an Umgebungsmodelle, beispielsweise der Detaillierungsgrad (LOD) der Nachbarbebauung aus GIS- oder OpenStreetMap-Daten.
- *Georeferenzierung und Zeitbasis:* Definition der Anforderungen an die räumliche und zeitliche Einordnung, inklusive Koordinatensystemen und dem Handling von Zeitzonen.

== Konzeption der Simulationslogik (Processing)
- *Methodenauswahl:* Begründung des gewählten geometrischen Raycasting-Verfahrens gegenüber alternativen Ansätzen wie Radiosity oder rein thermischen Simulationen.
- *Diskretisierungsstrategie:* Festlegung der zeitlichen Auflösung (Schrittweite der Jahressimulation) sowie der räumlichen Abtastung (Sampling-Raster) der Fensterflächen zur Ermittlung von Teilverschattungen.

== Definition der Systemarchitektur und Schnittstellen (Output)
- *Workflow-Design:* Erstellung einer schematischen Darstellung des gesamten Datenflusses, ausgehend von der digitalen Planung bis hin zur Ansteuerung der Aktoren.
- *Datenschnittstelle zur Automation:* Spezifikation des Exportformats (z. B. CSV-Struktur) und Festlegung der zu übergebenden Steuergrößen wie Verschattungsgrad und Status.
- *Mapping-Konzept:* Entwicklung einer Logik zur Verknüpfung der Simulationsergebnisse mit den physischen Datenpunkten der Gebäudeautomation (beispielsweise BACnet-Objekt-IDs).