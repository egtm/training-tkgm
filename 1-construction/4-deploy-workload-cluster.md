- [Deploy Workload Cluster](#deploy-workload-cluster)
- [After deploying Workload Cluster](#after-deploying-workload-cluster)
- [TSHOOT](#tshoot)
- [Option - Delete workload cluster](#option---delete-workload-cluster)

# Deploy Workload Cluster
[official](https://techdocs.broadcom.com/us/en/vmware-tanzu/standalone-components/tanzu-kubernetes-grid/2-5/tkg/workload-clusters-index.html)
```bash
# Get plugin from the Management Cluster
tanzu plugin sync
tanzu plugin list

# Set a new Workload Cluster name
CLUSTER_NAME=workload-1

# Generate a new YAML from Management Cluter YAML
cp ~/.config/tanzu/tkg/clusterconfigs/xxxxxxxxx.yaml ./${CLUSTER_NAME}.yaml

# Edit - Add CLUSTER_NAME field
vi ${CLUSTER_NAME}.yaml
  CLUSTER_NAME: "${CLUSTER_NAME}"
 
# Deploy
tanzu cluster create -f ${CLUSTER_NAME}.yaml -v9
```
 
# After deploying Workload Cluster
```bash
# Get context of workload cluster
tanzu cluster kubeconfig get ${CLUSTER_NAME} --admin
kubectl config get-context # Check
kubectl config use-context ${CLUSTER_NAME}-admin@${CLUSTER_NAME}
 
# Check
tanzu cluster get ${CLUSTER_NAME}
kubectl get pods -A
kubectl get nodes

# Scale out the nodes
tanzu cluster scale $CLUSTER_NAME -c3 -w3
```

# TSHOOT
```bash
# Login the the Contorl-plane node of Workload Cluster
ssh capv@${KCP_NODE_IPADDR}
sudo -i
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get pods -A
```


# Option - Delete workload cluster
```bash
# Delete workload cluster
tanzu cluster delete $CLUSTER_NAME
 
# Delete context
kubectl config get-contexts
kubectl config delete-context ${CLUSTER_NAME}-admin@${CLUSTER_NAME}
```
