# Listing Service

## Summary

`listing-service` owns property listing records and is the only service with a confirmed REST controller today.

| Item | Value |
|---|---|
| Path | `server/services/listing-service/` |
| Port | `8083` |
| Package | `com.proptech.listing` |
| Schema | `listing_service` |
| Table | `listings` |
| Migration | Flyway `V1__create_listings_table.sql` |
| Hibernate DDL | `validate` |

## Current Implementation

- Main class: `ListingServiceApplication`
- Entity: `Listing`
- Repository: `ListingRepository extends JpaRepository<Listing, UUID>`
- Application service: `ListingService`
- REST controller: `ListingController`

## Endpoints

| Method | Path | Behavior |
|---|---|---|
| GET | `/api/listings` | Returns all listings |
| POST | `/api/listings` | Creates a listing from request body |

## Swagger / OpenAPI

| URL | Purpose |
|---|---|
| `/swagger-ui.html` | Listing service Swagger UI |
| `/v3/api-docs` | Listing service OpenAPI JSON |

## Entity Fields

- `id`
- `title`
- `description`
- `price`
- `address`

## Known Gaps

- Controller receives and returns the JPA entity directly.
- No request/response DTOs.
- No listing status, property type, images, owner, approval workflow, or search criteria.
- `@SpringBootTest` smoke test requires PostgreSQL to be running.
