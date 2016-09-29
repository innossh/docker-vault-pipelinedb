#!/bin/bash

docker exec -it dockervaultpipelinedb_postgresql_1 \
  su postgres -c "psql -p 5432 -d postgres -c '
CREATE TABLE table_name(
  hour timestamp,
  project text,
  total_pages bigint,
  total_views numeric,
  min_views bigint,
  max_views bigint,
  avg_views numeric,
  p99_views double precision,
  total_bytes_served numeric,
  PRIMARY KEY( hour, project )
);
'"

docker exec -it dockervaultpipelinedb_vault_1 \
  vault mount -address=http://localhost:8200 -path postgresql postgresql

docker exec -it dockervaultpipelinedb_vault_1 \
  vault write -address=http://localhost:8200 postgresql/config/connection \
    connection_url="postgresql://postgres:postgres@postgresql:5432/postgres?sslmode=disable"

docker exec -it dockervaultpipelinedb_vault_1 \
  vault write -address=http://localhost:8200 postgresql/roles/readonly \
    sql="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
