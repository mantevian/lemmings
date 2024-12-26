create or replace function get_game_state(tk varchar(255), gid integer)
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	plr record;
	data json;
begin
	select get_login_from_token(tk) into lgn;
	if lgn is null then
    	return json_object('result' VALUE 'user_not_found');
	end if;

	select get_player(gid, lgn) into plr;

	if plr.id_game is null then
		return json_object('result' VALUE 'not_in_room');
	end if;

	select json_object(
		'result' VALUE 'ok',

		'id' VALUE gid,

		'is_your_turn' VALUE (select is_turn_of(gid, lgn)),

		'role' VALUE plr.color,

		'game' VALUE (select json_object(
			'time_left' VALUE extract(epoch from (g.current_turn_started + (g.turn_duration * interval '1 second') - now())),
			'current_turn_order' VALUE g.current_turn_order,
			'max_player_count' VALUE g.player_count,
			'has_hill_crashed' VALUE g.has_hill_crashed,
			'winner' VALUE (select login from players p
					where
						p.login in (select get_winner(gid))
					and
						p.id_game = gid
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
			))
			from players p
			where p.id_game = gid
		),

		'players' VALUE (select array_agg(p.login order by p.turn_order nulls last)
			from players p
			where p.id_game = gid
		)
	) into data;

	return data;
end;
$$;
