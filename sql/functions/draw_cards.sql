create or replace function draw_cards(tk varchar, amount integer)
returns bool
language plpgsql
external security invoker
as $$
declare
	gid integer;
    iddeck integer;
	player_iddeck integer;
	c record;
	p integer;
begin
	select id_game from connections where token = tk into gid;

	if gid is null then
		return false;
	end if;

	select id_deck from games where id_game = gid into iddeck;

	if iddeck is null then
		return false;
	end if;

	select id_deck from players where token = tk into player_iddeck;

	if player_iddeck is null then
		return false;
	end if;

	for c in (
		select id_deck, card
		from deck_cards
		where id_deck = iddeck
		order by random()
		limit amount
	) loop
		select coalesce(max(pos), 0) + 1 from deck_cards where id_deck = player_iddeck into p;

		insert into deck_cards (id_deck, card, pos) values (player_iddeck, c.card, p);

		with card_to_delete as (
			select id_deck, card
			from deck_cards
			where id_deck = iddeck and card = c.card
			limit 1
		)
		delete from deck_cards
		using card_to_delete
		where
			deck_cards.id_deck = card_to_delete.id_deck
		and
			deck_cards.card = card_to_delete.card;
	end loop;

return true;
end;
$$;
