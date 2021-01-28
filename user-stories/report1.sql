--As a publisher, I want our analysts to be able to query the account management system to report the popularity of all our published title --SQL1

select g.game_name,count(*) as player_count from CYDEV_CLONE_10.rocket_wh.player_games pg
 join CYDEV_CLONE_10.rocket_wh.games g
 on pg.game_id=g.game_id
 where pg.game_subscription_end_date > current_date()
 group by pg.game_id,g.game_name order by 2 desc;
