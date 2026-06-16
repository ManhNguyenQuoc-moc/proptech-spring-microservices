import { getListingServiceUrl } from "@/lib/env";
import type { Listing } from "./listing.types";

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
