= Diskussion und Fazit<Kap5>
== Zusammenfassung der Ergebnisse
- obwohl das ifc-modell viele fehler hatte und es einiges zu beachten gab
schreiben mit KI
- simulation dauert 3 tage 16 stunden für ein sehr großes und kompliziertes projekt für das four. für üblichere kleiner projekt wird simulationsdauer ein bruchteil davon sein.
== Marktanalyse und wirtschaftliches Potenzial
=== Marktbeschreibung und Marktgröße
Ein großes Interesse an intelligenten Verschattungslösungen existiert vor allem für große, prestigeträchtige Immobilien, wie Hochhäuser in zentraler Lage. Alleine in der Stadt Frankfurt sollen bis 2040 14 Hochhäuser (Gebäude über 60m) errichtet werden@frankfurt_hep_2024_anhang2. Der Markt für umgebungsabhängige Verschattungssimulationen beschränkt sich nicht nur auf Hochhäuser. Generell profitieren Zweckgebäude mit zentraler GA und großen Fensterflächen hiervon. Vermehrt wird in Ausschreibungen eine intelligente Verschattung gefordert.
Gebäudeeigentümer profitieren von einem erhöhten Gebäudewert durch höhere Nutzerzufriedenheit und Energieeffizienz. Aber auch Systemintegratoren profitieren von einem kostengünstigen, effizienten Prozess die Verschattungssimulation umzusetzen.

=== Marktanalyse: Abgrenzung zu Wettbewerbslösungen
Um das wirtschaftliche und technische Potenzial des entwickelten Workflows einzuordnen, wird ein Vergleich mit dem aktuellen Status Quo am Markt angestellt. Etablierte Sonnenschutzhersteller (wie beispielsweise WAREMA) bieten die Berechnung der Jahresverschattung derzeit primär als kostenpflichtige Dienstleistung an. Die Analyse der Angebotstexte@warema_jahresverschattung_basispreis offenbart dabei signifikante prozessuale Defizite, die durch den in dieser Arbeit vorgestellten Open-Source-Ansatz gelöst werden:

- *Medienbrüche und manuelle Datenaufbereitung:* Kommerzielle Dienstleister fordern häufig proprietäre CAD-Formate (wie Revit oder DWG) mit strikten Dateigrößenlimits (z. B. 250 MB). Zudem muss der Fachplaner das Modell manuell bereinigen (Entfernung von Innenwänden und Inventar), bevor es übermittelt wird. Der entwickelte IFC-basierte Workflow liest die relevanten Entitäten (`IfcWindow`, `IfcCurtainWall`) hingegen automatisiert und standardisiert aus dem OpenBIM-Modell aus und ist nicht auf eine Dateigröße begrenzt.

- *Integration von Umgebungsdaten:* Umgebungsdaten müssen bei konventionellen Dienstleistern manuell im 3D-Modell erstellt werden. Fehlen in den übermittelten CAD-Plänen detaillierte Höhenangaben zur Nachbarbebauung, müssen diese kostenpflichtig nachvermessen werden. Der hier vorgestellte Prozess integriert stattdessen frei verfügbare CityGML-Daten direkt in die Blender-Umgebung.

- *Kostenstruktur und räumliche Granularität:* Das Preismodell kommerzieller Anbieter basiert in der Regel auf der Anzahl der zu berechnenden Verschattungszonen. Um Kosten zu sparen, werden in der Praxis oft große Fassadenbereiche zu einer Zone zusammengefasst, was zu Lasten der Tageslichtautonomie geht. Die Iteration über alle Fenster in der Simulation verursacht außer einer erhöhten Rechendauer keinen Zusatzaufwand, wodurch eine fenstergenaue Simulation auch bei Großprojekten umsetzbar ist.

- *Herstellerunabhängigkeit:* Während Herstellerlösungen die errechneten Schattenverläufe meist über firmeneigene Software in herstellerspezifische Controller laden, ist der Output dieses Proof of Concepts (CSV/JSON) systemunabhängig. (((Die Verschattungsdaten können auf Standard-BACnet-Objekte gemappt und von Automationsstationen beliebiger Fabrikate verarbeitet werden.)))

Zusammenfassend transformiert der entwickelte Workflow die Jahresverschattung von einer manuellen, fehleranfälligen und ungenauen Dienstleistung hin zu einem transparenten und skalierbaren Engineering-Prozess.

=== Marktpotenzialanalyse

== Grenzen des entwickelten Prozesses
== Ausblick
- Raytracing probieren - Um spiegelungen mit zu berücksichtigen
  - Da der Rechenaufwand um ein vielfaches höher ist, müsste hier die wahrscheinlich parallel zum Betrieb laufen und es wird immer nur der nächste Tag berechnet
- 
Man könnte eine Exceltabelle entwickeln, die die vorliegenden IFC-Daten bewertet und daraus einen zusätzlichen Arbeitsaufwand berechnet. Dies könnte für die Angebotserstellung als Entscheidungsgrundlage herangezogen werden.
