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
