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

Enable User Namespaces in OpenShift:

```bash
cat << EOF | butane | oc apply -f -
variant: openshift
version: 4.12.0
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: subuid-subgid
storage:
  files:
  - path: /etc/subuid
    mode: 0644
    overwrite: true
    contents:
      inline: |
        core:100000:65536
        containers:200000:268435456
  - path: /etc/subgid
    mode: 0644
    overwrite: true
    contents:
      inline: |
        core:100000:65536
        containers:200000:268435456
EOF
```

Enable fuse-overlayfs

```bash
cat << EOF | oc apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
 name: fuse-device-plugin-daemonset
 namespace: kube-system
spec:
 selector:
   matchLabels:
     name: fuse-device-plugin-ds
 template:
   metadata:
     labels:
       name: fuse-device-plugin-ds
   spec:
     hostNetwork: true
     containers:
     - image: soolaugust/fuse-device-plugin:v1.0
       name: fuse-device-plugin-ctr
       securityContext:
         allowPrivilegeEscalation: false
         capabilities:
           drop: ["ALL"]
       volumeMounts:
         - name: device-plugin
           mountPath: /var/lib/kubelet/device-plugins
     volumes:
       - name: device-plugin
         hostPath:
           path: /var/lib/kubelet/device-plugins
     imagePullSecrets:
       - name: registry-secret
EOF
```

```bash
cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
 name: podman-userns
 annotations:
   io.kubernetes.cri-o.userns-mode: "auto:size=65536;keep-id=true"
spec:
 containers:
   - name: userns
     image: quay.io/podman/stable
     command: ["sleep", "10000"]
     securityContext:
       allowPrivilegeEscalation: false
       runAsNonRoot: true
       seccompProfile:
         type: RuntimeDefault
       capabilities:
         add:
           - "SYS_ADMIN"
           - "MKNOD"
           - "SYS_CHROOT"
           - "SETFCAP"
     resources:
       limits:
         github.com/fuse: 1
EOF
```

```bash
cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
 name: podman-userns
 annotations:
   io.kubernetes.cri-o.userns-mode: "auto:size=65536;keep-id=true"
spec:
 containers:
   - name: userns
     image: quay.io/podman/stable
     command: ["sleep", "10000"]
     securityContext:
       seccompProfile:
         type: RuntimeDefault
       capabilities:
         add:
           - "SYS_ADMIN"
           - "MKNOD"
           - "SYS_CHROOT"
           - "SETFCAP"
     resources:
       limits:
         github.com/fuse: 1
EOF
```

```yaml
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
  namespace: dw # Or wherever the DevWorkspace Operator is installed
```
