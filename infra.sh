#!/bin/bash 


AMI_ID=ami-0220d79f3f480ecf5
SECURITY_GROUP=sg-0852f24a7ee530aa1
INSTANCE=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "user" "cart" "shippig" "payment" "frontend")

for instance in ${INSTANCE[@]}
do
  InstanceId=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SECURITY_GROUP --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' --query "Instances[0].InstanceId" --output text)
  if [ $instance == frontend ]
  then 
    IP=$(aws ec2 describe-instances --instance-ids $InstanceId --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
  else 
    IP=$(aws ec2 describe-instances --instance-ids $InstanceId  --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
  fi
done
