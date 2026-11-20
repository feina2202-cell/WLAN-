# FRITZ!Box 7530 AX optimieren

Schritt-für-Schritt-Anleitung für die FRITZ!Box 7530 AX (Wi-Fi 6, Dualband 2,4 + 5 GHz, je 2×2 Antennen, DSL-Modem).
Die Menüpfade gelten für aktuelle FRITZ!OS-Versionen. Je nach Version heißen einzelne Punkte leicht anders oder
erscheinen erst nach Umschalten auf die **erweiterte Ansicht** (Menü unten links bzw. „Ansicht: Erweitert“).

Benutzeroberfläche: <http://fritz.box> (oder `http://192.168.178.1`) im Browser eines verbundenen Geräts öffnen.

## 0. Sicherheit zuerst

Der Aufkleber auf der Unterseite enthält den **WLAN-Schlüssel** und das **FRITZ!Box-Kennwort** im Klartext.
Wer ihn sieht oder fotografiert, kommt ins Netz und in die Router-Oberfläche.

- **System › FRITZ!Box-Benutzer**: eigenes, langes Anmeldekennwort setzen (nicht das vom Aufkleber).
- **WLAN › Sicherheit › Verschlüsselung**: neuen WLAN-Netzwerkschlüssel vergeben (≥ 16 Zeichen).
  Danach alle Geräte neu verbinden; der QR-Code auf dieser Seite hilft beim Smartphone.
- Fotos des Aufklebers nicht teilen und nicht in Repositories ablegen.

## 1. Firmware aktualisieren

- **System › Update › FRITZ!OS-Version**: „Neues FRITZ!OS suchen“.
- **System › Update › Auto-Update**: „Neue FRITZ!OS-Versionen automatisch installieren“.

## 2. Standort

- **Aufrecht** und frei hinstellen, die Antennen sind im Gehäuse verbaut. Nicht liegend, nicht in einem Schrank
  oder zwischen Kabeln und Geräten hinter Möbeln.
- Erhöht (ca. 1–2 m) und möglichst zentral; der DSL-Anschluss kann per längerem TAE-/DSL-Kabel verlängert werden,
  damit der Router nicht in der Ecke an der Telefondose stehen muss.
- Abstand zu DECT-Telefonen, Mikrowelle und Metallflächen.

## 3. WLAN-Kanäle

**WLAN › Funkkanal**

1. Unten bei **„Belegung der Funkkanäle“** (Diagramm „WLAN-Umgebung“) sieht man, welche Kanäle die Nachbarn
   nutzen. Das ersetzt den Scan mit `scripts/wlan-check.*`.
2. Zuerst **„Funkkanal-Einstellungen automatisch setzen (empfohlen)“** probieren. Die FRITZ!Box wählt den Kanal
   anhand der gemessenen Störungen selbst und passt ihn an.
3. Nur wenn es danach weiterhin Probleme gibt: **„Funkkanal-Einstellungen anpassen“** wählen und
   - **2,4 GHz:** Kanal **1, 6 oder 11** – den mit den wenigsten bzw. schwächsten Nachbarn,
   - **5 GHz:** einen Kanal aus **36–48**; ein freier DFS-Kanal (52–140) kann schneller sein, verursacht aber
     gelegentlich kurze Unterbrechungen durch die Radarerkennung.

**Weitere Einstellungen** auf derselben Seite (sofern angezeigt):

| Einstellung | Empfehlung |
|---|---|
| WLAN-Standard 2,4 GHz | `802.11ax + n + g` (nur bei sehr alten Geräten `+ b`) |
| WLAN-Standard 5 GHz | `802.11ax + ac + n` |
| Maximale Sendeleistung | 100 % |
| WLAN-Koexistenz (20/40 MHz) | aktiv lassen, in dichter Nachbarschaft ist 20 MHz bei 2,4 GHz ohnehin besser |
| Autokanal inkl. Kanal 12/13 | aus, falls ältere Geräte die Kanäle 12/13 nicht kennen |
| 160 MHz Kanalbandbreite (5 GHz) | nur aktivieren, wenn das 5-GHz-Umfeld frei ist; sonst 80 MHz |
| Band Steering | ein |

## 4. Funknetz

**WLAN › Funknetz**

- **Gleicher Name** für 2,4 und 5 GHz: Die FRITZ!Box lenkt Geräte dann per Band Steering selbst aufs passende Band.
- Einen **eigenen Netzwerknamen** vergeben, der weder Modell noch Namen verrät (statt des Werks-Namens vom Aufkleber).
- Smart-Home-Geräte, die sich nicht verbinden, kommen ins Gastnetz (siehe unten), das bei Bedarf nur 2,4 GHz nutzt.

## 5. Sicherheit

**WLAN › Sicherheit**

- **Verschlüsselung:** `WPA2 + WPA3`. Funktionieren alle Geräte damit, ist reines `WPA3` noch sicherer.
- **WPS-Schnellverbindung:** deaktivieren.
- **WLAN-Geräte:** „Unbekannte WLAN-Geräte dürfen sich verbinden“ bei Bedarf ausschalten, sobald alle eigenen
  Geräte einmal verbunden sind.

**Internet › Freigaben › FRITZ!Box-Dienste**: Zugriff aus dem Internet (HTTPS) nur aktivieren, wenn er gebraucht wird.

**WLAN › Gastzugang**: Gastnetz einrichten, sinnvoll auch für Smart-TV, Steckdosen, Kameras usw.

## 6. Internet & Priorisierung

- **Internet › Online-Monitor**: zeigt die Auslastung und die tatsächlich gebuchte Geschwindigkeit.
- **Internet › DSL-Informationen**: Ist die DSL-Synchronisation deutlich unter dem Tarif oder gibt es viele Fehler,
  liegt das Problem an der Leitung, nicht am WLAN. Dann den Provider kontaktieren.
- **Internet › Filter › Priorisierung**: Geräte für Videokonferenz, Telefonie oder Gaming als
  **„Echtzeitanwendungen“** eintragen. Das hilft bei voller Leitung gegen Ruckler.

## 7. Abdeckung erweitern

- **Heimnetz › Mesh**: Die 7530 AX ist Mesh-Master. Ein **FRITZ!Repeater** (oder ein Powerline-Adapter mit WLAN)
  bildet mit ihr ein gemeinsames Netz mit automatischer Übergabe.
- Repeater **per LAN-Kabel** anbinden („LAN-Brücke“), wenn möglich. Das ist deutlich schneller als eine Funkbrücke.
- Ohne Kabel: den Repeater auf halber Strecke aufstellen, dort wo die FRITZ!Box noch gut empfangen wird.

## 8. Kontrolle

- **WLAN › Funknetz › Bekannte WLAN-Geräte**: zeigt pro Gerät Band, Signal und Datenrate. Geräte mit geringer
  Datenrate und schwachem Signal sind Kandidaten für einen besseren Standort, LAN-Kabel oder Mesh-Repeater.
- Vorher/nachher per Speedtest messen (siehe [README](../README.md#1-ist-zustand-messen)).
