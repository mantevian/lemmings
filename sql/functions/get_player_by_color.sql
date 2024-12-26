create or replace function get_player_by_color(gid integer, col color)
returns record
language plpgsql
external security invoker
as $$
declare
	p record;
begin
	select * players
	where
		id_game = gid
	and
		color = col
	into p;

	return p;
end;
$$;
