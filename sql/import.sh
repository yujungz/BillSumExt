echo 开始初始化...

PRM_DKNAME=BillSumExt-mysql
PRM_DBPWD=Bill1@3
PRM_DBNAME=all
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} mysql < ./createdb.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./sum_all.sql
PRM_DBNAME=ai
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_channels.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_tokens.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_users.sql

PRM_DBNAME=csp
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_channels.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_tokens.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_users.sql

PRM_DBNAME=digitalcloud
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_channels.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_tokens.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_users.sql

PRM_DBNAME=pinova
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_channels.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_tokens.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_users.sql

PRM_DBNAME=qn
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_channels.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_tokens.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_users.sql

PRM_DBNAME=wshk
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_channels.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_tokens.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_users.sql

PRM_DBNAME=wzg
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_channels.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_tokens.sql
docker exec -i ${PRM_DKNAME} mysql --default-character-set=utf8mb4 -uroot -p${PRM_DBPWD} sum_${PRM_DBNAME} < ./${PRM_DBNAME}_ex_users.sql

