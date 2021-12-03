create or replace procedure CompressSeats(flight_id int)
as
$$
declare
    seat_num  int := 1;
    seat_name varchar(4);
    booked_cursor cursor for
        select *
        from NotFreeTickets
        where FlightId = flight_id
          and Type = 'booked'
        order by LPAD(SeatNo::text, 4, '0')
            for update;
    bought_cursor cursor for
        select *
        from Tickets
                 natural join Flights
        where FlightId = flight_id
          and FlightTime > current_timestamp
          and Type = 'bought'
        order by LPAD(SeatNo::text, 4, '0')
            for update;
begin
    -- incorrect flight
    if not exists(select from Flights where FlightId = flight_id)
    then
        return ;
    else
        create temporary table SeatNames
        (
            SeatId   int,
            SeatName varchar(4)
        );
        create temporary table SeatRenaming
        (
            PrevName varchar(4),
            SeatId   int,
            constraint seat_renaming_pk primary key (PrevName)
        );
        for seat_name in select SeatNo
                         from Seats
                         where PlaneId =
                               (select PlaneId from Flights where FlightId = flight_id)
                         order by LPAD(SeatNo::text, 4, '0')
            loop
                insert into SeatNames (SeatId, SeatName)
                values (seat_num, seat_name);
                seat_num := seat_num + 1;
            end loop;
        seat_num := 1;
        for _ in bought_cursor
            loop
                fetch bought_cursor into seat_name;
                update Tickets
                set SeatNo = (select SeatName from SeatNames where SeatId = seat_num)
                where current of bought_cursor;
                seat_num := seat_num + 1;
            end loop;
        for _ in booked_cursor
            loop
                fetch booked_cursor into seat_name;
                update Tickets
                set SeatNo = (select SeatName from SeatNames where SeatId = seat_num)
                where current of booked_cursor;
                seat_num := seat_num + 1;
            end loop;
    end if;
end;
$$
    language plpgsql;

select Reserve(1, 'hell', 3, '1B');
select Reserve(2, 'hell2', 3, '10A');
select Reserve(2, 'hell2', 3, '100A');
select BuyReserved(2, 'hell2', 3, '100A');
-- select BuyReserved(1,)
select *
from Tickets;

select SeatNo
from Seats
where PlaneId =
      (select PlaneId from Flights where FlightId = 3)
order by LPAD(SeatNo::text, 4, '0');


call CompressSeats(3);

select *
from Tickets;
