
# Smjernice za automatizirano testiranje

## 1. Svrha dokumenta

Ovaj dokument definira strukturu, pravila imenovanja i način
pokretanja automatiziranih testova za Mobile Companion App.

Cilj je osigurati dosljednu, preglednu i proširivu organizaciju
testova tijekom daljnjeg razvoja aplikacije te olakšati dodavanje
i održavanje testova svim članovima razvojnog tima.

## 2. Struktura testnih direktorija

Testovi su organizirani prema funkcionalnostima aplikacije
(featureima), prateći strukturu izvornog koda.

Unutar svake funkcionalnosti odvojeni su jedinični (unit)
i widget testovi. Testovi zajedničke aplikacijske logike
i glavne navigacije smještaju se u zaseban direktorij `app/`.

### 2.1. Predviđena struktura

```text
mobile_companion_app/
├── lib/
├── test/
│   ├── app/
│   │   ├── unit/
│   │   └── widget/
│   ├── features/
│   │   ├── gateway/
│   │   │   ├── unit/
│   │   │   └── widget/
│   │   ├── dashboard/
│   │   │   ├── unit/
│   │   │   └── widget/
│   │   ├── alerts/
│   │   │   ├── unit/
│   │   │   └── widget/
│   │   ├── can/
│   │   │   ├── unit/
│   │   │   └── widget/
│   │   └── settings/
│   │       ├── unit/
│   │       └── widget/
│   ├── helpers/
│   └── README.md
└── integration_test/
```

Prikazana struktura predstavlja predviđenu organizaciju testova
tijekom daljnjeg razvoja aplikacije.

### 2.2. Trenutačno stanje i proširivanje strukture

Trenutačno su implementirani jedinični i widget testovi unutar
direktorija `test/`.
Trenutačno implementirani testovi raspoređeni su u sljedeće direktorije:

| Direktorij | Vrsta testova |
|---|---|
| `test/app/widget/` | Widget testovi glavne navigacije |
| `test/features/gateway/unit/` | Jedinični testovi gateway modela, servisa, repozitorija, kontrolera i validatora |
| `test/features/gateway/widget/` | Widget testovi gateway ekrana i pripadajućih komponenti |
| `test/features/dashboard/widget/` | Widget testovi dashboard ekrana |

Prilikom dodavanja novih funkcionalnosti pripadajuće testove potrebno je smjestiti u odgovarajuće direktorije prema funkcionalnosti i vrsti testa.

Direktorij `integration_test/` još nije kreiran te će se dodati
prilikom implementacije prvih integracijskih testova.

Svi ostali direktoriji kreiraju se prema potrebi, prilikom
dodavanja odgovarajućih testova. Nije potrebno unaprijed
kreirati prazne direktorije niti dodavati `.gitkeep` datoteke.

Struktura se može proširivati dodavanjem novih funkcionalnosti
i pripadajućih testova tijekom razvoja aplikacije.

## 3. Vrste testova

### 3.1. Jedinični testovi (Unit tests)

Jedinični testovi provjeravaju ponašanje pojedinačnih funkcija,
klasa, modela, servisa, repozitorija i poslovne logike.

Primjeri područja testiranja:

- Serijalizacija i deserijalizacija modela.
- Validacija ulaznih podataka.
- Parsiranje CAN podataka.
- Provjera dostupnosti i povezivanja s gatewayem.
- Lokalna pohrana podataka.
- Evaluacija pravila upozorenja.
- Obrada pogrešaka.

Vanjske ovisnosti potrebno je prema potrebi zamijeniti
simuliranim implementacijama (mock ili fake objektima).

Lokacija testova pojedine funkcionalnosti:

`test/features/<feature>/unit/`

Lokacija testova zajedničke aplikacijske logike:

`test/app/unit/`

### 3.2. Widget testovi (Widget tests)

Widget testovi provjeravaju prikaz, ponašanje i interakciju
Flutter widgeta i ekrana.

Primjeri područja testiranja:

- Prikaz ekrana i widgeta.
- Unos podataka i interakcija s gumbima.
- Prikaz CAN signala.
- Prikaz upozorenja.
- Prikaz stanja učitavanja i pogrešaka.
- Navigacija između ekrana.

Lokacija testova pojedine funkcionalnosti:

`test/features/<feature>/widget/`

Widget testovi na razini cijele aplikacije, poput testova
glavne navigacije, smještaju se u:

`test/app/widget/`

### 3.3. Integracijski testovi (Integration tests)

Integracijski testovi provjeravaju međusobnu suradnju više
komponenti unutar pokrenute aplikacije.

Primjeri budućih integracijskih testova:

- Povezivanje aplikacije s CAN gatewayem.
- Primanje i prikaz CAN signala.
- Evaluacija i prikaz upozorenja.
- Prekid i ponovno uspostavljanje komunikacije.
- Izvođenje cjelovitih korisničkih scenarija.

Flutter integracijski testovi smještat će se u direktorij
`integration_test/` u korijenu projekta, izvan direktorija `test/`.

Za izvođenje integracijskih testova potreban je odgovarajući
testni uređaj ili emulator. Ovisno o testnom scenariju, može
biti potreban i CAN gateway ili pokrenuti CAN simulator.

Integracijski testovi trenutačno nisu implementirani.
Njihovo dodavanje predviđeno je tijekom daljnjeg razvoja
i integracije funkcionalnosti aplikacije.

## 4. Zajedničke pomoćne testne komponente

Pomoćne komponente koje se koriste u više testnih datoteka
unutar direktorija `test/` smještaju se u:

`test/helpers/`

Primjeri:

- Mock servisi.
- Fake repozitoriji.
- Zajednički testni podaci.
- Pomoćne funkcije za widget testove.
- Simulirani CAN podaci.

Pomoćne komponente koje se koriste samo unutar jedne
testne datoteke mogu ostati u toj datoteci.

Direktorij `helpers/` kreira se kada se pojavi potreba
za zajedničkim pomoćnim komponentama.

## 5. Pravila imenovanja

Sve testne datoteke trebaju:

- Koristiti `snake_case` način imenovanja.
- Završavati nastavkom `_test.dart`.
- Imati opisni naziv povezan s komponentom koja se testira.
- Biti smještene u odgovarajući direktorij prema
  funkcionalnosti i vrsti testa.

Primjeri:

| Komponenta | Naziv testne datoteke |
|---|---|
| GatewayInfo | `gateway_info_test.dart` |
| GatewayScreen | `gateway_screen_test.dart` |
| GatewayHealthService | `gateway_health_service_test.dart` |
| CanMessageParser | `can_message_parser_test.dart` |
| AlertRule | `alert_rule_test.dart` |
| MainNavigation | `main_navigation_test.dart` |

Nazivi pojedinačnih testova trebaju jasno opisivati
očekivano ponašanje testirane komponente.

Primjeri naziva pojedinačnih testova:

- `Returns available when gateway health status is ok`
- `Shows an error message when connection fails`
- `Activates an alert when the threshold is exceeded`

## 6. Dodavanje novih testova

Prilikom dodavanja novog testa potrebno je:

1. Odrediti funkcionalnost ili komponentu koja se testira.
2. Odrediti vrstu testa (unit, widget ili integration).
3. Kreirati odgovarajući direktorij ako još ne postoji.
4. Kreirati testnu datoteku s opisnim nazivom.
5. Definirati očekivano ponašanje i relevantne testne slučajeve.
6. Implementirati i pokrenuti novi test.
7. Pokrenuti sve postojeće unit i widget testove prije
   predaje promjena.
8. Prema potrebi ažurirati pripadajuću testnu dokumentaciju.

Primjeri mogućih lokacija budućih testova:

```text
test/features/can/unit/can_message_parser_test.dart
test/features/dashboard/widget/can_signal_card_test.dart
test/features/alerts/unit/alert_rule_test.dart
test/features/alerts/widget/alert_display_test.dart
test/features/settings/widget/settings_screen_test.dart
integration_test/can_data_flow_test.dart
```

Navedene putanje predstavljaju primjere budućih testnih
datoteka, a ne nužno trenutačno implementirane testove.

## 7. Pokretanje testova

Sve naredbe pokreću se iz korijenskog direktorija projekta.

Prije pokretanja testova potrebno je imati instaliran Flutter SDK
i preuzete projektne ovisnosti:

```bash
flutter pub get
```

### 7.1. Pokretanje svih unit i widget testova

```bash
flutter test
```

### 7.2. Pokretanje svih testova pojedine funkcionalnosti

```bash
flutter test test/features/gateway
```

### 7.3. Pokretanje jediničnih testova pojedine funkcionalnosti

```bash
flutter test test/features/gateway/unit
```

### 7.4. Pokretanje widget testova pojedine funkcionalnosti

```bash
flutter test test/features/gateway/widget
```

### 7.5. Pokretanje pojedinačne testne datoteke

```bash
flutter test test/features/gateway/unit/gateway_info_test.dart
```

### 7.6. Pokretanje testova glavne navigacije

```bash
flutter test test/app/widget/main_navigation_test.dart
```

### 7.7. Provjera pokrivenosti izvornog koda testovima

```bash
flutter test --coverage
```

Rezultati pokrivenosti spremaju se u datoteku:

`coverage/lcov.info`

Pokrivenost izvornog koda služi kao pomoć pri prepoznavanju
dijelova aplikacije koji nisu obuhvaćeni testovima.

Visoka pokrivenost sama po sebi ne jamči ispravnost aplikacije
niti kvalitetu implementiranih testova.

### 7.8. Pokretanje integracijskih testova (planirano)

Nakon implementacije integracijskih testova, konfiguracije
potrebnih ovisnosti i pripreme testnog uređaja, integracijski
testovi moći će se pokretati naredbom:

```bash
flutter test integration_test
```

Za odabir određenog testnog uređaja može se koristiti:

```bash
flutter test integration_test -d <device_id>
```

Popis dostupnih uređaja prikazuje se naredbom:

```bash
flutter devices
```

Napomena: naredbe za pokretanje integracijskih testova
namijenjene su budućoj uporabi, nakon implementacije testova
i kreiranja direktorija `integration_test/`.

## 8. Preporučene prakse testiranja

- Osigurati neovisnost i ponovljivost testova.
- Koristiti jasne i opisne nazive testova.
- Testirati uspješne i neuspješne scenarije.
- Obuhvatiti neispravne ulazne podatke i granične vrijednosti.
- Provjeravati obradu pogrešaka.
- Izbjegavati stvarne mrežne zahtjeve u unit i widget testovima.
- Koristiti mock i fake objekte za vanjske ovisnosti.
- Izbjegavati međusobnu ovisnost testova i ovisnost
  o redoslijedu njihova izvođenja.
- Ažurirati odgovarajuće testove prilikom promjene
  ponašanja aplikacije.
- Dodavati testove prilikom implementacije novih funkcionalnosti.
- Pokrenuti postojeće unit i widget testove prije otvaranja
  pull requesta.
- Održavati testnu dokumentaciju ažurnom.

## 9. Testna strategija i dokumentacija

Testna strategija projekta, upute za pokretanje CAN simulatora,
testni scenariji, očekivani rezultati i poznata ograničenja
dokumentirani su na Confluenceu.

Relevantne stranice:

- Testna strategija
- Pokretanje CAN simulatora

Ovaj dokument nadopunjuje testnu strategiju tehničkim
smjernicama za organizaciju, dodavanje i pokretanje
automatiziranih Flutter testova.

Testovi i pripadajuća dokumentacija kontinuirano se
nadopunjavaju tijekom daljnjeg razvoja aplikacije.

Svaki član razvojnog tima treba dodavati i održavati
relevantne testove za funkcionalnosti koje razvija,
u skladu s dogovorenom testnom strategijom.
