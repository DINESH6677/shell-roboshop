#!/bin/bash
AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-013a9c377a5c2354d
ZONE_ID=Z09655201PB8BBQ9OOULW
DOMAIN_NAME="devopswithdinesh.shop"



for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro  --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instances[0].InstanceId" --output text)

    if [ $instance != "frontend" ]; then
        IP=aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].PrivateIpAddress" --output text
        RECORD_NAME=$instance.$DOMAIN_NAME
    else
        IP=aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].PublicIpAddress" --output text
        RECORD_NAME=$DOMAIN_NAME
    fi
    echo "$instance : $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '{
      "Comment": "Add A record for devopswithdinesh.shop",
      "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": '$RECORD_NAME',
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [{ "Value": '$IP'}]
        }
      }]
    }'

done