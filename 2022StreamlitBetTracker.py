# -*- coding: utf-8 -*-
"""
Created on Tue Oct 26 11:04:56 2021

@author: DaronG
"""


import streamlit as st
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import mysql.connector
from getpass import getpass
from mysql.connector import connect, Error
import pandas as pd
from datetime import datetime
from datetime import date


## Connecting to sportsb database

try:
    with connect(
        host="localhost",
        port = 3308,
        user= 'root', #input("Enter username: "),
        password= '', #getpass("Enter password: "),
        database = 'sportsb',
    ) as cnx:
        print(cnx)
except Error as e:
    print(e)

cnx.reconnect()
cursor = cnx.cursor()
 

## Functions

def newEntry(selection, league, date, settle_year, bet_type, site, odds_multiplier, 
             principle, status, result):
    cursor.callproc('bet_entry_2022', [selection, date, league, settle_year, 
            bet_type, site, odds_multiplier, principle, status, result])
    cnx.commit()
    
    # TESTING 
    query = "SELECT * FROM sportsb.bet_info_2022;" # For View
    cursor.execute(query)
    results = cursor.fetchall()
    DF = pd.DataFrame(results)
    st.write(DF.tail())

def makeUpdate(betID_selection, new_status, new_result):
    cursor.callproc('bet_update_2022', [betID_selection, new_status, new_result])
    cnx.commit()
    
    # TESTING 
    query = f"SELECT * FROM sportsb.bet_info_2022 WHERE betID = {betID_selection};" # For View
    cursor.execute(query)
    results = cursor.fetchall()
    DF = pd.DataFrame(results)
    st.markdown(f"{DF}")

def makeDelete(betID_selection):
    cursor.callproc('bet_delete_2022', [betID_selection])
    cnx.commit()
    
    # TESTING 
    query = f"SELECT * FROM sportsb.bet_info_2022 WHERE betID = {betID_selection};" # For View
    cursor.execute(query)
    results = cursor.fetchall()
    DF = pd.DataFrame(results)
    st.markdown(f"{DF}")
    
def graphingBetOutcome():
    #nada
    print('nada')

#########

bettingSites = ["Barstool","BetMGM","Caesars", "DraftKings", "Fanduel", "PointsBet", "WynnBet" ]
leagues = ["NBA", "NFL", "USTA Men's", "USTA Women's"]
statuses = ["A", "C", "L", "W"]
NBA_bets = ["6th Man", "Assists", "Championship", "championship_pick", "COTY", 
            "DPOY", "Eastern Conference","Finals MVP", "Make Playoffs", "MIP",
            "MVP", "Northwest Division", "Rebounding", "Rebounding Group A", 
            "ROTY", "Scoring", "Western Conference", "Conference Seeding"]
USTAM_bets = ["Australian Open", "French Open", "Wimbledon", "US Open",
              "AO: Stage of Elimination", "AO: Finals Matchup"]
USTAW_bets = ["Australian Open", "French Open", "Wimbledon", "US Open"]

def main():
    # CRUD interface
    st.title('Sports Trading Tracker')
    
    menu = ['Entry', "Portfolio Analysis", 'Update/Delete', 'Bet Table']
    choice = st.sidebar.selectbox("Menu", menu)
    
    # bet entry page
    
    if choice == 'Entry':
        selection = st.text_input("Bet Selection", max_chars = 30)
        date= st.date_input("Date")
        site = st.selectbox("Betting Site", bettingSites)
        league = st.selectbox("Sports League", leagues)
        if league == "NFL":
            settle_year = 2023
        else:
            settle_year = 2022
        if league == "NBA":
            bet_type = st.selectbox("Bet Type", NBA_bets)
        elif league == "USTA Men's":
            bet_type = st.selectbox("Bet Type", USTAM_bets)
        elif league == "USTA Women's":
            bet_type = st.selectbox("Bet Type", USTAW_bets)
        else:
            bet_type = st.text_input("Bet Type")
        odds_multiplier = st.text_input("Odds Multiplier")#slider("Odds", 0.00,1000.00, step = .01)
        principle = st.text_input("Principle")#st.slider("Principle", 0, 2000)
        status = st.selectbox("Status", statuses)
        result = st.text_input("Payout")#st.slider("Payout", 0.00,10000.00, step = .01)
            
        insertButton = st.button("Submit Bet!")
        if insertButton:
            newEntry(selection, date, league, settle_year, bet_type, site, 
                     float(odds_multiplier), float(principle), status, 
                     float(result))
    elif choice == 'Portfolio Analysis':
        league = st.radio("Sports League", leagues)
        if league == "NFL":
            settle_year = 2023
        else:
            settle_year = 2022
        if league == "NBA":
            bet_type = st.selectbox("Bet Type", NBA_bets)
        elif league == "USTA Men's":
            bet_type = st.selectbox("Bet Type", USTAM_bets)
        elif league == "USTA Women's":
            bet_type = st.selectbox("Bet Type", USTAW_bets)
        else:
            bet_type = st.text_input("Bet Type")
        query = f"""SELECT bet_type, selection, 
                    	SUM(principle * odds_multiplier) - (c.bet_principle - SUM(principle)) AS potential_profit,
                        c.bet_principle AS total_principle_inc
                    FROM bet_info_2022 b JOIN
                    	(SELECT bet_type, SUM(principle) AS bet_principle
                        FROM bet_info_2022
                        WHERE status = "A"
                        GROUP BY bet_type) AS c USING(bet_type)
                    WHERE status = "A" AND league = "{league}" AND bet_type = "{bet_type}"
                    GROUP BY bet_type, selection
                    ORDER BY bet_type, selection, potential_profit;"""
        cursor.execute(query)
        results = cursor.fetchall()
        DF = pd.DataFrame(results, columns = ['bet type', 'selection', 'profit', 'total principal'])
        DF.sort_values(by = 'profit', inplace = True)
        plt.bar(DF['selection'], DF['profit'], color = ["red" if y <= 0  else "green" for y in DF['profit']])
        plt.xticks(rotation=60, fontsize= 5)
        #plt.yticks([])
        plt.ylabel("Net Profit")
        st.pyplot()
        
            
    elif choice == 'Update/Delete':
        betID_selection = (st.text_input("Bet ID", max_chars = 30))
        new_status = st.selectbox("Status", statuses)
        new_result = st.slider("Payout", 0.00,10000.00, step = .01)
        
        updateButton = st.button("Make Update!")
        deleteButton = st.button("Delete Entry!")
        if updateButton:
            makeUpdate(int(betID_selection), new_status, new_result)
        elif deleteButton:
            makeDelete(int(betID_selection))
            
    elif choice == 'Bet Table':
        query = f"SELECT * FROM sportsb.bet_info_2022"
        cursor.execute(query)
        results = cursor.fetchall()
        DF = pd.DataFrame(results)
        st.write(DF.tail(20))
        

if __name__ == '__main__':
    main()

