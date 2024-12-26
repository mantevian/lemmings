create or replace function card_magic(tk varchar(255), gid integer)
returns json
language plpgsql
external security definer
as $$
declare
	tile_count integer;
	count_lemmings_in_water integer;
begin
	if not (select check_card(tk, gid, 'magic')) then
		return json_object('result' VALUE 'cant_play');
	end if;

	select get_tile_count_of_game(gid) into tile_count;

	select count(*) from players
	where
		id_game = gid
	and
		tile = tile_count
	into count_lemmings_in_water;

	update players
	set pos = pos + count_lemmings_in_water
	where
		tile = tile_count - 1;

	update players
	set tile = least(tile + 1, tile_count)
	where id_game = gid;

	perform card_from_hand_to_game(tk, gid, 'magic');

	return json_object('result' VALUE 'ok');
end;
$$;
