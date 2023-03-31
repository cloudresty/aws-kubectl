# aws-kubectl

This repository contains a Dockerfile bundled with the following packages:

* Debian 11.6-slim as base image
* AWS CLI v2
* kubectl v1.26

&nbsp;

## Docker image

The Docker image can be found and pulled from Cloudresty's Docker Hub public repository available here [https://hub.docker.com/r/cloudresty/aws-kubectl](https://hub.docker.com/r/cloudresty/aws-kubectl).

&nbsp;

## Usage

Here is an example of how this Docker image can be used within a non-AWS Kubernetes cluster that requires access to a private AWS ECR registry. More precisely, in this example we will generate a series of resources that will help with refreshing the AWS Authentication Token. By default the AWS Authentication Token gets invalidated every 12 hours and this `AWS ECR Token Refresh CronJob` will help with generating a new token every 10 hours.

&nbsp;

Please create a new `YAML` file with the following content:

`aws-ecr-token-refresh.yaml`

```yaml
#
# Kubernetes Secret Manifest Document
#

apiVersion: v1
kind: Secret
metadata:
  name: ecr-token-refresh
  namespace: {kubernetes_namespace}
stringData:
  AWS_SECRET_ACCESS_KEY: "{aws_secret_access_key}"
---

#
# Kubernetes ConfigMap Manifest Document
#

apiVersion: v1
kind: ConfigMap
metadata:
  name: ecr-token-refresh
  namespace: {kubernetes_namespace}
data:
  AWS_ACCOUNT_ID: "{aws_account_id}"
  AWS_DEFAULT_REGION: "{aws_default_region}"
  AWS_ACCESS_KEY_ID: "{aws_access_key_id}"
  DOCKER_SECRET_NAME: "ecr-credentials"
---

#
# Kubernetes CronJob Manifest Document
#

apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: ecr-token-refresh
  namespace: {kubernetes_namespace}
spec:
  schedule: "0 */10 * * *"
  successfulJobsHistoryLimit: 3
  suspend: false
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: ecr-token-refresh
          containers:
          - name: ecr-registry-helper
            image: cloudresty/aws-kubectl:v1.0.0
            imagePullPolicy: IfNotPresent
            envFrom:
              - secretRef:
                  name: ecr-token-refresh
              - configMapRef:
                  name: ecr-token-refresh
            command:
              - /bin/sh
              - -c
              - |-
                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
                export ECR_TOKEN=`aws ecr get-login-password`
                export NAMESPACE_NAME={kubernetes_namespace}
                kubectl delete secret --ignore-not-found ${DOCKER_SECRET_NAME} -n ${NAMESPACE_NAME}
                kubectl create secret docker-registry ${DOCKER_SECRET_NAME} \
                  --docker-server=https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com \
                  --docker-username=AWS \
                  --docker-password="${ECR_TOKEN}" \
                  --namespace=${NAMESPACE_NAME}
                echo "Secret was successfully updated at $(date)"
          restartPolicy: Never
---

#
# Kubernetes ServiceAccount Manifest Document
#

apiVersion: v1
kind: ServiceAccount
metadata:
  name: ecr-token-refresh
  namespace: {kubernetes_namespace}
---

#
# Kubernetes Role Manifest Document
#

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: {kubernetes_namespace}
  name: ecr-token-refresh
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["ecr-credentials"]
  verbs: ["delete"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["create"]
---

#
# Kubernetes RoleBinding Manifest Document
#

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ecr-token-refresh
  namespace: {kubernetes_namespace}
subjects:
- kind: ServiceAccount
  name: ecr-token-refresh
  namespace: {kubernetes_namespace}
  apiGroup: ""
roleRef:
  kind: Role
  name: ecr-token-refresh
  apiGroup: ""

```

&nbsp;

Replace the values listed below:

* `{kubernetes_namespace}`
* `{aws_default_region}`
* `{aws_account_id}`
* `{aws_access_key_id}`
* `{aws_secret_access_key}`

&nbsp;

After replacing all values required we can then create the K8s resources using `kubectl` as shown in the example below:

```shell
kubectl apply -f aws-ecr-token-refresh.yaml
```

&nbsp;

---
Copyright &copy; [Cloudresty](https://cloudresty.com)
