import { AdminListingSummary } from "@/features/listings/AdminListingSummary";

export function AdminDashboard() {
  return (
    <main className="pageShell adminTheme">
      <section className="pageHeader">
        <p className="eyebrow">Admin</p>
        <h1>Operations dashboard</h1>
        <p className="lede">
          Manage listings, users, orders, products, and payments as backend APIs mature.
        </p>
      </section>
      <AdminListingSummary />
    </main>
  );
}
