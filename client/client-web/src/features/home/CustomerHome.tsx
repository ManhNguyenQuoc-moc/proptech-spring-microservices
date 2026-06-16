import { ListingHighlights } from "@/features/listings/ListingHighlights";

export function CustomerHome() {
  return (
    <main className="pageShell customerTheme">
      <section className="pageHeader">
        <p className="eyebrow">Customer</p>
        <h1>Find property listings</h1>
        <p className="lede">
          Browse available listings and prepare for richer search, saved homes, and inquiry workflows.
        </p>
      </section>
      <ListingHighlights />
    </main>
  );
}
