--This Script creates staging tables,warehouse tables
-----Creating Stage Tables---
CREATE TABLE IF NOT EXISTS rocket_stg.player_stg(
Player_Name VARCHAR,
Player_country	VARCHAR,
User_ID	VARCHAR,
Game_name	VARCHAR,
Game_Subscription_Start_date	Date,
Game_Subscription_End_date DATE,
Account_status Varchar);


CREATE TABLE IF NOT EXISTS rocket_stg.games_stg(Game_Name	VARCHAR,
STUDIO_Name VARCHAR,
Studio_Location Varchar,
Game_Categeory Varchar
);



---SEQUENCE
CREATE SEQUENCE "rocket_games_db"."ROCKET_WH".RG_SEQUENCE START 1 INCREMENT 1;

CREATE SEQUENCE "rocket_games_db"."ROCKET_WH".RG_GAME_SEQ START 1000 INCREMENT 1;

CREATE SEQUENCE "rocket_games_db"."ROCKET_WH".RG_STUDIO_SEQ START 101 INCREMENT 100;

---WH Tables

CREATE TABLE IF NOT EXISTS rocket_wh.Player
(Player_ID	number default rg_sequence.nextval not null,
 Player_Name Varchar,
 Player_country Varchar,
 User_ID Varchar not null,
Account_Start_date	Date not null,
Account_end_date	Date );

CREATE TABLE IF NOT EXISTS rocket_wh.studio
(Studio_ID	number default RG_STUDIO_SEQ.nextval not null,
 Studio_Name Varchar not null,
 Studio_Location Varchar);


CREATE TABLE IF NOT EXISTS rocket_wh.games
(Game_Id	number default RG_GAME_SEQ.nextval not null,
 Game_Name Varchar,
 Game_Categeory Varchar,
 Studio_ID number not null);


CREATE TABLE IF NOT EXISTS rocket_wh.Player_Games
(Player_ID	varchar not null,
Game_ID VARCHAR  not null,
Game_Subscription_Start_date	Date not null,
Game_Subscription_End_date	Date
);

