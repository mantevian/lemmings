create or replace function check_card(tk varchar(255), gid integer, c card)
returns bool
language plpgsql
external security invoker
as $$
declare
	lgn varchar;
	card_pos integer;
	did integer;
begin
	select get_login_from_token(tk) into lgn;

	if not (select is_turn_of(gid, lgn)) then
		return false;
	end if;

	select id_deck from get_player(gid, lgn) into did;
	
	select pos
	from deck_cards
	where
		id_deck = did
	and
		card = c
	limit 1
	into card_pos;

	if card_pos is null then
		return false;
	end if;

	return true;
end;
$$;