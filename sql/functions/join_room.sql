create or replace function join_room(jc varchar, tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	clr color;
	gid integer;
	current_pc integer;
	pc integer;
begin
	select get_login_from_token(tk) into lgn;
	if lgn is null then
		return json_object('result' VALUE 'user_not_found');
	end if;

	select id_game from games where games.join_code = jc into gid;

	if gid is null then
		return json_object('result' VALUE 'room_not_found');
	end if;

	update connections
	set id_game = gid
	where token = tk;

	if not exists (select * from players where login = lgn and id_game = gid) then
		if (select current_turn_order from games where id_game = gid) is not null then
			return json_object('result' VALUE 'this_room_is_already_playing');
		end if;

		select count(*) from players where id_game = gid into current_pc;
		select player_count from games where id_game = gid into pc;
		if current_pc = pc then
			return json_object('result' VALUE 'room_is_full');
		end if;

		insert into players (login, id_game) values (lgn, gid);
	end if;

	if (select current_turn_order from games where id_game = gid) is null then
		select count(*) from players where id_game = gid into current_pc;
		select player_count from games where id_game = gid into pc;
		if current_pc = pc then
			perform start_game(gid);
		end if;
	end if;

	return json_object(
		'result' VALUE 'ok',
		'id' VALUE gid,
		'players' VALUE (select json_agg(json_object('name' VALUE p.login)) from players p where id_game = gid),
		'max_player_count' VALUE (select player_count from games where id_game = gid)
	);
end;
$$;
