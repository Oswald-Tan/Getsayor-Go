import { Outlet } from "react-router-dom";
import Navbar from "../components/Navbar";

const currentYear = new Date().getFullYear();

const AdminLayout = () => {
  return (
    <div className="flex relative dark:bg-[#121212]">
     

      <div
        className={`flex-1 flex flex-col overflow-y-auto transition-all duration-500`}
      >
        <Navbar />
        <main className="bg-gray-100 dark:bg-[#121212]">
          <div className="p-4 min-h-[calc(100vh-130px)]">
            <Outlet />
          </div>

          <footer className="p-5 text-center">
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
