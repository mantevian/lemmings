create or replace function get_game_state(tk varchar(255), gid integer)
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	plr record;
	data json;
	time_left integer;
	current_turn_player varchar;
begin
	select get_login_from_token(tk) into lgn;
	if lgn is null then
    	return json_object('result' VALUE 'user_not_found');
	end if;

	select * from get_player(gid, lgn) into plr;

	if plr.id_game is null then
		return json_object('result' VALUE 'not_in_room');
	end if;

	select
		ceil(extract(epoch from (g.current_turn_started + (g.turn_duration * interval '1 second') - now())))
	into time_left
	from games g
	where id_game = gid;

	if time_left <= 0 then
		perform next_turn_inner(gid);
	end if;

	select login from players where id_game = gid and turn_order = (select current_turn_order from games where id_game = gid) into current_turn_player;
	if not exists(select * from connections where login = current_turn_player and id_game = gid) then
		perform next_turn_inner(gid);
	end if;

	select json_object(
		'result' VALUE 'ok',

		'id' VALUE gid,

		'is_your_turn' VALUE (select is_turn_of(gid, lgn)),

		'role' VALUE plr.color,

		'game' VALUE (select json_object(
			'time_left' VALUE time_left,
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
				where id_deck = plr.id_deck
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

		'players' VALUE (select json_agg(json_object(
				'login' VALUE login,
				'active' VALUE exists (select * from connections where id_game = gid and login = p.login)
			) order by p.turn_order)
			from players p
			where p.id_game = gid
		)
	) into data;

	return data;
end;
$$;
