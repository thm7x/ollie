#!/bin/bash

svcName=${1}

# serviceServer
mkdir -p kitex_gen
cwgo server --type RPC  --service ${svcName}  --module code.pypygo.com/vertex/ollie/apps/${svcName} --pass "-no-fast-api" -I ../../protos/apps -I ../../protos/lib -I ../../protos/onlykitex --idl ../../protos/apps/${svcName}/api.proto  -template /home/fire/vertex/devkit/_tpl/kitex-app/server/standard

# service proto validator with buf
cd ../../ && buf generate --template apps/${svcName}/buf.gen.yaml  protos/apps/${svcName}/api.proto