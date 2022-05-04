USE sportsb;

SELECT *
FROM bet_info
WHERE selection = "N. Jokic";

# Active Principle by Bet
SELECT bet_type, SUM(principle) as principle_total
FROM bet_info_2022
WHERE status = 'A'
GROUP BY bet_type
ORDER BY principle_total DESC;

# Principle by Site
SELECT site, SUM(principle) as principle_total
FROM bet_info_2022
WHERE status = 'A'
GROUP BY site;


# Total Money On Board

SELECT SUM(principle) AS MYMONEYYY, league
FROM bet_info_2022
WHERE status = "A"
GROUP BY league;

# Current Profits
SELECT bet_type, SUM(result - principle) AS NET_PROFIT
FROM bet_info_2022
WHERE status IN ("W", "L", "C")
GROUP BY bet_type;

SELECT bet_info_2022.league, SUM(result - principle) AS NET_PROFIT, 
SUM(principle) as total_principle, a.money_cashed
FROM bet_info_2022 JOIN
(SELECT SUM(result) AS money_cashed, league
FROM bet_info_2022
WHERE status = "C"
GROUP BY league) as a
ON bet_info_2022.league = a.league
WHERE status IN ("W", "L", "C")
GROUP BY a.league
;


# Potential Profit Per Bet (NBA)

SELECT bet_type, selection, 
	SUM(principle * odds_multiplier) - (c.bet_principle - SUM(principle)) AS potential_profit,
    c.bet_principle AS total_principle_inc
FROM bet_info_2022 b JOIN
	(SELECT bet_type, SUM(principle) AS bet_principle
    FROM bet_info_2022
    WHERE status = "A"
    GROUP BY bet_type) AS c USING(bet_type)
WHERE status = "A" -- AND league = "NBA"
GROUP BY bet_type, selection
ORDER BY bet_type, selection, potential_profit;
