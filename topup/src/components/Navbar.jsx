import { useSelector, useDispatch } from "react-redux";
import { LuHandCoins } from "react-icons/lu";
import { RiHistoryFill, RiMenuLine, RiCloseLine } from "react-icons/ri";
import { FiLogOut } from "react-icons/fi";
import { LogOut, reset } from "../features/authSlice";
import { useNavigate, Link, useLocation } from "react-router-dom";
import Swal from "sweetalert2";
import { useState, useRef, useEffect } from "react";
import Profile from "../assets/profile.png";

const Navbar = () => {
  const { user } = useSelector((state) => state.auth);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const location = useLocation();
  const [showDropdown, setShowDropdown] = useState(false);
  const [showMobileMenu, setShowMobileMenu] = useState(false);
  const dropdownRef = useRef();
  const mobileMenuRef = useRef();

  const logout = async () => {
    Swal.fire({
      title: "Konfirmasi Logout",
      text: "Apakah Anda yakin ingin logout?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "Ya, Logout",
      cancelButtonText: "Batal",
    }).then((result) => {
      if (result.isConfirmed) {
        dispatch(LogOut());
        dispatch(reset());
        navigate("/");
      }
    });
  };

  // Handle click outside
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setShowDropdown(false);
      }
      if (mobileMenuRef.current && !mobileMenuRef.current.contains(e.target)) {
        setShowMobileMenu(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const menus = [
    { name: "Top Up", link: "/topup", icon: <LuHandCoins size={18} /> },
    { name: "Top Up History", link: "/topup-history", icon: <RiHistoryFill size={18} /> },
  ];

  return (
    <div className="bg-white shadow-sm border-b px-4 md:px-6 py-3 flex items-center justify-between relative">
      {/* Logo & Mobile Menu Toggle */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => setShowMobileMenu(!showMobileMenu)}
          className="md:hidden text-gray-600"
        >
          {showMobileMenu ? <RiCloseLine size={24} /> : <RiMenuLine size={24} />}
        </button>
        
        <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
          <span className="text-[#1a4fb1] font-bold text-xl">GS</span>
        </div>
      </div>

      {/* Desktop Menu */}
      <div className="hidden md:flex gap-4 items-center bg-gray-100 rounded-full">
        {menus.map((menu, index) => (
          <Link
            key={index}
            to={menu.link}
            className={`flex items-center gap-2 text-sm px-5 py-3 rounded-full transition-all duration-200 ${
              location.pathname === menu.link
                ? "bg-[#1a4fb1] text-white"
                : "text-gray-600 hover:bg-gray-200"
            }`}
          >
            {menu.icon}
            <span>{menu.name}</span>
          </Link>
        ))}
      </div>

      {/* Mobile Menu */}
      {showMobileMenu && (
        <div
          ref={mobileMenuRef}
          className="absolute md:hidden top-full left-0 right-0 bg-white border-t shadow-lg z-50"
        >
          <div className="flex flex-col p-4 gap-2">
            {menus.map((menu, index) => (
              <Link
                key={index}
                to={menu.link}
                onClick={() => setShowMobileMenu(false)}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg ${
                  location.pathname === menu.link
                    ? "bg-[#1a4fb1] text-white"
                    : "text-gray-600 hover:bg-gray-100"
                }`}
              >
                {menu.icon}
                <span className="text-sm">{menu.name}</span>
              </Link>
            ))}
          </div>
        </div>
      )}

      {/* Profile Section */}
      <div className="flex items-center gap-4 relative" ref={dropdownRef}>
        <div className="relative">
          <img
            src={Profile}
            alt="User"
            onClick={() => setShowDropdown(!showDropdown)}
            className="w-10 h-10 rounded-full object-cover border-2 border-gray-200 cursor-pointer"
          />

          {showDropdown && (
            <div className="absolute right-0 mt-2 w-48 bg-white border rounded-md shadow-md z-50">
              <div className="px-4 py-3 border-b text-sm text-gray-700 font-medium">
                {user?.fullname || "User"}
              </div>
              <button
                onClick={logout}
                className="w-full px-4 py-2 flex items-center gap-2 text-sm text-red-600 hover:bg-red-50"
              >
                <FiLogOut size={16} />
                Logout
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Navbar;