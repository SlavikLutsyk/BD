DELIMITER ;;

DROP PROCEDURE IF EXISTS `everybody_pilot_rating`;;
CREATE PROCEDURE `everybody_pilot_rating`()
BEGIN
DECLARE number INT;
SET number = 1;
SELECT COUNT(id) INTO @count FROM Pilot;
WHILE number <= @count DO
CALL pilot_rating(number);
SET number = number + 1;
END WHILE;
END;;

DROP PROCEDURE IF EXISTS `pilot_rating`;;
CREATE PROCEDURE `pilot_rating`(IN pilot_idD INT)
BEGIN
    DECLARE num_flights INT;
    DECLARE total_duration INT;
    DECLARE rating FLOAT;
    DECLARE most_common_plane INT;
    DECLARE num_flights_on_most_common_plane INT;
    
    -- визначення кількості вильотів
    SELECT COUNT(*) INTO num_flights
    FROM Flight
    WHERE pilot_id = pilot_idD;
    
    -- визначення загальної тривалості перебування в польотах
    SELECT SUM(TIMESTAMPDIFF(MINUTE, boarding_time, departure_time)) INTO total_duration
    FROM Flight
    WHERE pilot_id = pilot_idD;
    
    -- визначення середньої тривалості польоту
    SET total_duration = total_duration / num_flights;
    
    -- визначення типу літака, на якому найбільше польотів
    SELECT plane_id, COUNT(*) AS cnt
    FROM Flight
    WHERE pilot_id = pilot_idD
    GROUP BY plane_id
    ORDER BY cnt DESC
    LIMIT 1 INTO most_common_plane, num_flights_on_most_common_plane;
    
    
    -- визначення рейтингу
    SET rating = num_flights * 0.2 + total_duration * 0.0001 + IF(most_common_plane = 1, 0.2, 0);
    
    -- повернення результату
    SELECT rating;
END;;

DELIMITER ;

DROP TABLE IF EXISTS `Commander`;
CREATE TABLE `Commander` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `crew_id` bigint NOT NULL,
  `UCR` varchar(20) NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `crew_id` (`crew_id`),
  CONSTRAINT `commander_ibfk_1` FOREIGN KEY (`crew_id`) REFERENCES `Crew` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Commander` (`id`, `crew_id`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	1,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	2,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(3,	3,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00');

DELIMITER ;;

CREATE TRIGGER `commander_before_insert` BEFORE INSERT ON `Commander` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `commander_before_update` BEFORE UPDATE ON `Commander` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

DROP TABLE IF EXISTS `Crew`;
CREATE TABLE `Crew` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `first_name` varchar(15) NOT NULL,
  `birth_date` datetime NOT NULL,
  `address` varchar(30) NOT NULL,
  `UCR` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Crew` (`id`, `first_name`, `birth_date`, `address`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	'John',	'1985-01-01 00:00:00',	'123 Main Street',	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	'Jane',	'1988-03-15 00:00:00',	'456 Oak Avenue',	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(3,	'Lutsyk',	'1980-04-23 13:05:04',	'Lutsyk Street',	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(4,	'Kozak',	'1981-04-23 13:05:04',	'Kozak Street',	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(5,	'Taras',	'1982-04-23 13:05:04',	'Lutsyk Street',	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(6,	'Krislatyy',	'1985-03-20 10:05:04',	'Kozak Street',	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(7,	'Fesenko',	'1983-01-31 13:05:04',	'Lutsyk Street',	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(8,	'Patyaka',	'1987-03-20 17:05:00',	'Kozak Street',	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(9,	'Filep',	'1983-01-30 12:00:00',	'Kozak Street',	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00');

DELIMITER ;;

CREATE TRIGGER `crew_before_insert` BEFORE INSERT ON `Crew` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `crew_before_update` BEFORE UPDATE ON `Crew` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

DROP TABLE IF EXISTS `Flight`;
CREATE TABLE `Flight` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `departure_point` varchar(20) NOT NULL,
  `destination` varchar(20) NOT NULL,
  `departure_time` datetime NOT NULL,
  `boarding_time` datetime NOT NULL,
  `plane_id` bigint NOT NULL,
  `pilot_id` bigint NOT NULL,
  `commander_id` bigint NOT NULL,
  `UCR` varchar(20) NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `pilot_id` (`pilot_id`),
  KEY `commander_id` (`commander_id`),
  KEY `flight_ibfk_3` (`plane_id`),
  CONSTRAINT `flight_ibfk_1` FOREIGN KEY (`pilot_id`) REFERENCES `Pilot` (`id`) ON DELETE CASCADE,
  CONSTRAINT `flight_ibfk_2` FOREIGN KEY (`commander_id`) REFERENCES `Commander` (`id`) ON DELETE CASCADE,
  CONSTRAINT `flight_ibfk_3` FOREIGN KEY (`plane_id`) REFERENCES `Plane` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Flight` (`id`, `departure_point`, `destination`, `departure_time`, `boarding_time`, `plane_id`, `pilot_id`, `commander_id`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	'New York',	'Los Angeles',	'2023-03-25 10:00:00',	'2023-03-25 09:00:00',	1,	1,	1,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	'Chicago',	'San Francisco',	'2023-10-26 12:00:00',	'2023-10-27 11:00:00',	2,	2,	2,	'',	'2023-04-10 12:09:42',	'root@172.18.0.2',	'2023-04-10 12:09:42'),
(3,	'Chervonograd',	'Sokal',	'2023-07-01 12:00:00',	'2023-07-01 15:00:00',	3,	3,	3,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(4,	'Ternopil',	'Sokal',	'2023-08-01 10:00:00',	'2023-08-02 15:00:00',	1,	1,	2,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(5,	'Chervonograd',	'Washington',	'2023-09-02 12:00:00',	'2023-09-04 15:00:00',	3,	3,	3,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(6,	'Kyiv',	'Franyk',	'2023-08-22 09:00:00',	'2023-08-22 17:08:00',	2,	1,	3,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(7,	'Ternopil',	'Donetsk',	'2023-10-26 14:00:00',	'2023-10-27 15:00:00',	9,	1,	3,	'root@172.18.0.2',	'2023-04-10 12:29:34',	'root@172.18.0.2',	'2023-04-10 12:29:34'),
(8,	'New York',	'Los Angeles',	'2023-02-25 10:00:00',	'2023-02-25 12:00:00',	1,	4,	2,	'root@172.18.0.3',	'2023-04-12 06:42:20',	'root@172.18.0.3',	'2023-04-12 06:42:20');

DELIMITER ;;

CREATE TRIGGER `flight_before_insert` BEFORE INSERT ON `Flight` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `check_pilot_break` BEFORE INSERT ON `Flight` FOR EACH ROW
BEGIN
    DECLARE last_flight_date DATETIME;
    SELECT departure_time INTO last_flight_date
    FROM Flight
    WHERE pilot_id = NEW.pilot_id
    ORDER BY departure_time DESC
    LIMIT 1;
    IF last_flight_date IS NOT NULL AND TIMESTAMPDIFF(DAY, last_flight_date, NEW.departure_time) < 3 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pilot must have a break of at least three days between flights';
    END IF;
END;;

CREATE TRIGGER `surrogate_key` BEFORE INSERT ON `Flight` FOR EACH ROW
BEGIN
    DECLARE max_id BIGINT;
    SELECT MAX(id) INTO max_id FROM Flight;
    IF NEW.id != max_id+1 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid id value';
    END IF;
END;;

CREATE TRIGGER `check_available_plane` BEFORE INSERT ON `Flight` FOR EACH ROW
BEGIN
  DECLARE plane_count INT;
  DECLARE plane_board_num INT;
  SELECT COUNT(*) INTO plane_board_num FROM Flight WHERE plane_id = NEW.plane_id;
  SELECT COUNT(*) INTO plane_count FROM Flight WHERE plane_id = NEW.plane_id 
  AND (departure_time <= NEW.departure_time AND boarding_time >= NEW.departure_time OR
  boarding_time >= NEW.boarding_time AND departure_time <= NEW.boarding_time);
  IF (plane_board_num != 0 AND plane_count > 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot insert new flight. Plane is not available.';
  END IF;
END;;

CREATE TRIGGER `check_available_personnel` BEFORE INSERT ON `Flight` FOR EACH ROW
BEGIN
  DECLARE pilot_count INT;
  DECLARE commander_count INT;
  DECLARE pilot_board_num INT;
  DECLARE commander_board_num INT;
  SELECT COUNT(*) INTO pilot_board_num FROM Flight WHERE pilot_id = NEW.pilot_id;
  SELECT COUNT(*) INTO commander_board_num FROM Flight WHERE commander_id = NEW.commander_id;
  SELECT COUNT(*) INTO pilot_count FROM Flight WHERE pilot_id = NEW.pilot_id AND (departure_time <= NEW.departure_time AND boarding_time >= NEW.departure_time OR
  boarding_time >= NEW.boarding_time AND departure_time <= NEW.boarding_time);
  SELECT COUNT(*) INTO commander_count FROM Flight WHERE commander_id = NEW.commander_id AND (departure_time <= NEW.departure_time AND boarding_time >= NEW.departure_time OR
  boarding_time >= NEW.boarding_time AND departure_time <= NEW.boarding_time);
  IF (pilot_board_num != 0 AND pilot_count > 0 OR commander_board_num != 0 AND commander_count > 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot insert new flight. Personnel is not available.';
  END IF;
END;;

CREATE TRIGGER `flight_before_update` BEFORE UPDATE ON `Flight` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

DROP TABLE IF EXISTS `Flight_Stewardess`;
CREATE TABLE `Flight_Stewardess` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `flight_id` bigint NOT NULL,
  `stewardess_id` bigint NOT NULL,
  `UCR` varchar(20) NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `flight_id` (`flight_id`),
  KEY `stewardess_id` (`stewardess_id`),
  CONSTRAINT `flight_stewardess_ibfk_1` FOREIGN KEY (`flight_id`) REFERENCES `Flight` (`id`) ON DELETE CASCADE,
  CONSTRAINT `flight_stewardess_ibfk_2` FOREIGN KEY (`stewardess_id`) REFERENCES `Stewardess` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Flight_Stewardess` (`id`, `flight_id`, `stewardess_id`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	1,	1,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	2,	2,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(3,	1,	3,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(4,	2,	1,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(5,	3,	3,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(6,	3,	1,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00');

DELIMITER ;;

CREATE TRIGGER `fl_st_before_insert` BEFORE INSERT ON `Flight_Stewardess` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `check_available_stewardess` BEFORE INSERT ON `Flight_Stewardess` FOR EACH ROW
BEGIN
  DECLARE stew_on_flight INT;
  DECLARE stew_count INT;
  DECLARE stew_board_num INT;
  
  SELECT COUNT(*) INTO stew_on_flight FROM Flight_Stewardess WHERE flight_id = NEW.flight_id;
  IF stew_on_flight >= 2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add one more stewardess to flight. There are two stewardesses.';
  ELSE
    SELECT COUNT(*) INTO stew_board_num FROM Flight_Stewardess WHERE stewardess_id = NEW.stewardess_id;
    SELECT COUNT(*) INTO stew_count FROM Flight f JOIN Flight_Stewardess fs ON f.id = fs.flight_id
    WHERE stewardess_id = NEW.stewardess_id AND (departure_time <= (SELECT departure_time FROM Flight WHERE id = NEW.flight_id) 
    AND boarding_time >= (SELECT departure_time FROM Flight WHERE id = NEW.flight_id) OR
    boarding_time >= (SELECT boarding_time FROM Flight WHERE id = NEW.flight_id) 
    AND departure_time <= (SELECT boarding_time FROM Flight WHERE id = NEW.flight_id));
    IF (stew_board_num != 0 AND stew_count > 0) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add new stewardess. Stewardess is not available.';
    END IF;
  END IF;
END;;

CREATE TRIGGER `fl_st_before_update` BEFORE UPDATE ON `Flight_Stewardess` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

DROP TABLE IF EXISTS `Model`;
CREATE TABLE `Model` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `number_seats` int NOT NULL,
  `carrying_capacity` int NOT NULL,
  `UCR` varchar(20) NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Model` (`id`, `number_seats`, `carrying_capacity`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	150,	50000,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	180,	60000,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(3,	200,	45000,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(4,	200,	55000,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(5,	200,	56000,	'root@172.18.0.3',	'2023-04-12 06:05:26',	'root@172.18.0.3',	'2023-04-12 06:05:26');

DELIMITER ;;

CREATE TRIGGER `model_before_insert` BEFORE INSERT ON `Model` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `model_before_update` BEFORE UPDATE ON `Model` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

DROP TABLE IF EXISTS `Pilot`;
CREATE TABLE `Pilot` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `crew_id` bigint NOT NULL,
  `break_time` int NOT NULL,
  `UCR` varchar(20) NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `crew_id` (`crew_id`),
  CONSTRAINT `pilot_ibfk_1` FOREIGN KEY (`crew_id`) REFERENCES `Crew` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Pilot` (`id`, `crew_id`, `break_time`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	4,	8,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	5,	4,	'',	'2023-04-12 06:05:00',	'root@172.18.0.3',	'2023-04-12 06:05:00'),
(3,	6,	10,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(4,	3,	3,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(5,	3,	3,	'root@172.18.0.3',	'2023-04-12 06:05:57',	'root@172.18.0.3',	'2023-04-12 06:05:57');

DELIMITER ;;

CREATE TRIGGER `pilot_before_insert` BEFORE INSERT ON `Pilot` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `pilot_before_update` BEFORE UPDATE ON `Pilot` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

DROP TABLE IF EXISTS `Pilot_Model`;
CREATE TABLE `Pilot_Model` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pilot_id` bigint NOT NULL,
  `model_id` bigint NOT NULL,
  `UCR` varchar(20) NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `pilot_id` (`pilot_id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `pilot_model_ibfk_1` FOREIGN KEY (`pilot_id`) REFERENCES `Pilot` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pilot_model_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `Model` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Pilot_Model` (`id`, `pilot_id`, `model_id`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	1,	1,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	2,	2,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(3,	1,	3,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(4,	3,	1,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00');

DELIMITER ;;

CREATE TRIGGER `pil_mod_before_insert` BEFORE INSERT ON `Pilot_Model` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `pil_mod_before_update` BEFORE UPDATE ON `Pilot_Model` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

DROP TABLE IF EXISTS `Plane`;
CREATE TABLE `Plane` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `model_id` bigint NOT NULL,
  `hoursWorked` int NOT NULL,
  `UCR` varchar(20) NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `plane_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `Model` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Plane` (`id`, `model_id`, `hoursWorked`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	1,	500,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	2,	750,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(3,	3,	600,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(4,	2,	250,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(5,	3,	367,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(6,	1,	56,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(7,	2,	123,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(8,	2,	45,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(9,	3,	145,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00');

DELIMITER ;;

CREATE TRIGGER `plane_before_insert` BEFORE INSERT ON `Plane` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `plane_before_update` BEFORE UPDATE ON `Plane` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

DROP TABLE IF EXISTS `Stewardess`;
CREATE TABLE `Stewardess` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `crew_id` bigint NOT NULL,
  `UCR` varchar(20) NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `crew_id` (`crew_id`),
  CONSTRAINT `stewardess_ibfk_1` FOREIGN KEY (`crew_id`) REFERENCES `Crew` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Stewardess` (`id`, `crew_id`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	7,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	8,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(3,	9,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00');

DELIMITER ;;

CREATE TRIGGER `stewardess_before_insert` BEFORE INSERT ON `Stewardess` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `stewardess_before_update` BEFORE UPDATE ON `Stewardess` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

DROP TABLE IF EXISTS `Tickets`;
CREATE TABLE `Tickets` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `flight_id` bigint NOT NULL,
  `sold_tickets` int NOT NULL,
  `UCR` varchar(20) NOT NULL,
  `DCR` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ULC` varchar(20) NOT NULL,
  `DLC` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `flight_id` (`flight_id`),
  CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`flight_id`) REFERENCES `Flight` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Tickets` (`id`, `flight_id`, `sold_tickets`, `UCR`, `DCR`, `ULC`, `DLC`) VALUES
(1,	1,	150,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(2,	2,	149,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(3,	3,	50,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(4,	1,	120,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(5,	4,	38,	'',	'0000-00-00 00:00:00',	'',	'0000-00-00 00:00:00'),
(6,	5,	38,	'',	'2023-04-12 06:03:42',	'root@172.18.0.3',	'2023-04-12 06:03:42'),
(8,	6,	14,	'Passenger@172.18.0.2',	'2023-04-10 15:54:02',	'Passenger@172.18.0.2',	'2023-04-10 15:54:02'),
(9,	1,	150,	'Passenger@172.18.0.2',	'2023-04-12 10:40:36',	'Passenger@172.18.0.2',	'2023-04-12 10:40:36');

DELIMITER ;;

CREATE TRIGGER `tickets_before_insert` BEFORE INSERT ON `Tickets` FOR EACH ROW
SET NEW.UCR = USER(),
NEW.DCR = NOW(),
NEW.ULC = USER(),
NEW.DLC = NOW();;

CREATE TRIGGER `tickets_before_update` BEFORE UPDATE ON `Tickets` FOR EACH ROW
SET NEW.ULC = USER(),
NEW.DLC = NOW();;

DELIMITER ;

CREATE USER 'AdminDB'@'%' IDENTIFIED BY 'root';
CREATE USER 'Passenger'@'%' IDENTIFIED BY 'root';
CREATE USER 'Pilot'@'%' IDENTIFIED BY 'root';
CREATE USER 'AdmAirport'@'%' IDENTIFIED BY 'root';

GRANT ALL PRIVILEGES ON sample.* TO 'AdminDB'@'%';
GRANT SELECT ON Flight TO 'Passenger'@'%';
GRANT SELECT ON Plane TO 'Passenger'@'%';
GRANT SELECT ON Model TO 'Passenger'@'%';
GRANT INSERT ON Tickets TO 'Passenger'@'%';
GRANT SELECT ON Plane TO 'Pilot'@'%';
GRANT SELECT ON Model TO 'Pilot'@'%';
GRANT SELECT ON Flight TO 'Pilot'@'%';
GRANT SELECT ON Commander TO 'Pilot'@'%';
GRANT SELECT ON Stewardess TO 'Pilot'@'%';
GRANT SELECT ON Pilot TO 'Pilot'@'%';
GRANT SELECT ON Pilot_Model TO 'Pilot'@'%';
GRANT SELECT ON Flight_Stewardess TO 'Pilot'@'%';
GRANT SELECT ON Crew TO 'Pilot'@'%';
GRANT SELECT ON sample.* TO 'AdmAirport'@'%';
GRANT INSERT, UPDATE, DELETE ON Flight TO 'AdmAirport'@'%';
GRANT INSERT, UPDATE, DELETE ON Model TO 'AdmAirport'@'%';
GRANT INSERT, UPDATE, DELETE ON Plane TO 'AdmAirport'@'%';
GRANT INSERT, UPDATE, DELETE ON Crew TO 'AdmAirport'@'%';
GRANT INSERT, UPDATE, DELETE ON Pilot TO 'AdmAirport'@'%';
GRANT INSERT, UPDATE, DELETE ON Commander TO 'AdmAirport'@'%';
GRANT INSERT, UPDATE, DELETE ON Stewardess TO 'AdmAirport'@'%';
GRANT INSERT, UPDATE, DELETE ON Pilot_Model TO 'AdmAirport'@'%';
GRANT INSERT, UPDATE, DELETE ON Flight_Stewardess TO 'AdmAirport'@'%';


CREATE ROLE admin, user;

GRANT ALL PRIVILEGES ON sample.* TO admin;
GRANT SELECT ON sample.* TO user;

GRANT admin TO 'AdminDB'@'%';
GRANT admin TO 'AdmAirport'@'%';
GRANT user TO 'Passenger'@'%';
GRANT user TO 'Pilot'@'%';

REVOKE SELECT ON Flight FROM 'Passenger'@'%';

REVOKE SELECT ON sample.* FROM 'user';

DROP ROLE 'admin';

DROP USER 'Passenger'@'%';