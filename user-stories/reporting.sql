--As a publisher, I want our analysts to be able to query the account management system to report the popularity of all our published title --SQL1

select g.game_name,count(*) as player_count from rocket_wh.player_games pg
 join rocket_wh.games g
 on pg.game_id=g.game_id
 where pg.game_subscription_end_date > current_date()
 group by pg.game_id,g.game_name order by 2 desc;

-------------------------------------------------------------------------------------------------------------------------
--As a publisher, I want out analysts to be able to query the account management system to report a list of all the players playing on a given studios' titles
--Assumed ? game_name comes data from api (game_name-The Armor) --SQL2

 select s.studio_name,g.game_name,p.player_name,p.user_id from rocket_wh.studio s
   join rocket_wh.games g
 on s.studio_id=g.studio_id
 join rocket_wh.player_games pg
 on pg.game_id = g.game_id
 join rocket_wh.player p
 on p.player_id = pg.player_id
 where g.game_name= '?'
 and pg.game_subscription_end_date >= current_date();
-------------------------------------------------------------------------------------------------------------------------
--As a publisher, I want to be able to use non Personal Identifiable Data (PII) from closed accounts in my reports  --SQL3
 select s.studio_name,g.game_name,p.user_id from rocket_wh.studio s
   join rocket_wh.games g
 on s.studio_id=g.studio_id
 join rocket_wh.player_games pg
 on pg.game_id = g.game_id
 join rocket_wh.player p
 on p.player_id = pg.player_id
 where  pg.game_subscription_end_date < current_date();
-------------------------------------------------------------------------------------------------------------------------

 ---As a studio owner, I want to be able to unregister a user from one or more games in our collection --SQL4
 --Assumed ? game_name comes data from api(game_name-The Armor)
 Update rocket_wh.player_games set game_subscritpiton_start_date = current_date()
 where Game_id in (select g.game_id from rocket_wh.games g join rocket_wh.player_games pg on g.game_id =pg.game_id where g.game_name='?')
-----------------------------------------------------------------------------------------------------------------------------------------------


--As a studio owner, I want to query the account management system to report the popularity of all our published games
--Assumed ? studio_name comes data from api (Molestie In Company) --SQL5
select g.game_name,count(*) as player_count from rocket_wh.player_games pg
 join rocket_wh.games g
 on pg.game_id=g.game_id
 join rocket_wh.studio s
 on s.studio_id = g.studio_id
 where pg.game_subscription_end_date > current_date()
 and s.studio_name = '?'
 group by pg.game_id,g.game_name order by 2 desc;

-----------------------------------------------------------------------------------------------------------------------------------------------


