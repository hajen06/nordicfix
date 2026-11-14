-- MekFix MVP foundation for Supabase.
-- Run in Supabase SQL Editor. Never put the service-role key in browser code.
create extension if not exists pgcrypto;
create type public.mekfix_role as enum ('admin', 'partner');
create type public.application_status as enum ('pending', 'reviewing', 'approved', 'rejected');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.mekfix_role not null default 'partner',
  workshop_id uuid,
  created_at timestamptz not null default now()
);

create table public.partner_applications (
  id uuid primary key default gen_random_uuid(),
  company_name text not null check (char_length(trim(company_name)) between 2 and 160),
  organization_number text not null check (char_length(trim(organization_number)) between 6 and 24),
  contact_name text not null check (char_length(trim(contact_name)) between 2 and 160),
  email text not null check (char_length(email) <= 254),
  phone text not null check (char_length(phone) <= 40),
  customer_phone text not null check (char_length(customer_phone) <= 40),
  emergency_phone text check (emergency_phone is null or char_length(emergency_phone) <= 40),
  street_address text not null check (char_length(street_address) <= 240),
  postal_code text not null check (char_length(postal_code) <= 16),
  city text not null check (char_length(trim(city)) between 2 and 120),
  services text not null check (char_length(services) <= 3000),
  insurance_company text not null check (char_length(insurance_company) <= 200),
  insurance_valid_until date,
  responsibility_acknowledged boolean not null default false check (responsibility_acknowledged),
  privacy_acknowledged boolean not null default false check (privacy_acknowledged),
  status public.application_status not null default 'pending',
  admin_notes text check (admin_notes is null or char_length(admin_notes) <= 3000),
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.workshops (
  id uuid primary key default gen_random_uuid(),
  company_name text not null check (char_length(trim(company_name)) between 2 and 160),
  organization_number text not null check (char_length(trim(organization_number)) between 6 and 24),
  email text not null check (char_length(email) <= 254),
  phone text not null check (char_length(phone) <= 40),
  customer_phone text not null check (char_length(customer_phone) <= 40),
  emergency_phone text check (emergency_phone is null or char_length(emergency_phone) <= 40),
  street_address text not null check (char_length(street_address) <= 240),
  postal_code text not null check (char_length(postal_code) <= 16),
  city text not null check (char_length(trim(city)) between 2 and 120),
  latitude double precision check (latitude is null or latitude between -90 and 90),
  longitude double precision check (longitude is null or longitude between -180 and 180),
  services text not null default '',
  insurance_company text,
  insurance_valid_until date,
  active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles add constraint profiles_workshop_id_fkey
  foreign key (workshop_id) references public.workshops(id) on delete set null;

create table public.availability_slots (
  id uuid primary key default gen_random_uuid(),
  workshop_id uuid not null references public.workshops(id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz,
  note text check (note is null or char_length(note) <= 500),
  created_at timestamptz not null default now(),
  check (ends_at is null or ends_at > starts_at)
);

create index partner_applications_status_created_idx on public.partner_applications(status, created_at desc);
create index workshops_active_city_idx on public.workshops(active, city);
-- PostgreSQL partial-index predicates must be immutable; do not use now() here.
create index availability_slots_workshop_time_idx on public.availability_slots(workshop_id, starts_at);
create index profiles_workshop_idx on public.profiles(workshop_id);

create function public.handle_new_auth_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, role) values (new.id, 'partner');
  return new;
end;
$$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute procedure public.handle_new_auth_user();

create function public.is_mekfix_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.role = 'admin');
$$;
create function public.current_workshop_id()
returns uuid language sql stable security definer set search_path = '' as $$
  select p.workshop_id from public.profiles p
  where p.id = (select auth.uid()) and p.role = 'partner' limit 1;
$$;
revoke all on function public.is_mekfix_admin() from public;
revoke all on function public.current_workshop_id() from public;
grant execute on function public.is_mekfix_admin() to authenticated;
grant execute on function public.current_workshop_id() to authenticated;

alter table public.profiles enable row level security;
alter table public.partner_applications enable row level security;
alter table public.workshops enable row level security;
alter table public.availability_slots enable row level security;

create policy "profile self read or admin read" on public.profiles
  for select to authenticated using (id = (select auth.uid()) or (select public.is_mekfix_admin()));
create policy "admin manages profiles" on public.profiles
  for all to authenticated using ((select public.is_mekfix_admin())) with check ((select public.is_mekfix_admin()));

create policy "public submits partner application" on public.partner_applications
  for insert to anon, authenticated
  with check (status = 'pending' and admin_notes is null and reviewed_at is null);
create policy "admin reads applications" on public.partner_applications
  for select to authenticated using ((select public.is_mekfix_admin()));
create policy "admin reviews applications" on public.partner_applications
  for update to authenticated using ((select public.is_mekfix_admin())) with check ((select public.is_mekfix_admin()));

create policy "admin manages workshops" on public.workshops
  for all to authenticated using ((select public.is_mekfix_admin())) with check ((select public.is_mekfix_admin()));
create policy "partner reads own workshop" on public.workshops
  for select to authenticated using (id = (select public.current_workshop_id()));

create policy "admin manages availability" on public.availability_slots
  for all to authenticated using ((select public.is_mekfix_admin())) with check ((select public.is_mekfix_admin()));
create policy "partner reads own availability" on public.availability_slots
  for select to authenticated using (workshop_id = (select public.current_workshop_id()));
create policy "partner adds own availability" on public.availability_slots
  for insert to authenticated with check (workshop_id = (select public.current_workshop_id()));
create policy "partner updates own availability" on public.availability_slots
  for update to authenticated using (workshop_id = (select public.current_workshop_id()))
  with check (workshop_id = (select public.current_workshop_id()));
create policy "partner deletes own availability" on public.availability_slots
  for delete to authenticated using (workshop_id = (select public.current_workshop_id()));

grant select on public.profiles to authenticated;
grant select, insert, update, delete on public.partner_applications to authenticated;
grant insert on public.partner_applications to anon;
grant select, insert, update, delete on public.workshops to authenticated;
grant select, insert, update, delete on public.availability_slots to authenticated;

-- Do not expose private workshop columns publicly or put a service-role key in browser code.
