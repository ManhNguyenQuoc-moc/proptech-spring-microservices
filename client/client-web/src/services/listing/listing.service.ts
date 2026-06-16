import { getListingServiceUrl } from "@/lib/env";
import type { CreateListingInput, Listing } from "./listing.types";

const baseUrl = getListingServiceUrl();

export async function getListings(): Promise<Listing[]> {
  const response = await fetch(`${baseUrl}/api/listings`, {
    cache: "no-store"
  });

  if (!response.ok) {
    throw new Error("Failed to load listings");
  }

  return response.json() as Promise<Listing[]>;
}

export async function createListing(input: CreateListingInput): Promise<Listing> {
  const response = await fetch(`${baseUrl}/api/listings`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(input)
  });

  if (!response.ok) {
    throw new Error("Failed to create listing");
  }

  return response.json() as Promise<Listing>;
}
