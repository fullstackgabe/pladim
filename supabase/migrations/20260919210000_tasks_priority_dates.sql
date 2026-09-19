alter table public.tasks add column if not exists priority_dates text[] not null default '{}';
