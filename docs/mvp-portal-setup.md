# MekFix MVP portal – setup guide

This repository's public site is a static GitHub Pages site. This first MVP increment adds a protected admin/partner portal and a Supabase database foundation. GitHub Pages hosts the portal UI; Supabase Auth and Row Level Security protect data. The Supabase project must be configured by the owner before the portal can sign in.

## Included in this increment

- `portal/index.html`: sign-in page and role-based starter dashboard.
- `supabase/migrations/202611140001_mekfix_mvp.sql`: profiles, partner applications, private workshops, availability slots, and role-based RLS policies.
- Admins can review partner applications and create/activate partner workshop records.
- Partners can see their own workshop profile and create/view/delete availability slots.
- Public visitors may submit a partner application; they cannot read application records.

This increment is not yet a full customer request/matching/bookings system. It does not geocode addresses, calculate the 30 km radius, send partner notifications, or create customer bookings. Those features need a server-side service and separate database migrations; do not treat the current static Formspree flow as implementing them.

## 1. Create/configure Supabase

1. Create a Supabase project and keep its database password and service-role key private.
2. In **SQL Editor**, run the migration file from this repository.
3. In **Authentication → Providers / Sign-in**, disable public user sign-ups. Create accounts only by invitation from the Supabase dashboard.
4. Copy the project URL and the **publishable/anon key**. These two values are intended for browser configuration when Row Level Security is enabled. Never use a `service_role` or secret key in this HTML file.

## 2. Create the first admin

1. In Supabase **Authentication → Users**, invite the owner's email address and complete the invitation/sign-in.
2. In SQL Editor, replace the example email and run the following, after confirming the user is the intended owner:

```sql
update public.profiles p
set role = 'admin', workshop_id = null
from auth.users u
where p.id = u.id
  and lower(u.email) = lower('OWNER_EMAIL_HERE');
```

3. Confirm exactly one row changed. Do not make an admin account publicly self-registerable. Add MFA to the owner account.

## 3. Configure and publish the portal

1. Open `portal/index.html` and replace `SUPABASE_URL_HERE` and `SUPABASE_ANON_KEY_HERE` with the project URL and publishable/anon key.
2. Commit/push the update to `main`. With GitHub Pages configured for `main` and `/(root)`, the portal will be at `https://hajen06.github.io/nordicfix/portal/`.
3. Sign in with the invited admin account. The role and all data access are checked by Supabase RLS, not by hiding the page.

The portal file is not connected to the public contact page, and the admin URL is not a security boundary. Database policies are the security boundary. If the project URL/key are not configured, the portal intentionally shows a setup warning.

## 4. Add a partner

1. Create/invite the partner's Auth user from Supabase Auth. Do not enable public sign-up.
2. In the admin portal, use **Lägg till verkstad** to create the approved workshop entry.
3. In SQL Editor, link the invited account to its workshop (use exact verified email and workshop UUID):

```sql
update public.profiles p
set role = 'partner', workshop_id = 'WORKSHOP_UUID_HERE'
from auth.users u
where p.id = u.id
  and lower(u.email) = lower('PARTNER_EMAIL_HERE');
```

4. Set the workshop active only after checking the partnership and insurance details. Do not collect insurance files in this MVP; the current schema stores insurer and expiry metadata only.

## 5. Partner applications

A public application form and spam controls should be wired to the `partner_applications` table in the next increment. The database permits inserts only and restricts reads/review to admins. Until that form is added, receive applications via the existing contact channel and review them manually.

## Security/operations checklist before using real customer data

- Verify RLS is enabled on every table; test as anon, admin, partner A, and partner B.
- Never commit Supabase service-role/secret keys, passwords, customer exports, or insurance documents.
- Keep sign-up disabled; use invitations and revoke accounts when a partner leaves.
- Add MFA for administrators, backups, audit/incident procedures, and data retention/deletion rules.
- Obtain privacy/partner terms and have the data handling and liability wording reviewed before collecting sensitive or customer data.
- Configure a custom production domain and HTTPS after verifying DNS.
- The current starter portal does not implement customer cases, matching, payments, email notifications, or schedule conflict protection.
