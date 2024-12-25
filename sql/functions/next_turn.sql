create or replace function next_turn(tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	gid integer;
	did integer;
	game_tord integer;
	player_tord integer;
	next_tord integer;
	pc integer;
	c integer;
	count_on_land integer;
begin
	set timezone = 'UTC';

	select id_game from connections where token = tk into gid;

	if (select get_winner(gid)) is not null then
		update games
		set finished = true
		where id_game = gid;
	end if;

	select id_deck from players where token = tk into did;
	select turn_order from players where token = tk into player_tord;
	select current_turn_order from games where id_game = gid into game_tord;

	if game_tord <> player_tord then
		return json_object('result' VALUE 'not_your_turn');
	end if;

	select count(*) from connections where id_game = gid into pc;

select (game_tord % pc + 1) into next_tord;

	update games
	set
		current_turn_order = next_tord,
		current_turn_started = now()
	where id_game = gid;

	select count(*) from deck_cards
	where id_deck = did
	into c;

	perform draw_cards(tk, 3 - c);

	return json_object('result' VALUE 'ok');
end;
$$;
