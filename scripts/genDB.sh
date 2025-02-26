#!/bin/bash

svcName=${1}

# serviceServer
export NAMESPACE="local"
cd ../../../${svcName} && go run dao/cmd/generate.go