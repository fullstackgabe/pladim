-- =====================================================================
-- Pladim — recreate everything from scratch (DESTRUCTIVE)
-- =====================================================================
-- Drops all user tables (cascade also removes their RLS policies and
-- indexes) and recreates them with the canonical schema + RLS.
-- Running this WIPES all data in these tables.
-- =====================================================================

drop table if exists public.task_history   cascade;
drop table if exists public.reward_history cascade;
drop table if exists public.rewards        cascade;
drop table if exists public.tasks          cascade;
drop table if exists public.profiles       cascade;

-- ============ profiles (owner column: id) ============
create table public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  email      text,
  name       text,
  avatar     text,
  created_at bigint
);

-- ============ tasks (owner column: user_id) ============
create table public.tasks (
  id              text primary key,
  user_id         uuid not null references auth.users (id) on delete cascade,
  email           text,
  title           text not null,
  points          integer not null default 0,
  scheduled_days  integer[] not null default '{}',
  completed_dates text[]    not null default '{}',
  created_at      bigint
);
create index tasks_user_id_idx on public.tasks (user_id);

-- ============ rewards (owner column: user_id) ============
create table public.rewards (
  id         text primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  email      text,
  title      text not null,
  points     integer not null default 0,
  created_at bigint
);
create index rewards_user_id_idx on public.rewards (user_id);

-- ============ reward_history (owner column: user_id) ============
create table public.reward_history (
  id           text primary key,
  user_id      uuid not null references auth.users (id) on delete cascade,
  email        text,
  reward_id    text,
  reward_title text,
  cost         integer not null default 0,
  purchased_at bigint
);
create index reward_history_user_id_idx on public.reward_history (user_id);

-- ============ task_history (owner column: user_id) ============
create table public.task_history (
  id             text primary key,
  user_id        uuid not null references auth.users (id) on delete cascade,
  email          text,
  task_id        text,
  task_title     text,
  points         integer not null default 0,
  completed_date text,
  completed_at   bigint
);
create index task_history_user_id_idx on public.task_history (user_id);

-- =====================================================================
-- Row Level Security + owner-only policies
-- =====================================================================

alter table public.profiles enable row level security;
create policy "profiles_select_own" on public.profiles
  for select to authenticated using ((select auth.uid())::text = id::text);
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated with check ((select auth.uid())::text = id::text);
create policy "profiles_update_own" on public.profiles
  for update to authenticated using ((select auth.uid())::text = id::text)
  with check ((select auth.uid())::text = id::text);
create policy "profiles_delete_own" on public.profiles
  for delete to authenticated using ((select auth.uid())::text = id::text);

alter table public.tasks enable row level security;
create policy "tasks_select_own" on public.tasks
  for select to authenticated using ((select auth.uid())::text = user_id::text);
create policy "tasks_insert_own" on public.tasks
  for insert to authenticated with check ((select auth.uid())::text = user_id::text);
create policy "tasks_update_own" on public.tasks
  for update to authenticated using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);
create policy "tasks_delete_own" on public.tasks
  for delete to authenticated using ((select auth.uid())::text = user_id::text);

alter table public.rewards enable row level security;
create policy "rewards_select_own" on public.rewards
  for select to authenticated using ((select auth.uid())::text = user_id::text);
create policy "rewards_insert_own" on public.rewards
  for insert to authenticated with check ((select auth.uid())::text = user_id::text);
create policy "rewards_update_own" on public.rewards
  for update to authenticated using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);
create policy "rewards_delete_own" on public.rewards
  for delete to authenticated using ((select auth.uid())::text = user_id::text);

alter table public.reward_history enable row level security;
create policy "reward_history_select_own" on public.reward_history
  for select to authenticated using ((select auth.uid())::text = user_id::text);
create policy "reward_history_insert_own" on public.reward_history
  for insert to authenticated with check ((select auth.uid())::text = user_id::text);
create policy "reward_history_update_own" on public.reward_history
  for update to authenticated using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);
create policy "reward_history_delete_own" on public.reward_history
  for delete to authenticated using ((select auth.uid())::text = user_id::text);

alter table public.task_history enable row level security;
create policy "task_history_select_own" on public.task_history
  for select to authenticated using ((select auth.uid())::text = user_id::text);
create policy "task_history_insert_own" on public.task_history
  for insert to authenticated with check ((select auth.uid())::text = user_id::text);
create policy "task_history_update_own" on public.task_history
  for update to authenticated using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);
create policy "task_history_delete_own" on public.task_history
  for delete to authenticated using ((select auth.uid())::text = user_id::text);
