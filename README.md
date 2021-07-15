# Deploying Vault with integrated storage on GKE

First, clone the Terraform code in any location.

```
$ git clone https://github.com/mohsinrz/vault-gke-raft
$ cd vault-gke-raft
```

```
$ terraform init
$ terraform apply
```

To get access to the cluster, run the command below:
```
gcloud container clusters get-credentials sam-vault-consul-demo --region us-central1 --project sam-gabrail-gcp-demos
Fetching cluster endpoint and auth data.
kubeconfig entry generated for sam-vault-consul-demo.
$ 
$ kubectl get pods -n vault
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 0/1     Running   0          24m
vault-1                                 0/1     Running   0          24m
vault-2                                 0/1     Running   0          24m
vault-agent-injector-7d4cccc866-7qfkx   1/1     Running   0          24m
```

The pods will not become ready until they are bootstrapped and unsealed which will involve making one of the pod as Raft leader and joining others to this pod. First, we will make `vault-0` as the leader to do that we will run the following commands to initialize Vault and unseal it.

```
$ kubectl exec -ti vault-0 -n vault -- vault operator init -key-shares=1 -key-threshold=1
```

Vault automatically unseals based on Google KMS

After the Vault is unsealed the pod will become ready and will be elected as leader (you can verify by checking logs `kubectl logs vault-0 -n vault`).

```
$ kubectl exec -ti vault-0 -n vault -- vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.7.0
Cluster Name    vault-cluster-5d640d05
Cluster ID      4d9f4351-52ac-4819-b0a0-ce9e2949aa87
HA Enabled      true
HA Cluster      https://vault-0.vault-internal:8201
HA Mode         active
$ 
$ kubectl get pods -n vault
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          2m18s
vault-1                                 0/1     Running   0          2m18s
vault-2                                 0/1     Running   0          2m18s
vault-agent-injector-7d4cccc866-fbmz4   1/1     Running   0          2m19s
```

Now we will make other pods join the cluster leader `Vault-0` so that they can become part of the Raft cluster and then we have to unseal them. This step will be done for all the remaining pods.

```
kubectl exec -ti vault-1 -n vault --  vault operator raft join -leader-ca-cert="$(cat ./tls/ca-certificate.cert)" --address "https://vault-1.vault-internal:8200" "https://vault-0.vault-internal:8200" 
Key       Value
---       -----
Joined    true 

# Unseal vault-1
kubectl exec -ti vault-1 -n vault -- vault operator unseal
```

```
$ kubectl get pods -n vault
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          12m
vault-1                                 1/1     Running   0          12m
vault-2                                 1/1     Running   0          12m
vault-agent-injector-7d4cccc866-5vs9w   1/1     Running   0          12m
```

After all the pods become part of the Raft cluster and unsealed, all pods will become ready and Vault cluster will be ready to serve any requests.

## Cleaning up

```
$ terraform destroy
```
