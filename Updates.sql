## Write out to CSV

## Notes
# Issue: current style of updating DB is error prone and cumbersome
# Solution: Develop UI
# MVP- start with basics - Be able to insert new bets, be able to update old, create new table 
# for each season. Benefit? Can analyze by time and also change up columns
# Also, can always join data from tables to further aggregate. 
# Later create simple cash-out / W / L / A functionality.  Would be nice simple implementation

SELECT *
FROM bet_info
INTO OUTFILE 'C:\\wamp64\\tmp\\04_16_21_sportsfuturesOutput.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

DROP PROCEDURE IF EXISTS bet_entry_2022;
DELIMITER // 
CREATE PROCEDURE bet_entry_2022(IN selection VARCHAR(50),
							IN league VARCHAR(50),
                            IN date_placed DATE,
                            IN settle_year CHAR(4),
                            IN bet_type VARCHAR(50),
                            IN site VARCHAR(50),
                            IN odds_multiplier DECIMAL(15,4),
                            IN principle DECIMAL(15,2),
                            IN status CHAR(1),
                            IN result DECIMAL(15,2)
                            )
BEGIN
	DECLARE EXIT HANDLER FOR 1062 SELECT 'Duplicate keys error encountered';
    DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT 'SQLException encountered';
    DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT 'SQLSTATE 23000';
    
    INSERT INTO bet_info_2022(selection, date_placed, league, settle_year, bet_type, site, odds_multiplier, principle, status, result)
	VALUES (selection, date_placed, league, settle_year, bet_type, site, odds_multiplier, principle, status, result);
	
END //
DELIMITER ;

# Updating database

DROP PROCEDURE IF EXISTS bet_update_2022;
DELIMITER // 
CREATE PROCEDURE bet_update_2022(IN betID_selection INT,
                            IN new_status CHAR(1),
                            IN new_result DECIMAL(15,2)
                            )
BEGIN
	DECLARE EXIT HANDLER FOR 1062 SELECT 'Duplicate keys error encountered';
    DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT 'SQLException encountered';
    DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT 'SQLSTATE 23000';
    
    UPDATE bet_info_2022
	SET status = new_status, result = new_result
    WHERE betID = betID_selection;

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS bet_update_2021;
DELIMITER // 
CREATE PROCEDURE bet_update_2021(IN betID_selection INT,
                            IN new_status CHAR(1),
                            IN new_result DECIMAL(15,2)
                            )
BEGIN
	DECLARE EXIT HANDLER FOR 1062 SELECT 'Duplicate keys error encountered';
    DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT 'SQLException encountered';
    DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT 'SQLSTATE 23000';
    
    UPDATE bet_info_2021
	SET status = new_status, result = new_result
    WHERE betID = betID_selection;

END //
DELIMITER ;
DROP PROCEDURE IF EXISTS bet_delete_2022;
DELIMITER // 
CREATE PROCEDURE bet_delete_2022(IN my_betID INT)
BEGIN
	DECLARE EXIT HANDLER FOR 1062 SELECT 'Duplicate keys error encountered';
    DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT 'SQLException encountered';
    DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT 'SQLSTATE 23000';
    
    DELETE FROM bet_info_2022
    WHERE betID = my_betID;

END //
DELIMITER ;
SET SQL_SAFE_UPDATES = 0;

# UPDATE AS WIN
UPDATE bet_info_2022
SET status = "W", result = principle*odds_multiplier + principle
WHERE status = "A" AND bet_type = "Australian Open" AND selection = "Rafael Nadal";


# UPDATE AS LOSS
UPDATE bet_info_2022
SET status = "L", result = 0
WHERE status = "A" AND bet_type = "Australian Open" AND selection != "Rafael Nadal";

UPDATE bet_info
SET status = "C", result = 75.80
WHERE betID = 100123;

UPDATE bet_info
SET status = "C", result = 102.74
WHERE betID = 100077;

SELECT *
FROM bet_info
WHERE selection = "Julius Randle";

UPDATE bet_info
SET status = "C", result = 426.86
WHERE betID = 100078;




 