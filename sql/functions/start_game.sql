create or replace function start_game(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	conn record;
	iddeck integer;
	player_iddeck integer;
	gid integer;
	pc integer;
	current_pc integer;
begin
set timezone = 'UTC';

	select get_login_from_token(tk) into lgn;
	if lgn is null then
    		return json_object('result' VALUE 'user_not_found');
	end if;

	if not exists(select * from connections where token = tk and id_game is not null) then
		return json_object('result' VALUE 'not_in_room');
	end if;

	select id_game from connections where token = tk into gid;

	select player_count from games where id_game = gid into pc;
	select count(*) from connections where id_game = gid into current_pc;
	if current_pc < pc then
		return json_object('result' VALUE 'not_enough_players');
	end if;

	insert into decks default values returning id_deck into iddeck;

	select id_game from connections where token = tk into gid;

	update games
	set
	id_deck = iddeck,
	current_turn_order = 1,
	current_turn_started = now()
	where id_game = gid;

	with random_turn_order as (
		select
			token,
			row_number() over (order by random()) as turn_order
	from connections
	where id_game = gid
	),
	random_color as (
		select
			token,
			row_number() over (order by random()) as color
	from connections
	where id_game = gid
	),
	color_mapping as (
		select token, color,
			case
				when color = 1 then 'red'::color
				when color = 2 then 'yellow'::color
				when color = 3 then 'green'::color
				when color = 4 then 'blue'::color
				when color = 5 then 'purple'::color
				when color = 6 then 'white'::color
			end as color_enum
		from random_color
	),
	random_pos as (
		select
			token,
			row_number() over (order by random()) as pos
		from connections
	where id_game = gid
	)
	insert into players (token, id_deck, color, turn_order, tile, pos)
	select
		t.token,
		null,
		cm.color_enum,
		t.turn_order,
		1,
		p.pos
	from random_turn_order t
	join color_mapping cm on t.token = cm.token
	join random_pos p on t.token = p.token;

	if (select color from players where
		token in (select token from connections where id_game = gid)
		and color = 'red'::color
	) is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_red', 1);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_red', 2);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_red', 3);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_red', 4);
	end if;

	if (select color from players where
		token in (select token from connections where id_game = gid)
		and color = 'yellow'::color
	) is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_yellow', 5);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_yellow', 6);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_yellow', 7);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_yellow', 8);
	end if;

	if (select color from players where
		token in (select token from connections where id_game = gid)
		and color = 'green'::color
	) is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_green', 9);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_green', 10);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_green', 11);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_green', 12);
	end if;

	if (select color from players where
		token in (select token from connections where id_game = gid)
		and color = 'blue'::color
	) is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_blue', 13);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_blue', 14);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_blue', 15);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_blue', 16);
	end if;

	if (select color from players where
		token in (select token from connections where id_game = gid)
		and color = 'purple'::color
	) is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_purple', 17);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_purple', 18);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_purple', 19);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_purple', 20);
	end if;

	if (select color from players where
		token in (select token from connections where id_game = gid)
		and color = 'white'::color
	) is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_white', 21);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_white', 22);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_white', 23);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_white', 24);
	end if;

	insert into deck_cards (id_deck, card, pos) values (iddeck, 'jump', 25);
	insert into deck_cards (id_deck, card, pos) values (iddeck, 'jump', 26);

	insert into deck_cards (id_deck, card, pos) values (iddeck, 'romeo', 27);
	insert into deck_cards (id_deck, card, pos) values (iddeck, 'romeo', 28);

	insert into deck_cards (id_deck, card, pos) values (iddeck, 'whoosh', 29);
	insert into deck_cards (id_deck, card, pos) values (iddeck, 'whoosh', 30);

	insert into deck_cards (id_deck, card, pos) values (iddeck, 'back', 31);
	insert into deck_cards (id_deck, card, pos) values (iddeck, 'back', 32);

	insert into deck_cards (id_deck, card, pos) values (iddeck, 'magic', 33);
	insert into deck_cards (id_deck, card, pos) values (iddeck, 'magic', 34);

	insert into deck_cards (id_deck, card, pos) values (iddeck, 'crash', 35);

	for conn in (select token from connections where id_game = gid) loop
		insert into decks default values returning id_deck into player_iddeck;
		
		update players
		set id_deck = player_iddeck
		where token = conn.token;
			
		perform draw_cards(conn.token, 3);
	end loop;

	return json_object('result' VALUE 'ok');
end;
$$;
