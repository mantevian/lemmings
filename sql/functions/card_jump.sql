create or replace function card_jump(tk varchar(255), card_pos integer, col color, target_tile integer)
returns json
language plpgsql
external security definer
as $$
declare
	car card;
	gid integer;
	did integer;
	tile_count integer;
	target_token varchar;
begin
	if not (select is_turn_of(tk)) then
		return json_object('result' VALUE 'cant_play_cards');
	end if;

	select id_deck from players where token = tk into did;
	select card from deck_cards where id_deck = did and pos = card_pos into car;
	if car <> 'jump'::card then
		return json_object('result' VALUE 'wrong_card');
	end if;

	select id_game from connections where token = tk into gid;
	select get_token_by_color_in_game(gid, col) into target_token;
	select get_tile_count_of_game(gid) into tile_count;

	if target_tile < 2 or target_tile > tile_count - 1 then
		return json_object('result' VALUE 'out_of_bounds');
	end if;

	if not (select move_separate(target_token, target_tile)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	perform card_from_hand_to_game(did, card_pos);

	return json_object('result' VALUE 'ok');
end;
$$;
