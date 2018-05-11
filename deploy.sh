# deploy.sh
#! /bin/bash

SHA1=$1

# Push image to ECR
$(aws ecr get-login --region <region>)
docker push 012881927014.dkr.ecr.ap-southeast-1.amazonaws.com/docker:$SHA1

# Create new Elastic Beanstalk version
EB_BUCKET=ngocduy-deploy-bucket
DOCKERRUN_FILE=$SHA1-Dockerrun.aws.json
sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE
aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE --region ap-southeast-1
aws elasticbeanstalk create-application-version --application-name ngocduy \
    --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKERRUN_FILE \
    --region ap-southeast-1
