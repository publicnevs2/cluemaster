ClueMaster - Die interaktive Schnitzeljagd-App
Willkommen bei ClueMaster! Dieses Flutter-Projekt ist eine vielseitige und moderne Anwendung zur Erstellung und Durchführung von interaktiven Schnitzeljagden. Ob für Kindergeburtstage, Teambuilding-Events oder einfach nur zum Spaß mit Freunden – ClueMaster verwandelt jede Umgebung in ein spannendes Abenteuer.

🚀 Projektbeschreibung
ClueMaster ist in zwei Hauptbereiche unterteilt: eine intuitive Benutzeroberfläche für die Spieler und einen leistungsstarken, passwortgeschützten Admin-Bereich für den Organisator der Schnitzeljagd.

Das Ziel der App ist es, eine vollständig digitale und medienreiche Schnitzeljagd zu ermöglichen, bei der Hinweise nicht nur aus Text, sondern auch aus Bildern, Audio- und Videobotschaften bestehen können. Zusätzlich können Hinweise mit interaktiven Rätseln verknüpft werden, um das Erlebnis noch herausfordernder zu gestalten.

✨ Features
Für Spieler:
Einfache Code-Eingabe: Spieler geben einen Code ein, um den nächsten Hinweis freizuschalten.

QR-Code-Scanner: Alternativ kann ein an der Station versteckter QR-Code gescannt werden, um Tippfehler zu vermeiden.

Multimedia-Hinweise: Hinweise können als Text, Bild, Audioaufnahme oder sogar als kurzes Video angezeigt werden.

Interaktive Rätsel: An Hinweise können Fragen geknüpft sein, die erst richtig beantwortet werden müssen, um den Hinweis als "gelöst" zu markieren.

Fortschrittsanzeige: Eine Liste zeigt alle bereits gefundenen und gelösten Hinweise an.

Für den Organisator (Admin-Bereich):
Passwortgeschützt: Sicherer Zugang zur Verwaltung der Schnitzeljagd.

Vollständige Hinweis-Verwaltung: Hinweise können direkt in der App erstellt, bearbeitet und gelöscht werden.

Flexible Hinweis-Typen: Volle Unterstützung für Text, Bild, Audio, Video und optionale Rätsel.

Dynamische Medien: Bilder können aus der Galerie oder direkt von der Kamera aufgenommen werden. Audio kann direkt in der App aufgezeichnet und Videos aus der Galerie ausgewählt werden.

Spiel zurücksetzen: Mit einem Klick können alle Hinweise auf "ungelöst" zurückgesetzt werden, um die Schnitzeljagd erneut zu starten.

🛠️ Wie der Code funktioniert (Architektur)
Das Projekt ist in einer sauberen und erweiterbaren Ordnerstruktur organisiert, um die Wartung zu erleichtern.

lib/main.dart: Der Einstiegspunkt der Anwendung. Hier werden das App-Theme und die grundlegende Navigation initialisiert.

lib/data/models/clue.dart: Das Herzstück der App. Diese Datei definiert das Clue-Objekt, also den "Bauplan" für jeden Hinweis. Ein Clue enthält:

code: Der einzigartige Code des Hinweises (z.B. "GARTENTOR").

type: Definiert die Art des Hinweises (text, image, audio, video).

content: Der eigentliche Inhalt (der Text selbst oder der Dateipfad zum Medium).

description: Ein optionaler Untertitel.

solved: Ein Status, der anzeigt, ob der Hinweis gelöst wurde.

question & answer: Optionale Felder, die einen Hinweis zu einem Rätsel machen.

lib/core/services/clue_service.dart: Das "Gehirn" der Datenverwaltung. Dieser Service ist dafür verantwortlich, die codes.json-Datei aus dem Gerätespeicher zu lesen und wieder dorthin zu schreiben. Er sorgt dafür, dass alle Änderungen (neue Hinweise, gelöste Rätsel) persistent gespeichert werden.

lib/features/: Dieser Ordner enthält die Benutzeroberfläche, aufgeteilt nach Funktionen:

home/: Der Startbildschirm für die Spieler mit Code-Eingabe und QR-Scan-Option.

clue/: Die Bildschirme zur Anzeige der Hinweis-Details und der Liste der gefundenen Hinweise.

admin/: Alle Bildschirme für den passwortgeschützten Verwaltungsbereich.

shared/: Wiederverwendbare Widgets, wie z.B. der qr_scanner_screen.

assets/codes.json: Die "Datenbank" der App. Diese JSON-Datei enthält die Start-Hinweise und dient als Vorlage, die beim ersten App-Start in den beschreibbaren Speicher des Geräts kopiert wird.

💡 Zukünftige Ideen
Das Projekt hat eine solide Grundlage und kann leicht um weitere spannende Features erweitert werden:

GPS-basierte Hinweise: Schalte Hinweise erst frei, wenn der Spieler einen bestimmten geografischen Ort erreicht.

QR-Codes in der App erstellen: Generiere QR-Codes für deine Hinweise direkt im Admin-Menü, anstatt externe Tools zu verwenden.

Story & Theming: Gib deiner Schnitzeljagd ein Thema (z.B. Piraten, Agenten) und passe das Design der App entsprechend an.

Admin-Passwort ändern: Eine Funktion im Admin-Bereich, um das Passwort zu ändern.

Mehrere Schnitzeljagden: Eine Möglichkeit, verschiedene Schnitzeljagden zu speichern und zwischen ihnen zu wechseln.