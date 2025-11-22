# AWS EBS Docker Cache

`aws-ebs-docker-cache` provisions an EC2-based cache builder that pre-pulls Docker images onto a dedicated 
EBS volume, snapshots it, and automatically rotates old snapshots. These snapshots are then used by your 
build/worker services to create new EBS volumes with pre-cached Docker layers, dramatically speeding up 
Docker-based workloads.

This solution ensures Docker caching happens on a separate EBS volume (not the root volume), providing 
cleaner isolation, faster builds, and snapshot-based reuse across environments.

## How It Works
1. Cache Builder EC2 Host (Periodic or Manual Trigger)
   - A small EC2 instance is launched on schedule or on-demand.
   - It attaches a dedicated EBS volume (cache volume).
   - The instance pulls all configured Docker images into a local cache directory on that EBS volume.
   - Once complete, the instance is terminated or stopped as per configuration.
2. Snapshot Creation & Rotation
   - After the cache volume is warmed with Docker layers, the system:
   - Creates a new EBS snapshot of the cache volume.
   - Deletes older snapshots based on retention policy to control cost.
   - Only the latest snapshot(s) are retained for production use.
3. Build Service Usage
   - When your build or worker service launches:
   - It creates a new EBS volume from the latest snapshot.
   - Attaches it to the worker host.
   - Docker reads cached layers from that mounted volume.
   - Builds become significantly faster because images/layers are pre-pulled.

## Why This Approach?
✔ **Massive Build Acceleration** \
Workers get Docker layers instantly — no more pulling base images repeatedly.

✔ **True Snapshot-Based Caching** \
Caching is pre-built, pre-warmed, and reused across workers.

✔ **Cost-Optimized**
- Cache builder host runs only briefly.
- EBS snapshots are cheap and incremental.
- Automatic snapshot retention cleans up old copies.

✔ **Clean Separation**\
Docker cache lives on a dedicated EBS volume, not on root volume, meaning:
- No clutter on system disk
- Easy replacement
- Safe for ephemeral build hosts

✔ Terraform Provisioned\
All AWS components — EC2 host, EBS volumes, policies, timers, and automation — are managed with Terraform.

## High-Level Architecture

1. Terraform provisions:
   - Cache builder EC2 instance configuration
   - IAM roles & policies
   - Cache EBS volume
   - Lambda (optional) for snapshot rotation
   - CloudWatch schedule (optional) for periodic rebuilds
2. Cache Builder Workflow:
   - Mount EBS volume
   - Pull Docker images
   - Save layers onto cache volume
   - Create EBS snapshot
   - Clean up host
3. Build Worker Workflow:
   - Launch worker
   - Create volume from snapshot
   - Mount it (e.g., /var/lib/docker-cache)
   - Docker automatically reuses cached layers

## Use Cases
- Slow CI builds due to large base images
- Private registries with network constraints
- Multi-region environments needing consistent layer caching
- Large monorepos with many build pipelines
- Air-gapped or isolated environments

## Key Components

- **Terraform infrastructure** definition for:
  - EC2 cache builder template
  - EBS cache volume
  - Snapshot logic
  - Snapshot rotation
  - Schedules for rebuilds
- **Docker image list** to pre-pull
- **Startup scripts** to warm the cache
- **Snapshot consumption logic** for downstream build services

## Maintainer
Maintained by Mishal Shah\
📧 mishalshah92@gmail.com