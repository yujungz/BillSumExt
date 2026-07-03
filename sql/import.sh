chcp 65001
@echo off
echo 开始初始化...

set PRM_DKNAME=BillSumExt-mysql
set PRM_DBPWD=Bill1@3
set PRM_DBNAME=all
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% mysql < ./createdb.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./sum_all.sql
set PRM_DBNAME=ai
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_channels.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_tokens.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_users.sql

set PRM_DBNAME=csp
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_channels.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_tokens.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_users.sql

set PRM_DBNAME=digitalcloud
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_channels.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_tokens.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_users.sql

set PRM_DBNAME=pinova
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_channels.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_tokens.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_users.sql

set PRM_DBNAME=qn
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_channels.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_tokens.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_users.sql

set PRM_DBNAME=wshk
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_channels.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_tokens.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_users.sql

set PRM_DBNAME=wzg
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_channels.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_tokens.sql
docker exec -i %PRM_DKNAME% mysql --default-character-set=utf8mb4 -uroot -p%PRM_DBPWD% sum_%PRM_DBNAME% < ./%PRM_DBNAME%_ex_users.sql


echo 初始化结束！

pause
echo on

