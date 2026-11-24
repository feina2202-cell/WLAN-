# ❄️ Gefrierschrank-App

Web-App (PWA) für eingefrorenes Fleisch und Fisch – läuft auf dem iPhone wie
eine normale App, auch offline. Alle Daten bleiben **nur auf dem Gerät**.

## Funktionen
- **Sorten mit Unterkategorien**: Fisch, Schwein, Rind, Wild (Reh, Hirsch,
  Wildschwein), Geflügel (Huhn, Ente, Gans, Pute) – z. B. Reh › Keule,
  Ente › Brust. Eigene Sorten/Unterkategorien in den Einstellungen anlegbar.
- **Datum** beim Einfrieren (vorbelegt mit heute, änderbar)
- **Stückzahl**, optional Gewicht, Fach/Ort und Notiz
- **Erinnerung nach 6 Monaten** – Standard einstellbar, zusätzlich pro Sorte
  und pro Eintrag
- Farbige Anzeige: grün = ok, gelb = in 30 Tagen fällig, rot = überfällig
- **Entnehmen** mit „−“ (1 Stück oder alles aufgebraucht)
- Suche, Filter (Sorte, Gruppe, bald fällig), Sortierung
- **📅 Kalender**: legt die Erinnerung als Termin im iPhone-Kalender an
- Mitteilung beim Öffnen der App, wenn etwas fällig ist
- Export/Import als Sicherung (JSON)

## Auf dem iPhone installieren
1. App-Adresse in **Safari** öffnen (z. B. über GitHub Pages, siehe unten).
2. Teilen-Symbol › **Zum Home-Bildschirm**.
3. App vom Home-Bildschirm starten, unter ⚙️ Mitteilungen erlauben.

## Veröffentlichen (GitHub Pages)
Repository › Settings › Pages › Branch `main`, Ordner `/ (root)` › Save.
Danach ist die App erreichbar unter
`https://<benutzername>.github.io/<repository>/gefrierschrank/`.

## Hinweis zu Erinnerungen
iOS erlaubt Web-Apps keine zeitgesteuerten Mitteilungen ohne Server.
Daher: Fälliges wird beim Öffnen angezeigt/gemeldet – für eine echte
Erinnerung zum Stichtag beim Eintrag auf **📅 Kalender** tippen.
