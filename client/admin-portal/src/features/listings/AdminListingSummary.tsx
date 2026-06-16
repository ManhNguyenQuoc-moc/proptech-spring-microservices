const adminItems = [
  "Listing moderation",
  "Product catalog operations",
  "Order tracking",
  "Payment review"
];

export function AdminListingSummary() {
  return (
    <section className="panelGrid" aria-label="Admin capabilities">
      {adminItems.map((item) => (
        <article className="panel" key={item}>
          <h2>{item}</h2>
          <p>Admin capability placeholder ready to connect to Spring Boot services.</p>
        </article>
      ))}
    </section>
  );
}
