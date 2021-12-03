create or replace function BuyReserved(
    user_id int, pass text, flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- incorrect user
    if (not CheckCredentials(user_id, pass))
        or
        -- incorrect flight or seat
       (not CheckFlightInfo(flight_id, seat_no))
        or
        -- ticket hasn't booked by this user
       (not exists(select 1
                   from NotFreeTickets
                   where FlightId = flight_id
                     and SeatNo = seat_no
                     and Type = 'booked'
                     and UserId = user_id))
    then
        return false;
    else
        -- because of previous if condition we know that
        -- tickets is for this user_id and booked
        update Tickets
        set ActionTime = current_timestamp,
            Type = 'bought'
        where SeatNo = seat_no
          and FlightId = flight_id;
        return true;
    end if;
end;
$$
    called on null input
    language plpgsql;


-- select BuyReserved(null, 'hell', 1, 'A111'); -- f
-- select BuyReserved(1, null, 1, 'A111'); -- f
-- select BuyReserved(1, 'hell', null, 'A111'); -- f
-- select BuyReserved(1, 'hell', 1, null); -- f
-- select BuyReserved(1, 'hel', 1, 'A111'); -- f
-- select BuyReserved(1, 'hell', 1, 'A111'); -- t
-- select BuyReserved(1, 'hell', 1, 'A222'); -- f
-- select BuyReserved(2, 'hell2', 1, 'A222'); -- t
-- select BuyReserved(2, 'hell2', 1, 'A444'); -- f
