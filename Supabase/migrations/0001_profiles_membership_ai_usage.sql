-- YCAppStarter V2.7 Supabase Auth/Profile baseline.
-- Run in Supabase SQL Editor after creating the project.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  avatar_url text,
  entitlement_id text,
  is_premium boolean not null default false,
  ai_daily_quota integer not null default 25,
  ai_used_today integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ai_usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  feature text not null default 'ai_proxy',
  model text,
  input_tokens integer,
  output_tokens integer,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.ai_usage_events enable row level security;

create policy "profiles select own row"
  on public.profiles for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "profiles insert own row"
  on public.profiles for insert
  to authenticated
  with check ((select auth.uid()) = id);

create policy "profiles update own row"
  on public.profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "ai usage select own rows"
  on public.ai_usage_events for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "ai usage insert own rows"
  on public.ai_usage_events for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create or replace function public.handle_new_user_profile()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile
  after insert on auth.users
  for each row execute procedure public.handle_new_user_profile();

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute procedure public.touch_updated_at();
