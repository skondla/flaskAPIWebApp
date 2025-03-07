#!/bin/bash
#Author: skondla@me.com
#Purpose: Create a Elastic Container Registry, Docker Build and instance of ECS cluster and deploy a container web application

#enviroment variables

export ECR_REPOSITORY="flaskwebapp1-demo-shop"
export APP_DIR="../../../../app1/"
#export AWS_ACCOUNT_ID=`cat ~/.secrets | grep 'AWS_ACCOUNT_ID' | awk '{print $2}'`
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
export AWS_REGION=`cat ~/.aws/config | grep region | awk '{print $3}'`
export AWS_ACCESS_KEY_ID=`cat ~/.aws/credentials|grep aws_access_key_id | awk '{print $3}'`
export AWS_SECRET_ACCESS_KEY=`cat ~/.aws/credentials|grep aws_secret_access_key | awk '{print $3}'`
export ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
#export IMAGE_TAG=$(git rev-parse --long HEAD | grep -v long)
export IMAGE_TAG=$(openssl rand -hex 32)

#Authenticate Docker to ECR
aws ecr get-login-password \
 --region ${AWS_REGION} | docker login --username AWS \
 --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

#Cretate ECR repo
aws ecr create-repository \
 --repository-name ${ECR_REPOSITORY} \
 --region ${AWS_REGION} \
 --image-scanning-configuration scanOnPush=true \
 --image-tag-mutability MUTABLE

# Build and push the docker image
export imagename=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

echo "Build and push $imagename"
docker build -t $imagename $APP_DIR

#Push image to ECR
docker push $imagename
echo "imageName: $imagename" > ~/Downloads/webapp_ecr_image.txt
echo "imageTag: $IMAGE_TAG" >> ~/Downloads/webapp_ecr_image.txt