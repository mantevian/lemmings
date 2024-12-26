create or replace function card_whoosh(tk varchar(255), gid integer, col1 color, col2 color)
returns json
language plpgsql
external security definer
as $$
declare
	tile_count integer;
	t1 integer;
	p1 integer;
	t2 integer;
	p2 integer;
begin
	if not (select check_card(tk, gid, 'whoosh')) then
		return json_object('result' VALUE 'cant_play');
	end if;

	if col1 = col2 then
		return json_object('result' VALUE 'two_same_lemmings');
	end if;

	select get_tile_count_of_game(gid) into tile_count;

	select
		tile, pos
	into
		t1, p1
	from get_player_by_color(gid, col1);

	select
		tile, pos
	into
		t2, p2
	from get_player_by_color(gid, col2);

	if (t1 is null) or (p1 is null) or (t2 is null) or (p2 is null) then
		return json_object('result' VALUE 'lemming_not_found');
	end if;

	update players
	set
		tile = t2,
		pos = p2
	where
		id_game = gid
	and
		color = col1;

	update players
	set
		tile = t1,
		pos = p1
	where
		id_game = gid
	and
		color = col2;

	perform card_from_hand_to_game(tk, gid, 'whoosh');

	return json_object('result' VALUE 'ok');
end;
$$;
