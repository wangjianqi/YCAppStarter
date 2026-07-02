-- YCAppStarter V2.8 Account Center / Privacy Requests / Push Devices.
-- Run after 0001_profiles_membership_ai_usage.sql.

create table if not exists public.privacy_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  request_type text not null check (request_type in ('data_export', 'delete_account')),
  status text not null default 'pending' check (status in ('pending', 'processing', 'completed', 'rejected')),
  reason text,
  admin_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.push_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  platform text not null default 'ios',
  apns_token_hash text,
  fcm_token_hash text,
  app_build text,
  app_version text,
  locale text,
  timezone text,
  marketing_opt_in boolean not null default false,
  transactional_opt_in boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now()
);

alter table public.privacy_requests enable row level security;
alter table public.push_devices enable row level security;

create policy "privacy requests select own rows"
  on public.privacy_requests for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "privacy requests insert own rows"
  on public.privacy_requests for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "push devices select own rows"
  on public.push_devices for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "push devices insert own rows"
  on public.push_devices for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "push devices update own rows"
  on public.push_devices for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop trigger if exists privacy_requests_touch_updated_at on public.privacy_requests;
create trigger privacy_requests_touch_updated_at
  before update on public.privacy_requests
  for each row execute procedure public.touch_updated_at();

drop trigger if exists push_devices_touch_updated_at on public.push_devices;
create trigger push_devices_touch_updated_at
  before update on public.push_devices
  for each row execute procedure public.touch_updated_at();
