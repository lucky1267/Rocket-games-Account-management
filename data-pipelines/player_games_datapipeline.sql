 ---This data-pipeline is responsible for loading data into player games table.

create or replace temporary table temp_player_games as
 select *from (select
               g.game_id,
               p.player_id,
               ps.game_name,
               ps.game_subscription_start_date,
               ps.game_subscription_end_date,
              p.ACCOUNT_START_DATE,
              p.ACCOUNT_END_DATE from rocket_stg.player_stg ps
              join rocket_wh.player p
              on ps.user_id = p.user_id
              join rocket_wh.games g
              on g.game_name = ps.game_name);



MERGE INTO rocket_wh.player_games pg USING temp_player_games tpg
    ON pg.game_id = tpg.game_id
    and pg.player_id = tpg.player_id
    and pg.game_subscription_start_date = tpg.game_subscription_start_date
    WHEN MATCHED THEN
        UPDATE set pg.GAME_SUBSCRIPTION_END_DATE = case when tpg.account_end_date is null
                                                   then tpg.GAME_SUBSCRIPTION_END_DATE
                                                   else tpg.ACCOUNT_END_DATE
                                                   end
     WHEN NOT MATCHED THEN
				   INSERT
                   (pg.player_id,
                     pg.game_id,
                   pg.GAME_SUBSCRIPTION_START_DATE,
                   pg.GAME_SUBSCRIPTION_END_DATE)
                   VALUES
                   (tpg.player_id,
                     tpg.game_id,
                   tpg.GAME_SUBSCRIPTION_START_DATE,
                   tpg.GAME_SUBSCRIPTION_END_DATE);