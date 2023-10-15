user=$NEW_ZUGRIFF_USER

kubectl delete namespace $user

kubectl delete csr $user-csr

kubectl config delete-context $user-context

kubectl config unset users.$user
