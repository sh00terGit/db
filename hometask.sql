--Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT ac.model, ac.aircraft_code, s.fare_conditions, count(s.seat_no)
FROM bookings.aircrafts_data ac INNER JOIN bookings.seats s ON ac.aircraft_code = s.aircraft_code
GROUP BY ac.aircraft_code, s.fare_conditions
ORDER BY ac.aircraft_code

--Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT ac.model, count(s.seat_no)
FROM bookings.aircrafts_data ac INNER JOIN bookings.seats s ON ac.aircraft_code = s.aircraft_code
GROUP BY ac.model
ORDER BY count(s.seat_no) DESC
LIMIT 3

--Вывести код,модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам
SELECT ac.aircraft_code, ac.model, s.seat_no
FROM bookings.aircrafts_data ac INNER JOIN bookings.seats s ON ac.aircraft_code = s.aircraft_code
WHERE ac.model->>'ru' = 'Аэробус A321-200' AND s.fare_conditions != 'Economy'
ORDER BY s.seat_no

--Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)
SELECT airport_code, airport_name, city
FROM bookings.airports_data
WHERE city IN (SELECT city
               FROM bookings.airports_data
               GROUP BY city
               HAVING COUNT(*) > 1)

-- Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT f.flight_id, f.flight_no, f.scheduled_departure, f.scheduled_arrival, f.departure_airport, f.arrival_airport, f.status
FROM bookings.flights f
WHERE f.status IN ('Scheduled', 'On Time', 'Delayed')
  AND f.departure_airport = (SELECT airport_code FROM bookings.airports_data WHERE city ->>'ru' = 'Екатеринбург')
  AND f.arrival_airport IN (SELECT airport_code FROM bookings.airports_data WHERE city ->>'ru' = 'Москва')
ORDER BY f.scheduled_departure
LIMIT 1

--Вывести самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)
(SELECT ticket_no, flight_id, fare_conditions, amount FROM bookings.ticket_flights
WHERE amount = (SELECT min(amount) FROM ticket_flights)
LIMIT 1)
UNION
(SELECT ticket_no, flight_id, fare_conditions, amount FROM bookings.ticket_flights
WHERE amount = (SELECT max(amount) FROM ticket_flights)
LIMIT 1)

-- Написать DDL таблицы Customers , должны быть поля id , firstName, LastName, email , phone. Добавить ограничения на поля ( constraints) .
DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers
(
    customer_id BIGSERIAL PRIMARY KEY,
    customer_firstName VARCHAR(30) NOT NULL,
    customer_lastName VARCHAR(30) NOT NULL,
    customer_email VARCHAR(50) UNIQUE, NOT NULL,
    customer_phone VARCHAR(20) UNIQUE, NOT NULL,
    UNIQUE(customer_firstName, customer_lastName)
);

--  Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + ограничения
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders
(
    order_id BIGSERIAL PRIMARY KEY,
    customerId BIGSERIAL NOT NULL REFERENCES Customers (customer_id),
    order_quantity INT CHECK (order_quantity > 0)
);

-- Написать 5 insert в эти таблицы
INSERT INTO Customers VALUES (1, 'Douglas', 'Williams', 'douglas@mail.ru', '+203849424');
INSERT INTO Customers VALUES (2, 'Varden', 'Wilson', 'varden@rambler.ru', '+1423244');
INSERT INTO Customers VALUES (3, 'Foster', 'Harris', 'foster@google.com', '+04957829');
INSERT INTO Customers VALUES (4, 'Octavio', 'Clark', 'octavio@yopmail.com', '+98740594');
INSERT INTO Customers VALUES (5, 'Dexter', 'Thomas', 'dexter@mail.ru', '+94038475');
INSERT INTO Orders VALUES (1, 3, 105);
INSERT INTO Orders VALUES (2, 1, 60);
INSERT INTO Orders VALUES (3, 1, 85);
INSERT INTO Orders VALUES (4, 4, 220);
INSERT INTO Orders VALUES (5, 2, 13);

-- удалить таблицы
DROP TABLE Orders;
DROP TABLE Customers;

-- Написать свой кастомный запрос ( rus + sql)
-- Вывести данные покупателя потратившего наибольшую сумму
SELECT c.customer_firstname, c.customer_lastname, c.customer_email, c.customer_phone, SUM(o.order_quantity) AS quantity
FROM bookings.customers c INNER JOIN orders o ON c.customer_id = o.customerId
GROUP BY o.customerId, c.customer_id
ORDER BY quantity DESC
LIMIT 1;
