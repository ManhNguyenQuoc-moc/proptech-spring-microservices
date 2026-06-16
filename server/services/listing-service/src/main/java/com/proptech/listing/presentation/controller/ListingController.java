package com.proptech.listing.presentation.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.proptech.listing.application.service.ListingService;
import com.proptech.listing.domain.entity.Listing;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/listings")
@Tag(name = "Listings", description = "Property listing APIs")
public class ListingController {

    private final ListingService listingService;

    public ListingController(ListingService listingService) {
        this.listingService = listingService;
    }

    @GetMapping
    @Operation(summary = "Get all listings")
    public List<Listing> getAll() {
        return listingService.getAll();
    }

    @PostMapping
    @Operation(summary = "Create a listing")
    public Listing create(@Valid @RequestBody Listing listing) {
        return listingService.create(listing);
    }
}
