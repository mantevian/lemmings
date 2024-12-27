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
begin
	set timezone = 'UTC';

	select get_login_from_token(tk) into lgn;
	if lgn is null then
		return json_object('result' VALUE 'user_not_found');
	end if;

	select * from get_player(gid, lgn) into plr;

	if plr is null then
		return json_object('result' VALUE 'not_in_this_room');
	end if;

	select count(*) from players where id_game = gid into pc;

	select current_turn_order from games where id_game = gid into game_tord;

	update connections
	set id_game = null
	where token = tk;

	if game_tord is null then
		delete from players
		where
			login = lgn
		and
			id_game = gid;
	else
		if not exists(
			select * from connections
			where
				login in (select login from players where id_game = gid)
			and
				id_game = gid
		) then
			perform stop_game(gid);
		end if;
	end if;

	return json_object('result' VALUE 'ok');
end;
$$;
