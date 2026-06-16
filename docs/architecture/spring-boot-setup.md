Spring Boot Project Setup Guide

1. Prerequisites
   Required Software
   Software Version
   Java 21
   Maven 3.9+
   Docker Desktop Latest
   Git Latest
   IntelliJ IDEA Community hoặc Ultimate
   PostgreSQL Docker
   RabbitMQ Docker
   Redis Docker
2. Verify Installation
   Java
   java --version

Expected:

openjdk 21
Maven
mvn -version

Expected:

Apache Maven 3.9.x
Git
git --version 3. Generate Spring Boot Project

Truy cập:

Spring Initializr

Project Information
Listing Service
Project: Maven

Language: Java

Spring Boot: 3.x

Group:
com.proptech

Artifact:
listing-service

Name:
listing-service

Package:
com.proptech.listing

Packaging:
Jar

Java:
21
Dependencies
Required
Spring Web

Spring Data JPA

Validation

PostgreSQL Driver

Lombok
Future Dependencies
Spring Security

Spring AMQP

Spring Cache

Spring Boot Actuator 4. Create Service Folder

Ví dụ:

proptech-platform/

services/

└── listing-service/

Giải nén project vào đây.

5. Package Structure

Tạo cấu trúc:

src/main/java/com/proptech/listing

├── domain
│
├── application
│
├── infrastructure
│
├── presentation
│
└── config 6. Create Domain Packages
domain/

├── aggregate
├── entity
├── valueobject
├── repository
├── service
└── event 7. Create Application Packages
application/

├── command
├── query
├── dto
└── usecase 8. Create Infrastructure Packages
infrastructure/

├── persistence
│ ├── entity
│ ├── repository
│ └── mapper
│
├── messaging
│
├── cache
│
└── external 9. Create Presentation Packages
presentation/

├── controller
├── request
├── response
├── mapper
└── exception 10. Create Config Packages
config/

├── JpaConfig
├── RabbitMqConfig
├── RedisConfig
├── SwaggerConfig
└── SecurityConfig 11. Application Configuration

File:

src/main/resources/application.yml

Ví dụ:

server:
port: 8083

spring:
application:
name: listing-service

datasource:
url: jdbc:postgresql://localhost:5432/listing_db
username: postgres
password: postgres

jpa:
hibernate:
ddl-auto: update

    show-sql: true

    properties:
      hibernate:
        format_sql: true

12. Create Main Class
    package com.proptech.listing;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ListingServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(
            ListingServiceApplication.class,
            args
        );
    }

} 13. Verify Project Runs
mvn clean install

Run:

mvn spring-boot:run

Expected:

Started ListingServiceApplication 14. Initial Git Commit
git add .

git commit -m "chore(listing-service): initialize spring boot project" 15. Recommended Development Order
Step 1

Setup Spring Boot project

✓ application.yml
✓ package structure
✓ PostgreSQL connection
Step 2

Domain Layer

✓ Aggregate
✓ Value Object
✓ Repository Interface
✓ Domain Events
Step 3

Application Layer

✓ Commands
✓ Queries
✓ DTOs
✓ Use Cases
Step 4

Infrastructure Layer

✓ JPA Repository
✓ Entity Mapping
✓ RabbitMQ
✓ Redis
Step 5

Presentation Layer

✓ Controllers
✓ Requests
✓ Responses
✓ Exception Handling
Final Structure
listing-service/

src/main/java/com/proptech/listing

├── domain
│
├── application
│
├── infrastructure
│
├── presentation
│
├── config
│
└── ListingServiceApplication.java
