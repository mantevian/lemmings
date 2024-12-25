create or replace function card_back(tk varchar(255), card_pos integer, col color)
returns json
language plpgsql
external security definer
as $$
declare
	car card;
	did integer;
	gid integer;
	tile_count integer;
	target_token varchar;
	current_tile integer;
begin
	if not (select is_turn_of(tk)) then
		return json_object('result' VALUE 'cant_play_cards');
	end if;

	select id_game from connections where token = tk into gid;
	select id_deck from players where token = tk into did;
	select card from deck_cards where id_deck = did and pos = card_pos into car;
	if car <> 'back'::card then
		return json_object('result' VALUE 'wrong_card');
	end if;

	select get_tile_count_of_game(gid) into tile_count;
		select get_token_by_color_in_game(gid, col) into target_token;
	select tile from players where token = target_token into current_tile;

	if not (select move(target_token, current_tile - 2)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	perform card_from_hand_to_game(did, card_pos);

	return json_object('result' VALUE 'ok');
end;
$$;
