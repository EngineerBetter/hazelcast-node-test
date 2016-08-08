# hazelcast-node-test

Quick script to demonstrate that a Hazelcast node running as a CF app cannot be communicated to, without TCP routing or container networking. Neither of these features are enabled in mainstream PCF at present.

## To run

The script assumes that you're logged into Cloud Foundry, and are targetting a space where you can push apps.

`CF_HOST` should be the app domain of your Cloud Foundry.

`NO_ROUTE_ADDR` is an address to try testing the Hazelcast node when it's given no HTTP route; perhaps an IP address of the Diego cell you think it's running on?

```
CF_HOST=apps.your-cf.com \
NO_ROUTE_ADDR=123.123.123.123 \
./test.sh
```

The script will output a summary at the end, and takes a few minutes to run.

It is expected that all tests will fail, as containers in Cloud Foundry cannot communicate with each other directly. TCP communications to apps in Cloud Foundry are only possible if TCP routing is enabled (not the case for most instances), and a TCP route created.