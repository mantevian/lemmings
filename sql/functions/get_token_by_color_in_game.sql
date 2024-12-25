create or replace function get_token_by_color_in_game(gid integer, col color)
returns varchar
language plpgsql
external security invoker
as $$
declare
	tk varchar;
begin
	select token from players
	where
		token in (select token from connections where id_game = gid)
	and
		color = col
	limit 1
	into tk;

	return tk;
end;
$$;
