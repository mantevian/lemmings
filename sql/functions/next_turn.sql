create or replace function next_turn(tk varchar(255), gid integer)
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	res boolean;
	game_tord integer;
	player_tord integer;
begin
	select get_login_from_token(tk) into lgn;

	select current_turn_order from games where id_game = gid into game_tord;
	select turn_order from get_player(gid, lgn) into player_tord;

	if game_tord <> player_tord then
		return json_object('result' VALUE 'not_your_turn');
	end if;

	select next_turn_inner(gid) into res;
	
	if res then
		return json_object('result' VALUE 'ok');
	end if;

	return json_object('result' VALUE 'cant_change_turn');
end;
$$;
