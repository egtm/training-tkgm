- [Ingress by Contour x AVI-LB](#ingress-by-contour-x-avi-lb)
- [Sample - Pod + svc](#sample---pod--svc)
- [Sample - kind:Ingress](#sample---kindingress)
- [Sample - kind:HTTPProxy](#sample---kindhttpproxy)

# Ingress by Contour x AVI-LB
- AVI-LB: L4 load balancing
- Contour(envoy): L7 load balancing
- Traffic flow
  - AVI-LB(L4-LB: ingress VIP) --> node (iptables:KUBE-NODEPORTS) --> svc:envoy --> envoy(L7-LB)  --> svc:target --> target pod


# Sample - Pod + svc
```bash
cat > sample-echo-go.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-go
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo-go
  template:
    metadata:
      labels:
        app: echo-go
    spec:
      containers:
      - name: echo-go
        image: gcr.io/google-containers/echoserver:1.8
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: echo-go
spec:
  selector:
    app: echo-go
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
EOF
kubectl apply -f sample-echo-go.yaml
```

# Sample - kind:Ingress
```bash
cat > sample-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: name: test-ingress
spec:
  rules:
  - http:
      paths:
      - path: /apple
        pathType: Prefix
        backend:
          service:
            name: echo-go
            port:
              number: 80
      - path: /banana
        pathType: Prefix
        backend:
          service:
            name: echo-go
            port:
              number: 80
EOF
kubectl apply -f sample-ingress.yaml

kubectl get ingress
#> NAME           CLASS    HOSTS   ADDRESS           PORTS   AGE
#> test-ingress   <none>   *       192.168.110.110   80      0s

VIP=192.168.110.110
curl http://${VIP}/apple  # apple
curl http://${VIP}/banana # banana
curl http://${VIP}/ringo  # no output
```

# Sample - kind:HTTPProxy
```bash
cat > sample-httpproxy.yaml <<EOF
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: sample-httpproxy-contour
  namespace: default
spec:
  virtualhost:
    fqdn: sample-httpproxy.lab.net
  routes:
  - conditions:
    - prefix: /apple
    requestHeadersPolicy:
      set:
      - name: X-Client-IP
        value: '%DOWNSTREAM_REMOTE_ADDRESS_WITHOUT_PORT%'
    services:
    - name: echo-go
      port: 80
  - conditions:
    - prefix: /banana
    requestHeadersPolicy:
      set:
      - name: X-Client-IP
        value: '%DOWNSTREAM_REMOTE_ADDRESS_WITHOUT_PORT%'
    services:
    - name: echo-go
      port: 80
EOF
kubectl apply -f sample-httpproxy.yaml

# Check
kubectl get httpproxy
#> NAME                       FQDN                       TLS SECRET   STATUS   STATUS DESCRIPTION
#> sample-httpproxy-contour   sample-httpproxy.lab.net                valid    Valid HTTPProxy

kubectl -n tanzu-system-ingress get svc envoy
#> NAME    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
#> envoy   LoadBalancer   100.64.114.191   192.168.12.224   80:32002/TCP,443:31929/TCP   4h15m

# Check
curl -i -H "Host: sample-httpproxy.lab.net" 192.168.12.224/banana
```
