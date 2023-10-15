#!/bin/bash

user=$NEW_ZUGRIFF_USER

current_context=$CURRENT_CONTEXT

cluster_name=$CLUSTER_NAME

echo $user

mkdir $user

touch ${user}/${user}-namespace.yaml

echo "apiVersion: v1
kind: Namespace
metadata:
  name: $user
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: $user
  name: $user-role
rules:
  - apiGroups: ['']
    resources: ['pods', 'services', 'configmaps', 'persistentvolumeclaims', 'secrets', 'events', 'endpoints']
    verbs: ['get', 'list', 'watch', 'create', 'delete', 'update', 'patch']
  - apiGroups: ['apps']
    resources: ['deployments', 'replicasets', 'statefulsets', 'daemonsets']
    verbs: ['get', 'list', 'watch', 'create', 'delete', 'update', 'patch']
  - apiGroups: ['batch']
    resources: ['jobs', 'cronjobs']
    verbs: ['get', 'list', 'watch', 'create', 'delete', 'update', 'patch']
  - apiGroups: ['networking.k8s.io']
    resources: ['networkpolicies', 'ingress']
    verbs: ['get', 'list', 'watch', 'create', 'delete', 'update', 'patch']
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $user-rolebinding
  namespace: $user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $user-role
subjects:
- kind: User
  name: $user
  apiGroup: rbac.authorization.k8s.io" > ${user}/${user}-namespace.yaml

kubectl apply -f ${user}/${user}-namespace.yaml

openssl genpkey -algorithm RSA -out ${user}/${user}.key

openssl req -new -key ${user}/${user}.key -out ${user}/${user}.csr -subj "/CN=$user/O=$user"

touch ${user}/${user}-csr.yaml

user_csr_encoded=$(cat ${user}/${user}.csr | base64 | tr -d '\n')

echo "apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $user-csr
spec:
  request: $user_csr_encoded
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth" > ${user}/${user}-csr.yaml
 
kubectl apply -f ${user}/${user}-csr.yaml

kubectl certificate approve $user-csr

kubectl get csr $user-csr -o jsonpath='{.status.certificate}' | base64 --decode > ${user}/${user}.crt

kubectl config use-context $current_context

kubectl config set-credentials $user --client-key=${user}/${user}.key --client-certificate=${user}/${user}.crt --embed-certs=true

kubectl config set-context $user-context --user=$user --namespace=$user --cluster=$cluster_name

kubectl config view --minify --flatten --context=$user-context > ${user}/${user}-kubeconfig.yaml

kubectl config --kubeconfig=${user}/${user}-kubeconfig.yaml use-context "$user-context"


