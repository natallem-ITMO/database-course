create or replace function BuyFree(
    flight_id int, seat_no varchar(4))
    returns boolean
as
$$
begin
    -- incorrect flight or seat
    if (not CheckFlightInfo(flight_id, seat_no))
        or
        -- ticket has already booked or bought
       (exists(select 1
               from NotFreeTickets
               where FlightId = flight_id
                 and SeatNo = seat_no))
    then
        return false;
    else
        insert into Tickets (FlightId,
                             PlaneId,
                             SeatNo,
                             UserId,
                             Type,
                             ActionTime)
        values (flight_id,
                (select PlaneId from Flights where FlightId = flight_id),
                seat_no,
                null,
                'bought',
                current_timestamp)
        on conflict (FlightId, SeatNo)
            do update set UserId     = null,
                          Type       = 'bought',
                          ActionTime = current_timestamp;
        return true;
    end if;
end;
$$
    called on null input
    language plpgsql;

-- select BuyFree(1, 'A123'); -- f
-- select BuyFree(43, 'A123'); -- f
-- select BuyFree(1, 'A111'); -- f
-- select BuyFree(null, 'A333'); -- f
-- select BuyFree(1, null); -- f
-- select BuyFree(1, 'A333'); -- t
-- select BuyFree(1, 'A333'); -- f
-- select FreeSeats(1);

