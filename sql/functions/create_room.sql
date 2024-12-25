create or replace function create_room(dur integer, pc integer, tk varchar(255))
returns json
language plpgsql
external security definer
as $$
declare
	code varchar(4);
	lgn varchar;
begin
	select get_login_from_token(tk) into lgn;
	if lgn is null then
		return json_object('result' VALUE 'user_not_found');
	end if;

	if pc < 2 or pc > 6 then
		return json_object('result' VALUE 'invalid_player_count');
	end if;

	if dur < 30 or dur > 300 then
		return json_object('result' VALUE 'invalid_turn_duration');
	end if;

	select string_agg(chr(65 + floor(random() * 26)::int), '')::varchar(4)
	from generate_series(1, 4)
	into code;

	insert into games (join_code, player_count, turn_duration, has_hill_crashed)
	values (code, pc, dur, false);

	return json_object(
		'result' VALUE 'ok',
		'join_code' VALUE code,
		'player_count' VALUE pc,
		'turn_duration' VALUE dur
	);
end;
$$;
