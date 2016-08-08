#!/bin/bash

set -x

: ${CF_HOST:?"CF_HOST is required, which should be the app domain that apps will run under"}
: ${NO_ROUTE_ADDR:?"NO_ROUTE_ADDR is required, which should be the host or IP that you want to try hitting a routeless node on"}

pushd node-no-route
  mvn clean package
  cf push
  HAZELCAST_ADDR=$NO_ROUTE_ADDR mvn verify
  no_route_exit=$?
  cf delete node -f
popd

pushd node-http-route
  mvn clean package
  cf push
  HAZELCAST_ADDR=node.$CF_HOST mvn verify
  http_route_exit=$?
popd

pushd hazelcast-example-app
  mvn clean package
  cf push --no-start
  cf set-env hazelcast-example-app ADDRESSES node.$CF_HOST
  cf start hazelcast-example-app
  example_start=$?
popd

cf delete hazelcast-example-app -f
cf delete node -f

if [ $no_route_exit -ne 0 ]; then
  echo "Test against node running with no route did not pass"
fi

if [ $http_route_exit -ne 0 ]; then
  echo "Test against node running with HTTP route did not pass"
fi

if [ $example_start -ne 0 ]; then
    echo "Example app failed to start, probably because it could not talk to the Hazelcast node"
fi