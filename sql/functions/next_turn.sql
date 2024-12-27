create or replace function next_turn(tk varchar(255), gid integer)
returns json
language plpgsql
external security definer
as $$
begin
	return select next_turn_inner(get_login_from_token(tk), gid);
end;
$$;
