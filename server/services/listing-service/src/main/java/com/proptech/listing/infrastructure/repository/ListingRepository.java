package com.proptech.listing.infrastructure.repository;
import com.proptech.listing.domain.entity.Listing;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;
public interface ListingRepository
        extends JpaRepository<Listing, UUID> {
}
