
create or replace function Reserve(
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
        -- ticket has already booked or bought
        (exists (select 1 from NotFreeTickets where FlightId = flight_id and SeatNo = seat_no))
    then
        return false;
    else
        delete from Tickets where FlightId = flight_id and SeatNo = seat_no;
        insert into Tickets (FlightId, PlaneId, SeatNo, UserId, Type, ActionTime)
        values (flight_id,
                (select PlaneId from Flights where FlightId = flight_id),
                seat_no,
                user_id,
                'booked',
                current_timestamp);
        return true;
    end if;
end;
$$
    called on null input
    language plpgsql;

-- select FreeSeats(1);
-- select Reserve(1, 'hell', 1, 'A228'); -- f
-- select Reserve(null, 'hell', 1, 'A111'); -- f
-- select Reserve(1, null, 1, 'A111'); -- f
-- select Reserve(1, 'hell', null, 'A111'); -- f
-- select Reserve(1, 'hell', 1, null); -- f
-- select Reserve(1, 'hel', 1, 'A111'); -- f
-- select Reserve(1, 'hell', 1, 'A111'); -- t
-- select Reserve(1, 'hell', 1, 'A111'); -- f
-- select Reserve(2, 'hell2', 1, 'A222'); -- t
-- select FreeSeats(1);
