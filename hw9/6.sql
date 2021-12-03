create or replace function FlightsStatistics(
    user_id int, pass text)
    returns table
            (
                CanBook     boolean,
                CanBuy      boolean,
                FreeSeats   integer,
                BookedSeats integer,
                BoughtSeats integer
            )
as
$$
declare
    CanBook             boolean;
    CanBuy              boolean;
    FreeSeats           integer;
    BookedByUser         integer;
    BookedOrBoughtByUser integer;
    AllSeats            integer;
    BoughtByUser         integer;
begin
    -- incorrect user
    if (not CheckCredentials(user_id, pass))
    then
        return;
    else
        BoughtByUser = (select count(*)
                       from Tickets
                       where Type = 'bought'
                         and UserId = user_id);
        BookedOrBoughtByUser = (select count(*)
                               from NotFreeTickets
                               where UserId = user_id);
        AllSeats = (select count(SeatNo)
                    from Flights
                             natural join Seats);
        FreeSeats = AllSeats - (select count(*)
                                from NotFreeTickets);
        BookedByUser = BookedOrBoughtByUser - BoughtByUser;
        CanBook = FreeSeats > 0;
        CanBuy = (FreeSeats + BookedByUser) > 0;
        return query values (CanBook, CanBuy, FreeSeats, BookedByUser, BoughtByUser);
    end if;
end;
$$
    called on null input
    language plpgsql;

-- run
-- select FlightsStatistics(null, 'hell'); -- f
-- select FlightsStatistics(1, null);
--
--
-- select FlightsStatistics(1, 'hell');
-- select * from Tickets;
-- select Reserve(1, 'hell', 2, 'B111');
-- select Reserve(1, 'hell', 2, 'B222');
-- select Reserve(1, 'hell', 2, 'B333');
-- select Reserve(1, 'hell', 2, 'B444');
-- select Reserve(1, 'hell', 1, 'A444');
-- select BuyReserved(1, 'hell', 2, 'B222');
-- select FlightsStatistics(1, 'hell');
-- select * from Tickets;
--
-- drop table Flights;

select FlightsStatistics(1, 'hell');
