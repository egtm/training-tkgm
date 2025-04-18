#!/bin/bash
# https://techdocs.broadcom.com/us/en/vmware-tanzu/standalone-components/tanzu-kubernetes-grid/2-5/tkg/mgmt-release-notes.html

# -----------------------------------------------------------------------------------------------------
# Add repostitory
# -----------------------------------------------------------------------------------------------------
# https://techdocs.broadcom.com/us/en/vmware-tanzu/cli/tanzu-packages/latest/tnz-packages/prep.html
imgpkg tag list -i projects.packages.broadcom.com/tkg/packages/standard/repo
#> v2025.1.27
VERSION=v2025.1.27

# Check
tanzu package repository list -A
#> (No output)

# Add a new package version
tanzu package repository add tanzu-standard --url projects.registry.vmware.com/tkg/packages/standard/repo:${VERSION} --namespace tkg-system
#> 11:23:45AM: Deploy succeeded

# Check == kubectl get packagerepositories -A
tanzu package repository list -A
#> NAMESPACE   NAME            SOURCE                                                                       STATUS
#> tkg-system  tanzu-standard  (imgpkg) projects.registry.vmware.com/tkg/packages/standard/repo:v2025.1.27  Reconcile succeeded

# Create a namespace for standard package
TANZU_PACKAGE_NS=mypackage
kubectl create namespace $TANZU_PACKAGE_NS
kubectl get ns


# -----------------------------------------------------------------------------------------------------
# Install cert-manager
# https://techdocs.broadcom.com/us/en/vmware-tanzu/cli/tanzu-packages/latest/tnz-packages/packages-cert-mgr.html
# -----------------------------------------------------------------------------------------------------
# Check the target package name
tanzu package available list -A | grep cert-manager
#>   tkg-system  cert-manager.tanzu.vmware.com                   cert-manager
TARGET_PACKAGE=cert-manager.tanzu.vmware.com

# Check the version
tanzu package available list $TARGET_PACKAGE -A
#>  NAMESPACE   NAME                           VERSION                 RELEASED-AT
#>  tkg-system  cert-manager.tanzu.vmware.com  1.1.0+vmware.1-tkg.2    2020-11-25 03:00:00 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.1.0+vmware.2-tkg.1    2020-11-25 03:00:00 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.11.1+vmware.1-tkg.1   2023-01-11 21:00:00 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.12.10+vmware.2-tkg.2  2023-06-15 21:00:00 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.12.2+vmware.2-tkg.2   2023-06-15 21:00:00 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.5.3+vmware.2-tkg.1    2021-08-24 02:22:51 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.5.3+vmware.4-tkg.1    2021-08-24 02:22:51 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.5.3+vmware.7-tkg.1    2021-08-24 02:22:51 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.5.3+vmware.7-tkg.3    2021-08-24 02:22:51 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.7.2+vmware.1-tkg.1    2021-10-29 21:00:00 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.7.2+vmware.3-tkg.1    2021-10-29 21:00:00 +0900 JST
#>  tkg-system  cert-manager.tanzu.vmware.com  1.7.2+vmware.3-tkg.3    2021-10-29 21:00:00 +0900 JST

# Install cert-manager
TARGET_VERSION=1.16.1+vmware.1-tkg.1
TARGET_PACKAGE=cert-manager.tanzu.vmware.com
tanzu package install cert-manager --package $TARGET_PACKAGE --namespace $TANZU_PACKAGE_NS --version $TARGET_VERSION
#> 4:12:16PM: Deploy succeeded

# Check the result
tanzu package installed list -A
#> NAMESPACE   NAME                                          PACKAGE-NAME                                        PACKAGE-VERSION         STATUS
#> mypackage   cert-manager                               cert-manager.tanzu.vmware.com                       1.16.1+vmware.1-tkg.1  Reconcile succeeded
#> tkg-system  w1-v252-cc-antrea                             antrea.tanzu.vmware.com                             1.13.3+vmware.4-tkg.1   Reconcile succeeded
#> tkg-system  w1-v252-cc-capabilities                       capabilities.tanzu.vmware.com                       0.32.3+vmware.1         Reconcile succeeded
#> tkg-system  w1-v252-cc-gateway-api                        gateway-api.tanzu.vmware.com                        1.0.0+vmware.1-tkg.2    Reconcile succeeded
#> tkg-system  w1-v252-cc-load-balancer-and-ingress-service  load-balancer-and-ingress-service.tanzu.vmware.com  1.11.2+vmware.2-tkg.2   Reconcile succeeded
#> tkg-system  w1-v252-cc-metrics-server                     metrics-server.tanzu.vmware.com                     0.6.2+vmware.8-tkg.1    Reconcile succeeded
#> tkg-system  w1-v252-cc-pinniped                           pinniped.tanzu.vmware.com                           0.25.0+vmware.3-tkg.1   Reconcile succeeded
#> tkg-system  w1-v252-cc-secretgen-controller               secretgen-controller.tanzu.vmware.com               0.15.0+vmware.2-tkg.1   Reconcile succeeded
#> tkg-system  w1-v252-cc-tkg-storageclass                   tkg-storageclass.tanzu.vmware.com                   0.32.3+vmware.1         Reconcile succeeded
#> tkg-system  w1-v252-cc-vsphere-cpi                        vsphere-cpi.tanzu.vmware.com                        1.28.0+vmware.3-tkg.2   Reconcile succeeded
#> tkg-system  w1-v252-cc-vsphere-csi                        vsphere-csi.tanzu.vmware.com                        3.3.0+vmware.1-tkg.1    Reconcile succeeded

# Check the status
tanzu package installed get cert-manager --namespace $TANZU_PACKAGE_NS
tanzu package installed status cert-manager --namespace $TANZU_PACKAGE_NS

kubectl get apps -A
kubectl get apps -n $TANZU_PACKAGE_NS
#> NAME           DESCRIPTION           SINCE-DEPLOY   AGE
#> cert-manager   Reconcile succeeded   10m            10m

kubectl -n cert-manager get all
#> NAME                                           READY   STATUS    RESTARTS   AGE
#> pod/cert-manager-cainjector-86b5776f5d-6mh88   1/1     Running   0          8m44s
#> pod/cert-manager-f9d788984-4thqw               1/1     Running   0          8m44s
#> pod/cert-manager-webhook-5f996b659b-lffn5      1/1     Running   0          8m44s
#> 
#> NAME                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
#> service/cert-manager           ClusterIP   100.64.245.114   <none>        9402/TCP   8m44s
#> service/cert-manager-webhook   ClusterIP   100.69.146.197   <none>        443/TCP    8m44s
#> 
#> NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
#> deployment.apps/cert-manager              1/1     1            1           8m44s
#> deployment.apps/cert-manager-cainjector   1/1     1            1           8m44s
#> deployment.apps/cert-manager-webhook      1/1     1            1           8m44s
#> 
#> NAME                                                 DESIRED   CURRENT   READY   AGE
#> replicaset.apps/cert-manager-cainjector-86b5776f5d   1         1         1       8m44s
#> replicaset.apps/cert-manager-f9d788984               1         1         1       8m44s
#> replicaset.apps/cert-manager-webhook-5f996b659b      1         1         1       8m44s

kubectl -n cert-manager get ep
#> NAME                   ENDPOINTS          AGE
#> cert-manager           100.96.3.3:9402    9m28s
#> cert-manager-webhook   100.96.3.2:10250   9m28s

# Check the YAML
kubectl get app -n $TANZU_PACKAGE_NS cert-manager -oyaml


# -----------------------------------------------------------------------------------------------------
# Install Contour
# https://techdocs.broadcom.com/us/en/vmware-tanzu/cli/tanzu-packages/latest/tnz-packages/packages-contour.html
# -----------------------------------------------------------------------------------------------------
# Check the target package name
tanzu package available list -A | grep contour
#>   tkg-system  contour.tanzu.vmware.com                        contour
TARGET_PACKAGE=contour.tanzu.vmware.com

# Check the version
tanzu package available list $TARGET_PACKAGE -A
#> NAMESPACE   NAME                      VERSION                RELEASED-AT
#> tkg-system  contour.tanzu.vmware.com  1.27.4+vmware.1-tkg.1  2024-06-12 09:00:00 +0900 JST
#> tkg-system  contour.tanzu.vmware.com  1.28.5+vmware.1-tkg.1  2024-06-12 09:00:00 +0900 JST
#> tkg-system  contour.tanzu.vmware.com  1.29.1+vmware.1-tkg.1  2024-06-12 09:00:00 +0900 JST

# Generate a YAML
cat > contour-data-values.yaml <<EOF
---
infrastructure_provider: vsphere
namespace: tanzu-system-ingress
contour:
 configFileContents: {}
 useProxyProtocol: false
 replicas: 2
 pspNames: "vmware-system-restricted"
 logLevel: info
envoy:
 service:
   type: LoadBalancer # NSX-ALB
   annotations: {}
   externalTrafficPolicy: Cluster
   disableWait: false
 hostPorts:
   enable: true
   http: 80
   https: 443
 hostNetwork: false
 terminationGracePeriodSeconds: 300
 logLevel: info
certificates:
 duration: 8760h
 renewBefore: 360h
EOF

TARGET_VERSION=1.30.2+vmware.1-tkg.1
TARGET_PACKAGE=contour.tanzu.vmware.com
TANZU_PACKAGE_NS=mypackage

# Check value schema
tanzu package available get contour.tanzu.vmware.com/${TARGET_VERSION} --values-schema

# Install Contour
tanzu package install contour --package $TARGET_PACKAGE --namespace $TANZU_PACKAGE_NS --version $TARGET_VERSION --values-file contour-data-values.yaml
#> 4:29:11PM: Deploy succeeded

# Check the result
tanzu package installed list -A
#> NAMESPACE   NAME                                          PACKAGE-NAME                                        PACKAGE-VERSION         STATUS
#> mypackage   cert-manager                                  cert-manager.tanzu.vmware.com                       1.12.10+vmware.2-tkg.2  Reconcile succeeded
#> mypackage   contour                                       contour.tanzu.vmware.com                            1.29.1+vmware.1-tkg.1   Reconcile succeeded

# Check the status
tanzu package installed get contour --namespace $TANZU_PACKAGE_NS
tanzu package installed status contour --namespace $TANZU_PACKAGE_NS

kubectl get apps -n $TANZU_PACKAGE_NS
#> NAME           DESCRIPTION           SINCE-DEPLOY   AGE
#> cert-manager   Reconcile succeeded   7m34s          18m
#> contour        Reconcile succeeded   85s            87s

kubectl -n tanzu-system-ingress get all
#> NAME                           READY   STATUS    RESTARTS   AGE
#> pod/contour-7fcc69775d-7bmmr   1/1     Running   0          104s
#> pod/contour-7fcc69775d-qx5zb   1/1     Running   0          104s
#> pod/envoy-88jt5                2/2     Running   0          105s
#> pod/envoy-l295r                2/2     Running   0          105s
#> pod/envoy-t5xwh                2/2     Running   0          105s
#> 
#> NAME              TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
#> service/contour   ClusterIP      100.64.145.32    <none>           8001/TCP                     104s
#> service/envoy     LoadBalancer   100.64.162.145   192.168.12.227   80:32422/TCP,443:30209/TCP   104s
#> 
#> NAME                   DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
#> daemonset.apps/envoy   3         3         3       3            3           <none>          105s
#> 
#> NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
#> deployment.apps/contour   2/2     2            2           104s
#> 
#> NAME                                 DESIRED   CURRENT   READY   AGE
#> replicaset.apps/contour-7fcc69775d   2         2         2       104s

kubectl -n tanzu-system-ingress get ep
#> NAME      ENDPOINTS                                                     AGE
#> contour   100.96.2.5:8001,100.96.3.4:8001                               2m11s
#> envoy     100.96.1.4:8443,100.96.2.4:8443,100.96.3.3:8443 + 3 more...   2m11s

# Check the YAML for TSHOOT
kubectl get app -n $TANZU_PACKAGE_NS contour -oyaml

kubectl get svc envoy -n tanzu-system-ingress
#> NAME    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
#> envoy   LoadBalancer   100.64.162.145   192.168.12.227   80:32422/TCP,443:30209/TCP   2m46s
