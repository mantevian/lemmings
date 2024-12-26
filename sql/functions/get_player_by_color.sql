create or replace function get_player_by_color(gid integer, col color)
returns players
language plpgsql
external security invoker
as $$
declare
	p record;
begin
	select * from players
	where
		id_game = gid
	and
		color = col
	into p;

	return p;
end;
$$;
