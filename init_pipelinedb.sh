#!/bin/bash

service_name=$1
container_name=dockervaultpipelinedb_${service_name}_1

if [ "$service_name" = "pipelinedb" ]; then
  docker exec -it $container_name \
    su - pipeline -c "pipeline -p 5432 -d pipeline -c '
ACTIVATE;
CREATE STREAM wiki_stream (hour timestamp, project text, title text, view_count bigint, size bigint);
CREATE CONTINUOUS VIEW wiki_stats AS
SELECT hour, project,
        count(*) AS total_pages,
        sum(view_count) AS total_views,
        min(view_count) AS min_views,
        max(view_count) AS max_views,
        avg(view_count) AS avg_views,
        percentile_cont(0.99) WITHIN GROUP (ORDER BY view_count) AS p99_views,
        sum(size) AS total_bytes_served
FROM wiki_stream
GROUP BY hour, project;'"
else
  docker exec -it $container_name \
    pipeline -U pipeline -p 5432 -d pipeline -c "
CREATE STREAM wiki_stream (hour timestamp, project text, title text, view_count bigint, size bigint);
CREATE CONTINUOUS VIEW wiki_stats AS
SELECT hour, project,
        count(*) AS total_pages,
        sum(view_count) AS total_views,
        min(view_count) AS min_views,
        max(view_count) AS max_views,
        avg(view_count) AS avg_views,
        percentile_cont(0.99) WITHIN GROUP (ORDER BY view_count) AS p99_views,
        sum(size) AS total_bytes_served
FROM wiki_stream
GROUP BY hour, project;"
fi

docker exec -it dockervaultpipelinedb_vault_1 \
  vault mount -address=http://localhost:8200 -path $service_name postgresql

docker exec -it dockervaultpipelinedb_vault_1 \
  vault write -address=http://localhost:8200 $service_name/config/connection \
    connection_url="postgresql://pipeline:pipeline@${service_name}:5432/pipeline?sslmode=disable"

docker exec -it dockervaultpipelinedb_vault_1 \
  vault write -address=http://localhost:8200 $service_name/roles/readonly \
    sql="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
