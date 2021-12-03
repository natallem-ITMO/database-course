create or replace function FlightStat(
    user_id int, pass text, flight_id int)
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
    CanBook              boolean;
    CanBuy               boolean;
    FreeSeats            integer;
    BookedByUser         integer;
    BookedOrBoughtByUser integer;
    AllSeats             integer;
    BoughtByUser         integer;
begin
    -- incorrect user
    if (not CheckCredentials(user_id, pass))
        -- incorrect flight
        or (not exists(select from Flights where FlightId = flight_id))
    then
        return ;
    else
        BoughtByUser = (select count(*)
                        from Tickets
                        where Type = 'bought'
                          and UserId = user_id
                          and FlightId = flight_id);
        BookedOrBoughtByUser = (select count(*)
                                from NotFreeTickets
                                where UserId = user_id
                                  and FlightId = flight_id);
        AllSeats = (select count(SeatNo)
                    from Flights
                             natural join Seats
                    where FlightId = flight_id);
        FreeSeats = AllSeats - (select count(*)
                                from NotFreeTickets
                                where FlightId = flight_id);
        BookedByUser = BookedOrBoughtByUser - BoughtByUser;
        CanBook = FreeSeats > 0;
        CanBuy = (FreeSeats + BookedByUser) > 0;
        return query values (CanBook, CanBuy, FreeSeats, BookedByUser, BoughtByUser);
    end if;
end;
$$
    called on null input
    language plpgsql;

select FlightStat(null, 'hell', 1); -- f
select FlightStat(1, null , 1); -- f
select FlightStat(1, 'hell' , 1);




--
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
select * from Tickets;
--
-- drop table Flights;

-- select FlightsStatistics(1, 'hell');
