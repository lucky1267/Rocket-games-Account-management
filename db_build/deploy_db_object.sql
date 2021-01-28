use role SECURITYADMIN;

==== Creation of Database
CREATE DATABASE IF NOT EXISTS rocket_games_db DATA_RETENTION_TIME_IN_DAYS=10 comment = 'Rocket Games Publisher Database';


==== Creation of Warehouses ====
CREATE WAREHOUSE rg_wh WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 600
 AUTO_RESUME = TRUE MIN_CLUSTER_COUNT = 1 MAX_CLUSTER_COUNT = 1 SCALING_POLICY = 'STANDARD';

==== Creation of Schema ====
create schema if not exists rocket_stg;

create schema if not exists rocket_wh;

=======Creation of Stages =====

create or replace stage rg_stg.stage_s3_ingest url = 's3://rocket-games-ingest-s3/';

=======Creation of File-Formats =====
CREATE FILE FORMAT "ROCKET_STG".ROCKET_STG_CSV TYPE = 'CSV' COMPRESSION = 'AUTO' FIELD_DELIMITER = ',' RECORD_DELIMITER = '\n'
SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' TRIM_SPACE = FALSE ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE ESCAPE = 'NONE'
ESCAPE_UNENCLOSED_FIELD = '\134' DATE_FORMAT = 'DD/MM/YYYY' TIMESTAMP_FORMAT = 'AUTO' NULL_IF = ('\\N');

-- list and show the stages
show stages;
list @rg_stg.stage_s3_ingest;

--creating snow pipe

create or replace pipe rocket_games_player_stream
auto_ingest=TRUE
as COPY INTO rocket_stg.player_stg
FROM @rg_stg.stage_s3_ingest/stage_data/player/
FILE_FORMAT = ROCKET_STG.ROCKET_STG_CSV;

create or replace pipe rocket_games_stream
auto_ingest=TRUE
as COPY INTO rocket_stg.player_stg
FROM @rg_stg.stage_s3_ingest/stage_data/games/
FILE_FORMAT = ROCKET_STG.ROCKET_STG_CSV;

create or replace pipe rocket_game_player_map_stream
auto_ingest=TRUE
as COPY INTO rocket_stg.player_game_map_stg
FROM @rg_stg.stage_s3_ingest/stage_data/player_game_map/
FILE_FORMAT = ROCKET_STG.ROCKET_STG_CSV;

show pipes; --Extract notification channel value and configure this in S3 bucket events

