--As a publisher, I want to be able to use non Personal Identifiable Data (PII) from closed accounts in my reports  --SQL3
 select s.studio_name,g.game_name,p.user_id from rocket_wh.studio s
   join rocket_wh.games g
 on s.studio_id=g.studio_id
 join rocket_wh.player_games pg
 on pg.game_id = g.game_id
 join rocket_wh.player p
 on p.player_id = pg.player_id
 where  pg.game_subscription_end_date < current_date();
