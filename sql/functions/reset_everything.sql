create or replace function reset_everything()
returns bool
language plpgsql
external security invoker
as $$
begin
	delete from games;
	delete from players;
	delete from users;
	delete from connections;
	delete from deck_cards;
	delete from decks;

	return true;
end;
$$;
