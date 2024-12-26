create or replace function quit_room(tk varchar(255), gid integer)
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	plr record;
	game_tord integer;
	pc integer;
	active_count integer;
begin
	set timezone = 'UTC';

	select get_login_from_token(tk) into lgn;
	if lgn is null then
		return json_object('result' VALUE 'user_not_found');
	end if;

	select get_player(gid, lgn) into plr;

	if plr is null then
		return json_object('result' VALUE 'not_in_this_room');
	end if;

	select count(*) from players where id_game = gid into pc;

	update players
	set active = false
	where
		login = lgn
	and
		id_game = gid;

	select current_turn_order from games where id_game = gid into game_tord;

	select count(*) from players
	where
		id_game = gid
	and
		active = true
	into active_count;

	if (game_tord is not null) and active_count = 0 then
		perform stop_game(gid);
	end if;

	return json_object('result' VALUE 'ok');
end;
$$;
