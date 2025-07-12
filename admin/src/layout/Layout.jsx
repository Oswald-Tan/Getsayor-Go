import { Outlet } from "react-router-dom";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";
import { useSidebar } from "../context/useSidebar";

const currentYear = new Date().getFullYear();

const AdminLayout = () => {
  const { open } = useSidebar();
  return (
    <div className="flex relative dark:bg-[#121212]">
      <div
        className={`fixed top-0 left-0 z-50 w-16 transition-all duration-500 ${
          open ? "w-[280px]" : "w-[68px]"
        }`}
      >
        <Sidebar />
      </div>

      <div
        className={`flex-1 flex flex-col overflow-y-auto transition-all duration-500 ${
          open ? "md:ml-[280px]" : "md:ml-[68px]"
        }`}
      >
        <Navbar />
        <main className="bg-gray-100 dark:bg-[#121212]">
          <div className="p-5 min-h-[calc(100vh-116px)]">
            <Outlet />
          </div>

          <footer className="p-5 md:text-end text-center">
            <p className="text-sm text-[#909090] dark:text-[#8b8b8b]">
              © {currentYear} - All rights reserved.
            </p>
          </footer>
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;
