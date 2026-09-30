#!/bin/bash 


AMI_ID="ami-0220d79f3f480ecf5"
SECURITY_GROUP="sg-0852f24a7ee530aa1"
INSTANCE=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "user" "cart" "shipping" "payment" "frontend")
DOMAIN_NAME=srinunayak.online
ZONE_ID=Z0407054ZOPSOXW1A7C8

for instance in ${INSTANCE[@]}
do
  InstanceId=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SECURITY_GROUP --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instances[0].InstanceId" --output text)
  if [ $instance == frontend ]
  then 
    IP=$(aws ec2 describe-instances --instance-ids $InstanceId --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
  else 
    IP=$(aws ec2 describe-instances --instance-ids $InstanceId  --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
  fi
  echo "$instance ip address: $IP"

  aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch
  {
  "Comment": "Creating a new A record",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$instance.$DOMAIN_NAME",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "$IP"
          }
        ]
      
    }
  ]
 }



done
