### Sunset notice

We believe there is an opportunity to create a truly outstanding developer experience for deploying to the cloud, however developing this vision requires that we temporarily limit our focus to just one cloud. Gruntwork has hundreds of customers currently using AWS, so we have temporarily suspended our maintenance efforts on this repo. Once we have implemented and validated our vision for the developer experience on the cloud, we look forward to picking this up. In the meantime, you are welcome to use this code in accordance with the open source license, however we will not be responding to GitHub Issues or Pull Requests.

If you wish to be the maintainer for this project, we are open to considering that. Please contact us at support@gruntwork.io.

---

[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/gruntwork-io/terraform-google-gke.svg?label=latest)](https://github.com/gruntwork-io/terraform-google-gke/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.0.x-blue.svg)

# Google Kubernetes Engine (GKE) Module

This repo contains a [Terraform](https://www.terraform.io) module for running a Kubernetes cluster on [Google Cloud Platform (GCP)](https://cloud.google.com/)
using [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/).

## Quickstart

If you want to quickly spin up a GKE Public Cluster, you can run the example that is in the root of this
repo. Check out the [gke-basic-helm example documentation](https://github.com/gruntwork-io/terraform-google-gke/blob/master/examples/gke-basic-helm)
for instructions.

## What's in this repo

This repo has the following folder structure:

- [root](https://github.com/gruntwork-io/terraform-google-gke/tree/master): The root folder contains an example of how
  to deploy a GKE Public Cluster with an example chart with [Helm](https://helm.sh/). See [gke-basic-helm](https://github.com/gruntwork-io/terraform-google-gke/blob/master/examples/gke-basic-helm)
  for the documentation.

- [modules](https://github.com/gruntwork-io/terraform-google-gke/tree/master/modules): This folder contains the
  main implementation code for this Module, broken down into multiple standalone submodules.

  The primary module is:

  - [gke-cluster](https://github.com/gruntwork-io/terraform-google-gke/tree/master/modules/gke-cluster): The GKE Cluster module is used to
    administer the [cluster master](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture)
    for a [GKE Cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-admin-overview).

  There are also several supporting modules that add extra functionality on top of `gke-cluster`:

  - [gke-service-account](https://github.com/gruntwork-io/terraform-google-gke/tree/master/modules/gke-service-account):
    Used to configure a GCP service account for use with a GKE cluster.

- [examples](https://github.com/gruntwork-io/terraform-google-gke/tree/master/examples): This folder contains
  examples of how to use the submodules.

- [test](https://github.com/gruntwork-io/terraform-google-gke/tree/master/test): Automated tests for the submodules
  and examples.

## What is Kubernetes?

[Kubernetes](https://kubernetes.io) is an open source container management system for deploying, scaling, and managing
containerized applications. Kubernetes is built by Google based on their internal proprietary container management
systems (Borg and Omega). Kubernetes provides a cloud agnostic platform to deploy your containerized applications with
built in support for common operational tasks such as replication, autoscaling, self-healing, and rolling deployments.

You can learn more about Kubernetes from [the official documentation](https://kubernetes.io/docs/tutorials/kubernetes-basics/).

## What is GKE?

Google Kubernetes Engine or "GKE" is a Google-managed Kubernetes environment. GKE is a fully managed experience; it
handles the management/upgrading of the Kubernetes cluster master as well as autoscaling of "nodes" through "node pool"
templates.

Through GKE, your Kubernetes deployments will have first-class support for GCP IAM identities, built-in configuration of
high-availability and secured clusters, as well as native access to GCP's networking features such as load balancers.

## <a name="how-to-run-applications"></a>How do you run applications on Kubernetes?

There are three different ways you can schedule your application on a Kubernetes cluster. In all three, your application
Docker containers are packaged as a [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod/), which are the
smallest deployable unit in Kubernetes, and represent one or more Docker containers that are tightly coupled. Containers
in a Pod share certain elements of the kernel space that are traditionally isolated between containers, such as the
network space (the containers both share an IP and thus the available ports are shared), IPC namespace, and PIDs in some
cases.

Pods are considered to be relatively ephemeral disposable entities in the Kubernetes ecosystem. This is because Pods are
designed to be mobile across the cluster so that you can design a scalable fault tolerant system. As such, Pods are
generally scheduled with
[Controllers](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/#pods-and-controllers) that manage the
lifecycle of a Pod. Using Controllers, you can schedule your Pods as:

- Jobs, which are Pods with a controller that will guarantee the Pods run to completion.
- Deployments behind a Service, which are Pods with a controller that implement lifecycle rules to provide replication
  and self-healing capabilities. Deployments will automatically reprovision failed Pods, or migrate Pods to healthy
  nodes off of failed nodes. A Service constructs a consistent endpoint that can be used to access the Deployment.
- Daemon Sets, which are Pods that are scheduled on all worker nodes. Daemon Sets schedule exactly one instance of a Pod
  on each node. Like Deployments, Daemon Sets will reprovision failed Pods and schedule new ones automatically on
  new nodes that join the cluster.

<!-- TODO: ## What parts of the Production Grade Infrastructure Checklist are covered by this Module? -->

