create or replace function get_player(gid integer, lgn varchar)
returns record
language plpgsql
external security invoker
as $$
	p record;
begin
	select * from players
	where
		login = lgn
	and
		id_game = gid
	into p;

	return p; 
end;
$$;
