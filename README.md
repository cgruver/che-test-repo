# Repository for testing Devfile and VS Code features in Eclipse Che

__Note:__ I use this repo to test Eclipse Che features.  It is not a stable repository and will change frequently.

## My Notes:

```bash
bash <(curl -sL  https://www.eclipse.org/che/chectl/)

chectl update stable
chectl server:deploy --platform openshift --no-auto-update --batch
oc patch CheCluster eclipse-che -n eclipse-che --type merge --patch '{"spec":{"devEnvironments":{"disableContainerBuildCapabilities":false,"storage":{"pvcStrategy":"per-workspace"}}}}'
```

```bash
oc patch CheCluster eclipse-che -n eclipse-che --type merge --patch '{"spec":{"components":{"pluginRegistry":{"openVSXURL":"","deployment":{"containers":[{"image":"image-registry.openshift-image-registry.svc:5000/eclipse-che-images/che-plugin-registry:che-code-vsx"}]}}}}}'
```

```bash
chectl server:delete -y --delete-all --delete-namespace
```

```bash
oc import-image che-plugin-registry:1.58.X --from=quay.io/cgruver0/che/che-plugin-registry:1.58.X --confirm -n openshift
oc patch CheCluster devspaces -n openshift-operators --type merge --patch '{"spec":{"components":{"pluginRegistry":{"openVSXURL":"","deployment":{"containers":[{"image":"image-registry.openshift-image-registry.svc:5000/openshift/che-plugin-registry:1.58.X"}]}}}}}'
```

```bash
cat << EOF | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: devworkspace-controller-admin-kafka
rules:
- apiGroups:
  - kafka.strimzi.io
  resources:
  - kafkas
  - kafkatopics
  verbs:
  - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
  name: devworkspace-controller-admin-kafka
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: devworkspace-controller-admin-kafka
subjects:
- kind: ServiceAccount
  name: devworkspace-controller-serviceaccount
  namespace: openshift-operators
EOF
```

```bash
ECLIPSE_CHE_NAMESPACE=eclipse-che
OPERATOR_NAMESPACE=eclipse-che
CHE_CLUSTER_NAME=eclipse-che
CUSTOM_ROLES_NAME=edit

oc apply -f - <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: che-ns-edit
  labels:
    app.kubernetes.io/part-of: che.eclipse.org
subjects:
  - kind: ServiceAccount
    name: che-operator
    namespace: openshift-operators
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
EOF

oc patch checluster/eclipse-che --patch '{"spec": {"components": {"cheServer": {"clusterRoles": ["edit"]}}}}' --type=merge -n eclipse-che

# ${ECLIPSE_CHE_NAMESPACE}-cheworkspaces-clusterrole and ${ECLIPSE_CHE_NAMESPACE}-cheworkspaces-devworkspace-clusterrole are defaults user's clusterrole
USER_CLUSTER_ROLES="edit,eclipse-che-cheworkspaces-clusterrole,eclipse-che-cheworkspaces-devworkspace-clusterrole"

oc patch checluster/eclipse-che --patch '{"spec": {"components": {"cheServer": {"extraProperties": {"CHE_INFRA_KUBERNETES_USER__CLUSTER__ROLES": "'${USER_CLUSTER_ROLES}'"}}}}}' --type=merge -n eclipse-che
```
