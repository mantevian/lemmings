create or replace function color_to_card(c color)
returns card
language plpgsql
external security invoker
as $$
begin
	case c
		when 'red'::color then return 'move_red'::card;
		when 'yellow'::color then return 'move_yellow'::card;
		when 'green'::color then return 'move_green'::card;
		when 'blue'::color then return 'move_blue'::card;
		when 'purple'::color then return 'move_purple'::card;
		when 'white'::color then return 'move_white'::card;
		else return null;
	end case;
	
	return null;
end;
$$;
