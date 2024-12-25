create or replace function card_crash(tk varchar(255), card_pos integer)
returns json
language plpgsql
external security definer
as $$
declare
	car card;
	did integer;
	gid integer;
	tile_count integer;
	count_lemmings_in_water integer;
begin
	if not (select is_turn_of(tk)) then
		return json_object('result' VALUE 'cant_play_cards');
	end if;

	select id_game from connections where token = tk into gid;
	select id_deck from players where token = tk into did;
	select card from deck_cards where id_deck = did and pos = card_pos into car;
	if car <> 'crash'::card then
		return json_object('result' VALUE 'wrong_card');
	end if;

	select get_tile_count_of_game(gid) into tile_count;
	if tile_count = 5 then
		return json_object('result' VALUE 'already_used_this_card');
	end if;

	select count(*) from players
	where
		token in (select token from connections where id_game = gid)
	and
		tile = 6
	into count_lemmings_in_water;

	update players
	set tile = 5, pos = pos + count_lemmings_in_water
	where
		token in (select token from connections where id_game = gid)
	and
		tile = 6;

	update games
	set has_hill_crashed = true
	where id_game = gid;

	delete from deck_cards
	where
		id_deck = did
	and
		pos = card_pos;
	
	return json_object('result' VALUE 'ok');
end;
$$;
