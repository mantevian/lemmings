create or replace function card_crash(tk varchar(255), gid integer)
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	card_pos integer;
	did integer;
	gid integer;
	tile_count integer;
	count_lemmings_in_water integer;
begin
	if not (select check_card(tk, gid, 'crash')) then
		return json_object('result' VALUE 'cant_play');
	end if;

	select get_tile_count_of_game(gid) into tile_count;
	if tile_count = 5 then
		return json_object('result' VALUE 'already_used_this_card');
	end if;

	select count(*) from players
	where
		id_game = gid
	and
		tile = 6
	into count_lemmings_in_water;

	update players
	set
		tile = 5,
		pos = pos + count_lemmings_in_water
	where
		id_game = gid
	and
		tile = 6;

	update games
	set has_hill_crashed = true
	where id_game = gid;

	delete from deck_cards
	where
		id_deck in (select id_deck from players where id_game = gid)
	and
		card = 'crash';

	delete from deck_cards
	where
		id_deck = (select id_deck from games where id_game = gid)
	and
		card = 'crash';
	
	return json_object('result' VALUE 'ok');
end;
$$;
