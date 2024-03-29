#!/bin/bash
#Author: skondla@me.com
#Purpose: Create a new instance of GKE cluster and deploy a container web application

# Create a project and set GKE_PROJECT to the project id:
# See https://console.cloud.google.com/projectselector2/home/dashboard

# Set parameters
source ~/.bash_profile
export GKE_PROJECT=${GCP_PROJECT_ID} #env variable from  ~/.secrets
export GKE_CLUSTER="flaskapp1-demo-cluster"
export GKE_APP_ADMIN_NAME="flaskapp1-admin-ui"
export GKE_APP_USER_NAME="flaskapp1-user-ui"
export GKE_SERVICE="flaskapp1-service"
export GKE_SERVICE_ACCOUNT="flaskapp1-serviceaccount"
export GKE_DEPLOYMENT_NAME="flaskapp1-deployment"
export APP_MANIFESTS_DIR="manifests/flaskapp1"
export DB_MANIFESTS_DIR="manifests/postgres/sample2"
export APP_ADMIN_DIR="../../../dockerized/ADMIN"
export APP_USER_DIR="../../../dockerized/USER"
export GKE_NAMESPACE="flaskapp1-namespace"
export GKE_ADMIN_APP_PORT=30443
export GKE_USER_APP_PORT=50443


# Get a list of regions:
# $ gcloud compute regions list
#
# Get a list of zones:
# $ gcloud compute zones list
export GKE_REGION="us-east4"
export GKE_ZONE="us-east4-a"
export GKE_ADDITIONAL_ZONE="us-east4-b"


# Just a placeholder for the first deployment
export GITHUB_SHA_ADMIN=${GKE_APP_ADMIN_NAME}
export GITHUB_SHA_USER=${GKE_APP_USER_NAME}

#Login to gcloud
gcloud auth login

gcloud config set project $GKE_PROJECT
gcloud config set compute/zone $GKE_ZONE
#gcloud config set compute/zone $GKE_ADDITIONAL_ZONE
gcloud config set compute/region $GKE_REGION

# enable API
gcloud services enable \
 compute.googleapis.com \
 containerregistry.googleapis.com \
 container.googleapis.com \
 artifactregistry.googleapis.com


# Create a GKE cluster
#gcloud container clusters create example-cluster  --zone us-east1-b --additional-zones us-east1-c  --preemptible --num-nodes 1 --enable-autoscaling --min-nodes 1 --max-nodes 3 --enable-autorepair --scopes "https://www.googleapis.com/auth/cloud-platform" --enable-ip-alias --metadata disable-legacy-endpoints=true --enable-stackdriver-kubernetes --enable-private-nodes --master-ipv4-cidr

gcloud container clusters create ${GKE_CLUSTER} \
 --zone ${GKE_ZONE} \
 --additional-zones ${GKE_ADDITIONAL_ZONE} \
 --preemptible \
 --num-nodes 1 \
 --enable-autoscaling \
 --min-nodes 1 \
 --max-nodes 3 \
 --enable-autorepair \
 --scopes "https://www.googleapis.com/auth/cloud-platform" \
 --enable-ip-alias \
 --metadata disable-legacy-endpoints=true \
 --logging=SYSTEM,WORKLOAD \
 --monitoring=SYSTEM,API_SERVER,SCHEDULER,CONTROLLER_MANAGER 
 
 #--service-account=178146062177-compute@developer.gserviceaccount.com

if [ $? -ne 0 ]; then
  echo "gcloud container clusters create failed!"
  exit 1
fi

#gcloud container clusters create $GKE_CLUSTER --num-nodes=1

# Configure kubctl
gcloud container clusters get-credentials $GKE_CLUSTER

# Create repository
gcloud artifacts repositories create $GKE_PROJECT \
  --repository-format=docker \
  --location=$GKE_REGION \
  --description="Docker repository"

# Create a service account
gcloud iam service-accounts create $GKE_SERVICE_ACCOUNT \
  --display-name "GitHub Deployment" \
  --description "Used to deploy from GitHub Actions to GKE"

# Get mail of service account
gcloud iam service-accounts list

export GKE_SVC_MAIL="$GKE_SERVICE_ACCOUNT@$GKE_PROJECT.iam.gserviceaccount.com"

# Add 'container.clusterAdmin' role:
gcloud projects add-iam-policy-binding $GKE_PROJECT \
  --member=serviceAccount:$GKE_SVC_MAIL \
  --role=roles/container.clusterAdmin 

# Add 'artifactregistry.admin' role:
gcloud projects add-iam-policy-binding $GKE_PROJECT \
  --member=serviceAccount:$GKE_SVC_MAIL \
  --role=roles/artifactregistry.admin


# Add 'container.namespaces.get' role:
# gcloud projects add-iam-policy-binding $GKE_PROJECT \
#   --member=serviceAccount:$GKE_SVC_MAIL \
#   --role=roles/container.namespaces.get

# Download JSON
gcloud iam service-accounts keys create ~/.private/flaskapp_key.json --iam-account=$GKE_SVC_MAIL

# Build and push the docker image (ADMIN APP)
docker build --tag \
  "$GKE_REGION-docker.pkg.dev/$GKE_PROJECT/$GKE_PROJECT/$GKE_APP_ADMIN_NAME:$GITHUB_SHA_ADMIN" \
  ${APP_ADMIN_DIR}/
gcloud auth configure-docker $GKE_REGION-docker.pkg.dev --quiet
gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://$GKE_REGION-docker.pkg.dev
docker push "$GKE_REGION-docker.pkg.dev/$GKE_PROJECT/$GKE_PROJECT/$GKE_APP_ADMIN_NAME:$GITHUB_SHA_ADMIN"


# Build and push the docker image (USER APP)
docker build --tag \
  "$GKE_REGION-docker.pkg.dev/$GKE_PROJECT/$GKE_PROJECT/$GKE_APP_USER_NAME:$GITHUB_SHA_USER" \
  ${APP_USER_DIR}/
gcloud auth configure-docker $GKE_REGION-docker.pkg.dev --quiet
gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://$GKE_REGION-docker.pkg.dev
docker push "$GKE_REGION-docker.pkg.dev/$GKE_PROJECT/$GKE_PROJECT/$GKE_APP_USER_NAME:$GITHUB_SHA_USER"


#Check envsubst is configured correctly (this example is on MacOS only)
which gettext

if [ $? -ne 0 ]; then
  echo "gettext NOT installed!"
  brew install gettext
  brew link --force gettext 
  exit 1
else
  brew link --force gettext 
fi

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

# Create postgresql database
export PG_ROOT=`cat ~/.secrets | grep PG_ROOT | awk '{print $2}'`

envsubst < ${DB_MANIFESTS_DIR}/secret_pg.yaml | kubectl apply -f -
envsubst < ${DB_MANIFESTS_DIR}/csi_storage_class_pg.yaml | kubectl apply -f -
envsubst < ${DB_MANIFESTS_DIR}/csi_pvc_pg.yaml | kubectl apply -f -
envsubst < ${DB_MANIFESTS_DIR}/deployment_pg.yaml | kubectl apply -f -
envsubst < ${DB_MANIFESTS_DIR}/service_pg.yaml | kubectl apply -f -

##########
#Create namespace and service account
envsubst < ${APP_MANIFESTS_DIR}/flaskapp1.yaml | kubectl apply -f -
# Create deployment
envsubst < ${APP_MANIFESTS_DIR}/Deployment_admin_ui.yaml | kubectl apply -f -
envsubst < ${APP_MANIFESTS_DIR}/Deployment_user_ui.yaml | kubectl apply -f -
# Create service
envsubst < ${APP_MANIFESTS_DIR}/Service_admin_ui.yaml | kubectl apply -f -
envsubst < ${APP_MANIFESTS_DIR}/Service_user_ui.yaml | kubectl apply -f -

#Check application is running, test application REST endpioints (ADMIN APP)
curl -Lk https://`kubectl get svc -n $GKE_NAMESPACE | grep $GKE_SERVICE-admin | awk '{print $4}'`:$GKE_ADMIN_APP_PORT/signup
curl -Lk https://`kubectl get svc -n $GKE_NAMESPACE | grep $GKE_SERVICE-admin | awk '{print $4}'`:$GKE_ADMIN_APP_PORT/login
curl -Lk https://`kubectl get svc -n $GKE_NAMESPACE | grep $GKE_SERVICE-admin | awk '{print $4}'`:$GKE_ADMIN_APP_PORT/logout

#Check application is running, test application REST endpioints (USER APP)
curl -Lk https://`kubectl get svc -n $GKE_NAMESPACE | grep $GKE_SERVICE-user | awk '{print $4}'`:$GKE_USER_APP_PORT/login
curl -Lk https://`kubectl get svc -n $GKE_NAMESPACE | grep $GKE_SERVICE-user | awk '{print $4}'`:$GKE_USER_APP_PORT/status
curl -Lk https://`kubectl get svc -n $GKE_NAMESPACE | grep $GKE_SERVICE-user | awk '{print $4}'`:$GKE_USER_APP_PORT/restore
curl -Lk https://`kubectl get svc -n $GKE_NAMESPACE | grep $GKE_SERVICE-user | awk '{print $4}'`:$GKE_USER_APP_PORT/attachdb 

kubectl get service
echo ""
echo "Note: if the EXTERNAL-IP is still pending you have to wait and run 'kubectl get service' again to find out the external ip to test the application!"
echo ""

echo ""
echo "Please create a secret named 'GKE_SA_KEY' in GitHub with the followign content:"
echo ""
cat ~/.private/flaskapp_key.json | base64
echo ""


#resource "serviceaccounts" in API group "" in the namespace "flaskapp1-namespace": requires one of ["container.serviceAccounts.get"] permission(s