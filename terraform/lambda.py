import boto3
import os
from datetime import datetime, timedelta, timezone

ec2_client = boto3.client('ec2')
ssm_client = boto3.client('ssm')
delete_before_hour = 48

# Environment Vars
OWNER = os.environ['Owner']
STACK = os.environ['Stack_name']
ENV = os.environ['Env']
AWS_REGION = os.environ['AWS_DEFAULT_REGION']


def launch_cache_warmer():
    launch_template_id = os.environ['EC2_LC_ID']
    launch_template_ver = os.environ['EC2_LC_VER']

    response = ec2_client.run_instances(
        LaunchTemplate={
            'LaunchTemplateId': launch_template_id,
            'Version': launch_template_ver
        },
        MaxCount=1,
        MinCount=1
    )

    return response['Instances']


def get_snapshots():
    snapshots = ec2_client.describe_snapshots(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    'docker-cache-' + STACK + "-" + ENV
                ]
            },
            {
                'Name': 'tag:Owner',
                'Values': [
                    OWNER
                ]
            },
            {
                'Name': 'tag:Stack_name',
                'Values': [
                    STACK
                ]
            },
            {
                'Name': 'tag:Env',
                'Values': [
                    ENV
                ]
            },
        ],
    )

    if 'Snapshots' in snapshots:
        return snapshots['Snapshots']
    else:
        return []


def filter_snapshots(snapshots=[]):
    filtered_snapshot_list = []
    time_diff = datetime.utcnow().replace(tzinfo=timezone.utc) - timedelta(hours=delete_before_hour)

    for snapshot in snapshots:
        snapshot_id = snapshot['SnapshotId']
        snapshot_time = snapshot['StartTime']

        if snapshot_time < time_diff:
            filtered_snapshot_list.append(snapshot_id)

    return filtered_snapshot_list


def delete_snapshots(snapshots=[]):
    responses = []
    for snapshot_id in snapshots:
        response = ec2_client.delete_snapshot(
            SnapshotId=snapshot_id,
        )

        responses.append(response)

    return responses


def terminate_warmer_instance(snapshot_id):
    response = ec2_client.describe_snapshots(
        SnapshotIds=[
            snapshot_id
        ]
    )
    print(response)
    if 'Snapshots' in response:

        tags = response['Snapshots'][0]['Tags']
        name = None
        owner = None
        service = None
        team = None
        instance_id = None

        for tag in tags:
            if 'Name' == tag['Key']:
                name = tag['Value']

            if 'Owner' == tag['Key']:
                owner = tag['Value']

            if 'Source_instance_id' == tag['Key']:
                instance_id = tag['Value']

        if name == 'docker-cache-' + STACK + "-" + ENV and owner == OWNER and instance_id is not None:
            return ec2_client.terminate_instances(
                InstanceIds=[
                    instance_id
                ],
            )

    return None


def lambda_handler(event, context):

    if "detail-type" in event and "source" in event:

        if "aws.ec2" in event['source'] and "EBS Snapshot Notification" in event['detail-type']:

            print("INFO: Event: EBS Snapshot Notification Success.")

            snapshot_id = event['detail']['snapshot_id']
            snapshot_id = snapshot_id.replace("arn:aws:ec2::" + AWS_REGION + ":snapshot/", '')

            # Updating snapshot-id to SSM
            response = put_ssm_parameter(snapshot_id=snapshot_id)
            print(response)

            # Terminating docker cache warmer instance.
            response = terminate_warmer_instance(snapshot_id=snapshot_id)
            if response is None:
                print("Info: No instance to delete.")
            else:
                print("Info: Docker cache warmer instance delete complete.")
                print(response)

        elif "aws.events" in event['source'] and "Scheduled Event" in event['detail-type']:

            print("INFO: Event: Cron schedule.")

            # Launch docker warmer
            response = launch_cache_warmer()
            print("Info: Docker cache warmer launch is complete.")
            print(response)

            # Delete old Snapshots
            snapshots = get_snapshots()
            filtered_snapshots = filter_snapshots(snapshots=snapshots)

            response = delete_snapshots(snapshots=filtered_snapshots)
            print("Info: Below docker cache snapshots deleted successfully.")
            print(response)

        else:
            print("INFO: Event: Cron schedule (Default).")

            # Launch docker warmer
            response = launch_cache_warmer()
            print("Info: Docker cache warmer launch is complete.")
            print(response)

    else:
        print("Info: No event found.")
