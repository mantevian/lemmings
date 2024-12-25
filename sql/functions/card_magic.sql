create or replace function card_magic(tk varchar(255), card_pos integer)
returns json
language plpgsql
external security definer
as $$
declare
	car card;
	did integer;
	gid integer;
	tile_count integer;
begin
	if not (select is_turn_of(tk)) then
		return json_object('result' VALUE 'cant_play_cards');
	end if;

	select id_game from connections where token = tk into gid;
	select id_deck from players where token = tk into did;
	select card from deck_cards where id_deck = did and pos = card_pos into car;
	if car <> 'magic'::card then
		return json_object('result' VALUE 'wrong_card');
	end if;

	select get_tile_count_of_game(gid) into tile_count;

	update players
	set tile = least(tile + 1, tile_count)
	where token in (select token from connections where id_game = gid);

	perform card_from_hand_to_game(did, card_pos);

	return json_object('result' VALUE 'ok');
end;
$$;
