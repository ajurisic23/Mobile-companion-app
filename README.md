# mobile_companion_app
CAN Mobile Monitor je mobilna aplikacija razvijena korištenjem Flutter razvojnog okvira. Aplikacija je namijenjena povezivanju s CAN gatewayem te praćenju podataka s CAN sabirnice.

Projekt je konfiguriran s podrškom za Android i iOS platforme.

## 1. Preduvjeti

Za razvoj i pokretanje aplikacije potrebno je imati:

- [Git](https://git-scm.com/downloads) za preuzimanje projekta.
- [Flutter SDK](https://docs.flutter.dev/install).
- [Android Studio](https://developer.android.com/studio) s dodacima Flutter i Dart.
- Instaliran Android SDK.
- Android emulator ili fizički Android uređaj.

Za razvoj i pokretanje aplikacije na iOS platformi potrebno je računalo s operacijskim sustavom macOS i instaliranim Xcodeom.

## 2. Instalacija razvojnog okruženja

### 2.1. Instalacija Flutter SDK-a

1. Otvoriti [službenu Flutter dokumentaciju za instalaciju](https://docs.flutter.dev/install).
2. Odabrati operacijski sustav na kojem će se razvijati aplikacija.
3. Preuzeti i instalirati Flutter SDK prema službenim uputama.
4. Dodati direktorij `bin` unutar Flutter SDK-a u sistemsku varijablu `PATH`, prema uputama za odabrani operacijski sustav.
5. Otvoriti terminal i provjeriti instalaciju naredbom:

   ```bash
   flutter --version
   ```

Ako je Flutter uspješno instaliran, terminal će prikazati informacije o instaliranoj verziji.

### 2.2. Instalacija i konfiguracija Android Studija

1. Preuzeti i instalirati [Android Studio](https://developer.android.com/studio).
2. Pokrenuti Android Studio.
3. Otvoriti **Postavke (Settings) → Dodaci (Plugins)**.
4. Pronaći i instalirati dodatak **Flutter**.
5. Ako je potrebno, instalirati i dodatak **Dart**.
6. Ponovno pokrenuti Android Studio nakon instalacije dodataka.
7. Provjeriti jesu li instalirani Android SDK i potrebni razvojni alati putem **SDK Managera**.

### 2.3. Postavljanje Android emulatora

Za pokretanje aplikacije bez fizičkog Android uređaja može se koristiti emulator.

1. U Android Studiju otvoriti **Device Manager (Upravitelj uređaja)**.
2. Odabrati mogućnost izrade novog virtualnog uređaja.
3. Odabrati model uređaja i odgovarajuću Android sistemsku sliku.
4. Dovršiti konfiguraciju virtualnog uređaja.
5. Pokrenuti emulator.

Umjesto emulatora može se koristiti fizički Android uređaj s omogućenim USB otklanjanjem pogrešaka (*USB debugging*).

### 2.4. Provjera razvojnog okruženja

U terminalu pokrenuti:

```bash
flutter doctor
```

Naredba provjerava instalaciju Fluttera i dostupnost potrebnih razvojnih alata.

Ako se prikažu upozorenja ili nedostajuće komponente, potrebno ih je riješiti prema ispisanim uputama. Za razvoj Android aplikacije posebno je važno da je Android razvojno okruženje ispravno konfigurirano.

Za provjeru dostupnih uređaja pokrenuti:

```bash
flutter devices
```

Naredba prikazuje dostupne emulatore i povezane fizičke uređaje.

## 3. Preuzimanje projekta

Otvoriti terminal i klonirati GitHub repozitorij:

```bash
git clone https://github.com/ajurisic23/Mobile-companion-app.git
```

Prijeći u direktorij preuzetog projekta:

```bash
cd Mobile-companion-app
```

Za razvoj se koristi grana `dev`. Nakon kloniranja moguće je prijeći na nju naredbom:

```bash
git switch dev
```

Projekt se zatim može otvoriti u Android Studiju odabirom direktorija koji sadržava datoteku `pubspec.yaml`.

## 4. Pokretanje aplikacije

### 4.1. Instalacija projektnih ovisnosti

U terminalu, unutar glavnog direktorija projekta, pokrenuti:

```bash
flutter pub get
```

Naredba preuzima ovisnosti definirane u datoteci `pubspec.yaml`.

### 4.2. Pokretanje na Android uređaju

1. Pokrenuti Android emulator ili povezati fizički Android uređaj.
2. Provjeriti prepoznaje li Flutter uređaj:

   ```bash
   flutter devices
   ```

3. Pokrenuti aplikaciju:

   ```bash
   flutter run
   ```

Ako je dostupno više uređaja, Flutter može zatražiti odabir uređaja. Određeni uređaj može se odabrati i pomoću naredbe:

```bash
flutter run -d <device-id>
```

Oznaku `<device-id>` potrebno je zamijeniti identifikatorom uređaja prikazanim naredbom `flutter devices`.

Aplikaciju je moguće pokrenuti i iz Android Studija odabirom uređaja te klikom na **Run (Pokreni)**.

### 4.3. Pokretanje na iOS uređaju

Projekt sadržava direktorij `ios/` i konfiguriran je s podrškom za iOS platformu.

Za izgradnju i pokretanje iOS aplikacije potreban je macOS s instaliranim Xcodeom i odgovarajućim iOS razvojnim alatima.

Upute za konfiguraciju dostupne su u [službenoj Flutter dokumentaciji za iOS](https://docs.flutter.dev/platform-integration/ios/setup).

## 5. Provjera ispravnosti projekta

### 5.1. Statička analiza koda

Za provjeru mogućih problema u Dart i Flutter kodu pokrenuti:

```bash
flutter analyze
```

### 5.2. Pokretanje testova

Za pokretanje postojećih automatiziranih testova pokrenuti:

```bash
flutter test
```

### 5.3. Provjera instaliranog Fluttera

Za prikaz informacija o Flutter razvojnom okruženju pokrenuti:

```bash
flutter doctor
```

## 6. Struktura projekta

Osnovni direktoriji Flutter projekta:

```text
mobile_companion_app/
├── android/          # Konfiguracija Android aplikacije
├── ios/              # Konfiguracija iOS aplikacije
├── lib/              # Izvorni Dart/Flutter kod
│   └── main.dart     # Ulazna točka aplikacije
├── test/             # Automatizirani testovi
├── pubspec.yaml      # Ovisnosti i konfiguracija projekta
└── README.md         # Upute za instalaciju i pokretanje
```

Detaljnija organizacija direktorija unutar lib/ razvija se u sklopu zadatka SCRUM-8 te će biti dokumentirana nakon dovršetka tog zadatka.