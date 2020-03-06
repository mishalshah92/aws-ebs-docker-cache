#!/bin/bash

set -e

AWS_REGION="${aws_region}"
NAME="${name}"
STACK_NAME="${stack_name}"
ENV="${env}"
OWNER="${owner}"
ATOM="${atom}"
TOOL="${tool}"

{
  sudo mkfs -t xfs /dev/nvme0n1
  sudo mkdir -p /mnt/docker
  sudo mount /dev/nvme0n1 /mnt/docker

  sudo systemctl stop docker
  sudo echo '{"data-root": "/mnt/docker", "storage-driver": "overlay2"}' >>/etc/docker/daemon.json
  sudo systemctl daemon-reload
  sudo systemctl start docker

  for download_image in ${docker_images}; do
    sudo docker pull $download_image
  done

  sudo systemctl stop docker
  sudo umount /mnt/docker

  Instance_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  DOCKER_VOL_ID=$(aws ec2 describe-instances --instance-ids $Instance_ID --query "Reservations[0].Instances[0].BlockDeviceMappings[?DeviceName=='/dev/sdf'].Ebs.VolumeId" --output text --region $AWS_REGION)
  SNAPSHOT_ID=$(aws ec2 create-snapshot \
    --volume-id "$DOCKER_VOL_ID" \
    --description "Snapshot of docker image cache." \
    --tag-specifications "ResourceType=snapshot,
                                            Tags=[
                                                { Key=Name, Value='$NAME' },
                                                { Key=Stack_name, Value='$STACK_NAME' },
                                                { Key=Env, Value='$ENV' },
                                                { Key=Owner, Value='$OWNER' },
                                                { Key=Atom, Value='$ATOM' },
                                                { Key=Tool, Value='$TOOL' },
                                                { Key=Source_instance_id, Value='$Instance_ID' },
                                            ]" \
    --output text \
    --query 'SnapshotId' \
    --region $AWS_REGION)

  echo "INFO: Snapshot creation triggered $SNAPSHOT_ID."

} ||
  {
    echo "Error: Something went wrong!!! Shutting down instance."
    sudo shutdown -P now
  }
