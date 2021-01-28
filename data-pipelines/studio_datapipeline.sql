 ---- Merge statement for Studio

create or replace temporary table temp_studio as
select *from (select studio_name,studio_location from rocket_stg.studio_games_stg group by studio_name,studio_location );



 MERGE INTO rocket_wh.studio s USING temp_studio ts
    ON s.studio_name = ts.studio_name
    WHEN MATCHED THEN
        UPDATE set s.studio_location = ts.STUDIO_LOCATION
     WHEN NOT MATCHED THEN
				   INSERT
                   (s.studio_name,
                   s.studio_location)
                   VALUES
                   (ts.studio_name,
                   ts.studio_location);