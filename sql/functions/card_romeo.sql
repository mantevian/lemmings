create or replace function card_romeo(tk varchar(255), card_pos integer, col1 color, col2 color, target_tile integer)
returns json
language plpgsql
external security definer
as $$
declare
	car card;
	gid integer;
	did integer;
	tile_count integer;
	target_token_1 varchar;
	target_token_2 varchar;
begin
	if not (select is_turn_of(tk)) then
		return json_object('result' VALUE 'cant_play_cards');
	end if;

	select id_game from connections where token = tk into gid;
	select id_deck from players where token = tk into did;
	select card from deck_cards where id_deck = did and pos = card_pos into car;
	if car <> 'romeo'::card then
		return json_object('result' VALUE 'wrong_card');
	end if;

	if col1 = col2 then
		return json_object('result' VALUE 'two_same_lemmings');
	end if;

	select get_tile_count_of_game(gid) into tile_count;

	select get_token_by_color_in_game(gid, col1) into target_token_1;
	select get_token_by_color_in_game(gid, col2) into target_token_2;

	if target_tile < 1 or target_tile > tile_count - 1 then
		return json_object('result' VALUE 'out_of_bounds');
	end if;

	if not (select move_separate(target_token_1, target_tile)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	if not (select move_separate(target_token_2, target_tile)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	perform card_from_hand_to_game(did, card_pos);

	return json_object('result' VALUE 'ok');
end;
$$;
