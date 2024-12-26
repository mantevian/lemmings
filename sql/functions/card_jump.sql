create or replace function card_jump(tk varchar(255), gid integer, col color, target_tile integer)
returns json
language plpgsql
external security definer
as $$
declare
	tile_count integer;
begin
	if not (select check_card(tk, gid, 'jump')) then
		return json_object('result' VALUE 'cant_play');
	end if;

	select get_tile_count_of_game(gid) into tile_count;

	if target_tile < 2 or target_tile > tile_count - 1 then
		return json_object('result' VALUE 'out_of_bounds');
	end if;

	if not (select move_separate(gid, col, target_tile)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	perform card_from_hand_to_game(tk, gid, 'jump');

	return json_object('result' VALUE 'ok');
end;
$$;
