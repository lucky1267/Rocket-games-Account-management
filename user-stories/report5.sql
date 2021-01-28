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