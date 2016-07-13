#!/usr/bin/env bash

PORT=${PORT-9000}

source "$(dirname "$0")/helper.bash"

run_test "curl localhost:$PORT" retry 20 5 curl -v http://localhost:$PORT
