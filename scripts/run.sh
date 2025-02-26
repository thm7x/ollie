#!/bin/bash

svcName=${1}

if [ -d "apps/${svcName}" ];then
    cd apps/${svcName} && NAMESPACE=local air
fi
