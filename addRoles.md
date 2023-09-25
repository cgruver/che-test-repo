# Add Customer Roles to Users

```bash
cat << EOF | oc apply -f -
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: image-creator
  labels:
    app.kubernetes.io/part-of: che.eclipse.org
rules:
- apiGroups:
  - image.openshift.io
  resources:
  - imagestreamimages
  - imagestreammappings
  - imagestreams
  - imagestreams/secrets
  - imagestreamtags
  - imagetags
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ""
  - image.openshift.io
  resources:
  - imagestreamimports
  verbs:
  - create
- apiGroups:
  - ""
  - image.openshift.io
  resources:
  - imagestreams/layers
  verbs:
  - get
  - update
- apiGroups:
  - ""
  - image.openshift.io
  resources:
  - imagestreams
  verbs:
  - create
- apiGroups:
  - ""
  - image.openshift.io
  resources:
  - imagestreams/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  - image.openshift.io
  resources:
  - imagestreamimages
  - imagestreammappings
  - imagestreams
  - imagestreamtags
  - imagetags
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  - image.openshift.io
  resources:
  - imagestreams/layers
  verbs:
  - get
EOF
```

```bash
cat << EOF | oc apply -f -
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: image-creator
  labels:
    app.kubernetes.io/part-of: che.eclipse.org
subjects:
  - kind: ServiceAccount
    name: che-operator
    namespace: openshift-operators
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: image-creator
EOF
```

```bash
oc patch checluster eclipse-che --patch '{"spec": {"components": {"cheServer": {"clusterRoles": ["'image-creator'"]}}}}' --type=merge -n eclipse-che
oc patch checluster eclipse-che --patch '{"spec": {"devEnvironments": {"user": {"clusterRoles": ["'image-creator'"]}}}}' --type=merge -n eclipse-che
```
