create or replace function FreeSeats(flight_id int)
    returns table
            (
                SeatNo varchar(4)
            )
as
$$
begin
    return query
        select s.SeatNo as SeatNo
        from Flights f
                 natural join Seats s
        where f.FlightId = flight_id
          and current_timestamp < f.FlightTime
        except
        select nft.SeatNo as SeatNo
        from NotFreeTickets nft
        where nft.FlightId = flight_id;
end;
$$
    called on null input
    language plpgsql;

select FreeSeats(1); -- full
select FreeSeats(134); -- empty
select FreeSeats(null); -- empty

