kubectl label nodes ubuntu-mac istio=ingressgateway
kubectl label nodes ubuntu-mac app=api-gateway
kubectl label nodes ubuntu-mac node=env-prod-grpc
kubectl label nodes ubuntu-mac node-web=env-prod-web

# kubectl apply -k env-prod/release-admin/
# kubectl -n env-prod port-forward svc/release-admin 8080:80
# kubectl delete -k env-prod/release-admin/