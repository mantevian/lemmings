create or replace function card_back(tk varchar(255), gid integer, col color)
returns json
language plpgsql
external security definer
as $$
declare
	lgn varchar;
	t integer;
begin
	if not (select check_card(tk, gid, 'back')) then
		return json_object('result' VALUE 'cant_play');
	end if;

	select tile from get_player_by_color(gid, col) into t;

	if not (select move(gid, col, t - 2)) then
		return json_object('result' VALUE 'cant_move');
	end if;

	perform card_from_hand_to_game(tk, gid, 'back');

	return json_object('result' VALUE 'ok');
end;
$$;
