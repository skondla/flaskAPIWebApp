#!/bin/bash
#Author: skondla@me.com
#Purpose: Create a new instance of GKE cluster and deploy a container web application

# Create a project and set GKE_PROJECT to the project id:
# See https://console.cloud.google.com/projectselector2/home/dashboard

# Set parameters
export GKE_PROJECT=${GCP_PROJECT_ID} #env variable from  ~/.secrets
export GKE_CLUSTER="flaskapp1-demo-cluster"
export GKE_APP_NAME="flaskapp1-demo-shop"
export GKE_SERVICE="flaskapp1-service"
export GKE_SERVICE_ACCOUNT="flaskapp1-serviceaccount"
export GKE_DEPLOYMENT_NAME="flaskapp1-deployment"
export MANIFESTS_DIR="deploy/manifests/webapp"
export APP_DIR="../../app1/"
export GKE_NAMESPACE="flaskapp1-namespace"
export GKE_APP_PORT="25443"

# Get a list of regions:
# $ gcloud compute regions list
#
# Get a list of zones:
# $ gcloud compute zones list
export GKE_REGION="us-east4"
export GKE_ZONE="us-east4-a"
export GKE_ADDITIONAL_ZONE="us-east4-b"


# Just a placeholder for the first deployment
export GITHUB_SHA="flaskapp1-demo-shop"
export GKE_SVC_MAIL="$GKE_SERVICE_ACCOUNT@$GKE_PROJECT.iam.gserviceaccount.com"

#Login to gcloud
gcloud auth login

gcloud config set project $GKE_PROJECT
gcloud config set compute/zone $GKE_ZONE
#gcloud config set compute/zone $GKE_ADDITIONAL_ZONE
gcloud config set compute/region $GKE_REGION


##########
#To be tested why this is needed: give the Google Service Acccount cluster-admin clusterrole binding
export check=`kubectl get clusterrolebinding | grep $GKE_SERVICE_ACCOUNT | awk '{print $1}' | wc -l`
if [ ${check} -le 1 ]; then
  kubectl create clusterrolebinding $GKE_SERVICE_ACCOUNT \
   --clusterrole cluster-admin \
   --user $GKE_SVC_MAIL
else
  echo "clusterrolebinding $GKE_SERVICE_ACCOUNT already exists"
  echo "${check}"
fi
##########