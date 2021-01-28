--creating a role for publisher
use role SECURITYADMIN;

CREATE ROLE IF NOT EXISTS rg_publisher;
--schema rocket_stg
GRANT ownership on database rocket_games_db to role rg_publisher REVOKE CURRENT GRANTS;
GRANT all on  schema rocket_games_db.rocket_stg to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all sequences in schema rocket_games_db.rocket_stg to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all tasks in schema rocket_games_db.rocket_stg to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all streams in schema rocket_games_db.rocket_stg to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all file formats in schema rocket_games_db.rocket_stg to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all functions in schema rocket_games_db.rocket_stg to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all procedures in schema rocket_games_db.rocket_stg to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all tables in schema rocket_games_db.rocket_stg to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all stages in schema rocket_games_db.rocket_stg to role rg_publisher REVOKE CURRENT GRANTS;
GRANT operate, usage, monitor on warehouse rg_wh to role rg_publisher;
GRANT role rg_publisher to role rg_sysadmin;
--schema rocket_wh
GRANT ownership on database rocket_games_db to role rg_publisher REVOKE CURRENT GRANTS;
GRANT all on  schema rocket_games_db.rocket_wh to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all sequences in schema rocket_games_db.rocket_wh to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all tasks in schema rocket_games_db.rocket_wh to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all streams in schema rocket_games_db.rocket_wh to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all file formats in schema rocket_games_db.rocket_wh to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all functions in schema rocket_games_db.rocket_wh to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all procedures in schema rocket_games_db.rocket_wh to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all tables in schema rocket_games_db.rocket_wh to role rg_publisher REVOKE CURRENT GRANTS;
GRANT ownership on all stages in schema rocket_games_db.rocket_wh to role rg_publisher REVOKE CURRENT GRANTS;
GRANT operate, usage, monitor on warehouse rg_wh to role rg_publisher;
GRANT role rg_publisher to role rg_sysadmin;

--creating a role for studio
use role SECURITYADMIN;

CREATE ROLE IF NOT EXISTS rg_studio;
--schema rocket_stg
GRANT usage on database rocket_games_db to role rg_studio;
GRANT usage on schema rocket_games_db.rocket_stg to role rg_studio;
GRANT select on all tables in schema rocket_games_db.rocket_stg to role rg_studio;
GRANT select on all views in schema rocket_games_db.rocket_stg to role rg_studio;
GRANT usage, monitor on warehouse rg_wh to rg_studio;
GRANT role rg_purg_studioblisher to role rg_sysadmin;

--schema rocket_wh
GRANT usage on database rocket_games_db to role rg_studio;
GRANT usage on schema rocket_games_db.rocket_wh to role rg_studio;
GRANT select on all tables in schema rocket_games_db.rocket_wh to role rg_studio;
GRANT select on all views in schema rocket_games_db.rocket_wh to role rg_studio;
GRANT usage, monitor on warehouse rg_wh to rg_studio;
GRANT role rg_purg_studioblisher to role rg_sysadmin;
