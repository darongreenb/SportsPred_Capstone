DROP DATABASE IF EXISTS sportsb;
CREATE DATABASE IF NOT EXISTS sportsb;

USE sportsb;

DROP TABLE IF EXISTS bet_info_2022;
CREATE TABLE IF NOT EXISTS bet_info_2022(
	betID INT AUTO_INCREMENT,
    selection VARCHAR(50),
    league VARCHAR(50),
    date_placed DATE,
    settle_year CHAR(4),
    bet_type VARCHAR(50),
    site VARCHAR(50),
    odds_multiplier DECIMAL(15,4),
    principle DECIMAL(15,2),
    status CHAR(1),
    result DECIMAL(15,2),
    PRIMARY KEY(betID)
) ENGINE = INNODB;

CREATE TABLE bet_info_2020 AS SELECT * FROM bet_info_2021;
RENAME TABLE
	bet_info TO bet_info_2021;

LOAD DATA INFILE 'c:\\wamp64\\tmp\\SportsFutures.csv'
INTO TABLE bet_info
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;