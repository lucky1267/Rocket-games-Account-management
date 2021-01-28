-- This datapipe line is responsible for merging the player stage data to player table.

MERGE INTO rocket_wh.player p USING rocket_stg.player_stg ps
    ON p.user_id = ps.user_id
    WHEN MATCHED THEN
        UPDATE set p.account_end_date = CASE WHEN ps.account_status ='N'
                                             then current_date()
                                        ELSE NULL
                                        end
     WHEN NOT MATCHED THEN
				   INSERT
                   (p.player_name,
                   p.Player_country,
                   p.user_id,
                   p.account_Start_date,
                   p.account_End_date)
                   VALUES
                   (ps.player_name,
                   ps.Player_country,
                   ps.user_id,
                   CURRENT_DATE(),
                   NULL);