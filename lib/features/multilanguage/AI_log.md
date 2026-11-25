# Iteracija 1 – Korisnička priča 1: Odabir jezika aplikacije

**Razina primjene AI-ja:** 3

**Način rada:** Programiranje u paru uz primjenu TDD principa.

## PITANJE 1

Opiši mi jedinične testove koji su potrebni za prolazak priče 1, daj mi da su što jednostavniji.

### Odgovor AI-ja

Najjednostavniji skup koji pokriva sva tri kriterija je šest jediničnih testova za `LocaleController` i jedan widget test za ekran Settings, koji se piše prije implementacije korisničkog sučelja.

### Pomoćna funkcija

Napraviti pomoćnu funkciju koja gradi kontroler. Funkcija prima neobavezne parametre za spremljene postavke i jezik uređaja.

Unutar funkcije pozivaju se `SharedPreferences.setMockInitialValues()`, `SharedPreferences.getInstance()` i konstruktor klase `LocaleController`.

Na taj način svaki test može sadržavati samo nekoliko redaka koda.

### Jedinični testovi – LocaleController

| # | Naziv testa                                           | Zadano                                       | Očekivani rezultat                     | Kriterij  |
| - | ----------------------------------------------------- | -------------------------------------------- | -------------------------------------- | --------- |
| 1 | uses German when the device language is German        | Nema spremljenog jezika, uređaj de           | Jezik je de                            | 3         |
| 2 | uses English for any other device language            | Nema spremljenog jezika, uređaj fr           | Jezik je en                            | 3         |
| 3 | uses the saved language over the device language      | Spremljen de, uređaj en                      | Jezik je de                            | 2         |
| 4 | setLocale changes the language and notifies listeners | Zadani kontroler, poziv setLocale(de)        | Jezik je de, listener je pozvan jednom | 1         |
| 5 | setLocale saves the choice                            | Promjena jezika i stvaranje novog kontrolera | Novi kontroler ima jezik de            | 2         |
| 6 | setLocale ignores an unsupported language             | Poziv setLocale(fr)                          | Jezik ostaje en                        | Robusnost |

Za testove 1–3 dovoljno je provjeriti vrijednost `controller.locale.languageCode`.

Testovi 4–6 koriste `await` jer je metoda `setLocale()` asinkrona.

Kod petog testa novi kontroler mora koristiti iste SharedPreferences podatke kao prvi kontroler.

Dodatni testovi za ponovni odabir istog jezika i neispravnu spremljenu vrijednost nisu uključeni u minimalni predloženi skup.

### Widget test

Predložen je widget test kojim se provjerava otvaranje Settings ekrana na engleskom jeziku, odabir opcije Deutsch i promjena naslova Language u Sprache.

### Princip rada

Test – razvoj metode – prolazak testa – sljedeći test.

---

## PITANJE 2

Sada kada se taj dio implementirao, što bi trebao sadržavati jedinični test za screen na kojem će se dodati u settingsima gumb?

### Odgovor AI-ja

Za Settings ekran potrebno je napisati widget test (`testWidgets`), a ne običan jedinični test, jer se provjerava interakcija korisnika s korisničkim sučeljem.

### Priprema testnog okruženja

- Stvoriti LocaleController s praznim SharedPreferences postavkama i engleskim jezikom uređaja.
- Koristiti ChangeNotifierProvider za dostupnost kontrolera.
- Konfigurirati MaterialApp s lokalizacijskim delegatima i podržanim jezicima.
- Povezati locale aplikacije s LocaleControllerom.
- Postaviti SettingsScreen kao početni ekran.

### Predloženi widget testovi

| # | Naziv testa                                          | Radnja                                     | Očekivani rezultat                            | Kriterij |
| - | ---------------------------------------------------- | ------------------------------------------ | --------------------------------------------- | -------- |
| 1 | shows the language options                           | Otvoriti Settings ekran                    | Prikazani Language, English i Deutsch         | 1        |
| 2 | switches the screen to German when Deutsch is tapped | Odabrati Deutsch                           | Prikazan Sprache, Language više nije prikazan | 1        |
| 3 | updates the controller when Deutsch is tapped        | Odabrati Deutsch                           | controller.locale.languageCode == 'de'        | 1        |
| 4 | keeps the choice after a restart                     | Odabrati Deutsch i stvoriti novi kontroler | Novi kontroler ima jezik de                   | 2        |

Za simulaciju korisničkog odabira koriste se `tester.tap()` i `tester.pumpAndSettle()`.

Četvrti test provjerava povezanost korisničkog sučelja i kontrolera te trajno spremanje odabranog jezika.

### Dodatna preporuka AI-ja

Za provjeru lokalizacije navigacije predložen je dodatni widget test koji bi nakon promjene jezika provjerio prijevode naziva navigacijskih kartica.

### Rezultat i odluke

Implementiran je LocaleController koji omogućuje:

- Odabir engleskog ili njemačkog jezika.
- Automatski odabir jezika prema jeziku uređaja.
- Spremanje odabranog jezika pomoću SharedPreferences.
- Obavještavanje aplikacije o promjeni jezika.
- Odbijanje nepodržanih jezika.

Widget testovi za Settings ekran bili su predloženi, ali nisu implementirani u ovoj fazi. Vidljiva kontrola za odabir jezika naknadno je dodana tijekom druge iteracije.

---

# Iteracija 2 – Korisnička priča 2: Gateway lokalizacija

**Razina primjene AI-ja:** 4

**Način rada:** Programiranje u paru uz korištenje AI agenta za generiranje testova i implementacije.

**Metodologija:** Test Driven Development – RED, GREEN, REFACTOR.

## 1. RED faza

### PITANJE 1 – Generiranje testova

Na temelju postojećih klasa generiraj testove za lokalizaciju Gateway funkcionalnosti na engleski i njemački jezik. Sve testove organiziraj u jednu datoteku unutar foldera test/features/multilanguage. Primijeni TDD i prvo generiraj testove, bez implementacije funkcionalnosti.

### Rezultat AI agenta

Generirano je osam widget testova u datoteci:

`test/features/multilanguage/gateway_localization_test.dart`

Testovi provjeravaju:

- Prikaz engleskog korisničkog sučelja.
- Prikaz njemačkog korisničkog sučelja.
- Lokalizaciju naslova spremljenih gatewaya.
- Lokalizaciju validacije adrese.
- Lokalizaciju validacije porta.
- Lokalizaciju gumba za ponovni pokušaj povezivanja.
- Lokalizaciju poruke greške povezivanja.
- Lokalizaciju dijaloga za brisanje gatewaya.

### Rezultat izvršavanja testova

| Ukupno | Uspješni | Neuspješni |
| ------ | -------- | ---------- |
| 8      | 1        | 7          |

Test engleskog sučelja uspješno je prošao. Testovi njemačke lokalizacije nisu prošli jer očekivani njemački tekstovi nisu pronađeni u korisničkom sučelju.

### Zaključak

Potvrđena je RED faza TDD-a za trenutačno napisane testove.

---

## 2. Proširenje RED faze

### PITANJE 2 – Testiranje pluralizacije i grešaka CAN portova

Proširi postojeću testnu datoteku testovima za pluralizaciju CAN portova, lokalizaciju greške prilikom dohvata CAN portova i lokalizaciju gumba za ponovni pokušaj.

Sve testove zadrži u istoj datoteci.

### Rezultat AI agenta

Generirano je pet dodatnih widget testova.

Za simulaciju HTTP odgovora korišten je MockClient kako testovi ne bi ovisili o stvarnom gateway uređaju.

### Konačni skup testova

| #  | Funkcionalnost              | Očekivani rezultat                                    |
| -- | --------------------------- | ----------------------------------------------------- |
| 1  | Englesko sučelje            | Engleski tekstovi                                     |
| 2  | Njemačko sučelje            | Njemački tekstovi                                     |
| 3  | Spremljeni gatewayi         | Gespeicherte Gateways                                 |
| 4  | Prazna adresa               | Gateway-Adresse ist erforderlich                      |
| 5  | Neispravan port             | Der Port muss zwischen 1 und 65535 liegen             |
| 6  | Ponovni pokušaj povezivanja | Erneut versuchen                                      |
| 7  | Greška povezivanja          | Lokalizirana njemačka poruka                          |
| 8  | Dijalog za brisanje         | Gateway löschen, Löschen, Abbrechen                   |
| 9  | Jedan CAN port              | 1 Port                                                |
| 10 | Dva CAN porta               | 2 Ports                                               |
| 11 | Pet CAN portova             | 5 Ports                                               |
| 12 | Greška dohvata CAN portova  | Das Gateway konnte die CAN-Ports nicht bereitstellen. |
| 13 | Ponovni pokušaj dohvata     | Erneut versuchen                                      |

### Rezultat izvršavanja testova

| Ukupno | Uspješni | Neuspješni |
| ------ | -------- | ---------- |
| 13     | 1        | 12         |

Testovi su se uspješno pokrenuli, ali očekivani lokalizirani tekstovi nisu pronađeni.

### Zaključak

Potvrđena je RED faza za svih 13 testova korisničke priče 2.

---

## 3. GREEN faza – Konfiguracija lokalizacije

### PITANJE 3

Kako implementirati lokalizaciju aplikacije na engleski i njemački jezik koristeći postojeći LocaleController i Flutter lokalizaciju? Trenutačno nemamo ARB datoteke.

### Rezultat AI agenta

AI agent predložio je korištenje Flutterove ugrađene lokalizacije pomoću ARB datoteka i automatski generiranih lokalizacijskih klasa.

Dodane su sljedeće datoteke:

- `l10n.yaml`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_de.arb`

Automatski su generirane:

- `app_localizations.dart`
- `app_localizations_en.dart`
- `app_localizations_de.dart`

U datoteku `pubspec.yaml` dodane su ovisnosti `flutter_localizations` i `intl` te konfiguracija `generate: true`.

### Problem tijekom implementacije

Prilikom izvršavanja naredbe `flutter pub get` pojavila se greška:

`A dependency may only have one source.`

Uzrok je bio neispravan položaj konfiguracije `generate: true` i `uses-material-design: true` unutar YAML datoteke.

### Rješenje AI agenta

AI agent generirao je ispravljenu datoteku `pubspec.yaml` s pravilno odvojenim ovisnostima i Flutter konfiguracijom.

Nakon ispravka pokrenute su naredbe:

- `flutter pub get`
- `flutter gen-l10n`

### Tehnička odluka

Prijevodi se pohranjuju centralizirano u ARB datotekama, umjesto korištenja zasebnih uvjeta za svaki jezik unutar Gateway widgeta.

---

## 4. GREEN faza – Implementacija lokalizacije

### PITANJE 4

Na temelju postojećih testova i kriterija prihvaćanja implementiraj lokalizaciju Gateway funkcionalnosti na engleski i njemački jezik.

Zadrži postojeću poslovnu logiku i generiraj kompletne datoteke koje možemo pregledati i integrirati u projekt.

### Rezultat AI agenta

AI agent generirao je implementaciju postupno, po pojedinim datotekama.

### 4.1. main.dart

Aplikacija je povezana s postojećim LocaleControllerom pomoću providera.

MaterialApp konfiguriran je tako da koristi:

- Trenutačno odabrani locale.
- AppLocalizations.localizationsDelegates.
- AppLocalizations.supportedLocales.

Time je omogućeno automatsko osvježavanje lokaliziranih widgeta nakon promjene jezika.

### 4.2. gateway_failure_localization.dart

Generirana je nova datoteka koja koristi Dart extension metode za lokalizaciju objekata ConnectionFailure i CanPortsException.

Poruke grešaka određuju se prema tipu greške i trenutačno odabranom jeziku.

Tehnička odluka bila je odvojiti poslovnu logiku i tipove grešaka od njihovog prikaza korisniku.

### 4.3. gateway_validators.dart

Postojeći validatori prošireni su neobaveznim lokalizacijskim parametrom.

Lokalizirane su poruke za:

- Praznu adresu gatewaya.
- Neispravnu IP adresu.
- Neispravan naziv hosta.
- Nedopuštene znakove u adresi.
- Neispravan format porta.
- Port izvan dopuštenog raspona.

Zadržana su postojeća pravila validacije i engleske zadane poruke radi kompatibilnosti s postojećim pozivima validatora.

### 4.4. connection_screen.dart

AI agent generirao je kompletnu lokaliziranu datoteku ConnectionScreen.

Lokalizirani su:

- Naslov ekrana.
- Opcija simuliranih podataka.
- Polja za unos adrese i porta.
- Gumb za povezivanje.
- Gumb za ponovni pokušaj.
- Naslov spremljenih gatewaya.
- Validacijske poruke.
- Poruke grešaka povezivanja.

Umjesto spremanja gotove tekstualne poruke greške, implementacija sprema objekt ConnectionFailure.

Poruka se lokalizira unutar metode build(), čime se omogućuje promjena jezika postojeće poruke bez ponovnog pokušaja povezivanja.

### Međurezultat testiranja

| Ukupno | Uspješni | Neuspješni |
| ------ | -------- | ---------- |
| 13     | 7        | 6          |

Nakon lokalizacije ConnectionScreen ekrana i validatora potvrđen je prolazak sedam testova.

---

### 4.5. delete_gateway_dialog.dart

**Upit prema AI agentu:** Lokaliziraj postojeći dijalog za brisanje gatewaya i generiraj cijelu datoteku.

AI agent lokalizirao je naslov dijaloga, poruku potvrde i gumbe za potvrdu i odustajanje.

Za prikaz adrese gatewaya unutar prevedene rečenice korišten je ARB placeholder:

`l10n.deleteGatewayConfirmation(gateway.address)`

Postojeća logika potvrđivanja brisanja ostala je nepromijenjena.

### 4.6. saved_gateway_tile.dart

**Upit prema AI agentu:** Lokaliziraj postojeći SavedGatewayTile.

AI agent lokalizirao je tooltipove gumba za povezivanje i brisanje.

Naziv i adresa gatewaya nisu prevedeni jer predstavljaju korisničke podatke.

Tooltipovi nisu zasebno pokriveni postojećim skupom od 13 testova.

### 4.7. can_port_selector.dart

**Upit prema AI agentu:** Lokaliziraj postojeći CanPortSelector, uključujući pluralizaciju, poruke grešaka i gumb za ponovni pokušaj.

AI agent generirao je kompletnu lokaliziranu datoteku.

Lokalizirani su:

- Poruka kada gateway nije povezan.
- Poruka učitavanja CAN portova.
- Naziv CAN porta.
- Odabir CAN porta.
- Oznaka deaktiviranog porta.
- Poruka kada nema dostupnih portova.
- Poruke grešaka dohvata.
- Gumb za ponovni pokušaj.

### Implementacija pluralizacije

Umjesto ručnog određivanja jednine i množine korištena je ICU pluralizacija unutar ARB datoteka.

Za prikaz broja portova koristi se:

`l10n.canPortCount(ports.length)`

Primjeri:

| Broj portova | Engleski | Njemački |
| ------------ | -------- | -------- |
| 1            | 1 port   | 1 Port   |
| 2            | 2 ports  | 2 Ports  |
| 5            | 5 ports  | 5 Ports  |

Poruke grešaka lokaliziraju se prilikom izgradnje korisničkog sučelja, umjesto spremanja unaprijed prevedenog teksta.

Zadržana je postojeća logika dohvata CAN portova, ponovnog pokušaja i odabira porta.

---

## 5. Završni rezultat GREEN faze

Nakon implementacije svih navedenih datoteka ponovno je pokrenuta testna kolekcija:

`flutter test test/features/multilanguage/gateway_localization_test.dart`

### Rezultat

**+13: All tests passed!**

| Faza                  | Ukupno testova | Uspješni | Neuspješni |
| --------------------- | -------------- | -------- | ---------- |
| Početna RED faza      | 8              | 1        | 7          |
| Proširena RED faza    | 13             | 1        | 12         |
| Djelomična GREEN faza | 13             | 7        | 6          |
| Završna GREEN faza    | 13             | 13       | 0          |

Svi testovi korisničke priče 2 uspješno prolaze.

Postojeći očekivani rezultati testova nisu mijenjani kako bi se prilagodili implementaciji.

---

## 6. Naknadna implementacija odabira jezika iz korisničke priče 1

### PITANJE 5

Svi testovi prolaze, ali gdje je gumb za promjenu jezika?

### Odgovor AI agenta

AI agent utvrdio je da je LocaleController implementiran i povezan s aplikacijom, ali SettingsScreen ne sadrži vidljivu kontrolu za odabir jezika.

Predloženo je dodavanje SegmentedButton komponente na vrh Settings ekrana.

### PITANJE 6

Možemo li dodati gumb za promjenu jezika bez pisanja dodatnog widget testa?

### Rezultat AI agenta

AI agent generirao je kompletnu izmijenjenu datoteku `settings_screen.dart`.

Dodana je SegmentedButton komponenta koja omogućuje odabir između:

- English
- Deutsch

Odabir jezika poziva postojeću metodu `LocaleController.setLocale()`.

Promjena jezika odmah se prenosi na MaterialApp i lokalizirane Gateway widgete, bez potrebe za pritiskom na Save changes.

### Odluka para

Odlučeno je da se gumb implementira bez zasebnog widget testa jer već postoje testovi kontrolera i Gateway lokalizacije.

Funkcionalnost gumba provjerena je ručnim pokretanjem aplikacije.

Ova izmjena predstavlja naknadno dovršavanje dijela korisničke priče 1 tijekom druge iteracije.

Za implementaciju gumba korišten je kod koji je generirao AI agent, što odgovara načinu rada na razini 4. Za sam gumb nije proveden zaseban TDD ciklus.

### Rezultat

Potvrđeno je da gumb za promjenu jezika radi u aplikaciji.

---

## 7. REFACTOR faza

### PITANJE 7

Svi testovi korisničke priče 2 uspješno prolaze. Što je potrebno napraviti nakon GREEN faze?

### Odgovor AI agenta

AI agent predložio je:

- Pokretanje kompletne testne kolekcije.
- Pokretanje statičke analize koda.
- Zajednički pregled generiranog koda.
- Provjeru dupliciranja koda i prijevoda.
- Provjeru preostalih hardkodiranih tekstova.
- Provjeru očuvanja postojeće poslovne logike.
- Ručnu provjeru promjene jezika.
- Ponovno pokretanje testova nakon eventualnih izmjena.

### Primijenjene tehničke odluke

- Centralizacija Gateway prijevoda u ARB datotekama.
- Ponovno korištenje postojećih lokalizacijskih ključeva.
- Odvajanje lokalizacije grešaka od poslovne logike.
- Korištenje ICU pluralizacije.
- Spremanje objekata grešaka umjesto gotovih tekstualnih poruka.
- Zadržavanje postojećih pravila validacije.
- Korištenje postojećeg LocaleControllera.
- Zadržavanje korisničkih podataka u izvornom obliku.

### Preostale provjere

Potrebno je potvrditi rezultate naredbi:

- `flutter test`
- `flutter analyze`

Potrebno je pregledati GatewayHealthStatusWidget i provjeriti postoje li dodatni nelokalizirani tekstovi.

Naslov kontrole za odabir jezika trenutačno koristi jednostavan uvjet za prikaz Language ili Sprache. U daljnjem refaktoriranju može se prebaciti u ARB datoteke.

Lokalizacija svih navigacijskih oznaka i ostalih Settings tekstova nije obuhvaćena ovom implementacijom.

---

## 8. Uloga AI-ja i programiranje u paru

AI agent korišten je za:

- Generiranje widget testova na temelju kriterija prihvaćanja.
- Analizu postojećih klasa i widgeta.
- Generiranje lokalizacijskih datoteka.
- Generiranje kompletnih implementacija.
- Rješavanje konfiguracijskih problema.
- Objašnjavanje generiranog koda.
- Predlaganje tehničkih odluka.
- Predlaganje koraka REFACTOR faze.

Članice para bile su odgovorne za:

- Definiranje kriterija prihvaćanja.
- Dostavljanje postojećeg izvornog koda.
- Integraciju generiranog koda u projekt.
- Pokretanje testova.
- Praćenje rezultata testiranja.
- Donošenje odluka o prihvaćanju predloženih rješenja.
- Ručnu provjeru funkcionalnosti aplikacije.

Zajednički pregled i razumijevanje generiranog koda dio su završne provjere rada na razini 4.

---

## 9. Zaključak druge iteracije

Tijekom druge iteracije korišten je AI agent na razini 4 za generiranje testova i implementaciju lokalizacije Gateway funkcionalnosti.

Primijenjen je TDD pristup u kojem su najprije generirani i pokrenuti testovi, nakon čega je postupno implementirana funkcionalnost.

Početno stanje bilo je jedan uspješan i dvanaest neuspješnih testova, dok je nakon implementacije potvrđen uspješan prolazak svih trinaest testova korisničke priče 2.

Naknadno je implementiran i gumb za promjenu jezika u Settings ekranu, čime je omogućeno korištenje lokalizacije kroz korisničko sučelje aplikacije.

Funkcionalnost promjene jezika potvrđena je ručnom provjerom.