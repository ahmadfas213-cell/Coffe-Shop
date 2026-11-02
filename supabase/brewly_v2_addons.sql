-- BREWLY V2 add-on storage for the 20 operations modules.
-- Safe to run after the original supabase/schema.sql. Does not alter existing tables.

create table if not exists public.workspace_records (
  id uuid primary key default gen_random_uuid(),
  module_key text not null,
  title text not null,
  status text not null default 'open',
  amount numeric(12,2),
  payload jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists workspace_records_module_created_idx
  on public.workspace_records(module_key, created_at desc);

alter table public.workspace_records enable row level security;

drop policy if exists "Authenticated users can read workspace records" on public.workspace_records;
create policy "Authenticated users can read workspace records"
on public.workspace_records for select to authenticated
using (true);

drop policy if exists "Authenticated users can create workspace records" on public.workspace_records;
create policy "Authenticated users can create workspace records"
on public.workspace_records for insert to authenticated
with check (true);

drop policy if exists "Authenticated users can update workspace records" on public.workspace_records;
create policy "Authenticated users can update workspace records"
on public.workspace_records for update to authenticated
using (true) with check (true);

drop policy if exists "Authenticated users can delete workspace records" on public.workspace_records;
create policy "Authenticated users can delete workspace records"
on public.workspace_records for delete to authenticated
using (true);

create or replace function public.set_workspace_record_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists workspace_records_updated_at on public.workspace_records;
create trigger workspace_records_updated_at
before update on public.workspace_records
for each row execute procedure public.set_workspace_record_updated_at();
