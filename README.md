# AWS Retail Store Production Grade Cloud Native Microservices Platform

A production-oriented cloud-native retail application deployed on **Amazon EKS** using **Terraform, Kubernetes, Helm, Karpenter, AWS managed services, and OpenTelemetry**.

The project demonstrates how a microservices-based retail application can be deployed and operated on AWS with a focus on **automation, scalability, high availability, security, cost optimization, and observability**.

---

## Architecture

```text
                         Internet
                            |
                            v
                   AWS Load Balancer
                            |
                            v
                     Amazon EKS
                            |
          +-----------------+-----------------+
          |        |        |        |        |
         UI     Catalog    Cart   Checkout   Orders
          |        |        |        |        |
          |       RDS    DynamoDB  Redis    RDS
          |      MySQL              |      PostgreSQL
          |                         |
          +-------------------------+
                            |
                           SQS

              Observability
                    |
              ADOT / OpenTelemetry
                    |
             CloudWatch + X-Ray
```

---

## Technology Stack

| Category | Technologies |
|---|---|
| Cloud | AWS |
| Infrastructure | Terraform |
| Kubernetes | Amazon EKS |
| Application | Retail Store Microservices |
| Packaging | Helm |
| Autoscaling | HPA + Karpenter |
| Compute | EC2 On-Demand + Spot |
| Databases | RDS MySQL, RDS PostgreSQL |
| Data Services | DynamoDB, ElastiCache Redis |
| Messaging | Amazon SQS |
| Security | IAM, EKS Pod Identity, Secrets Manager |
| Networking | VPC, AWS Load Balancer Controller |
| Observability | ADOT, OpenTelemetry, CloudWatch, X-Ray |

---

## Infrastructure with Terraform

The AWS infrastructure is provisioned using **Terraform**, providing a repeatable and version-controlled foundation.

Key resources include:

- Amazon VPC and subnets
- Amazon EKS cluster
- IAM and EKS Pod Identity
- RDS MySQL and PostgreSQL
- DynamoDB
- ElastiCache Redis
- SQS
- Supporting security and networking resources

Terraform state is maintained using an **Amazon S3 backend**.

---

## Microservices

The retail application consists of:

- **UI** – Customer-facing application
- **Catalog** – Product catalog backed by RDS MySQL
- **Cart** – Shopping cart backed by DynamoDB
- **Checkout** – Checkout processing using Redis
- **Orders** – Order processing using PostgreSQL and SQS

The services are packaged and deployed using **Helm**.

---

## Autoscaling & High Availability

### Karpenter

Karpenter dynamically provisions EC2 nodes based on pending pod requirements.

The cluster uses both:

- On-Demand capacity
- Spot capacity

This enables workload-aware provisioning and improved cost efficiency.

### HPA

Kubernetes HPA scales application replicas based on workload demand, while Karpenter provides the underlying compute capacity when additional nodes are required.

### Multi-AZ Resilience

**Topology Spread Constraints** distribute application replicas across Availability Zones.

**PodDisruptionBudgets** help maintain application availability during node drains, consolidation, and other voluntary disruptions.

**Spot interruption** scenarios were also tested to validate node replacement and workload rescheduling.

---

## Security

The platform follows AWS-native security practices:

- **EKS Pod Identity** for workload-level AWS permissions
- **AWS Secrets Manager** for sensitive credentials
- **Secrets Store CSI Driver** for Kubernetes secret integration
- Private networking and security groups
- No long-lived AWS credentials stored inside application containers

---

## Observability

The platform uses **AWS Distro for OpenTelemetry (ADOT)** to collect observability data from the Kubernetes environment.

- **CloudWatch** – centralized logs
- **Prometheus / Kubernetes metrics** – infrastructure and workload metrics
- **AWS X-Ray** – distributed tracing
- **OpenTelemetry** – telemetry collection and instrumentation

This provides visibility across the application and infrastructure layers.

---

## Deployment

Configure access to the EKS cluster:

```bash
aws eks update-kubeconfig \
  --name retail-dev-eksdemo1 \
  --region us-east-1
```

Deploy the retail application:

```bash
./install-retail-apps.sh
```

Verify the workloads:

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
helm list -A
```

---

## Key Project Highlights

- Infrastructure fully automated with **Terraform**
- Production-oriented **Amazon EKS** architecture
- Microservices deployed using **Helm**
- Dynamic node provisioning with **Karpenter**
- **On-Demand + Spot** compute strategy
- Application autoscaling with **HPA**
- Multi-AZ workload distribution
- Resilience using **PodDisruptionBudgets**
- Secure AWS access using **EKS Pod Identity**
- Secrets managed through **AWS Secrets Manager**
- AWS managed data plane using **RDS, DynamoDB, Redis and SQS**
- Centralized observability with **ADOT, CloudWatch and X-Ray**

---

## Project Outcome

This project brings together the core capabilities required to operate a modern cloud-native application on AWS:

**Infrastructure as Code → Kubernetes → Microservices → Autoscaling → Security → Observability → Resilience**

It serves as a hands-on demonstration of **AWS DevOps, Kubernetes, Platform Engineering, and cloud-native architecture**.
