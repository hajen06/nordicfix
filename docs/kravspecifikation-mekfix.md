# MekFix – kravspecifikation

**Version:** 1.0  
**Datum:** 14 november 2026  
**Status:** Produktkrav och MVP-underlag  
**Primärt lanseringsområde:** Gävleborg, Sverige

## 1. Syfte

MekFix ska hjälpa en bilägare att hitta en godkänd partnerverkstad som kan ta emot bilen. Kunden lämnar en förfrågan med plats, kontakt- och fordonsuppgifter samt en felbeskrivning. Systemet hittar aktiva partnerverkstäder inom relevant kör-/sökradie, samlar in deras närmaste lediga tider och visar alternativen med den **tidigaste lediga bokningstiden först**.

MekFix förmedlar kontakten och bokningsförfrågan. Verkstaden ansvarar för sin bedömning, offert, arbete, försäkringar och kundens bil enligt avtal. Webbplatsen får inte antyda att en bokning är bekräftad innan verkstaden uttryckligen har bekräftat den.

## 2. Mål och framgångskriterier

### Mål för MVP
- Bilägare kan skicka en förfrågan från mobil eller dator.
- Endast godkända och aktiva partnerverkstäder inom områdets radie får förfrågan.
- Kunden kan se matchande verkstäder och deras angivna nästa lediga tid, sorterade tidigast först.
- Kunden kan välja en verkstad/tid och få tydlig status på om verkstaden har bekräftat.
- Om ingen match finns får kunden ett tydligt besked och kan be MekFix att återkomma.
- Administratören kan privat hantera partneransökningar, verkstäder, förfrågningar och inställningar.
- Partnerverkstäder kan ansöka om samarbete; ansökan blir inte automatiskt en aktiv partner.
- Förfrågningar och beslut går att följa i en enkel historik.

### Mätetal
- Antal förfrågningar och andel som får minst en match.
- Tid från förfrågan till första verkstadssvar.
- Andel tidsförslag som kunden väljer.
- Andel valda tider som verkstaden bekräftar.
- Antal avslutade förmedlingar per verkstad.
- Andel ärenden utan match och utan svar.

Mätetal ska inte marknadsföras som bevisade resultat innan tillräckligt med verklig data finns.

## 3. Roller och behörigheter

### 3.1 Besökare/kund
- Kan läsa den publika webbplatsen och skicka en förfrågan.
- Kan se verkstäder som matchar just den egna förfrågan.
- Kan välja ett tidsförslag, tacka nej eller be MekFix återkomma.
- Kan inte se andra kunders uppgifter, ärenden eller registreringsnummer.

### 3.2 Partnerverkstad
- Kan skicka in en partneransökan utan att vara inloggad.
- Efter att administratören godkänt ansökan kan verkstaden få ett eget konto.
- Kan endast se ärenden som skickats till den egna verkstaden och uppgifter som behövs för att hantera dem.
- Kan ange och uppdatera nästa tillgängliga tider, svara på förfrågningar och bekräfta/avböja en vald tid.
- Kan inte se andra verkstäders ärenden, kundlistor eller administrativa uppgifter.

### 3.3 Administratör/ägare
- Endast uttryckligen inbjudna administratörskonton får administratörsbehörighet.
- Administratörsinloggning ska inte vara offentlig självregistrering.
- Kan granska, godkänna, avslå eller begära komplettering av partneransökningar.
- Kan lägga till, redigera, pausa och avaktivera verkstäder och konton.
- Kan se och hantera alla förfrågningar, matchningar, bokningsstatus och relevanta loggar.
- Kan ändra radier, lanseringsområden och verksamhetsinställningar.
- Administrativa data skyddas på serversidan, inte bara genom att dölja länkar eller knappar.

## 4. Kundens förfrågningsformulär

### Obligatoriska fält
- Namn.
- E-postadress.
- Telefonnummer.
- Stad/ort.
- Gatuadress och eventuellt gatunummer, om det behövs för lokalisering.
- Postnummer.
- Bilmodell och årsmodell (årsmodell kan göras valfri om den inte behövs).
- Registreringsnummer.
- Beskrivning av felet.
- Samtycke/information om att uppgifterna används för att matcha och kontakta relevanta verkstäder.

### Valfria fält
- Önskat datum/tidsintervall.
- Om bilen går att köra.
- Bilder eller annan relevant information (bilagor bör vänta tills lagring och åtkomstskydd är på plats).

### Validering och skydd
- Kontrollera obligatoriska fält, rimligt format på e-post, telefon och postnummer.
- Visa fel nära fältet och behåll ifyllda värden vid fel.
- Skydda formuläret mot spam och automatiserad missbrukstrafik.
- Registreringsnummer och adress behandlas som personuppgifter när de kan kopplas till en person; de visas aldrig publikt.
- Kunden ska inte behöva lämna fler uppgifter än vad som behövs för matchning och kontakt.

## 5. Ort, geokodning och avstånd

1. Systemet använder kundens postnummer/adress för att hitta en ungefärlig geografisk position via en vald geokodningstjänst.
2. Systemet lagrar koordinaterna bara om det behövs för matchning och drift. Adressen ska inte exponeras för verkstäder innan kunden valt eller matchningsflödet kräver den.
3. Systemet mäter **radie i fågelväg** mellan kundposition och verkstadens registrerade position. UI och villkor ska tydligt säga att detta inte är uppskattad körtid eller köravstånd.
4. Standardradien är **30 km**. Radien ska kunna ställas in per område/region. För större städer kan administratören välja exempelvis **40 eller 50 km**.
5. Endast godkända, aktiva verkstäder med en giltig position inom den aktuella radien matchas.
6. Om adressen inte går att hitta ska kunden kunna rätta eller komplettera den; systemet ska inte gissa en exakt adressposition utan att visa det.
7. Geokodningstjänstens användningsvillkor, dataskydd, kostnader och begränsningar ska kontrolleras innan tjänsten väljs.

## 6. Matchning, tillgänglighet och sortering

### Matchningsregler
- Filtrera först på status `aktiv`, godkänd partner och relevanta tjänster/fordonstyper om sådana filter finns.
- Filtrera därefter på inställd radie för kundens område.
- En verkstad utanför radien får inte kundens förfrågan.
- Alla matchande aktiva partnerverkstäder får en avisering om en ny förfrågan, enligt användarens önskemål.
- Aviseringen ska innehålla minsta nödvändiga information. Fullständiga kontaktuppgifter och registreringsnummer delas först när det behövs och kunden har informerats.

### Tillgänglighet och sortering
- Verkstaden ska ange konkreta nästa lediga datum/tider eller ett tydligt tidsintervall. I MVP uppdateras tillgänglighet manuellt i partnerportalen; automatisk kalenderintegration ingår inte.
- Kundens matchningslista sorteras efter **nästa lediga bokningstid, tidigast först**.
- Om två verkstäder har samma lediga tid sorteras de närmast kunden först.
- Verkstäder som ännu inte har lämnat en tillgänglig tid visas separat som “Svar inväntas” eller visas inte som bokningsbara; de får inte sorteras som om de hade en bekräftad tid.
- En ledig tid är ett förslag, inte en bekräftad bokning, tills verkstaden bekräftat kundens val.
- Tidszon är svensk lokal tid (`Europe/Stockholm`); tider lagras i ett entydigt format och visas tydligt.

### Ingen match
- Visa exempelvis: “Vi hittade ingen aktiv partnerverkstad inom 30 km just nu.”
- Erbjud kunden att lämna/behålla en förfrågan så att MekFix kan kontakta kunden manuellt.
- Skicka administratören en avisering om förfrågan saknar match.
- Märk ärendet `Manuell uppföljning`; lämna inte kunden med intrycket att en verkstad har kontaktats.

## 7. Bokningsflöde och statusar

Föreslagna statusar:
1. `Mottagen` – förfrågan sparad.
2. `Matchar verkstäder` – partnerurval genomfört.
3. `Väntar på verkstadssvar` – aviseringar skickade.
4. `Tidsförslag mottaget` – en eller flera verkstäder har angett tider.
5. `Kunden valde verkstad/tid` – kundens val registrerat, ännu inte bekräftat.
6. `Bokad` – verkstaden har bekräftat.
7. `Kunden avböjde` eller `Verkstaden kunde inte` – flödet återgår till andra matchningar eller manuell uppföljning.
8. `Ingen match` / `Manuell uppföljning`.
9. `Avslutad` / `Avbruten`.

Systemet ska skydda mot dubbelbokning och gamla tidsförslag: när en tid inte längre är tillgänglig måste verkstaden kunna avvisa kundens val och kunden erbjudas ett annat alternativ.

## 8. Partneransökan och verkstadsregister

### Ansökan från verkstad
- Företagets juridiska namn och eventuellt marknadsnamn.
- Organisationsnummer.
- Besöksadress, ort, postnummer och geografisk position.
- Kontaktperson, roll, e-post och direkttelefon.
- Telefonnummer som kunder kan ringa.
- Akut-/journummer och vilka tider det gäller (valfritt).
- Tjänster, bilmärken/fordonstyper och kapacitet.
- Öppettider och hur snabbt verkstaden normalt svarar (uppgift, inte garanterad SLA).
- Ansvarsförsäkring: försäkringsbolag, typ, giltighetstid och eventuell dokumentation som administratören begär.
- Bekräftelse att verkstaden ansvarar för sin felsökning, offert, arbete, garanti, kundkommunikation och hantering av fordonet enligt separat partneravtal.
- Godkännande av integritetsinformation och villkor för partneransökan.

Insamling av försäkringsdokument och organisationsuppgifter kräver säker åtkomst och en bestämd gallringsrutin. Krav på dokument bör granskas innan lansering.

### Granskning och aktivering
- Ny ansökan får status `Inkommen` och blir inte sökbar.
- Administratören kan godkänna, avslå eller begära komplettering; beslut och tidpunkt loggas.
- Endast godkänd och aktiv verkstad ingår i matchning och får kundförfrågningar.
- Avstängd, utgången eller ej verifierad verkstad tas omedelbart bort från nya matchningar.
- Administratören kan manuellt skapa en partnerpost utan ansökan.

## 9. Administrationsportal

Skyddad inloggning och startsida med:
- Sammanställning av nya ärenden, ärenden utan match och partneransökningar.
- Sök/filter på ärende-ID, status, ort, datum och verkstad.
- Ärendedetaljer och tidslinje över skickade aviseringar, kundval och verkstadsbeslut.
- Partnerregister med status, kontaktuppgifter, adress/position, tjänster, tillgänglighet och försäkringskontroll.
- Åtgärder: godkänn/avslå ansökan, lägg till/redigera/pausa/avaktivera verkstad.
- Inställning av områden och sökradie, med standard 30 km och möjlighet till 40–50 km där administratören väljer det.
- Manuell uppföljning av förfrågningar utan match.
- Export endast om det finns ett verksamhetsbehov och åtkomsten är begränsad.
- Auditlogg för administratörsåtgärder. Lösenord och andra hemligheter får inte sparas i HTML eller klientkod.

## 10. Partnerportal

Efter godkännande kan partnern logga in och:
- Se och hantera endast sina egna mottagna förfrågningar.
- Ange, ändra och ta bort kommande lediga tider.
- Svara att verkstaden kan ta ärendet eller avböja med en enkel orsakskategori.
- Bekräfta eller avböja kundens val.
- Uppdatera kontaktperson, telefon, akutnummer, öppettider, tjänster och position; känsliga ändringar kan kräva administratörsgodkännande.
- Se status och historik för egna ärenden.

MVP kan starta med e-postlänkar och administratörshanterad tillgänglighet om partnerportal annars försenar pilotstarten, men kundens val och bokningsbekräftelse måste ändå spåras säkert.

## 11. E-post och aviseringar

- Kund: mottagningsbekräftelse, tillgängliga tider, status på kundens val och bekräftad bokning.
- Verkstad: ny relevant förfrågan, kundens val och avbokning/statusändring.
- Administratör: ny partneransökan, förfrågan utan match, tekniskt leveransfel och manuell uppföljning.
- Mejlen ska inte påstå att bokning är klar innan den är bekräftad.
- Använd en transaktionell e-posttjänst med server-side-konfiguration; API-nycklar får aldrig ligga i publikt JavaScript.
- Formspree kan användas för ett enkelt inkommande formulär under pilot, men ersätter inte databas, åtkomstkontroll, matchning eller partner-/adminportal.
- Logga leveransstatus, men undvik att spara onödiga kopior av personuppgifter i loggar.

## 12. Affärsregler och prissättning

### Pilot
- Lansering börjar i Gävleborg.
- De första minst tre partnerverkstäderna ska kunna vara kostnadsfria under introduktionsperioden.
- Exakt vilka tre, hur länge erbjudandet gäller och vad som händer efter perioden ska dokumenteras i partneravtal.

### Möjlig senare avgift
- Planerad modell: 499 kr per verkstad och månad.
- Grundarens förslag “ingen kund genom MekFix – ingen betalning” behöver preciseras innan någon fakturering byggs.
- Förslag till mätbar definition: en förmedlad kund räknas när kunden aktivt väljer en verkstad/tid och verkstaden bekräftar bokningen. Ett klick eller ett obesvarat tidsförslag ska inte räknas.
- Definiera vad som gäller vid avbokning, felaktig bokning, återkommande kund, tvist, gratisperiod, moms, fakturadatum och uppsägning.
- Betalningsintegration och automatisk debitering ingår inte i första MVP:n; börja med tydliga manuella avtal och fakturering först när villkoren är beslutade.

## 13. Integritet, säkerhet och ansvar

Detta avsnitt är produktkrav, inte juridisk rådgivning. Integritetsinformation, partneravtal, ansvarsvillkor och personuppgiftsroller ska granskas av kunnig rådgivare innan offentlig lansering.

- Samla endast nödvändiga personuppgifter och begränsa åtkomst per roll.
- Använd TLS/HTTPS, säker autentisering, server-side auktorisering och databasregler (t.ex. Row Level Security).
- Separera kundens privata kontakt- och fordonsuppgifter från publika verkstadsprofiler.
- Admin: MFA rekommenderas; begränsa konton och logga känsliga ändringar.
- Partner: en verkstad får endast läsa sin egen profil och de ärenden den fått tilldelade.
- Skydda mot spam, brute-force, CSRF där relevant, injektion och överdriven dataåtkomst.
- Ha rutiner för export, rättelse, radering, incidenter och säkerhetskopiering.
- Bestäm retentionperiod per datatyp innan drift. Den tidigare föreslagna uppgiften om radering inom 90 dagar är ännu inte ett beslutat policybeslut och ska inte kommuniceras som löfte innan rutinen finns.
- Dokumentera vilka tjänsteleverantörer som får personuppgifter och kontrollera deras villkor och eventuella överföringar utanför EES.
- Verkstaden ska tydligt stå som ansvarig för bedömning, offert, reparation och fordonet; exakt ansvarsfördelning ska stå i avtal och juridiskt granskas.

## 14. Icke-funktionella krav

- Mobilanpassad, snabb och användbar även på långsammare nät.
- Svenskt språk, svenska kronor och Europe/Stockholm-tid.
- Tillgänglighet: tangentbordsnavigering, synliga fokusmarkeringar, etiketter på formulär och begriplig feltext.
- Semantisk HTML och kontrast som fungerar för läsbarhet.
- Tillförlitlig hantering av e-postfel och geokodningsfel; kunden ska få ett ärligt besked.
- Testbar logik för avstånd, radie, statusövergångar, åtkomst och sortering.
- Miljövariabler/hemligheter hålls utanför GitHub-repot och klientbundlen.

## 15. Rekommenderad teknisk lösning

Nuvarande GitHub Pages-webbplats är statisk och kan fortsätta användas som publik startsida. Den kan inte ensam säkert hantera admininloggning, partneråtkomst, databas eller privata kundärenden.

För full MVP behövs:
- Publik frontend och skyddade admin-/partnerflöden.
- Backend/API för formulär, matchning, behörighetskontroll och aviseringar.
- Relationsdatabas med rollbaserad dataseparation.
- Autentisering med inbjudna admin- och partnerkonton.
- Geokodning/avståndsberäkning och transaktionell e-post.
- Produktionsmiljö med HTTPS, miljövariabler, säkerhetskopiering och övervakning.

Teknikval (t.ex. Supabase för Postgres/Auth och Vercel eller motsvarande för app/API) är ett genomförandebeslut och behöver fastställas separat. Formspree kan behållas som tillfällig ansöknings-/kontaktkanal, men ska inte användas som ensam databas eller administratörslösning.

## 16. Datamodell – miniminivå

- **users**: konto-ID, roll, e-post, status, skapad/ändrad.
- **workshops**: företagsidentitet, kontaktuppgifter, adress, koordinater, tjänster, försäkringsstatus, partnerstatus, radie/region, profilens synlighet.
- **partner_applications**: inskickade uppgifter, ansökningsstatus, administratörsbeslut och tidpunkter.
- **customer_requests**: ärende-ID, kontakt, fordonsuppgifter, plats, felbeskrivning, samtycke, status, skapad/ändrad, gallringsdatum.
- **request_matches**: ärende, verkstad, avstånd, matchningsorsak, aviseringens status.
- **availability_slots**: verkstad, start/slut, status och uppdateringstid.
- **offers/bookings**: ärende, verkstad, föreslagen tid, kundens val, verkstadens bekräftelse och status.
- **notifications**: mottagare, typ, leveransstatus och tidsstämpel; minimera persondata i loggar.
- **audit_events**: administratörs-/partneråtgärd, aktör, objekt och tidpunkt.

Exakta fält, datatyper och databasregler fastställs i teknisk design.

## 17. MVP-omfattning och senare versioner

### MVP – måste ingå
1. Gävleborg som första område.
2. Kundformulär med ort, adress, postnummer, bil, fel och kontaktuppgifter.
3. Partneransökan och administratörens manuella granskning.
4. Administratör kan skapa/redigera/aktivera/pausa verkstäder.
5. Geokodning och konfigurerbar radie: 30 km som standard.
6. Matchning enbart till aktiva partnerverkstäder inom radien.
7. Verkstäder anger nästa lediga tid manuellt; kunden ser tider tidigast först.
8. Kunden väljer verkstad/tid; verkstaden bekräftar; aviseringar skickas.
9. Ingen match leder till adminnotis och frivillig manuell uppföljning.
10. Säker autentisering, rollseparation, integritetsinformation och grundläggande loggning.

### Senare, inte krav för första MVP
- Automatisk kalenderintegration.
- Dynamiska priser eller betalningsprenumerationer.
- Flera regioner med automatiskt föreslagna radier.
- Kartvy och körsträckeberäkning.
- Bilduppladdning och dokumentlagring.
- SMS, chatt, kundkonto och avancerad analys.
- Automatisk fakturering, erbjudanden och kampanjer.

## 18. Acceptanstester

1. En kund kan skicka ett giltigt formulär och ser en mottagningsstatus.
2. Ogiltig e-post eller saknade obligatoriska uppgifter stoppas med begriplig feltext.
3. En godkänd aktiv partner inom 30 km matchas; en partner utanför 30 km matchas inte.
4. Om områdets radie ändras till 50 km kan partner mellan 30 och 50 km matchas.
5. Ej godkänd, pausad eller inaktiv partner får inte nya förfrågningar.
6. Matchande verkstäder får avisering; icke-matchande verkstäder får ingen avisering.
7. Två tillgängliga tider visas med tidigaste bokning först; vid lika tid visas närmaste verkstad först.
8. En tid markeras inte som bokad förrän verkstaden bekräftat kundens val.
9. Om ingen partner matchar kan kunden begära manuell uppföljning och administratören får en notis.
10. Partner A kan inte läsa partner B:s profilärenden eller andra kunders uppgifter.
11. Oinloggad besökare kan inte läsa admin- eller partnerdata genom direkta API-anrop.
12. Registreringsnummer, full adress och kundens kontaktuppgifter visas inte på publika verkstadskort.
13. Administratörens godkännande, pausning och ändring av verkstad loggas.
14. E-postleveransfel visas/loggas och leder inte till ett falskt löfte om att meddelandet kom fram.

## 19. Beslut som återstår före implementation

Följande behöver beslutas eller bekräftas:
- Ska radie vara fågelväg (rekommenderat för MVP) eller faktisk körsträcka?
- Ska kunden välja bland tider efter att verkstäderna svarat, eller välja en verkstad först och därefter få dess tider?
- Hur länge väntar systemet på verkstadssvar innan administratören får eskalera ärendet?
- Ska full adress och registreringsnummer delas med matchade verkstäder direkt, eller först efter kundens val?
- Exakt vilka verkstadsdokument och försäkringsbevis krävs för godkännande?
- Hur länge sparas ansökningar, kundärenden, aviseringar och försäkringsdokument?
- Vad är den exakta definitionen av “kund genom MekFix” för framtida 499 kr/mån-villkor, och vilka undantag gäller?
- Vilken geokodning, databas, autentisering, hosting och e-postleverantör väljs?
- Vilka juridiska villkor, integritetsinformation och partneravtal ska granskas och godkännas?

---

**Produktbeslut som redan framgår av beställningen:** Gävleborg först; 30 km som normalradie; möjlighet till större områdesradie, exempelvis 40–50 km, i större städer; endast partnerverkstäder inom radien får förfrågan; kunden ser verkstäder och platser; tider sorteras närmast lediga först; administratörskontrollerad partneraktivering; verkstäder kan ansöka; de första minst tre partnerna planeras kostnadsfria och 499 kr/månad är en senare affärsmodell som inte ska debiteras innan villkoren är fastställda.
