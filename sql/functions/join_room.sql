create or replace function join_room(jc varchar, tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	clr color;
	gid integer;
	tord integer;
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

	if exists (select * from connections where connections.login = lgn and connections.id_game = gid) then
		return json_object('result' VALUE 'already_in_room');
	end if;

	if exists (select * from connections where connections.token = tk and connections.id_game is not null) then
		return json_object('result' VALUE 'already_in_room');
	end if;

	if (select current_turn_order from games where id_game = gid) is not null then
		return json_object('result' VALUE 'this_room_is_already_playing');
	end if;

	select count(*) from connections where id_game = gid into current_pc;
	select player_count from games where id_game = gid into pc;
	if current_pc >= pc then
		return json_object('result' VALUE 'room_is_full');
	end if;

	update connections set id_game = gid where token = tk;

	return json_object(
		'result' VALUE 'ok',
		'players' VALUE (select json_agg(json_object('name' VALUE c.login)) from connections c where id_game = gid),
		'max_player_count' VALUE (select player_count from games where id_game = gid)
	);
end;
$$;
