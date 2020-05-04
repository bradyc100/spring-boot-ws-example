#!/bin/bash

IMAGE_ID=(`docker ps | grep postgres`)
echo "Attaching to image id ${IMAGE_ID}"

docker exec -it $IMAGE_ID psql -U postgres -f /docker-entrypoint-initdb.d/mock-data.sql
