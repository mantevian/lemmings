create or replace function move_separate(gid integer, col color, target_tile integer)
returns bool
language plpgsql
external security invoker
as $$
declare
	lgn varchar;
	current_tile integer;
	current_pos integer;
	target_pos integer;
	water_tile integer;
	target_tile_norm integer;
begin
	select login
	from players
	where
		id_game = gid
	and
		color = col
	into lgn;

	select get_tile_count_of_game(gid) into water_tile;

	select least(water_tile, greatest(1, target_tile)) into target_tile_norm;

	select
		tile, pos
	into
		current_tile, current_pos
	from get_player(gid, lgn);
	
	if current_tile = target_tile_norm then
		return false;
	end if;

	select pos + 1 from players
	where
		id_game = gid
	and
		tile = target_tile_norm
	order by pos desc
	limit 1
	into target_pos;

	update players
	set
		tile = target_tile_norm,
		pos = coalesce(target_pos, 1)
	where
		id_game = gid
	and
		login = lgn;

	update players
	set
		pos = pos - 1
	where
		id_game = gid
	and
		tile = current_tile
	and
		pos > current_pos;

	return true;
end;
$$;
