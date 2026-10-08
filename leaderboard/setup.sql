-- Chim Bay leaderboard: paste this whole file into Supabase > SQL Editor and run it once.
-- It is safe to run again; it only (re)creates the objects below.

create table if not exists public.scores (
  name       text primary key check (char_length(name) between 2 and 12),
  score      int  not null check (score >= 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.runs (
  id         uuid primary key default gen_random_uuid(),
  started_at timestamptz not null default now(),
  used       boolean not null default false
);

alter table public.scores enable row level security;
alter table public.runs   enable row level security;

-- Anyone can read the leaderboard. Nobody can write to either table directly:
-- scores only change through submit_score(), and runs are private.
drop policy if exists "anyone can read scores" on public.scores;
create policy "anyone can read scores" on public.scores for select to anon using (true);

revoke all on public.scores from anon;
revoke all on public.runs   from anon;
grant select on public.scores to anon;

-- Called when a run starts. Returns a one-time run id; the server remembers when it was issued.
create or replace function public.start_run() returns uuid
language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  delete from runs where started_at < now() - interval '1 day';
  insert into runs default values returning id into v_id;
  return v_id;
end $$;

-- Called when a run ends. Accepts the score only if that many points could have been
-- reached in the time since start_run(). A run id works once.
-- Timing (matches the game): first point ~2.56 s after the first flap, then one point
-- every ~1.45 s. 1 s of slack covers network delay. If you change the game's speed or
-- pipe spacing, update the two numbers below.
create or replace function public.submit_score(p_run uuid, p_name text, p_score int) returns void
language plpgsql security definer set search_path = public as $$
declare
  v_started timestamptz;
  v_elapsed numeric;
  v_max     int;
  v_name    text;
begin
  v_name := btrim(regexp_replace(coalesce(p_name, ''), '\s+', ' ', 'g'));
  if char_length(v_name) < 2 or char_length(v_name) > 12 then
    raise exception 'invalid name';
  end if;
  if p_score is null or p_score < 0 or p_score > 1000 then
    raise exception 'invalid score';
  end if;

  update runs set used = true where id = p_run and used = false returning started_at into v_started;
  if v_started is null then
    raise exception 'invalid run';
  end if;

  v_elapsed := extract(epoch from (now() - v_started));
  if v_elapsed + 1.0 < 2.56 then
    v_max := 0;
  else
    v_max := floor((v_elapsed + 1.0 - 2.56) / 1.449)::int + 1;
  end if;
  if p_score > v_max then
    raise exception 'score not plausible';
  end if;
  if p_score = 0 then
    return;
  end if;

  insert into scores (name, score) values (v_name, p_score)
  on conflict (name) do update set score = excluded.score, updated_at = now()
  where excluded.score > scores.score;
end $$;

revoke all on function public.start_run() from public;
revoke all on function public.submit_score(uuid, text, int) from public;
grant execute on function public.start_run() to anon;
grant execute on function public.submit_score(uuid, text, int) to anon;
