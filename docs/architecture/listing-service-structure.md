# Listing Service Structure

## Overview

`listing-service` chịu trách nhiệm quản lý toàn bộ nghiệp vụ liên quan đến tin đăng bất động sản trong hệ thống PropTech.

### Responsibilities

- Tạo tin đăng
- Cập nhật tin đăng
- Xóa tin đăng
- Tìm kiếm tin đăng
- Xem chi tiết tin đăng
- Duyệt tin đăng
- Từ chối tin đăng
- Quản lý trạng thái tin đăng

---

# Package Structure

```text
listing-service/

src/main/java/com/proptech/listing

├── domain/
├── application/
├── infrastructure/
├── presentation/
└── config/
```

---

# Clean Architecture Layers

```text
Presentation
      ↓
Application
      ↓
Domain
      ↑
Infrastructure
```

Dependency Rule:

- Domain không phụ thuộc bất kỳ layer nào.
- Application chỉ phụ thuộc Domain.
- Infrastructure triển khai các interface của Domain.
- Presentation gọi Application.

---

# Domain Layer

Chứa toàn bộ business rules.

```text
domain/
│
├── aggregate/
├── entity/
├── valueobject/
├── repository/
├── service/
└── event/
```

---

## Aggregate

Aggregate Root của Listing Context.

```text
aggregate/
└── Listing.java
```

Ví dụ:

```text
Listing
│
├── Address
├── Price
├── Images
├── PropertyType
└── ListingStatus
```

---

## Entity

```text
entity/
├── ListingImage.java
└── ListingFeature.java
```

---

## Value Object

```text
valueobject/
├── Address.java
├── Price.java
├── PropertyType.java
└── ListingStatus.java
```

Ví dụ:

```java
public record Price(BigDecimal amount) {}
```

---

## Repository

Repository abstraction.

```text
repository/
└── ListingRepository.java
```

Ví dụ:

```java
public interface ListingRepository {

    Listing save(Listing listing);

    Optional<Listing> findById(UUID id);

    List<Listing> search(ListingCriteria criteria);

}
```

---

## Domain Service

Chứa nghiệp vụ phức tạp không thuộc Entity.

```text
service/
└── ListingDomainService.java
```

---

## Domain Events

```text
event/
├── ListingCreatedEvent.java
├── ListingUpdatedEvent.java
├── ListingApprovedEvent.java
└── ListingRejectedEvent.java
```

---

# Application Layer

Chứa Use Cases.

```text
application/
│
├── command/
├── query/
├── dto/
└── usecase/
```

---

## Commands

Các thao tác thay đổi dữ liệu.

```text
command/
├── CreateListingCommand.java
├── UpdateListingCommand.java
└── ApproveListingCommand.java
```

---

## Queries

Các thao tác đọc dữ liệu.

```text
query/
├── GetListingByIdQuery.java
└── SearchListingQuery.java
```

---

## DTO

```text
dto/
├── CreateListingDto.java
├── UpdateListingDto.java
└── ListingResponseDto.java
```

---

## Use Cases

```text
usecase/
├── CreateListingUseCase.java
├── UpdateListingUseCase.java
├── ApproveListingUseCase.java
├── RejectListingUseCase.java
├── SearchListingUseCase.java
└── GetListingDetailUseCase.java
```

Use Case là nơi điều phối nghiệp vụ giữa Domain và Infrastructure.

---

# Infrastructure Layer

Chứa implementation details.

```text
infrastructure/
│
├── persistence/
├── messaging/
├── cache/
└── external/
```

---

## Persistence

JPA Implementation.

```text
persistence/
│
├── entity/
│
├── repository/
│
└── mapper/
```

---

### JPA Entity

```text
entity/
└── ListingJpaEntity.java
```

Ví dụ:

```java
@Entity
@Table(name = "listings")
public class ListingJpaEntity {
}
```

---

### Repository Implementation

```text
repository/
├── SpringDataListingRepository.java
└── JpaListingRepository.java
```

Trong đó:

```java
JpaListingRepository
```

implements:

```java
ListingRepository
```

---

## Messaging

RabbitMQ Publisher / Consumer.

```text
messaging/
│
├── publisher/
└── consumer/
```

Ví dụ:

```text
publisher/
├── ListingCreatedPublisher.java
└── ListingApprovedPublisher.java
```

---

## Cache

Redis integration.

```text
cache/
├── ListingCacheService.java
└── RedisListingCache.java
```

---

## External

Kết nối dịch vụ bên ngoài.

```text
external/
├── CloudinaryClient.java
└── MapApiClient.java
```

---

# Presentation Layer

Expose REST APIs.

```text
presentation/
│
├── controller/
├── request/
├── response/
├── mapper/
└── exception/
```

---

## Controller

```text
controller/
└── ListingController.java
```

---

## Request

```text
request/
├── CreateListingRequest.java
└── UpdateListingRequest.java
```

---

## Response

```text
response/
├── ListingResponse.java
└── ListingDetailResponse.java
```

---

## Exception

```text
exception/
├── GlobalExceptionHandler.java
└── ErrorResponse.java
```

---

# Config Layer

Application Configuration.

```text
config/
│
├── JpaConfig.java
├── RabbitMqConfig.java
├── RedisConfig.java
├── SwaggerConfig.java
└── SecurityConfig.java
```

---

# Initial REST APIs

## Create Listing

```http
POST /api/listings
```

---

## Get Listing Detail

```http
GET /api/listings/{id}
```

---

## Search Listings

```http
GET /api/listings
```

---

## Update Listing

```http
PUT /api/listings/{id}
```

---

## Approve Listing

```http
PATCH /api/listings/{id}/approve
```

---

## Reject Listing

```http
PATCH /api/listings/{id}/reject
```

---

# Initial Git Commits

```bash
chore(listing-service): initialize spring boot project

chore(listing-service): setup clean architecture packages

feat(listing-service): create listing aggregate

feat(listing-service): implement create listing use case

feat(listing-service): implement listing persistence layer

feat(listing-service): expose listing rest api
```

---

# Development Order

Phase 1

- Generate Spring Boot project
- Setup package structure
- Setup PostgreSQL connection

Phase 2

- Create Aggregate
- Create Value Objects
- Create Repository Interfaces

Phase 3

- Create Use Cases
- Create DTOs

Phase 4

- Implement JPA Repositories
- Implement REST APIs

Phase 5

- RabbitMQ Integration
- Redis Cache
- Cloudinary Integration

Phase 6

- Unit Testing
- Integration Testing
- Documentation

```

```
