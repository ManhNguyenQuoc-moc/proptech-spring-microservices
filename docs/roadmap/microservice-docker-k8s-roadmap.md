PropTech Platform Learning Roadmap
Spring Boot → Microservices → Docker → Kubernetes

1. Objective

Mục tiêu của roadmap này là xây dựng một hệ thống PropTech hoàn chỉnh đồng thời học:

Java 21
Spring Boot 3
Clean Architecture
Domain Driven Design (DDD)
Microservices
PostgreSQL
RabbitMQ
Redis
Docker
Docker Compose
Kubernetes
CI/CD 2. Learning Strategy

Không học Kubernetes trước.

Lộ trình đúng:

Spring Boot
↓
Clean Architecture
↓
DDD
↓
Microservices
↓
Docker
↓
Docker Compose
↓
RabbitMQ
↓
Redis
↓
CI/CD
↓
Kubernetes
Phase 1 — Foundation Setup
Goal

Khởi tạo monorepo và chuẩn hóa cấu trúc dự án.

Tasks
Repository Structure
proptech-platform/

├── services/
├── frontend/
├── infrastructure/
├── docs/
├── .github/
├── docker-compose.yml
└── README.md
Git Strategy
main
develop

feature/setup-repository
feature/identity-service
feature/listing-service
feature/transaction-service
feature/payment-service
feature/reporting-service
Documentation
docs/

├── requirements/
├── architecture/
├── bounded-context/
├── use-cases/
└── roadmap/
Deliverables

✅ Monorepo

✅ Git Workflow

✅ Documentation Structure

Phase 2 — Spring Boot Fundamentals
Goal

Nắm vững Spring Boot trước khi làm Microservice.

Topics
Spring Core
IoC
Dependency Injection
Bean Lifecycle
Spring MVC
Controller
Request Mapping
Validation
Exception Handling
Spring Data JPA
Entity
Repository
Relationship Mapping
Query Methods
Practice

Tạo:

listing-service

với:

CRUD Listing
Deliverables

✅ Listing CRUD API

✅ PostgreSQL Connection

✅ Unit Tests

Phase 3 — Clean Architecture + DDD
Goal

Tách rõ business logic và infrastructure.

Service Structure
listing-service/

src/main/java/com/proptech/listing

├── domain
├── application
├── infrastructure
├── presentation
└── config
Domain Layer
aggregate
entity
valueobject
repository
event
service
Application Layer
command
query
dto
usecase
Deliverables

✅ Listing Aggregate

✅ Value Objects

✅ Repository Interfaces

Phase 4 — Docker
Goal

Containerize Spring Boot Services.

Topics
Docker Basics
Image
Container
Volume
Network
Dockerfile

Ví dụ:

FROM eclipse-temurin:21-jdk

WORKDIR /app

COPY target/app.jar app.jar

ENTRYPOINT ["java","-jar","app.jar"]
Practice

Dockerize:

listing-service
Deliverables

✅ Dockerfile

✅ Docker Image

✅ Container Running

Phase 5 — Docker Compose
Goal

Chạy nhiều services cùng lúc.

Infrastructure
PostgreSQL
RabbitMQ
Redis
Listing Service
Identity Service
Structure
infrastructure/

└── compose/
├── local/
├── dev/
└── prod/
Deliverables

✅ docker-compose.yml

✅ Multi-container setup

Phase 6 — Identity Service
Goal

Authentication & Authorization.

Features
Register
Login
JWT
Refresh Token
Role Management
Roles
ADMIN
REALTOR
CUSTOMER
Deliverables

✅ JWT Authentication

✅ Spring Security

Phase 7 — Listing Service
Goal

Quản lý tin đăng bất động sản.

Features
Create Listing
Update Listing
Search Listing
Approve Listing
Reject Listing
Deliverables

✅ Listing Domain

✅ Listing APIs

Phase 8 — Event Driven Architecture
Goal

Học RabbitMQ.

Topics
Producer
Listing Service
Consumer
Transaction Service
Events
listing.created
listing.updated
listing.approved
listing.rejected
Deliverables

✅ RabbitMQ Setup

✅ Event Publishing

✅ Event Consumption

Phase 9 — Redis
Goal

Caching.

Use Cases
Listing Search
Cache Search Results
Property Detail
Cache Listing Detail
Deliverables

✅ Redis Integration

✅ Cache Layer

Phase 10 — Additional Services
Transaction Service

Responsibilities:

Purchase Workflow
Rental Workflow
Contract Management
Payment Service

Responsibilities:

Payment
Commission
Invoice
Reporting Service

Responsibilities:

Dashboard
Revenue Reports
Statistics
Deliverables

✅ Full Microservice Ecosystem

Phase 11 — CI/CD
Goal

Tự động hóa build và deploy.

GitHub Actions
.github/workflows/
Pipeline
Build
↓
Test
↓
Docker Build
↓
Push Image
Deliverables

✅ Automated Pipeline

Phase 12 — Kubernetes
Goal

Triển khai hệ thống lên K8S.

Infrastructure Structure
infrastructure/

└── k8s/
Topics
Week 1
Pod
Deployment
Service
Week 2
ConfigMap
Secret
Namespace
Week 3
Ingress
Persistent Volume
Week 4
Helm
HPA
Monitoring
Example Structure
k8s/

├── namespace/
├── configmap/
├── secret/

├── postgres/
├── rabbitmq/
├── redis/

├── identity-service/
├── listing-service/
├── transaction-service/
├── payment-service/
└── reporting-service/
Deliverables

✅ Deploy Spring Boot on Kubernetes

✅ Service Discovery

✅ ConfigMap

✅ Secret

✅ Ingress

Final Architecture
Frontend
│
├── Client Web
└── Admin Portal

        │

API Gateway

        │

┌─────────────────────┐
│ Identity Service │
│ Listing Service │
│ Transaction Service │
│ Payment Service │
│ Reporting Service │
└─────────────────────┘

        │

RabbitMQ
Redis

        │

PostgreSQL
Success Criteria

Kết thúc roadmap, bạn sẽ có:

✅ Spring Boot Portfolio Project

✅ Clean Architecture

✅ Domain Driven Design

✅ Microservices

✅ RabbitMQ

✅ Redis

✅ Docker

✅ Docker Compose

✅ Kubernetes

✅ CI/CD

✅ Một hệ thống PropTech hoàn chỉnh có thể deploy thực tế.
