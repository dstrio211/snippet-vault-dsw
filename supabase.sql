create table if not exists public.snippets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  content text not null check (char_length(content) between 1 and 20000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists snippets_user_id_idx on public.snippets (user_id, created_at desc);
alter table public.snippets enable row level security;
create policy "Users can view their own snippets" on public.snippets for select to authenticated using ((select auth.uid())=user_id);
create policy "Users can insert their own snippets" on public.snippets for insert to authenticated with check ((select auth.uid())=user_id);
create policy "Users can update their own snippets" on public.snippets for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "Users can delete their own snippets" on public.snippets for delete to authenticated using ((select auth.uid())=user_id);
