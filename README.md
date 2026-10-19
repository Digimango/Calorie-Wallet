# Calorie Wallet

Dein persönliches Banking für Ernährung.  
**Keine Moral.** Kein Lebensmittel ist gut oder schlecht – manche kosten einfach mehr vom Budget.

Die App läuft **vollständig offline**: keine Cloud, keine Accounts, keine externen Lebensmittelsuchen. Alle Daten bleiben auf deinem Gerät.

---

## Idee

Statt starrer Tageslimits verwaltest du ein **Wochenbudget (Wochenlohn)**.  
Mahlzeiten werden zu **Buchungen**, Nährstoffe zu **Investments**. Flexibel über die Woche – wie ein Konto, nicht wie ein Verbot.

---

## Features

### Budget & Tracking
- **Wochenlohn** statt starrem Tageslimit
- **Buchungen** mit Kategorie (Frühstück, Mittag, Abend, Snack)
- **Investments**: Protein, Kohlenhydrate, Fett, Ballaststoffe
- **Kontoauszug / Übersicht** – Wochen durchwischen, Jahr + KW
- Automatischer **Wochen-Reset** (Montag)
- Optional: Tagesmarkierungen auf der Wochenleiste

### Lebensmittel – 100 % offline
- Eingebaute Liste gängiger Lebensmittel + Fast-Food-Richtwerte
- **Eigene Lebensmittel** anlegen (Name, kcal & Makros pro 100 g)
- **Barcode-Scanner**: bekannt → buchen, unbekannt → selbst eintragen & speichern
- **Zuletzt gebucht** für Schnellzugriff
- Keine Open-Food-Facts-API, kein Internet nötig

### App & Gerät
- **Hive**-Speicherung (lokal, persistent)
- **Hell- & Dunkelmodus**
- Homescreen-**Widget** (Wochenbudget verfügbar)
- Android-APK, Portrait

### Datenschutz
- Keine INTERNET-Permission im Release-Build
- Keine Accounts, kein Tracking, keine Cloud-Sync
- Daten nur auf dem Gerät

---

## Lohn & Ziele

Unter **Lohn** legst du Wochenbudget und Makro-Ziele fest.  
**Lohn berechnen** ermittelt lokal den Erhalt (Halten); Abnehmen / Aufbau leiten sich davon ab (−500 / +300 kcal pro Tag). Manuelle Eingaben haben immer Vorrang.

---

## Technik (Kurz)

| Bereich        | Stack                          |
|----------------|--------------------------------|
| UI             | Flutter                        |
| State          | Provider                       |
| Speicher       | Hive                           |
| Scanner        | mobile_scanner                 |
| Widget         | home_widget                    |
| Build          | GitHub Actions → Release-APK   |

---

## Mitmachen / Build

APK über den Workflow **Build APK** erzeugen und unter *Actions → Artifacts* herunterladen.

---

