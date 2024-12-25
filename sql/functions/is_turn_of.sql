create or replace function is_turn_of(tk varchar)
returns bool
language plpgsql
external security invoker
as $$
declare
	gid integer;
	did integer;
	player_tord integer;
	game_tord integer;
	lgn varchar;
	dur integer;
	started timestamp;
begin
	set timezone = 'UTC';

	select get_login_from_token(tk) into lgn;
	if lgn is null then
		return false;
	end if;

	if not exists (select * from connections where token = tk and id_game is not null) then
		return false;
	end if;

	select id_game from connections where token = tk into gid;
	select id_deck from players where token = tk into did;

	select turn_order from players where token = tk into player_tord;
	select current_turn_order from games where id_game = gid into game_tord;
	select current_turn_started from games where id_game = gid into started;
	select turn_duration from games where id_game = gid into dur;

	if (player_tord is null) or (game_tord is null) then
		return false;
	end if;

	if now() > started + (dur * interval '1 second') then
		perform next_turn(tk);
	end if;

	if player_tord <> game_tord then
		return false;
	end if;

	return true;
end;
$$;
