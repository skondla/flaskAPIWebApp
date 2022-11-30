#!/bin/bash
#Author: skondla@me.com
#Purpose run Docker container for FLask Auth App (DB Restore tool)

if [ $# -lt 1 ];
then
    echo "USAGE: bash $0 [containerName"]
    echo "example: $ bash dockerRunFlaskAuthUser.sh flaskauthuser"
    echo "Please enter Constainer Name.  !!!Exiting !!!"
    exit 1
fi

containerName=${1}

if [[ `docker ps -a | grep ${containerName} | awk '{print $1}'|wc -l` -ge 1 ]]; then
    docker rm `docker ps -a | grep ${containerName} | awk '{print $1}'`
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd ${SCRIPTPATH}
#echo "PWD: `pwd`"
AWS_ACCESS_KEY_ID=`cat ~/.aws/credentials|grep aws_access_key_id | awk '{print $3}'`
AWS_SECRET_ACCESS_KEY=`cat ~/.aws/credentials|grep aws_secret_access_key | awk '{print $3}'`
REGION=`aws configure get region`

docker run \
 -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
 -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
 -e AWS_DEFAULT_REGION=eu-west-1  -d \
 -p 50443:50443 -p 5042:5042 \
 --env-file ./env.sh \
 --name ${containerName} flaskauthuser
