create or replace function next_turn(tk varchar(255), gid integer)
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	did integer;
	game_tord integer;
	player_tord integer;
	next_tord integer;
	pc integer;
	c integer;
	count_on_land integer;
begin
	set timezone = 'UTC';

	select get_login_from_token(tk) into lgn;

	if (select get_winner(gid)) is not null then
		update games
		set finished = true
		where id_game = gid;
	end if;

	select
		id_deck, turn_order
	into
		did, player_tord
	from get_player(gid, lgn);

	select current_turn_order from games where id_game = gid into game_tord;

	if game_tord <> player_tord then
		return json_object('result' VALUE 'not_your_turn');
	end if;

	select count(*) from players where id_game = gid into pc;

	select (game_tord % pc + 1) into next_tord;

	update games
	set
		current_turn_order = next_tord,
		current_turn_started = now()
	where id_game = gid;

	select count(*) from deck_cards
	where id_deck = did
	into c;

	perform draw_cards(gid, lgn, 3 - c);

	return json_object('result' VALUE 'ok');
end;
$$;
