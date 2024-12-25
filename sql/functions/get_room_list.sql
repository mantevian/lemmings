create or replace function get_room_list(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
begin
	if (select get_login_from_token(tk)) is null then
return json_object('result', 'user_not_found');
	end if;
	
	return json_object('rooms' VALUE
    	(select json_agg(row_to_json(game))
			from (
				select g.turn_duration, g.player_count, g.join_code, count(c.token) as current_player_count
				from games g
				left join connections c on g.id_game = c.id_game
				where g.current_turn_started is null
				group by g.id_game
			) game)
	);
end;
$$;
