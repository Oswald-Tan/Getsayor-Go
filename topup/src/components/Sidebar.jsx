import React, { useEffect, useState } from "react";
import { RiHistoryFill  } from "react-icons/ri";
import { LuHandCoins } from "react-icons/lu";
import { FiLogOut } from "react-icons/fi";
import { useSidebar } from "../context/useSidebar";
import { Link } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { LogOut, reset } from "../features/authSlice";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import Logo from "../assets/cs.png";

const Sidebar = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { user } = useSelector((state) => state.auth);
  const { open, toggleSidebar } = useSidebar();
  const [menus, setMenus] = useState([]);

  useEffect(() => {
    // Update menus berdasarkan role setelah user tersedia
    const updatedMenus = [
      {
        name: "Top Up",
        link: "/topup",
        icon: LuHandCoins,
      },
      {
        name: "Top Up History",
        link: "/topup-history",
        icon: RiHistoryFill,
      },

      // {
      //   name: "Setting",
      //   link: "/setting",
      //   icon: RiSettings4Line,
      //   margin: true,
      // },
      {
        name: "Logout",
        action: () => logout(),
        icon: FiLogOut,
        margin: true,
      },
    ];

    setMenus(updatedMenus);
  }, [user]);

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

  return (
    <>
      {/* Overlay untuk sidebar mobile */}
      {open && (
        <div
          onClick={toggleSidebar}
          className="fixed inset-0 bg-black opacity-50 z-10 md:hidden"
        />
      )}

      <section className="flex gap-6 relative">
        <div
          className={`bg-[#121212] border-r border-[#282828] min-h-screen ${
            open
              ? "w-[280px]"
              : "md:w-[68px] md:translate-x-0 -translate-x-[280px]"
          } fixed top-0 left-0 z-20 duration-500 text-gray-100 px-4`}
        >
          <div className="py-4 px-2 flex relative">
            <h2
              className={`whitespace-pre duration-1000 text-xl font-semibold ${
                !open && "-translate-x-[280px] opacity-0"
              }`}
            >
              Admin Dashboard
            </h2>
            <img
              src={Logo}
              className={`absolute left-[6px] w-6 overflow-hidden duration-300 transition-opacity ${
                open ? "opacity-0 delay-0" : "opacity-100 delay-500"
              }`}
              alt="Logo"
            />
          </div>

          <div className="mt-2 flex flex-col gap-1 relative">
            {menus.map((menu, i) =>
              menu.action ? (
                // Untuk Logout atau menu yang memiliki action
                <button
                  key={i}
                  onClick={menu.action}
                  className={`${
                    menu.margin && "mt-5"
                  } group flex items-center text-sm gap-3.5 font-medium px-2 py-3 hover:bg-[#282828] rounded-xl w-full text-left`}
                >
                  <div>{React.createElement(menu.icon, { size: "20" })}</div>
                  <h2
                    style={{
                      transitionDelay: `${i + 3}00ms`,
                    }}
                    className={`whitespace-pre duration-500 ${
                      !open && "opacity-0 translate-x-28 overflow-hidden"
                    }`}
                  >
                    {menu.name}
                  </h2>
                </button>
              ) : (
                // Untuk menu biasa yang memiliki link
                <Link
                  to={menu.link}
                  key={i}
                  className={`${
                    menu.margin && "mt-5"
                  } group flex items-center text-sm gap-3.5 font-medium px-2 py-3 hover:bg-[#282828] rounded-xl`}
                >
                  <div>{React.createElement(menu.icon, { size: "20" })}</div>
                  <h2
                    style={{
                      transitionDelay: `${i + 3}00ms`,
                    }}
                    className={`whitespace-pre duration-500 ${
                      !open && "opacity-0 translate-x-28 overflow-hidden"
                    }`}
                  >
                    {menu.name}
                  </h2>
                </Link>
              )
            )}
          </div>
        </div>
      </section>
    </>
  );
};

export default Sidebar;
