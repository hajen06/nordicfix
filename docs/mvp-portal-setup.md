# MekFix MVP – Supabase och portalens start

Portalens kod finns på `portal/index.html`; partneransökan finns på `partner/index.html`. GitHub Pages kan publicera dessa statiska sidor, mutta data och inloggning skyddas av Supabase Auth och Row Level Security (RLS). Följ stegen nedan innan riktiga uppgifter används.

## Vad som fungerar i denna MVP-grund

- Privat inloggning för inbjudna administratörs- och partnerkonton.
- Admin kan läsa partneransökningar, granska/godkänna/avslå dem, lägga till verkstäder och pausa/aktivera verkstäder.
- Godkännande skapar en **inaktiv** verkstadspost; aktivering är ett separat administratörsbeslut.
- Partner kan läsa sin egen verkstadsprofil och hantera sina egna lediga tider.
- Publik partneransökan sparar uppgifter i Supabase; endast administratörer får läsa eller granska dem.

Detta är ännu **inte** ett fullständigt bokningssystem: inga kundärenden, kund- eller verkstadsmail, geokodning, 30 km-matchning, automatisk kalenderkoppling eller betalningar. Den publika Formspree-kundformen är fortfarande separat från portalen. Lägg inte in riktiga kunduppgifter i test innan dataskydd, åtkomst och drift är granskade.

## 1. Skapa Supabase-projektet och kör databasen

1. Skapa ett Supabase-projekt och spara databaslösenordet säkert.
2. Supabase → **SQL Editor**: kör först hela `supabase/migrations/202611140001_mekfix_mvp.sql` och därefter `supabase/migrations/202611140002_partner_review.sql`.
3. Auth → **Sign-in / Providers**: stäng av offentlig registrering. Använd endast inbjudningar.
4. Auth → Users: bjud in ägarens konto. När det är skapat, kör SQL nedan efter att du kontrollerat rätt e-post. Det ska ändra exakt en profil:

```sql
update public.profiles p
set role = 'admin', workshop_id = null
from auth.users u
where p.id = u.id
  and lower(u.email) = lower('DIN_EPOST_HÄR');
```

Aktivera MFA för administratören. Publicera aldrig service-role/secret-nyckeln.

## 2. Konfigurera Supabase-anslutningen

Öppna `portal/config.js` och sätt:

```js
window.MEKFIX_SUPABASE_CONFIG = {
  url: 'https://DITT-PROJEKT.supabase.co',
  anonKey: 'DIN_PUBLISHABLE_ELLER_ANON_KEY'
};
```

Project URL och publishable/anon key kan finnas i browsern om RLS är korrekt aktiverat. **Använd aldrig `service_role` eller secret key i denna fil.** Ändra den lokalt/GitHub-editorn och publicera i ditt repo. Om repot är publikt är det normalt att publishable/anon key syns; säkerheten ligger i RLS-policyerna.

## 3. Öppna portalen

Med GitHub Pages källa `main` och `/ (root)`:
- Admin/partnerportal: `https://hajen06.github.io/nordicfix/portal/`
- Partneransökan: `https://hajen06.github.io/nordicfix/partner/`

Kontrollera Settings → Pages att publicering är aktiv. GitHub Pages kan behöva några minuter efter en commit.

## 4. Granska en ansökan och ge partnerkonto

1. Verkstaden skickar ansökan på partnerlänken. Ansökan blir inte automatiskt godkänd eller aktiv.
2. Logga in som admin i `/portal/`, granska företags-/försäkringsuppgifter och tryck **Godkänn ansökan**. Detta skapar en inaktiv verkstad.
3. Bjud in verkstadens e-post i Supabase Auth → Users. Offentlig sign-up ska fortfarande vara avstängd.
4. I adminlistan, hitta verkstadens UUID (vid behov via Supabase Table Editor → workshops). Koppla den inbjudna profilen i SQL Editor:

```sql
update public.profiles p
set role = 'partner', workshop_id = 'VERKSTADENS-UUID'
from auth.users u
where p.id = u.id
  and lower(u.email) = lower('PARTNERNS_VERIFIERADE_EPOST');
```

5. Aktivera verkstaden i adminpanelen först efter att kontot, uppgifterna och partneravtalet är kontrollerade. Partnern kan därefter logga in och lägga in nästa lediga tider.

## 5. Säkerhets- och driftskontroll före riktiga personuppgifter

- Testa med anon, admin, partner A och partner B: ansökningar privata, adminfunktioner admin-only, partners ser bara egen verkstad/tider.
- Kontrollera Supabase Auth redirect URLs och lägg till publicerad portal-URL.
- Använd HTTPS; konfigurera MFA, backup, radering/retention och incidentrutin.
- Kontrollera formulärens integritetstext, partneravtal och ansvar/försäkringskrav juridiskt. Denna prototyp ska inte uppfattas som juridiskt godkänd.
- CDN-scriptet använder Supabase JS v2. För högre driftssäkerhet bör det senare låsas till en testad versionsadress.
- Adminens webbadress är inte hemlig. Skyddet är Supabase-inloggning plus RLS; gömda knappar/URL är inte säkerhet.

## 6. Nästa tekniska etapp

För att koppla kundflödet krävs ytterligare backend och databasdelar: kundärenden, geokodning, server-side radie-matchning, matchning bara till aktiva partners, tillgänglighets-/bokningslås, mejlutskick och statusflöde. Dessa är avsiktligt inte låtsas-implementerade i denna portalgrund.
