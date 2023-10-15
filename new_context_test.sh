user=$NEW_ZUGRIFF_USER

mv ~/.kube/config ~/.kube/config.backup
cp ${user}/${user}-kubeconfig.yaml ~/.kube/config
kubectl get pods # this should work only within the laurin namespace and with the permissions of laurin-role.
mv ~/.kube/config.backup ~/.kube/config

