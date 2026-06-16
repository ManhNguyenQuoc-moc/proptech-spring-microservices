const highlights = [
  "Listing search and filters",
  "Listing detail pages",
  "Customer inquiries",
  "Saved listings"
];

export function ListingHighlights() {
  return (
    <section className="panelGrid" aria-label="Customer listing features">
      {highlights.map((item) => (
        <article className="panel" key={item}>
          <h2>{item}</h2>
          <p>Planned customer workflow for the PropTech listing experience.</p>
        </article>
      ))}
    </section>
  );
}
