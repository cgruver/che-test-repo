
function setGitHubAccessToken() {

  CHE_USER=$(oc whoami)
  CHE_NAMESPACE=$(oc get $(oc get project --selector app.kubernetes.io/component=workspaces-namespace -o name) -o jsonpath='{.metadata.name}')
  echo "Enter your Github User ID:"
  read GIT_USER
  GIT_PAT="hello"
  GIT_PAT_CHK="goodbye"
  echo "Creating default root password for KVM hosts:"
  while [[ ${GIT_PAT} != ${GIT_PAT_CHK} ]]
  do
    echo "Enter a password for the KVM host root user:"
    read -s GIT_PAT
    echo "Re-Enter the password for the KVM host root user:"
    read -s GIT_PAT_CHK
    if [[ ${GIT_PAT} != ${GIT_PAT_CHK} ]]
    then
      echo "Passwords do not match. Try Again."
    fi
  done
  createGitHubSecret
  GIT_PAT=""
  GIT_PAT_CHK=""
  GIT_USER=""
}

function createGitHubSecret() {
cat << EOF | oc apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: personal-access-token-${CHE_USER}
  namespace: ${CHE_NAMESPACE}
  labels:
    app.kubernetes.io/component: scm-personal-access-token
    app.kubernetes.io/part-of: che.eclipse.org
  annotations:
    che.eclipse.org/che-userid: ${CHE_USER}
    che.eclipse.org/scm-personal-access-token-name: github
    che.eclipse.org/scm-url: https://github.com
    che.eclipse.org/scm-userid: ${GIT_USER}
data:
  token: ${GIT_TOKEN}
type: Opaque
EOF
}
