Install all tools containerlab, docker, kind, kubectl

Deploy lab environment
Important note: First start the containerlab environment, then create the kind cluster, otherwise there will be networking issues to connect them together.
```bash
clab deploy swinog.clab.yml
kind create cluster -n swinog
```
Setup sdc
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
kubectl wait -n cert-manager --for=condition=Available=True --timeout=300s deployments.apps cert-manager-webhook

kubectl apply -f https://docs.sdcio.dev/artifacts/basic-usage/colocated.yaml

kubectl get pods -n network-system


#check if the same https://docs.sdcio.dev/getting-started/basic-usage/
kubectl apply -f sdc/schema.yml
kubectl apply -f sdc/connectionsecret.yml
kubectl apply -f sdc/connectionprofile.yml
kubectl apply -f sdc/syncprofile.yml
kubectl apply -f sdc/discoveryrule.yml
```


Install Infrahub via devcontainer

Add repository on infrahub UI --> write GQL query

```
mutation {
  CorePasswordCredentialCreate(
    data: {
      name: { value: "my-git-credential" },
      username: { value: "MY_USERNAME" },
      password: { value: "MY_TOKEN_OR_PASSWORD" }
    }
  ) {
    ok
    object {
      hfid
    }
  }
}



#terraform setup
mutation {
  InfrahubAccountTokenCreate(data: {name: "terraform"}) {
    object {
      token {
        value
      }
    }
  }
}
```

```
helm install vidra-operator oci://ghcr.io/infrahub-operator/vidra/helm-charts/vidra-operator --namespace vidra-system --create-namespace
kubectl apply -f vidra.yaml


k label target.inv.sdcio.dev/spine1 sdcio.dev/node="spine1"
```

