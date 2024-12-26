create or replace function get_winner(gid integer)
returns varchar
language plpgsql
external security invoker
as $$
declare
	tile_count integer;
	count_on_land integer;
	lgn varchar;
begin
	select get_tile_count_of_game(gid) into tile_count;
	select count(*) from players
	where
		id_game = gid
	and
		tile < tile_count
	into count_on_land;

	if count_on_land <> 1 then
		return null;
	end if;

	select login from players
	where
		id_game = gid
	and
		tile < tile_count
	into lgn;

	return lgn;
end;
$$;
