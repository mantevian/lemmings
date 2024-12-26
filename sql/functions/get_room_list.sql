create or replace function get_room_list(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
begin
	select get_login_from_token(tk) into lgn;

	if lgn is null then
		return json_object('result', 'user_not_found');
	end if;
	
	return json_object(
		'result' VALUE 'ok',

		'open_rooms' VALUE (select json_agg(row_to_json(game))
			from (
				select g.turn_duration, g.player_count, g.join_code, count(p.login) as current_player_count
				from games g
				left join players p on g.id_game = p.id_game
				where g.current_turn_started is null
				group by g.id_game
			) game
		),

		'my_rooms' VALUE (select json_agg(row_to_json(game))
			from (
				select g.turn_duration, g.player_count, g.join_code, count(p.login) as current_player_count
				from games g
				left join players p on g.id_game = p.id_game
				where g.id_game in (select id_game from players where login = lgn)
				group by g.id_game
			) game
		)
	);
end;
$$;
