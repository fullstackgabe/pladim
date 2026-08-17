-- =====================================================================
-- Pladim — full database bootstrap (schema + Row Level Security)
-- =====================================================================
-- Idempotent: safe to run on an existing project (existing tables are
-- left untouched via "if not exists") AND as a from-zero setup on a
-- fresh Supabase project.
--
-- Column types follow how the app actually writes data (see
-- src/services/storage.ts):
--   * ids of records are short strings -> text
--   * the owner key is the Supabase auth user id -> uuid
--   * timestamps are stored as epoch millis (Date.now()) -> bigint
--   * day/date lists are arrays -> integer[] / text[]
--
-- RLS: the publishable/anon key is shipped in the frontend bundle, so it
-- is public. The only thing protecting user data is RLS. Every table is
-- owner-scoped via auth.uid(). Casts to text keep the policies valid
-- regardless of the underlying column type.
-- =====================================================================

-- ============ profiles (owner column: id) ============
create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  email      text,
  name       text,
  avatar     text,
  created_at bigint
);

-- ============ tasks (owner column: user_id) ============
create table if not exists public.tasks (
  id              text primary key,
  user_id         uuid not null references auth.users (id) on delete cascade,
  email           text,
  title           text not null,
  points          integer not null default 0,
  scheduled_days  integer[] not null default '{}',
  completed_dates text[]    not null default '{}',
  created_at      bigint
);
create index if not exists tasks_user_id_idx on public.tasks (user_id);

-- ============ rewards (owner column: user_id) ============
create table if not exists public.rewards (
  id         text primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  email      text,
  title      text not null,
  points     integer not null default 0,
  created_at bigint
);
create index if not exists rewards_user_id_idx on public.rewards (user_id);

-- ============ reward_history (owner column: user_id) ============
create table if not exists public.reward_history (
  id           text primary key,
  user_id      uuid not null references auth.users (id) on delete cascade,
  email        text,
  reward_id    text,
  reward_title text,
  cost         integer not null default 0,
  purchased_at bigint
);
create index if not exists reward_history_user_id_idx on public.reward_history (user_id);

-- ============ task_history (owner column: user_id) ============
create table if not exists public.task_history (
  id             text primary key,
  user_id        uuid not null references auth.users (id) on delete cascade,
  email          text,
  task_id        text,
  task_title     text,
  points         integer not null default 0,
  completed_date text,
  completed_at   bigint
);
create index if not exists task_history_user_id_idx on public.task_history (user_id);

-- =====================================================================
-- Row Level Security + owner-only policies
-- =====================================================================

-- ---------- profiles (owner column: id) ----------
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
drop policy if exists "profiles_delete_own" on public.profiles;

create policy "profiles_select_own" on public.profiles
  for select to authenticated
  using ((select auth.uid())::text = id::text);

create policy "profiles_insert_own" on public.profiles
  for insert to authenticated
  with check ((select auth.uid())::text = id::text);

create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using ((select auth.uid())::text = id::text)
  with check ((select auth.uid())::text = id::text);

create policy "profiles_delete_own" on public.profiles
  for delete to authenticated
  using ((select auth.uid())::text = id::text);

-- ---------- tasks (owner column: user_id) ----------
alter table public.tasks enable row level security;

drop policy if exists "tasks_select_own" on public.tasks;
drop policy if exists "tasks_insert_own" on public.tasks;
drop policy if exists "tasks_update_own" on public.tasks;
drop policy if exists "tasks_delete_own" on public.tasks;

create policy "tasks_select_own" on public.tasks
  for select to authenticated
  using ((select auth.uid())::text = user_id::text);

create policy "tasks_insert_own" on public.tasks
  for insert to authenticated
  with check ((select auth.uid())::text = user_id::text);

create policy "tasks_update_own" on public.tasks
  for update to authenticated
  using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);

create policy "tasks_delete_own" on public.tasks
  for delete to authenticated
  using ((select auth.uid())::text = user_id::text);

-- ---------- rewards (owner column: user_id) ----------
alter table public.rewards enable row level security;

drop policy if exists "rewards_select_own" on public.rewards;
drop policy if exists "rewards_insert_own" on public.rewards;
drop policy if exists "rewards_update_own" on public.rewards;
drop policy if exists "rewards_delete_own" on public.rewards;

create policy "rewards_select_own" on public.rewards
  for select to authenticated
  using ((select auth.uid())::text = user_id::text);

create policy "rewards_insert_own" on public.rewards
  for insert to authenticated
  with check ((select auth.uid())::text = user_id::text);

create policy "rewards_update_own" on public.rewards
  for update to authenticated
  using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);

create policy "rewards_delete_own" on public.rewards
  for delete to authenticated
  using ((select auth.uid())::text = user_id::text);

-- ---------- reward_history (owner column: user_id) ----------
alter table public.reward_history enable row level security;

drop policy if exists "reward_history_select_own" on public.reward_history;
drop policy if exists "reward_history_insert_own" on public.reward_history;
drop policy if exists "reward_history_update_own" on public.reward_history;
drop policy if exists "reward_history_delete_own" on public.reward_history;

create policy "reward_history_select_own" on public.reward_history
  for select to authenticated
  using ((select auth.uid())::text = user_id::text);

create policy "reward_history_insert_own" on public.reward_history
  for insert to authenticated
  with check ((select auth.uid())::text = user_id::text);

create policy "reward_history_update_own" on public.reward_history
  for update to authenticated
  using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);

create policy "reward_history_delete_own" on public.reward_history
  for delete to authenticated
  using ((select auth.uid())::text = user_id::text);

-- ---------- task_history (owner column: user_id) ----------
alter table public.task_history enable row level security;

drop policy if exists "task_history_select_own" on public.task_history;
drop policy if exists "task_history_insert_own" on public.task_history;
drop policy if exists "task_history_update_own" on public.task_history;
drop policy if exists "task_history_delete_own" on public.task_history;

create policy "task_history_select_own" on public.task_history
  for select to authenticated
  using ((select auth.uid())::text = user_id::text);

create policy "task_history_insert_own" on public.task_history
  for insert to authenticated
  with check ((select auth.uid())::text = user_id::text);

create policy "task_history_update_own" on public.task_history
  for update to authenticated
  using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);

create policy "task_history_delete_own" on public.task_history
  for delete to authenticated
  using ((select auth.uid())::text = user_id::text);
