- [Tanzu CLI](#tanzu-cli)
- [Management Cluster](#management-cluster)
- [Kubernetes](#kubernetes)
- [CSI](#csi)
- [Authentication](#authentication)
- [Ingress](#ingress)
- [Tanzu Standard Package](#tanzu-standard-package)

# Tanzu CLI
```bash
tanzu version
tanzu config get
tanzu context list
tanzu plugin list
tanzu plugin source list

tanzu mc get
tanzu cluster list -A
tanzu cluster list -A --include-management-cluster
tanzu cluster get $CLUSTER
```

# Management Cluster
```bash
# Cluster API
kubectl get cluster -A
kubectl get machines -A
kubectl get machinedeployments -A
kubectl get vspheremachines -A
kubectl get vspheremachinetemplates -A

# Cluster API log
kubectl -n capi-system logs deployments/capi-controller-manager
kubectl -n capv-system logs deployments/capv-controller-manager

# Restart capv/capi
kubectl -n capi-system rollout restart deployments/capi-controller-manager
kubectl -n capv-system rollout restart deployments/capv-controller-manager

# CNI/CSI/Kapp version
kubectl get cbt -A

# VM image
kubectl get tkr
kubectl get osimages

# certs managed by cert-manager
kubectl get certificates -A -owide
```

# Kubernetes
```bash
# Node
kubectl get nodes
kubectl top nodes

# Pod
kubectl get pods -A
kubectl top pods -A --sort-by=cpu
kubectl top pods -A --sort-by=memory

# Common
kubectl api-resources
kubectl get events -A
kubectl get pdb -A
```

# CSI
```bash
# Check CSI version to see Release note
kubectl get pkgi -n tkg-system | grep -E 'NAME|csi'
kubectl get csidrivers

# Persistent Volume
kubectl get storageclass
kubectl get volumeattachments
kubectl get pvc -A
kubectl get pv

# CSI pods
kubectl -n vmware-system-csi get all
kubectl -n vmware-system-csi get pods -owide # pod x node to check the logs

# POD x PVC x Node
kubectl get pods -A -o custom-columns="NAMESPACE:.metadata.namespace, POD:.metadata.name, PVC:.spec.volumes[*].persistentVolumeClaim.claimName, NODE:.spec.nodeName" | grep -v none


# CSI pod logs
kubectl -n vmware-system-csi logs deployment/vsphere-csi-controller --since=1h --all-containers=true
kubectl -n vmware-system-csi logs deployment/vsphere-csi-controller --since=1h -c csi-attacher
kubectl -n vmware-system-csi logs deployment/vsphere-csi-controller --since=1h -c vsphere-csi-controller
kubectl -n vmware-system-csi logs deployment/vsphere-csi-controller --since=1h -c csi-provisioner
kubectl -n vmware-system-csi logs deployment/vsphere-csi-controller --since=1h -c vsphere-syncer
kubectl -n vmware-system-csi logs deployment/vsphere-csi-controller --since=1h -c csi-resizer # option
kubectl -n vmware-system-csi logs deployment/vsphere-csi-controller --since=1h -c liveness-probe # option
kubectl -n vmware-system-csi logs deployment/vsphere-csi-controller --since=1h -c csi-snapshotter # option
kubectl -n vmware-system-csi logs daemonset/vsphere-csi-node --since=1h --all-containers=true
kubectl -n vmware-system-csi logs daemonset/vsphere-csi-node --since=1h -c vsphere-csi-node


# Restart vsphere-csi-controller pods
kubectl -n vmware-system-csi rollout restart deployment vsphere-csi-controller
kubectl -n vmware-system-csi rollout status deployment vsphere-csi-controller
kubectl -n vmware-system-csi rollout restart daemonset vsphere-csi-node
```

# Authentication
```bash
kubectl get oidcidentityproviders -A
kubectl get ldapidentityproviders -A
```

# Ingress
```bash
kubectl get ingress -A
kubectl get httpproxy -A
kubectl get ingressclass
kubectl get svc -A
kubectl get ep -A
```

# Tanzu Standard Package
```bash
tanzu package available list -A
kubectl get pkgr
kubectl get pkgi
kubectl get apps
```
