create or replace function get_tile_count_of_game(gid integer)
returns integer
language plpgsql
external security invoker
as $$
begin
	if (select has_hill_crashed from games where id_game = gid) = true then
		return 5;
	else
		return 6;
	end if;
end;
$$;
