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