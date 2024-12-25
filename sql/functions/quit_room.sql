create or replace function quit_room(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	gid integer;
	player_tord integer;
	game_tord integer;
	pc integer;
begin
	set timezone = 'UTC';

	select get_login_from_token(tk) into lgn;
	if lgn is null then
		return json_object('result' VALUE 'user_not_found');
	end if;

	if not exists (select * from connections where token = tk and id_game is not null) then
		return json_object('result' VALUE 'not_in_room');
	end if;

	select id_game from connections where token = tk into gid;

	select turn_order from players where token = tk into player_tord;
	select current_turn_order from games where id_game = gid into game_tord;
	select count(*) from connections where id_game = gid into pc;

	if (pc > 1) and (player_tord is not null) and (game_tord is not null) and (player_tord = game_tord) then
		update games
		set
			current_turn_order = (current_turn_order - 1) % (pc - 1) + 1,
			current_turn_started = now()
		where id_game = gid;
	end if;

	delete from players where token = tk;

	if player_tord is not null then
	update players
	set turn_order = turn_order - 1
	where turn_order > player_tord;
	end if;

	update connections set id_game = null where token = tk;

	if (game_tord is not null) and (select count(*) from connections where id_game = gid) = 0 then
		perform stop_game(gid);
	end if;

	return json_object('result' VALUE 'ok');
end;
$$;
