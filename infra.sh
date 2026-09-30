#!/bin/bash 


AMI_ID=i-0104ee616152c8e2e
SECURITY_GROUP=sg-0852f24a7ee530aa1
INSTANCE=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "user" "cart" "shippig" "payment" "frontend")

for instance in ${INSTANCE[@]}
do
  InstanceId=$(aws ec2 run-instances --image-id ami-0123456789abcdef0 --instance-type t3.micro --security-group-ids sg-0123456789abcdef0 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' --query "Instances[0].InstanceId" --output text)
  if [ $instance == frontend ]
  then 
    IP=$(aws ec2 describe-instances --instance-ids i-0123456789abcdef0 --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
  else 
    IP=$(aws ec2 describe-instances --instance-ids i-0123456789abcdef0 --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)

#   aws route53 change-resource-record-sets --hosted-zone-id YOUR_HOSTED_ZONE_ID --change-batch
#   {
#     "Comment": "Creating a new A record",
#     "Changes": [
#         {
#         "Action": "CREATE",
#         "ResourceRecordSet": {
#             "Name": "://yourdomain.com",
#             "Type": "A",
#             "TTL": 300,
#             "ResourceRecords": [
#                 {
#                     "Value": "192.0.2.44"
#                 }
#             ]
         
#         }
#     ]
#   }


done
