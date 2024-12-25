create or replace function card_move(tk varchar(255), card_pos integer, direction varchar(32))
returns json
language plpgsql
external security definer
as $$
declare
	car card;
	col color;
	gid integer;
	did integer;
	current_tile integer;
	target_tile integer;
	tile_count integer;
	target_token varchar;
begin
	if not (select is_turn_of(tk)) then
		return json_object('result' VALUE 'cant_play_cards');
	end if;

	select id_game from connections where token = tk into gid;
	select id_deck from players where token = tk into did;

	select card from deck_cards where id_deck = did and pos = card_pos into car;
	select card_to_color(car) into col;
	if col is null then
		return json_object('result' VALUE 'wrong_card');
	end if;

	select get_token_by_color_in_game(gid, col) into target_token;

	select tile from players where token = target_token into current_tile;
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

	if not (select move(target_token, target_tile)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	perform card_from_hand_to_game(did, card_pos);

	return json_object('result' VALUE 'ok');
end;
$$;
