#!/bin/bash

docker build --no-cache --tag nginx-quic .

ID=$(docker create nginx-quic)
docker cp $ID:/build/nginx-quic/objs/nginx .
docker rm $ID
