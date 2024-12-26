create or replace function card_move(tk varchar(255), gid integer, col color, direction varchar(32))
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	p integer;
	did integer;
	current_tile integer;
	target_tile integer;
	tile_count integer;
	c card;
begin
	select get_login_from_token(tk) into lgn;

	if not (select is_turn_of(gid, lgn)) then
		return json_object('result' VALUE 'cant_play_cards');
	end if;

	select id_deck from get_player(gid, lgn) into did;

	select color_to_card(col) into c;
	
	select pos
	from deck_cards
	where
		id_deck = did
	and
		card = c
	limit 1
	into p;

	if p is null then
		return json_object('result' VALUE 'wrong_card');
	end if;

	select tile from get_player_by_color(gid, col) into current_tile;
	select get_tile_count_of_game(gid) into tile_count;

	if direction <> 'right' and direction <> 'left' then	
		return json_object('result' VALUE 'invalid_direction');
	end if;

	if direction = 'left' then
		select current_tile - 1 into target_tile;
	end if;

	if direction = 'right' then
		select current_tile + 1 into target_tile;
	end if;

	if not (select move(gid, col, target_tile)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	perform card_from_hand_to_game(tk, gid, c);

	return json_object('result' VALUE 'ok');
end;
$$;
