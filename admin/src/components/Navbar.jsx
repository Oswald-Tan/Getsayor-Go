import { HiMenuAlt3 } from "react-icons/hi";
import { useSidebar } from "../context/useSidebar";
import { useSelector } from "react-redux";
import { useState } from "react";
import { AiOutlineUser } from "react-icons/ai";
import useDarkMode from "../hooks/useDarkMode";

const Navbar = () => {
  const { user } = useSelector((state) => state.auth);
  const { toggleSidebar } = useSidebar();
  const [setIsProfileOpen] = useState(false); // State untuk toggle profile menu
  const { isDarkMode, toggleDarkMode } = useDarkMode();

  return (
    <div className="relative flex items-center justify-between h-[56px] px-4 bg-white dark:bg-[#121212] border-b dark:border-[#282828] border-white">
      {/* Toggle Sidebar */}
      <button
        className="cursor-pointer text-[#0e0e0e] dark:text-white"
        onClick={toggleSidebar}
        aria-label="Toggle Sidebar"
      >
        <HiMenuAlt3 size={26} />
      </button>

      {/* Toggle Profile */}
      <div className="relative">
        <div
          className="flex items-center justify-center gap-2"
          onClick={() => setIsProfileOpen((prev) => !prev)} // Toggle state
        >
          <button
            onClick={toggleDarkMode}
            className="relative w-14 h-7 rounded-full bg-indigo-100 dark:bg-[#282828] transition-colors duration-500 ease-in-out"
            aria-label="Toggle Dark Mode"
          >
            {/* Thumb */}
            <div
              className={`absolute top-1 w-5 h-5 bg-white rounded-full shadow-lg transform transition-transform duration-300 ${
                isDarkMode ? "translate-x-8" : "translate-x-1"
              }`}
            >
              <span className="sr-only">
                {isDarkMode ? "Light Mode" : "Dark Mode"}
              </span>
            </div>
          </button>
         <div className="flex items-center justify-center gap-1">
         <div className="border border-gray-500 dark:border-white rounded-full p-1">
            <AiOutlineUser size={20} className="text-gray-500 dark:text-white" />
          </div>
          <p className="text-xs text-gray-500 dark:text-white sm:block hidden">{user && user.fullname}</p>
         </div>
        </div>
      </div>
    </div>
  );
};

export default Navbar;
