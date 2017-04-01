test_revoke: read_creds
	# Succeccful in PostgreSQL
	docker exec -it dockervaultpipelinedb_vault_1 \
	  vault revoke -address=http://localhost:8200 `grep "lease_id" tmp_postgresql_creds.log | cut -f2 | tr -d '\r\n'`
	# Failed in PipelineDB
	docker exec -it dockervaultpipelinedb_vault_1 \
	  vault revoke -address=http://localhost:8200 `grep "lease_id" tmp_pipelinedb_creds.log | cut -f2 | tr -d '\r\n'` || true
	# In PipelineDB 0.9.7
	docker exec -it dockervaultpipelinedb_vault_1 \
	  vault revoke -address=http://localhost:8200 `grep "lease_id" tmp_pipelinedb-097_creds.log | cut -f2 | tr -d '\r\n'`

read_creds:
	docker exec -it dockervaultpipelinedb_vault_1 \
	  vault read -address=http://localhost:8200 pipelinedb/creds/readonly \
	    | tee tmp_pipelinedb_creds.log
	docker exec -it dockervaultpipelinedb_vault_1 \
	  vault read -address=http://localhost:8200 postgresql/creds/readonly \
	    | tee tmp_postgresql_creds.log
	docker exec -it dockervaultpipelinedb_vault_1 \
	  vault read -address=http://localhost:8200 pipelinedb-097/creds/readonly \
	    | tee tmp_pipelinedb-097_creds.log

init: init_containers init_postgresql init_pipelinedb init_pipelinedb_fixed

init_containers:
	docker-compose up -d
	sleep 10

init_postgresql:
	./init_postgresql.sh

init_pipelinedb:
	./init_pipelinedb.sh pipelinedb

init_pipelinedb_fixed:
	./init_pipelinedb.sh pipelinedb-097

clean:
	docker-compose stop
	docker-compose rm -f
	rm -f tmp_*.log
