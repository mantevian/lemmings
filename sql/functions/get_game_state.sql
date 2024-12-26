create or replace function get_game_state(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	gid integer;
	did integer;
	data json;
begin
	select get_login_from_token(tk) into lgn;
	if lgn is null then
    		return json_object('result' VALUE 'user_not_found');
	end if;

	if not exists (select * from connections where token = tk and id_game is not null) then
		return json_object('result' VALUE 'not_in_room');
	end if;

	select id_game from connections where token = tk into gid;
	select id_deck from players where token = tk into did;

	select json_object(
		'result' VALUE 'ok',

		'is_your_turn' VALUE (select is_turn_of(tk)),

		'role' VALUE (select color from players where token = tk),

		'game' VALUE (select json_object(
			'time_left' VALUE extract(epoch from (g.current_turn_started + (g.turn_duration * interval '1 second') - now())),
			'current_turn_order' VALUE g.current_turn_order,
			'max_player_count' VALUE g.player_count,
			'has_hill_crashed' VALUE g.has_hill_crashed,
			'winner' VALUE (select login from connections
				where
					token in (select get_winner(gid))
				and
					g.finished = true
				)
			) from games g
			where id_game = gid
		),

		'hand' VALUE (select json_agg(card) as cards from (
				select card from deck_cards
				where id_deck = did
				order by pos
			)
		),

		'lemmings' VALUE (select json_agg(json_object(
			'color' VALUE p.color,
			'tile' VALUE p.tile,
			'pos' VALUE p.pos
			)) from players p
				where p.token in (select token from connections where id_game = gid)),

		'players' VALUE (select array_agg(c.login order by p.turn_order)
			from players p
			join connections c on p.token = c.token
			where c.id_game = gid
		),

		'logins' VALUE (select array_agg(c.login)
			from connections c
			where c.id_game = gid
		)
	) into data;

	return data;
end;
$$;
