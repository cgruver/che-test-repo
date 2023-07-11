# Notes

```bash
aws --endpoint-url=http://localhost:4566 s3api create-bucket --bucket my-bucket --region us-east-1
```

```bash
cat << EOF | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: localstack-addendum
rules:
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - get
  - list
  - watch
  - create
  - delete
  - deletecollection
  - patch
  - update
EOF

oc policy add-role-to-user localstack-addendum cgruver -n cgruver-che
```
