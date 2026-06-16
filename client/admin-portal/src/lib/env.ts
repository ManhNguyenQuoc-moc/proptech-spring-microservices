export function getListingServiceUrl() {
  return process.env.NEXT_PUBLIC_LISTING_SERVICE_URL ?? "http://localhost:8083";
}
