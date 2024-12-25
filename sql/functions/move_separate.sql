create or replace function move_separate(tk varchar, target_tile integer)
returns bool
language plpgsql
external security invoker
as $$
declare
	gid integer;
	current_tile integer;
	current_pos integer;
	target_pos integer;
	water_tile integer;
	target_tile_norm integer;
begin
	select id_game from connections where token = tk into gid;

	if gid is null then
		return false;
	end if;

	select get_tile_count_of_game(gid) into water_tile;

	select least(water_tile, greatest(1, target_tile)) into target_tile_norm;

	select tile from players where token = tk into current_tile;
	select pos from players where token = tk into current_pos;

	if current_tile = target_tile_norm then
		return false;
	end if;

	select pos + 1 from players
	where
		token in (select token from connections where id_game = gid)
	and
		tile = target_tile_norm
	order by pos desc
	limit 1
	into target_pos;

	update players
	set tile = target_tile_norm, pos = coalesce(target_pos, 1)
	where token = tk;

	update players
	set pos = pos - 1
	where
		token in (select token from connections where id_game = gid)
	and
		tile = current_tile
	and
		pos >= current_pos;

	return true;
end;
$$;
