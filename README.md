# Create new users for your Kubernetes Cluster

To add new users to your cluster follow the next steps.
### Clone Project
```bash
git clone https://github.com/Laurin-Notemann/kube-create-new-user
```

```bash
cd kube-create-new-user
```

### Create Environment

#### Export the user to add
```bash
export NEW_ZUGRIFF_USER=<username>
```

#### Get your current context and export it
```bash
export CURRENT_CONTEXT=$(kubectl config current-context)
```

#### Get your cluster name and export it
```bash
export CLUSTER_NAME=$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"$CURRENT_CONTEXT\")].context.cluster}")
```

### Create new user

#### Run the script
```bash
sh create-user.sh
```

This has created a new folder named after the new <user> and there are the key, certificate request and the certificate (.key, .csr, .crt) as well as three yaml files.

### Test the new user

If you want to test if the user was corectly created run

```bash
sh new_context_test.sh
```
output should be: No resources found in <user> namespace. That means everything worked.

Now send the <user>-kubeconfig.yaml file to the new user (as securely as possible)
They have to run the following steps:

### User already has an existing kubeconfig and kubectl installed
```bash
KUBECONFIG=~/.kube/config:user-kubeconfig.yaml kubectl config view --flatten > merged-config.yaml
```

```bash
mv merged-config.yaml ~/.kube/config
```

### User does not have kubectl installed yet and no config yet

Install Kubernetes first and kubectl.

```bash
mv user-kubeconfig.yaml ~/.kube/config
```

## Danger!!!

### Remove namespace and all certificates from user run
```bash
sh delete_create_user.sh
```
