package com.proptech.listing.application.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.proptech.listing.domain.entity.Listing;
import com.proptech.listing.infrastructure.repository.ListingRepository;

@Service
public class ListingService {

    private final ListingRepository listingRepository;

    public ListingService(ListingRepository listingRepository) {
        this.listingRepository = listingRepository;
    }

    public List<Listing> getAll() {
        return listingRepository.findAll();
    }

    public Listing create(Listing listing) {
        return listingRepository.save(listing);
    }
}