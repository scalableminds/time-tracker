#!/bin/bash

if [ $# -lt 3 ]; then
  echo "Usage: $0 project_name branch build_number"
  exit 1
fi

export JOB_NAME=$1
export GIT_BRANCH=$2
export BUILD_NUMBER=$3

`dirname $0`/build.sh