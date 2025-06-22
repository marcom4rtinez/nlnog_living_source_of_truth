# Setup Demo SDC Infrahub Terraform

Install all tools containerlab, docker, kind, kubectl

Deploy lab environment
Important note: First start the containerlab environment, then create the kind cluster, otherwise there will be networking issues to connect them together.

```bash
clab deploy swinog.clab.yml
kind create cluster -n swinog
```

Setup infrahub

```bash
infrahub/setupInfrahub.sh
```

Setup sdc

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
kubectl wait -n cert-manager --for=condition=Available=True --timeout=300s deployments.apps cert-manager-webhook
kubectl apply -f https://docs.sdcio.dev/artifacts/basic-usage/colocated.yaml
kubectl apply -f sdc/schema.yml
kubectl apply -f sdc/connectionsecret.yml
kubectl apply -f sdc/connectionprofile.yml
kubectl apply -f sdc/syncprofile.yml
kubectl apply -f sdc/discoveryrule.yml
```

```graphql
mutation {
  CoreReadOnlyRepositoryCreate(
    data: {
      name: { value: "swinog" },
      location: { value: "https://github.com/marcom4rtinez/SwiNOG40_living_source_of_truth.git" },
      ref: { value: "main" },
    }
  ) {
    ok
    object {
      id
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

Create IP