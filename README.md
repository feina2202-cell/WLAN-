# WLAN-Router optimieren

Anleitung und Werkzeuge, um ein Heim-WLAN schneller, stabiler und sicherer zu machen.

Gerätespezifisch: [FRITZ!Box 7530 AX](docs/fritzbox-7530-ax.md)

- [Schnellstart](#schnellstart)
- [1. Ist-Zustand messen](#1-ist-zustand-messen)
- [2. Standort des Routers](#2-standort-des-routers)
- [3. Funkeinstellungen](#3-funkeinstellungen)
- [4. Firmware & Sicherheit](#4-firmware--sicherheit)
- [5. Netzwerk & Dienste](#5-netzwerk--dienste)
- [6. Abdeckung erweitern](#6-abdeckung-erweitern)
- [Fehlersuche](#fehlersuche)
- [Skripte](#skripte)

## Schnellstart

Die zehn Maßnahmen mit der größten Wirkung, nach Aufwand sortiert:

1. **Router neu starten** und prüfen, ob eine **Firmware-Aktualisierung** verfügbar ist.
2. Router **frei, erhöht und zentral** aufstellen, nicht im Schrank, hinter dem Fernseher oder im Keller.
3. **Kanalscan** mit `scripts/wlan-check.sh` bzw. `scripts/wlan-check.ps1` ausführen und den freiesten Kanal einstellen
   (2,4 GHz: nur **1, 6 oder 11**).
4. **5 GHz (bzw. 6 GHz)** für Geräte in Router-Nähe nutzen; 2,4 GHz nur für Reichweite und IoT-Geräte.
5. **Kanalbreite**: 2,4 GHz auf **20 MHz**, 5 GHz auf **80 MHz** (160 MHz nur bei freier Umgebung).
6. **WPA3** (oder WPA2/WPA3-Mischmodus) aktivieren; **WPS** und **WEP/TKIP** abschalten.
7. **Band Steering** bzw. einen gemeinsamen Netzwerknamen für beide Bänder aktivieren, sofern die Geräte damit zurechtkommen.
8. Feste Geräte (TV, PC, Konsole, NAS) per **LAN-Kabel** anschließen. Das entlastet das WLAN für alle anderen.
9. Alte **802.11b/g-Kompatibilitätsmodi** abschalten, wenn keine Altgeräte mehr im Einsatz sind.
10. Bei mehreren Etagen bzw. dicken Wänden ein **Mesh-System** oder einen **Access Point per LAN** statt eines Repeaters verwenden.

## 1. Ist-Zustand messen

Ohne Messung lässt sich keine Verbesserung belegen. Vorher und nachher messen:

| Was | Wie |
|---|---|
| Internet-Geschwindigkeit | Speedtest einmal **per LAN-Kabel** und einmal per WLAN in verschiedenen Räumen |
| Signalstärke (RSSI) | `scripts/wlan-check.*`, Router-Oberfläche oder WLAN-Analyse-App |
| Latenz/Stabilität | `ping -c 100 <Router-IP>` (Windows: `ping -n 100`) und auf Ausreißer bzw. Paketverlust achten |
| Kanalbelegung | `scripts/wlan-check.*` |

**Richtwerte für die Signalstärke:**

| RSSI | Bewertung |
|---|---|
| ≥ −50 dBm | ausgezeichnet |
| −50 … −60 dBm | gut |
| −60 … −67 dBm | ausreichend (Video, Telefonie noch ok) |
| −67 … −75 dBm | schwach, instabil |
| < −75 dBm | unbrauchbar |

Ist der Speedtest per **LAN-Kabel** schon langsam, liegt das Problem beim Anschluss bzw. Provider und nicht am WLAN.

## 2. Standort des Routers

- **Zentral** in der Wohnung und **erhöht** (Regal, ca. 1–2 m), nicht auf dem Boden.
- **Frei stehend**: nicht in Metallschränken, hinter Heizkörpern, Spiegeln, Aquarien oder dem Fernseher.
- **Abstand** zu Mikrowelle, DECT-Basisstation, Babyfon und Bluetooth-Lautsprechern (stören 2,4 GHz).
- **Antennen** (falls vorhanden): eine senkrecht, eine waagerecht ausrichten. Das hilft bei unterschiedlich gehaltenen Geräten.
- Beton- und Stahlbetonwände sowie Fußbodenheizungen dämpfen stark, besonders 5 und 6 GHz.

## 3. Funkeinstellungen

### Frequenzbänder

| Band | Vorteil | Nachteil | Einsatz |
|---|---|---|---|
| 2,4 GHz | große Reichweite, durchdringt Wände | langsam, stark überfüllt, nur 3 überlappungsfreie Kanäle | IoT, entfernte Räume |
| 5 GHz | schnell, viele Kanäle | geringere Reichweite | Standard für Laptops, Smartphones, TV |
| 6 GHz (Wi-Fi 6E/7) | sehr schnell, kaum belegt | kürzeste Reichweite, nur neue Geräte | Geräte im selben Raum |

### Kanalwahl

- **2,4 GHz:** ausschließlich **1, 6 oder 11** verwenden. Alle anderen Kanäle überlappen mit zwei Nachbarkanälen und
  verursachen mehr Störungen als ein geteilter Kanal.
- **5 GHz:** Die Kanäle **36–48** sind meist erlaubt und schnell verfügbar. **DFS-Kanäle (52–144)** sind oft leer, der
  Router muss dort aber Radar meiden und kann kurz die Verbindung unterbrechen. Ausprobieren lohnt sich.
- **Automatische Kanalwahl** ist bei modernen Routern oft gut. Bei Problemen einen festen Kanal laut Scan wählen.

### Kanalbreite

| Band | Empfehlung |
|---|---|
| 2,4 GHz | **20 MHz** (40 MHz stört Nachbarn und bringt in der Praxis kaum etwas) |
| 5 GHz | **80 MHz**; 160 MHz nur in ruhiger Umgebung, 40 MHz in Mehrfamilienhäusern mit vielen Netzen |
| 6 GHz | 160 MHz (Wi-Fi 7: 320 MHz) |

### Weitere Optionen

- **WLAN-Standard:** höchstmöglichen Modus wählen (z. B. „802.11ax/ac/n“). Den reinen **b/g-Modus abschalten**.
  Ein einziges altes Gerät bremst sonst alle anderen aus.
- **Band Steering / ein Netzwerkname:** Der Router verteilt die Geräte automatisch auf die Bänder. Verbinden sich
  einzelne Geräte (oft IoT) nicht mehr, ein separates 2,4-GHz-Netz anlegen.
- **Sendeleistung:** in der Regel auf **100 %** lassen; nur bei mehreren Access Points reduzieren, damit die Geräte
  sauber wechseln.
- **Airtime Fairness, MU-MIMO, OFDMA, Beamforming:** aktivieren, sofern vorhanden.
- **Zeitschaltung / WLAN-Abschaltung:** nach Bedarf, spart Strom.

## 4. Firmware & Sicherheit

- **Firmware aktualisieren** und automatische Updates aktivieren. Das schließt Sicherheitslücken und verbessert oft die Leistung.
- **Verschlüsselung:** **WPA3-Personal (SAE)**, ersatzweise WPA2/WPA3-Mischmodus. **Kein** WEP, kein WPA (TKIP).
- **WLAN-Passwort:** mindestens 16 Zeichen, nicht der Aufkleberwert, wenn der Router alt ist.
- **WPS abschalten** (PIN-Verfahren ist angreifbar).
- **Admin-Passwort** des Routers ändern; **Fernzugriff** aus dem Internet deaktivieren, wenn nicht benötigt.
- **UPnP** nur aktivieren, wenn es wirklich gebraucht wird (z. B. für Spielkonsolen).
- **Gastnetz** für Besucher und am besten auch für **IoT-Geräte** (Smart-TV, Steckdosen, Kameras) verwenden.
  Damit sind sie vom Heimnetz getrennt.
- **Netzwerkname (SSID):** keine persönlichen Daten oder das Router-Modell im Namen.

## 5. Netzwerk & Dienste

- **QoS / Priorisierung:** Videokonferenz, Telefonie oder Gaming-Geräte priorisieren. Bei vollem Upload hilft
  **SQM** bzw. **Smart Queue** (falls angeboten) erheblich gegen Verzögerungen („Bufferbloat“).
- **DNS:** Ein schneller DNS-Server (z. B. der des Providers, `1.1.1.1`, `9.9.9.9`) kann das Laden von Webseiten
  beschleunigen. **DNS over TLS/HTTPS** erhöht die Privatsphäre.
- **IPv6** aktiviert lassen, sofern der Provider es unterstützt.
- **DHCP-Reservierungen** für Drucker, NAS und Server vergeben.
- **Ungenutzte Geräte** aus der Geräteliste entfernen bzw. sperren.
- **Regelmäßiger Neustart** (z. B. wöchentlich nachts) hilft bei älteren Routern mit Speicherproblemen.

## 6. Abdeckung erweitern

Reihenfolge nach Qualität:

1. **Access Point per LAN-Kabel**: beste Leistung.
2. **Mesh-System mit LAN-Backhaul** oder **dediziertem Funk-Backhaul** (Tri-Band).
3. **Powerline mit WLAN**: brauchbar, abhängig von der Hausinstallation.
4. **Klassischer Repeater**: halbiert meist die Geschwindigkeit, nur als Notlösung.

Mesh-Knoten bzw. Repeater **auf halber Strecke** zwischen Router und Funkloch platzieren, dort wo das Signal noch
mindestens −65 dBm stark ist, und nicht erst im Funkloch selbst.

## Fehlersuche

| Symptom | Mögliche Ursache | Maßnahme |
|---|---|---|
| Überall langsam, auch per Kabel | Anschluss/Provider | Provider kontaktieren, Modem/Router neu starten |
| Langsam nur per WLAN | Kanal überfüllt, falsches Band | Kanalscan, auf 5 GHz wechseln, Kanalbreite prüfen |
| Langsam nur in bestimmten Räumen | Reichweite | Router umstellen, Mesh/Access Point |
| Kurze Abbrüche (5 GHz) | DFS-Radarerkennung | Nicht-DFS-Kanal 36–48 wählen |
| Hohe Ping-Spitzen bei Up-/Downloads | Bufferbloat | QoS/SQM aktivieren |
| IoT-Gerät verbindet sich nicht | Band Steering, WPA3 | Separates 2,4-GHz-Netz mit WPA2 (Gastnetz) |
| Gerät verbindet sich, hat aber kein Internet | IP-Konflikt/DHCP | Gerät „vergessen“ und neu verbinden, Router neu starten |

## Skripte

Beide Skripte scannen die WLANs in der Umgebung, zeigen die Belegung pro Kanal und empfehlen einen Kanal.
Sie ändern **nichts** am Router. Den Kanal stellst du anschließend selbst in der Router-Oberfläche ein.

### Linux / macOS

```bash
chmod +x scripts/wlan-check.sh
./scripts/wlan-check.sh            # Linux: nutzt nmcli (NetworkManager), alternativ iw (dann sudo)
```

Unter macOS nutzt das Skript `system_profiler SPAirPortDataType` (ab macOS 14 je nach Datenschutzeinstellungen
ggf. ohne Netzwerknamen, die Kanäle werden trotzdem ausgewertet).

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\wlan-check.ps1
```

Nutzt `netsh wlan show networks mode=bssid`. Je nach Windows-Version muss dafür die **Standortfreigabe** aktiviert sein.

### Beispielausgabe

```
== 2,4 GHz ==
Kanal   Netze  stärkstes Signal
  1        4   -48 dBm
  6        7   -55 dBm
 11        2   -71 dBm
Empfehlung 2,4 GHz: Kanal 11

== 5 GHz ==
Kanal   Netze  stärkstes Signal
 36        3   -62 dBm
 44        1   -80 dBm
Empfehlung 5 GHz: Kanal 40 (frei)
```
