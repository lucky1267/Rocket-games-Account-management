 ---This is game datapipe line

  create or replace TEMPORARY TABLE temp_games AS
   SELECT *FROM (SELECT distinct gs.studio_name,
                gs.studio_location,
                gs.game_name,
                gs.GAME_CATEGEORY,
                s.studio_id from
                rocket_stg.studio_games_stg gs
                join rocket_wh.studio s
                on gs.Studio_Name=s.Studio_Name
               );

 MERGE INTO rocket_wh.games g USING temp_games tg
    ON g.game_name = tg.game_name
    WHEN MATCHED THEN
        UPDATE set g.GAME_CATEGEORY = tg.GAME_CATEGEORY
     WHEN NOT MATCHED THEN
				   INSERT
                   (g.game_name,
                   g.GAME_CATEGEORY,
                   g.studio_id)
                   VALUES
                   (tg.game_name,
                   tg.GAME_CATEGEORY,
                   tg.studio_id  );