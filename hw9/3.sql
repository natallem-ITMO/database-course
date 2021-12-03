create or replace function ExtendReservation(
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
        -- because of previous 'if condition' we know that
        -- ticket is for this user_id and booked
        update Tickets
        set ActionTime = current_timestamp
        where SeatNo = seat_no
          and FlightId = flight_id;
        return true;
    end if;
end;
$$
    called on null input
    language plpgsql;

select FreeSeats(1);
-- select ExtendReservation(1, 'hell', 1, 'A228'); -- f
-- select ExtendReservation(null, 'hell', 1, 'A111'); -- f
-- select ExtendReservation(1, null, 1, 'A111'); -- f
-- select ExtendReservation(1, 'hell', null, 'A111'); -- f
-- select ExtendReservation(1, 'hell', 1, null); -- f
-- select ExtendReservation(1, 'hel', 1, 'A111'); -- f
-- select ExtendReservation(1, 'hell', 1, 'A111'); -- t
-- select ExtendReservation(1, 'hell', 1, 'A111'); -- t
-- select ExtendReservation(1, 'hell', 1, 'A222'); -- f
-- select ExtendReservation(2, 'hell2', 1, 'A222'); -- t
--

