#!/bin/bash

svcName=${1}

# serviceClient
cd protos_gen && cwgo client --type RPC --service ${svcName}  --module code.pypygo.com/vertex/ollie/protos_gen --pass "-no-fast-api"  -I ../protos/apps -I ../protos/lib  --idl ../protos/apps/${svcName}/api.proto -template /home/fire/vertex/devkit/_tpl/kitex-app/client/standard

# serviceServer
cd ../apps/${svcName} && cwgo server --type RPC  --service ${svcName}  --module code.pypygo.com/vertex/ollie/apps/${svcName} --pass "-use code.pypygo.com/vertex/ollie/protos_gen/kitex_gen"  -I ../../protos/apps -I ../../protos/lib --idl ../../protos/apps/${svcName}/api.proto -template /home/fire/vertex/devkit/_tpl/kitex-app/server/standard

# go orm validator gen

buf generate --template ../../apps/${svcName}/buf.gen.yaml ../protos/apps/${svcName}/api.proto
