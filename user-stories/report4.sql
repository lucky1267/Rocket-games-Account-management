 ---As a studio owner, I want to be able to unregister a user from one or more games in our collection --SQL4
 --Assumed ? game_name comes data from api(game_name-The Armor)
 Update rocket_wh.player_games set game_subscritpiton_start_date = current_date()
 where Game_id in (select g.game_id from rocket_wh.games g join rocket_wh.player_games pg on g.game_id =pg.game_id where g.game_name='?')