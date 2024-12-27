create or replace function is_turn_of(gid integer, lgn varchar)
returns bool
language plpgsql
external security invoker
as $$
declare
	did integer;
	player_tord integer;
	game_tord integer;
	dur integer;
	st timestamp;
begin
	set timezone = 'UTC';

	select
		id_deck, turn_order
	into
		did, player_tord
	from players
	where
		id_game = gid
	and
		login = lgn;

	select
		current_turn_order, current_turn_started, turn_duration
	into
		game_tord, st, dur
	from games
	where id_game = gid;

	if (player_tord is null) or (game_tord is null) then
		return false;
	end if;

	if now() > st + (dur * interval '1 second') then
		perform next_turn_inner(gid);
	end if;

	if player_tord <> game_tord then
		return false;
	end if;

	return true;
end;
$$;
