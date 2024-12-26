create or replace function start_game(tk varchar(255), gid integer)
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	conn record;
	iddeck integer;
	player_iddeck integer;
	pc integer;
	current_pc integer;
	colors color[] := array['red', 'yellow', 'green', 'blue', 'purple', 'white'];
	random_colors color[];
begin
	set timezone = 'UTC';

	select get_login_from_token(tk) into lgn;
	if lgn is null then
		return json_object('result' VALUE 'user_not_found');
	end if;

	if not exists(select * from players where login = lgn and id_game = gid) then
		return json_object('result' VALUE 'not_in_this_room');
	end if;

	select player_count from games where id_game = gid into pc;
	select count(*) from connections where id_game = gid into current_pc;
	if current_pc < pc then
		return json_object('result' VALUE 'not_enough_players');
	end if;

	insert into decks default values returning id_deck into iddeck;

	update games
	set
		id_deck = iddeck,
		current_turn_order = 1,
		current_turn_started = now()
	where id_game = gid;

	select array(select unnest(colors) order by random()) into random_colors;

	with numbered_rows as (
		select
			ctid,
			row_number() over (order by random()) as rn
		FROM 
			players
		where
			id_game = gid
	)
	update players
	set color = random_colors[numbered_rows.rn]
	from numbered_rows
	where players.ctid = numbered_rows.ctid;

	with numbered_rows as (
		select
			ctid,
			row_number() over (order by random()) as rn
		FROM 
			players
		where
			id_game = gid
	)
	update players
	set turn_order = numbered_rows.rn
	from numbered_rows
	where players.ctid = numbered_rows.ctid;

	with numbered_rows as (
		select
			ctid,
			row_number() over (order by random()) as rn
		FROM 
			players
		where
			id_game = gid
	)
	update players
	set pos = numbered_rows.rn
	from numbered_rows
	where players.ctid = numbered_rows.ctid;

	if (select color from players where id_game = gid and color = 'red') is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_red', 1);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_red', 2);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_red', 3);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_red', 4);
	end if;

	if (select color from players where id_game = gid and color = 'yellow') is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_yellow', 5);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_yellow', 6);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_yellow', 7);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_yellow', 8);
	end if;

	if (select color from players where id_game = gid and color = 'green') is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_green', 9);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_green', 10);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_green', 11);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_green', 12);
	end if;

	if (select color from players where id_game = gid and color = 'blue') is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_blue', 13);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_blue', 14);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_blue', 15);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_blue', 16);
	end if;

	if (select color from players where id_game = gid and color = 'purple') is not null then
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_purple', 17);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_purple', 18);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_purple', 19);
		insert into deck_cards (id_deck, card, pos) values (iddeck, 'move_purple', 20);
	end if;

	if (select color from players where id_game = gid and color = 'white') is not null then
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

	for pl in (select * from players where id_game = gid) loop
		insert into decks default values returning id_deck into player_iddeck;
		
		update players
		set id_deck = player_iddeck
		where
			login = pl.login
		and
			id_game = gid;
			
		perform draw_cards(gid, pl.login, 3);
	end loop;

	return json_object('result' VALUE 'ok');
end;
$$;
