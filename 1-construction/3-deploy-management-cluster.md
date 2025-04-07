- [Deploy Management Cluster](#deploy-management-cluster)
- [After Deployment](#after-deployment)
- [TSHOOT](#tshoot)

# Deploy Management Cluster
- [official](https://techdocs.broadcom.com/us/en/vmware-tanzu/standalone-components/tanzu-kubernetes-grid/2-5/tkg/mgmt-deploy-ui.html)
```bash
# ------------------------------------------------------------------------------
# 0. Preparation
# ------------------------------------------------------------------------------
# Create SSH key
ssh-keygen -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub

# Show ALB server cert
- Access via SOCKS5 browser -  https://alb-s1.lab.net/
- (TOP) Templates --> Security --> SSL/TLS Certificates --> alb-s1.lab.net --> Clieck Export icon --> COPY TO CLIPBOARD

# Kick installer web UI
#tanzu mc create --ui --bind=0.0.0.0:8080
tanzu mc create --ui --bind=192.168.201.1:8080 --browser node

# Access via browser with SOCKS5
http://192.168.201.1:8080/#/ui

Select VMware vSphere --> DEPLOY

# ------------------------------------------------------------------------------
# 1. IaaS Provider
# ------------------------------------------------------------------------------
- VCENTER SERVER: vc-s1.lab.net
- USERNAME: administrator@vsphere.local
- PASSWORD: ***********
- Do not check "Disable Verification" (Not required but it will be used for the next operation training)
- CONNECTED
  - Select "DEPLOY TKG MANAGEMENT CLUSTER"
- SSH PUBLIC_KEY: copy and paste the output (cat ~/.ssh/id_rsa.pub)
- NEXT

# ------------------------------------------------------------------------------
# 2. Cluster Settings
# ------------------------------------------------------------------------------
- Management Cluster Settings
  - Select "Development"
  - INSTANCE TYPE: small
  - MANAGEMENT CLUSTER NAME: mgmt
- MACHINE HEALTH CHECKS: Check "Enable"
- CONTROL PLANE ENDPOINT PROVIDER: NEX Advanced Load Balancer
- NEXT

# ------------------------------------------------------------------------------
# 3. VMware NSX Advanced Load Balancer
# ------------------------------------------------------------------------------
- CONTROLLER HOST: alb-s1.lab.net
- USERNAME: admin
- PASSWORD: **********
- CONTROLLER CERTIFICATE AUTHORITY: "See Show ALB server cert section"
- VERIFY CREDENTIALS

# Use dropdown to select the value
- CLOUD NAME: Default-Cloud
- SERVICE ENGINE GROUP NAME: Default-Group
- Workload Cluster
  -  WORKLOAD CLUSTER - DATA PLANE VIP NETWORK NAME: vlan202-vip
  -  WORKLOAD CLUSTER - DATA PLANE VIP NETWORK CIDR: 192.168.202.0/24
  -  WORKLOAD CLUSTER - CONTROL PLANE VIP NETWORK NAME: vlan202-vip
  -  WORKLOAD CLUSTER - CONTROL PLANE VIP NETWORK CIDR: 192.168.202.0/24
- Management Cluster
  -  MANAGEMENT CLUSTER - DATA PLANE VIP NETWORK NAME: vlan202-vip
  -  MANAGEMENT CLUSTER - DATA PLANE VIP NETWORK CIDR: 192.168.202.0/24
  -  MANAGEMENT CLUSTER - CONTROL PLANE VIP NETWORK NAME: vlan202-vip
  -  MANAGEMENT CLUSTER - CONTROL PLANE VIP NETWORK CIDR: 192.168.202.0/24
- NEXT


# ------------------------------------------------------------------------------
# 4. Metadata
# ------------------------------------------------------------------------------
NEXT

# ------------------------------------------------------------------------------
# 5. Resources
# ------------------------------------------------------------------------------
- VM FOLDER: /Datacenter/vm/TKGM-TRAINING
- DATASTORE: /Datacenter/datastore/datastore-1
- CLUSTERS, HOSTS, AND RESOURCE POOLS: Check "Cluster"
- NEXT


# ------------------------------------------------------------------------------
# 6. Kubernetes Network Settings
# ------------------------------------------------------------------------------
- NETWORK NAME: /Datacenter/network/vlan203-workload
- Proxy Settings
  - Enable "ACTIVATE PROXY SETTINGS"
  - HTTP PROXY URL: http://192.168.203.1:8000
  - Check "Use same configuration for https proxy"
- NO PROXY
  - vc-s1.lab.net,alb-s1.lab.net,192.168.0.0/16
- NEXT


# ------------------------------------------------------------------------------
# 7. Identity Management
# ------------------------------------------------------------------------------
NEXT

# ------------------------------------------------------------------------------
# 8. OS Image
# ------------------------------------------------------------------------------
- OS IMAGE: /Datacenter/vm/TKGM-TRAINING/photon-5-kube-v1.28.11
- NEXT

# ------------------------------------------------------------------------------
# 9. CEIP Agreement
# ------------------------------------------------------------------------------
- Uncheck "Participate in the Customer Experience Improvement Program"
- NEXT

# Final step
REVIEW CONFIGURATION
EXPORT CONFIGURATION
DEPLOY MANAGEMENT CLUSTER
```

# After Deployment
```bash
tanzu mc get
kubectl get nodes
```

# TSHOOT
```bash
# Check the build process
docker exec -it $(docker ps -q --filter "name=kind") bash
kubectl get pods -A

# Check ClusterAPI log
kubectl -n capi-system logs deployment/capi-controller-manager
kubectl -n capv-system logs deployment/capv-controller-manager

# Cleanup kind
docker stop $(docker ps -q --filter "name=kind") && docker rm $(docker ps -aq --filter "name=kind")

# Example - Re-kick MC build
tanzu management-cluster create --file /root/.config/tanzu/tkg/clusterconfigs/23c6hp2mru.yaml -v9

# Proxy log
tail -f /var/log/squid/access.log
```
