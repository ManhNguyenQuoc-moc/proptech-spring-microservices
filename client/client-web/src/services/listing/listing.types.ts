export interface Listing {
  id: string;
  title: string;
  description: string;
  price: number;
  address: string;
}

export interface CreateListingInput {
  title: string;
  description: string;
  price: number;
  address: string;
}
