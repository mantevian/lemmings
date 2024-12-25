create or replace function card_whoosh(tk varchar(255), card_pos integer, col1 color, col2 color)
returns json
language plpgsql
external security definer
as $$
declare
	car card;
	did integer;
	gid integer;
	tile_count integer;
	target_token_1 varchar;
	target_token_2 varchar;
	target_1_tile integer;
	target_1_pos integer;
	target_2_tile integer;
	target_2_pos integer;
begin
	if not (select is_turn_of(tk)) then
		return json_object('result' VALUE 'cant_play_cards');
	end if;

	select id_game from connections where token = tk into gid;
	select id_deck from players where token = tk into did;
	select card from deck_cards where id_deck = did and pos = card_pos into car;
	if car <> 'whoosh'::card then
		return json_object('result' VALUE 'wrong_card');
	end if;

	if col1 = col2 then
		return json_object('result' VALUE 'two_same_lemmings');
	end if;

	select get_tile_count_of_game(gid) into tile_count;

	select get_token_by_color_in_game(gid, col1) into target_token_1;
	select get_token_by_color_in_game(gid, col2) into target_token_2;

	if target_token_1 is null or target_token_2 is null then
		return json_object('result' VALUE 'incorrect_color');
	end if;

	select tile
	from players
	where token = target_token_1
	into target_1_tile;

	select tile
	from players
	where token = target_token_2
	into target_2_tile;

	select pos
	from players
	where token = target_token_1
	into target_1_pos;

	select pos
	from players
	where token = target_token_2
	into target_2_pos;

	update players
	set tile = target_2_tile, pos = target_2_pos
	where token = target_token_1;

	update players
	set tile = target_1_tile, pos = target_1_pos
	where token = target_token_2;

	perform card_from_hand_to_game(did, card_pos);

	return json_object('result' VALUE 'ok');
end;
$$;
