create or replace function card_to_color(c card)
returns color
language plpgsql
external security invoker
as $$
begin
	case c
		when 'move_red'::card then return 'red'::color;
		when 'move_yellow'::card then return 'yellow'::color;
		when 'move_green'::card then return 'green'::color;
		when 'move_blue'::card then return 'blue'::color;
		when 'move_purple'::card then return 'purple'::color;
		when 'move_white'::card then return 'white'::color;
		else return null;
	end case;
	
	return null;
end;
$$;
