-- Admin review workflow. Safe to run after migration 001.
-- Approved applications create an inactive workshop record; admins must verify it
-- and explicitly activate it before it can ever be used in public matching.
alter table public.partner_applications
  add column if not exists workshop_id uuid references public.workshops(id) on delete set null;

create or replace function public.review_partner_application(
  p_application_id uuid,
  p_decision public.application_status,
  p_admin_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  app public.partner_applications%rowtype;
  created_workshop_id uuid;
begin
  if not (select public.is_mekfix_admin()) then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;
  if p_decision not in ('reviewing'::public.application_status, 'approved'::public.application_status, 'rejected'::public.application_status) then
    raise exception 'Invalid application decision' using errcode = '22023';
  end if;
  select * into app from public.partner_applications where id = p_application_id for update;
  if not found then raise exception 'Application not found' using errcode = 'P0002'; end if;

  created_workshop_id := app.workshop_id;
  if p_decision = 'approved' and created_workshop_id is null then
    insert into public.workshops (
      company_name, organization_number, email, phone, customer_phone,
      emergency_phone, street_address, postal_code, city, services,
      insurance_company, insurance_valid_until, active
    ) values (
      app.company_name, app.organization_number, app.email, app.phone, app.customer_phone,
      app.emergency_phone, app.street_address, app.postal_code, app.city, app.services,
      app.insurance_company, app.insurance_valid_until, false
    ) returning id into created_workshop_id;
  end if;

  update public.partner_applications
  set status = p_decision,
      admin_notes = p_admin_notes,
      reviewed_at = now(),
      workshop_id = created_workshop_id
  where id = p_application_id;
  return created_workshop_id;
end;
$$;

revoke all on function public.review_partner_application(uuid, public.application_status, text) from public;
grant execute on function public.review_partner_application(uuid, public.application_status, text) to authenticated;
