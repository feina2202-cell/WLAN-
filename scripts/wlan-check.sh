#!/usr/bin/env bash
# WLAN-Kanalanalyse für Linux und macOS.
# Scannt die umliegenden WLANs, zeigt die Belegung pro Kanal und empfiehlt einen Kanal.
# Ändert nichts am Router.
#
# Aufruf:
#   ./wlan-check.sh                 Umgebung scannen
#   ./wlan-check.sh --input DATEI   Bereits erfasste Daten auswerten (Zeilen: "<kanal> <dBm> <SSID>")
#   ./wlan-check.sh --raw           Nur die erfassten Rohdaten ausgeben
set -euo pipefail

usage() { sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; }

INPUT=""
RAW=0
while [ $# -gt 0 ]; do
  case "$1" in
    --input) INPUT="${2:?Datei fehlt}"; shift 2 ;;
    --raw) RAW=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unbekannte Option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# Frequenz (MHz) -> Kanalnummer
freq_to_chan() {
  local f=${1%.*}
  if   [ "$f" -eq 2484 ]; then echo 14
  elif [ "$f" -ge 2412 ] && [ "$f" -le 2472 ]; then echo $(( (f - 2407) / 5 ))
  elif [ "$f" -ge 5160 ] && [ "$f" -le 5885 ]; then echo $(( (f - 5000) / 5 ))
  elif [ "$f" -ge 5955 ] && [ "$f" -le 7115 ]; then echo "6e$(( (f - 5950) / 5 ))"
  else echo ""
  fi
}

scan_nmcli() {
  nmcli device wifi rescan >/dev/null 2>&1 || true
  sleep 3
  # Ausgabe: CHAN:SIGNAL:FREQ:SSID ; SIGNAL in Prozent -> dBm ≈ Prozent/2 - 100
  nmcli -t -f CHAN,SIGNAL,FREQ,SSID device wifi list 2>/dev/null |
    awk -F: '{
      chan=$1; sig=$2; freq=$3; sub(/ MHz/,"",freq)
      ssid=$0; sub(/^[^:]*:[^:]*:[^:]*:/,"",ssid); gsub(/\\:/,":",ssid)
      if (ssid=="") ssid="<versteckt>"
      if (freq+0 >= 5955) chan="6e" chan
      printf "%s %d %s\n", chan, int(sig/2 - 100), ssid
    }'
}

scan_iw() {
  local ifc
  ifc=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2; exit}')
  [ -n "$ifc" ] || { echo "Kein WLAN-Interface gefunden." >&2; return 1; }
  local out
  if ! out=$(iw dev "$ifc" scan 2>/dev/null); then
    out=$(sudo iw dev "$ifc" scan) || { echo "iw-Scan fehlgeschlagen (Root-Rechte nötig?)." >&2; return 1; }
  fi
  printf '%s\n' "$out" | awk '
    /^BSS /        { if (freq) print freq, sig, (ssid==""?"<versteckt>":ssid); freq=""; sig=""; ssid="" }
    /^\tfreq:/     { freq=$2 }
    /^\tsignal:/   { sig=int($2) }
    /^\tSSID:/     { ssid=$0; sub(/^\tSSID: ?/,"",ssid) }
    END            { if (freq) print freq, sig, (ssid==""?"<versteckt>":ssid) }
  ' | while read -r freq sig ssid; do
    chan=$(freq_to_chan "$freq")
    [ -n "$chan" ] && echo "$chan $sig $ssid"
  done
}

scan_macos() {
  # Bereich "Other Local Wi-Fi Networks"/"Current Network Information" auswerten
  system_profiler SPAirPortDataType 2>/dev/null | awk '
    /^ {12}[^ ].*:$/ && !/Channel|Signal|PHY|Security|Network Type|Country/ {
      name=$0; sub(/^ +/,"",name); sub(/:$/,"",name)
    }
    /Channel:/ {
      chan=$2; band=$0
      if (band ~ /6GHz/) chan="6e" chan
    }
    /Signal \/ Noise:/ {
      sig=$4
      if (chan!="") print chan, sig, (name==""?"<unbekannt>":name)
      chan=""
    }
  '
}

collect() {
  if [ -n "$INPUT" ]; then cat "$INPUT"; return; fi
  case "$(uname -s)" in
    Darwin) scan_macos ;;
    Linux)
      if command -v nmcli >/dev/null 2>&1 && nmcli -t -f WIFI general 2>/dev/null | grep -q enabled; then
        scan_nmcli
      elif command -v iw >/dev/null 2>&1; then
        scan_iw
      else
        echo "Weder nmcli (NetworkManager) noch iw gefunden. Bitte eines davon installieren." >&2
        exit 1
      fi ;;
    *) echo "Nicht unterstütztes System: $(uname -s). Unter Windows wlan-check.ps1 verwenden." >&2; exit 1 ;;
  esac
}

analyze() {
  awk '
    # Gewicht eines Netzes: je stärker das Signal, desto mehr stört es (-100 dBm -> 0, -30 dBm -> 70)
    function w(s) { s = s + 100; return s < 0 ? 0 : s }
    function abs(x) { return x < 0 ? -x : x }
    function rating(sig) {
      if (sig >= -50) return "ausgezeichnet"
      if (sig >= -60) return "gut"
      if (sig >= -67) return "ausreichend"
      if (sig >= -75) return "schwach"
      return "sehr schwach"
    }
    {
      chan=$1; sig=$2+0
      if (chan ~ /^6e/) { c=substr(chan,3)+0; n6[c]++; if (!(c in b6) || sig>b6[c]) b6[c]=sig; total++; next }
      c=chan+0
      if (c < 1) next
      n[c]++; if (!(c in best) || sig > best[c]) best[c]=sig
      sig_of[NR]=sig; ch_of[NR]=c
      total++
    }
    END {
      if (total == 0) { print "Keine WLANs gefunden. WLAN aktiv? Ggf. Standortfreigabe bzw. Root-Rechte prüfen."; exit 1 }
      printf "%d WLAN(s) gefunden.\n", total

      # ---- 2,4 GHz ----
      print "\n== 2,4 GHz =="
      print "Kanal   Netze  stärkstes Signal"
      any24=0
      for (c=1; c<=14; c++) if (c in n) { printf "%3d     %4d   %d dBm (%s)\n", c, n[c], best[c], rating(best[c]); any24=1 }
      if (!any24) print "  (keine Netze)"
      bad=0
      for (c=1; c<=14; c++) if ((c in n) && c!=1 && c!=6 && c!=11) bad+=n[c]
      # Kandidaten 1/6/11: Störung = Summe der Gewichte aller Netze, deren 20-MHz-Kanal überlappt (Abstand < 5)
      bestc=0; bestscore=-1
      split("1 6 11", cand, " ")
      for (i=1; i<=3; i++) {
        k=cand[i]; s=0
        for (r in ch_of) if (ch_of[r] <= 14 && abs(ch_of[r]-k) < 5) s += w(sig_of[r])
        score24[k]=s
        if (bestscore < 0 || s < bestscore) { bestscore=s; bestc=k }
      }
      printf "Störwert:  Kanal 1 = %d,  Kanal 6 = %d,  Kanal 11 = %d  (kleiner ist besser)\n", score24[1], score24[6], score24[11]
      printf "Empfehlung 2,4 GHz: Kanal %d, Kanalbreite 20 MHz\n", bestc
      if (bad > 0) printf "Hinweis: %d Netz(e) nutzen überlappende Kanäle (nicht 1/6/11) und stören zusätzlich.\n", bad

      # ---- 5 GHz ----
      print "\n== 5 GHz =="
      print "Kanal   Netze  stärkstes Signal"
      any5=0
      for (c=32; c<=177; c++) if (c in n) {
        dfs = (c>=52 && c<=144) ? "  [DFS]" : ""
        printf "%3d     %4d   %d dBm (%s)%s\n", c, n[c], best[c], rating(best[c]), dfs; any5=1
      }
      if (!any5) print "  (keine Netze)"
      # Kandidaten 36-48: gleicher Kanal voll, gleicher 80-MHz-Block (36-48) halb gewichtet
      bestc=0; bestscore=-1
      for (k=36; k<=48; k+=4) {
        s=0
        for (r in ch_of) {
          c=ch_of[r]
          if (c == k) s += w(sig_of[r])
          else if (c >= 36 && c <= 48) s += w(sig_of[r]) / 2
        }
        if (bestscore < 0 || s < bestscore) { bestscore=s; bestc=k }
      }
      printf "Empfehlung 5 GHz: Kanal %d (ohne DFS)%s, Kanalbreite 80 MHz%s\n", bestc, (bestscore==0 ? " – völlig frei" : ""), (bestscore > 150 ? " (oder 40 MHz bei vielen Nachbarn)" : "")
      # Freie DFS-Blöcke melden
      split("52 100 116 132", blk, " ")
      freeblk=""
      for (i=1; i<=4; i++) {
        used=0
        for (c=blk[i]; c<blk[i]+16; c+=4) if (c in n) used=1
        if (!used) freeblk = freeblk (freeblk=="" ? "" : ", ") blk[i] "-" (blk[i]+12)
      }
      if (freeblk != "") printf "Alternative: freie DFS-Blöcke %s (kann kurze Unterbrechungen durch Radarerkennung verursachen)\n", freeblk

      # ---- 6 GHz ----
      any6=0
      for (c in n6) any6=1
      if (any6) {
        print "\n== 6 GHz =="
        print "Kanal   Netze  stärkstes Signal"
        for (c=1; c<=233; c++) if (c in n6) printf "%3d     %4d   %d dBm (%s)\n", c, n6[c], b6[c], rating(b6[c])
      }
    }
  '
}

DATA=$(collect)
if [ "$RAW" -eq 1 ]; then printf '%s\n' "$DATA"; exit 0; fi
printf '%s\n' "$DATA" | grep -E '^(6e)?[0-9]+ -?[0-9]+' | analyze
