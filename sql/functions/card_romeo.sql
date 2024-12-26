create or replace function card_romeo(tk varchar(255), gid integer, col1 color, col2 color, target_tile integer)
returns json
language plpgsql
external security definer
as $$
declare
	tile_count integer;
begin
	if not (select check_card(tk, gid, 'romeo')) then
		return json_object('result' VALUE 'cant_play');
	end if;

	if col1 = col2 then
		return json_object('result' VALUE 'two_same_lemmings');
	end if;

	select get_tile_count_of_game(gid) into tile_count;

	if target_tile < 1 or target_tile > tile_count - 1 then
		return json_object('result' VALUE 'out_of_bounds');
	end if;

	if not (select move_separate(gid, col1, target_tile)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	if not (select move_separate(gid, col2, target_tile)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	perform card_from_hand_to_game(tk, gid, 'romeo');

	return json_object('result' VALUE 'ok');
end;
$$;
