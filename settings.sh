#!/bin/bash

export GOOGLE_REGION=europe-west8
export GOOGLE_CREDENTIALS=~/WORK/crypt-420813-0f7a4e118fef.json
# export GOOGLE_CLOUD_KEYFILE_JSON=~/WORK/crypt-420813-0f7a4e118fef.json
export GOOGLE_PROJECT=crypt-420813
export TF_VAR_project_id="crypt-420813"
export TF_GCLOUD_CREDENTIALS=~/WORK/crypt-420813-0f7a4e118fef.json
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

export TEKTON_SECRET_TOKEN=${TEKTON_SECRET_TOKEN-$(head -c 24 /dev/random | base64)}

kubectl create secret generic git-secret --from-literal=secretToken=$TEKTON_SECRET_TOKEN

# GOOGLE_CLOUD_SERVICE_ACCOUNT_JSON

#  env | grep GOOGLE
#gcloud auth login
#gcloud config set project crypt-420813
#gcloud container clusters delete cryptk8s --region=us-west1
# gcloud container clusters delete cryptk8s --region=us-west1

#gcloud config set project crypt-420813
#gcloud config set account  crypttrader@crypt-420813.iam.gserviceaccount.com

# gcloud -q compute networks delete default --project=${var.projectId}

#GOOGLE_APPLICATION_CREDENTIALS
# kubectl get apiservices
#command:
#    - /metrics-server
#    - --kubelet-insecure-tls
 #   - --kubelet-preferred-address-types=InternalIP
 # kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# kubectl port-forward svc/argocddev-server -n argocd-dev 8081:443
# argocd login --insecure localhost:8081
# kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097
# kubectl -n tekton-pipelines port-forward svc/tekton-dashboard 9097:9097

#kubectl -n tekton-pipelines port-forward svc/tekton-dashboard 9097:9097

# gcloud container clusters list
# gcloud auth activate-service-account ACCOUNT
# gcloud auth application-default login

# kind: Service
#apiVersion: v1
#metadata:
#  labels:
#    k8s-app: kubernetes-dashboard
#  name: kubernetes-dashboard
 # namespace: kubernetes-dashboard
#spec:
#  ports:
#    - port: 443
#      targetPort: 8443
#  selector:
#    k8s-app: kubernetes-dashboard

#    kubectl port-forward pod/kubernetes-dashboard 8443:8443 
#export TF_GCLOUD_BUCKET=<remote state bucket name>
#export TF_GCLOUD_PREFIX=<remote state bucket prefix>
#export TF_GCLOUD_CREDENTIALS=<gcp credentials.json>

#tf -c=gcloud destroy 

#kubectl -n kube-system create serviceaccount tiller

#kubectl create clusterrolebinding tiller
#–clusterrole=cluster-admin
#–serviceaccount=kube-system:tiller

#helm init --service-account tiller

#kubectl create clusterrolebinding tiller  –clusterrole=cluster-admin

#helm init --kube-context CONTEXT_NAME --upgrade

#helm ls -A --kubeconfig=$HOME/.kube/cryptk8s

#Determining your repository URL on Google container registry
#In order to push a container image to Google container registry, there is an important consideration regarding the repository URL. First of all, there are several Google container registry region hosts available:

#gcr.io (currently USA region)
#us.gcr.io (USA region)
#eu.gcr.io (Europe region)
#asia.gcr.io (Asia region)
#Note that these region hosts are network latency purpose, doesn't mean to restrict to a particular region. They are still accessible worldwide.
#Second of all, while you tag the container image, you also need to specify your project-id on which you've enabled billing and API. Therefore, the entire repository URL could be:

#<gcr region>/<project-id>/<image name>:tag

#docker build -t gcr.io/{PROJECT_ID}/{image}:tag
#gcloud docker -- push gcr.io/{PROJECT_ID}/{image}:tag
#gcloud docker -- pull gcr.io/{PROJECT_ID}/{image}:tag

#gcloud container images list

gcloud container images list --filter=blog
This command can also be used to list images in a public registry:

gcloud container images list --repository=gcr.io/google-containers
For public registries, you can directly use “docker search”, too:

docker search gcr.io/google-containers/kube

#     gcloud config set project crypt-420813 && \
#     export GOOGLE_REGION=us-west1 && \
#    export GOOGLE_CREDENTIALS=~/WORK/crypt-420813-0f7a4e118fef.json && \
#    export GOOGLE_PROJECT=crypt-420813 && \
#    gcloud container clusters get-credentials cryptk8s --project crypt-420813 --region us-west1 && \
#

/*
provider "kubernetes" {
  config_path    = "~/.kube/cryptk8s"
  config_context = "cryptk8s"
}*/
/*
provider "kubernetes" {
  host = "https://cluster_endpoint:port"

  client_certificate     = file("~/.kube/client-cert.pem")
  client_key             = file("~/.kube/client-key.pem")
  cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")
}
provider "kubernetes" {
  config_data = data.vault_generic_secret.k8s_creds.data["KUBECONFIG"]
}
*/

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/cloud/deploy.yaml

gcloud compute firewall-rules delete validate-nginx

