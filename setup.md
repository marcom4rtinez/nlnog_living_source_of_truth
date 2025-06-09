Install all tools containerlab, docker, kind, kubectl

Deploy lab environment
Important note: First start the containerlab environment, then create the kind cluster, otherwise there will be networking issues to connect them together.
```bash
clab deploy swinog.clab.yml
kind create cluster -n swinog
```
Setup sdc
```bash
# Install Cert-Manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
# If the SDCIO resources, see below are being applied to fast, the webhook of the cert-manager is not already there.
# Hence we need to wait for the resource be become Available
kubectl wait -n cert-manager --for=condition=Available=True --timeout=300s deployments.apps cert-manager-webhook

# Install SDC Components
kubectl apply -f https://docs.sdcio.dev/artifacts/basic-usage/colocated.yaml

# Check if sdc is running should be 1 config server pod
kubectl get pods -n network-system

# Connect SDC to clab devices
kubectl apply -f sdc/schema.yml
kubectl apply -f sdc/connectionsecret.yml
kubectl apply -f sdc/connectionprofile.yml
kubectl apply -f sdc/syncprofile.yml
kubectl apply -f sdc/discoveryrule.yml
```