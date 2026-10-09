-- Xù Bay leaderboard: paste this whole file into Supabase > SQL Editor and run it once.
-- It is safe to run again. If you ran an earlier version of this file, running this one
-- also removes the old run-checking pieces (start_run, runs, the old submit_score).

drop function if exists public.start_run();
drop function if exists public.submit_score(uuid, text, int);
drop table    if exists public.runs;

create table if not exists public.scores (
  name       text primary key check (char_length(name) between 2 and 12),
  score      int  not null check (score >= 0),
  updated_at timestamptz not null default now()
);

alter table public.scores enable row level security;

-- Anyone can read the leaderboard. Nobody can write to the table directly;
-- scores only change through submit_score() below.
drop policy if exists "anyone can read scores" on public.scores;
create policy "anyone can read scores" on public.scores for select to anon using (true);

revoke all on public.scores from anon;
grant select on public.scores to anon;

-- The game sends the player's nickname and score here when a run ends.
-- The score is taken as sent (no cheat checks). Only the nickname length and a sane
-- score range are enforced, and a player's row is only replaced by a higher score.
create or replace function public.submit_score(p_name text, p_score int) returns void
language plpgsql security definer set search_path = public as $$
declare
  v_name text;
begin
  v_name := btrim(regexp_replace(coalesce(p_name, ''), '\s+', ' ', 'g'));
  if char_length(v_name) < 2 or char_length(v_name) > 12 then
    raise exception 'invalid name';
  end if;
  if p_score is null or p_score < 0 or p_score > 9999 then
    raise exception 'invalid score';
  end if;
  if p_score = 0 then
    return;
  end if;

  insert into scores (name, score) values (v_name, p_score)
  on conflict (name) do update set score = excluded.score, updated_at = now()
  where excluded.score > scores.score;
end $$;

revoke all on function public.submit_score(text, int) from public;
grant execute on function public.submit_score(text, int) to anon;
