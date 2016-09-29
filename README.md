# docker-vault-pipelinedb

```
$ make init
$ make test_revoke
...

# Failed in PipelineDB
docker exec -it dockervaultpipelinedb_vault_1 \
          vault revoke -address=http://localhost:8200 `grep "lease_id" tmp_pipelinedb_creds.log | cut -f2 | tr -d '\r\n'`
Revoke error: Error making API request.

URL: PUT http://localhost:8200/v1/sys/revoke/pipelinedb/creds/readonly/1b30406a-d9c7-8108-6418-d97cded1704a
Code: 400. Errors:

* failed to revoke entry: resp:(*logical.Response)(nil) err:could not perform all revocation statements: pq: cache lookup failed for attribute -7 of relation 16397
make: *** [test_revoke] Error 1

$ docker-compose logs pipelinedb
...

pipelinedb_1  | ERROR:  cache lookup failed for attribute -7 of relation 16397
pipelinedb_1  | STATEMENT:  REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA "public" FROM "token-377da77c-b17d-fdae-4244-fe2f251b650b";
pipelinedb_1  | ERROR:  cache lookup failed for attribute -7 of relation 16397
pipelinedb_1  | STATEMENT:  REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM "token-377da77c-b17d-fdae-4244-fe2f251b650b";
```
