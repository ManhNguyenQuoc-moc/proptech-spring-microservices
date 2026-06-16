import Link from "next/link";
import { CustomerHome } from "@/features/home/CustomerHome";

export default function HomePage() {
  return (
    <>
      <CustomerHome />
      <footer className="appFooter">
        <Link href="/customer">Customer home</Link>
      </footer>
    </>
  );
}
