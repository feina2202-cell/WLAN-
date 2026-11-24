# WLAN – iPhone absichern

Anleitung, um ein iPhone gegen Abhören und Ausspähen zu schützen sowie Cookies,
Tracker und Werbung zu sperren. Gilt für iOS 17/18 und neuer (Menünamen können
je nach Version leicht abweichen).

---

## 1. Abhören verhindern

### Sofort prüfen
| Prüfung | Wo |
|---|---|
| Unbekannte Konfigurationsprofile oder MDM entfernen | Einstellungen › Allgemein › **VPN und Geräteverwaltung** |
| Unbekannte Geräte von der Apple-ID abmelden | Einstellungen › [Dein Name] › Geräteliste ganz unten |
| Wer sieht meinen Standort / meine Daten? | Einstellungen › Datenschutz & Sicherheit › **Sicherheitsprüfung** |
| Welche Apps nutzen Mikrofon / Kamera? | Einstellungen › Datenschutz & Sicherheit › **Mikrofon** bzw. **Kamera** |
| Was haben Apps zuletzt genutzt? | Einstellungen › Datenschutz & Sicherheit › **App-Datenschutzbericht** (aktivieren) |

**Orange Punkt** oben rechts = Mikrofon aktiv, **grüner Punkt** = Kamera aktiv.
Kontrollzentrum öffnen zeigt, welche App gerade zugreift.

### Konto absichern
1. **Apple-ID-Passwort ändern** (lang, einmalig) und **Zwei-Faktor-Authentifizierung** aktivieren.
2. **Code-Sperre** mit mindestens 6 Ziffern, besser alphanumerisch
   (Einstellungen › Face ID & Code › Code ändern › Codeoptionen).
3. **Schutz für gestohlene Geräte** aktivieren (Einstellungen › Face ID & Code).
4. **Erweiterter Datenschutz für iCloud** (Ende-zu-Ende-Verschlüsselung für Backups):
   Einstellungen › [Dein Name] › iCloud › Erweiterter Datenschutz.
5. **Sicherheitsschlüssel** für die Apple-ID, falls vorhanden (FIDO2-Stick).

### System härten
- **iOS immer aktuell halten**: Einstellungen › Allgemein › Softwareupdate ›
  Automatische Updates **und** Sicherheitsmaßnahmen/Hintergrund-Sicherheitsupdates an.
- **Blockierungsmodus (Lockdown Mode)** bei konkretem Verdacht auf gezielte
  Spähsoftware (z. B. Pegasus): Einstellungen › Datenschutz & Sicherheit ›
  Blockierungsmodus. Schränkt Funktionen ein, schützt aber stark.
- **Keine fremden Profile** installieren und **kein Jailbreak**.
- **Siri bei Sperre aus**: Einstellungen › Siri › „Siri im Sperrzustand" aus.
- **Zugriff im Sperrzustand** begrenzen (Kontrollzentrum, Mitteilungen, USB-Zubehör aus):
  Einstellungen › Face ID & Code.
- **Bluetooth/AirDrop**: AirDrop auf „Nur Kontakte" oder „Empfang aus".
- **iMessage-Kontaktschlüsselbestätigung** aktivieren (Einstellungen › [Dein Name] ›
  Kontaktschlüsselbestätigung) – zeigt an, wenn sich jemand dazwischenschaltet.
- **Verschlüsselt telefonieren/schreiben**: FaceTime, iMessage oder Signal statt
  normaler Anrufe/SMS (Mobilfunk-Gespräche und SMS sind nicht Ende-zu-Ende verschlüsselt).

### Mailbox und Rufumleitung
- Mailbox-PIN ändern (nicht 0000/1234).
- Unbemerkte Umleitungen prüfen: `*#21#` wählen; alle Umleitungen löschen mit `##002#`.

### Bei konkretem Verdacht
- Backup machen, dann **iPhone löschen und als neues Gerät einrichten**
  (nicht aus dem verdächtigen Backup wiederherstellen).
- Apple-ID-Passwort von einem anderen, sauberen Gerät aus ändern.
- Beratung: Polizei / Beratungsstellen gegen digitale Gewalt
  (z. B. bei Stalkerware durch Partner oder Bekannte).

---

## 2. Cookies und Tracking sperren

### Safari
Einstellungen › Apps › **Safari**:
- **Websiteübergreifendes Tracking verhindern** – an
- **IP-Adresse verbergen** – „Vor Trackern und Websites"
- **Betrugswarnung** – an
- **Alle Cookies blockieren** – an *(Achtung: manche Logins funktionieren dann
  nicht; ggf. wieder ausschalten und nur Tracking verhindern)*
- **Erweiterter Schutz vor Tracking und Fingerprinting** – „Gesamtes Surfen"
  (unter Safari › Erweitert)
- Verlauf und Websitedaten regelmäßig löschen: Safari › **Verlauf und Websitedaten löschen**

### App-Tracking
- Einstellungen › Datenschutz & Sicherheit › **Tracking** › „Apps erlauben,
  Tracking anzufordern" **aus**.
- Einstellungen › Datenschutz & Sicherheit › **Apple-Werbung** ›
  „Personalisierte Werbung" **aus**.
- Ortungsdienste › Systemdienste › „Ortsabhängige Apple-Werbung" und
  „Wichtige Orte" **aus**.

### Mail
Einstellungen › Apps › Mail › **Datenschutz** › „Mail-Aktivität schützen" an
(blockiert Tracking-Pixel).

### iCloud Privat-Relay (mit iCloud+)
Einstellungen › [Dein Name] › iCloud › **Privat-Relay** an – verschleiert IP
und DNS-Anfragen in Safari.

---

## 3. Werbung sperren

### Variante A: Systemweit per verschlüsseltem DNS (empfohlen, kostenlos)
Blockiert Werbung und Tracker in **allen** Apps und Browsern.

1. Datei [`profile/adguard-dns-werbeblocker.mobileconfig`](profile/adguard-dns-werbeblocker.mobileconfig)
   auf dem iPhone in **Safari** öffnen und laden (Download erlauben).
2. Einstellungen › **Profil geladen** › Installieren › Code eingeben.
3. Einstellungen › Allgemein › VPN und Geräteverwaltung › DNS › prüfen, dass das
   Profil **aktiv** ist.

Entfernen: Einstellungen › Allgemein › VPN und Geräteverwaltung › Profil › Entfernen.

> Hinweis: Ist iCloud Privat-Relay aktiv, nutzt Safari dessen DNS statt des Profils.
> In den anderen Apps greift das Profil weiterhin.

Alternativen zum gleichen Prinzip: NextDNS (eigene Filterlisten, Statistiken),
Mullvad DNS, Control D.

### Variante B: Safari-Inhaltsblocker
App aus dem App Store installieren, z. B. **AdGuard**, **1Blocker** oder
**Wipr**, dann aktivieren unter Einstellungen › Apps › Safari › **Erweiterungen**.

### Variante C: Im ganzen WLAN (Router)
Für alle Geräte im Heimnetz: **Pi-hole** oder **AdGuard Home** auf einem
Raspberry Pi betreiben und im Router (z. B. FRITZ!Box: Internet › Zugangsdaten ›
DNS-Server) als DNS-Server eintragen.

### Weitere Werbung reduzieren
- In Apps: Einstellungen der jeweiligen App › Werbung/Personalisierung aus.
- Mitteilungen: Werbe-Mitteilungen pro App abschalten (Einstellungen › Mitteilungen).
- Unbekannte Anrufer stummschalten: Einstellungen › Apps › Telefon ›
  „Unbekannte Anrufer stummschalten".

---

## Kurz-Checkliste
- [ ] iOS aktuell, automatische Updates an
- [ ] Apple-ID: starkes Passwort + 2FA, fremde Geräte entfernt
- [ ] Keine unbekannten Profile / MDM
- [ ] Sicherheitsprüfung durchgeführt
- [ ] Mikrofon/Kamera-Rechte geprüft
- [ ] Rufumleitungen geprüft (`*#21#`)
- [ ] Safari: Tracking verhindern, Cookies blockieren, IP verbergen
- [ ] App-Tracking-Anfragen aus, personalisierte Werbung aus
- [ ] DNS-Werbeblocker-Profil installiert
