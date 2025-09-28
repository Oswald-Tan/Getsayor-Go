import React, { useEffect, useState } from "react";
import { RiCoinLine } from "react-icons/ri";
import { TbLayoutDashboard } from "react-icons/tb";
import { AiOutlineUser, AiOutlineProduct } from "react-icons/ai";
import {
  MdCardGiftcard,
  MdKeyboardArrowUp,
  MdKeyboardArrowDown,
} from "react-icons/md";
import { RiHome9Line } from "react-icons/ri";
import { PiMapPinSimpleAreaBold } from "react-icons/pi";
import { HiOutlineClipboardList } from "react-icons/hi";
import { FiLogOut } from "react-icons/fi";
import { useSidebar } from "../context/useSidebar";
import { Link } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { LogOut, reset } from "../features/authSlice";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import { MdOutlineWbSunny } from "react-icons/md";
import { LuMoon } from "react-icons/lu";
import useDarkMode from "../hooks/useDarkMode";

const Sidebar = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { user } = useSelector((state) => state.auth);
  const { open, toggleSidebar } = useSidebar();
  const [menus, setMenus] = useState([]);
  const [activeSubMenu, setActiveSubMenu] = useState("");
  const { isDarkMode, toggleDarkMode } = useDarkMode();

  // Tutup semua submenu saat sidebar ditutup
  useEffect(() => {
    if (!open) {
      setActiveSubMenu("");
    }
  }, [open]);

  useEffect(() => {
    if (user?.role === "admin") {
      // Update menus berdasarkan role setelah user tersedia
      const updatedMenus = [
        {
          name: "Dashboard",
          link: "/dashboard",
          icon: TbLayoutDashboard,
        },
        { name: "User", link: "/users", icon: AiOutlineUser },

        {
          name: "Top Up Poin",
          link: "/topup/poin",
          icon: RiCoinLine,
          hasSubMenu: true,

          subMenu: [
            { name: "User Top Up", link: "/topup/poin" },
            { name: "Poin", link: "/poin" },
          ],
        },
        {
          name: "Pesanan",
          link: "/pesanan",
          icon: HiOutlineClipboardList,
        },
        {
          name: "Manage Products",
          icon: AiOutlineProduct,
          hasSubMenu: true,

          subMenu: [
            { name: "Products", link: "/products" },
            { name: "Set Harga Poin", link: "/harga/poin/product" },
          ],
        },
        {
          name: "Manage City Province",
          icon: PiMapPinSimpleAreaBold,
          hasSubMenu: true,

          subMenu: [
            { name: "City Province", link: "/city/province" },
            { name: "Shipping Rate", link: "/shipping/rates" },
          ],
        },
        {
          name: "Afiliasi Bonus",
          link: "/afiliasi/bonus",
          icon: MdCardGiftcard,
        },
        // {
        //   name: "Setting",
        //   link: "/setting",
        //   icon: RiSettings4Line,
        // },
        {
          name: isDarkMode ? "Light Mode" : "Dark Mode",
          icon: isDarkMode ? MdOutlineWbSunny : LuMoon,
          action: toggleDarkMode,
        },
        {
          name: "Logout",
          action: () => logout(),
          icon: FiLogOut,
        },
      ];

      setMenus(updatedMenus);
    }
  }, [user, isDarkMode]);

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

  const handleSubMenuClick = (menuName) => {
    if (!open) {
      toggleSidebar();
      setTimeout(() => {
        setActiveSubMenu(menuName);
      }, 300);
    } else {
      setActiveSubMenu(activeSubMenu === menuName ? "" : menuName);
    }
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
          } fixed top-0 left-0 z-20 duration-500 text-gray-100 px-4 overflow-y-auto flex flex-col`}
          style={{ height: "100vh" }}
        >
          <div>
            <div className="py-4 px-2 flex relative">
              <h2
                className={`whitespace-pre duration-1000 text-xl font-semibold ${
                  !open && "-translate-x-[280px] opacity-0"
                }`}
              >
                Admin Dashboard
              </h2>
              <RiHome9Line
                size={20}
                className={`absolute left-[6px] w-6 overflow-hidden duration-300 transition-opacity ${
                  open ? "opacity-0 delay-0" : "opacity-100 delay-500"
                }`}
              />
            </div>

            <div className="mt-2 flex flex-col gap-1 relative">
              {menus.map((menu, i) => {
                if (menu.hasSubMenu) {
                  return (
                    <div key={i} className="">
                      <button
                        onClick={() => handleSubMenuClick(menu.name)}
                        className={`group flex items-center justify-between w-full text-sm gap-3.5 font-medium px-2 py-3 hover:bg-[#252525] rounded-xl text-left`}
                      >
                        <div className="flex items-center">
                          <div>
                            {React.createElement(menu.icon, { size: "20" })}
                          </div>
                          <h2
                            style={{
                              transitionDelay: `${i + 3}00ms`,
                            }}
                            className={`whitespace-pre duration-500 ml-3 ${
                              !open &&
                              "opacity-0 translate-x-28 overflow-hidden"
                            }`}
                          >
                            {menu.name}
                          </h2>
                        </div>
                        <div className={`${!open ? "hidden" : "block"}`}>
                          {activeSubMenu === menu.name ? (
                            <MdKeyboardArrowUp size={14} />
                          ) : (
                            <MdKeyboardArrowDown size={14} />
                          )}
                        </div>
                      </button>

                      <div
                        className={`transition-all duration-300 ease-in-out overflow-hidden ${
                          activeSubMenu === menu.name ? "max-h-40" : "max-h-0"
                        }`}
                      >
                        <div className="pl-8 py-1 space-y-1">
                          {menu.subMenu.map((sub, j) => (
                            <Link
                              to={sub.link}
                              key={j}
                              className="flex items-center text-sm gap-3.5 font-medium px-2 py-2 hover:bg-[#252525] rounded-lg transition-colors duration-200"
                              onClick={() => !open && toggleSidebar()}
                            >
                              <div className="w-1 h-1 bg-gray-400 rounded-full"></div>
                              <h2
                                style={{
                                  transitionDelay: `${j + 3}00ms`,
                                }}
                                className={`whitespace-pre duration-500 ${
                                  !open &&
                                  "opacity-0 translate-x-28 overflow-hidden"
                                }`}
                              >
                                {sub.name}
                              </h2>
                            </Link>
                          ))}
                        </div>
                      </div>
                    </div>
                  );
                }

                return menu.action ? (
                  <button
                    key={i}
                    onClick={menu.action}
                    className={`group flex items-center text-sm gap-3.5 font-medium px-2 py-3 hover:bg-[#282828] rounded-xl w-full text-left`}
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
                  <Link
                    to={menu.link}
                    key={i}
                    className={`group flex items-center text-sm gap-3.5 font-medium px-2 py-3 hover:bg-[#282828] rounded-xl`}
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
                );
              })}
            </div>
          </div>

          {/* Bagian bawah untuk menampilkan info user */}
          <div className="mt-auto pb-4">
            <div className={`${!open ? "hidden" : "block"} mt-6`}>
              <div className="flex items-center gap-3 px-2 py-3 bg-[#252525] rounded-xl">
                <div className="border border-gray-400 rounded-full p-2 flex-shrink-0">
                  <AiOutlineUser size={20} />
                </div>
                <div className="min-w-0">
                  <p className="text-sm font-medium truncate">
                    {user?.fullname ? (
                      user.fullname.length > 22 ? (
                        `${user.fullname.substring(0, 22)}...`
                      ) : (
                        user.fullname
                      )
                    ) : (
                      <span className="text-gray-400">Loading...</span>
                    )}
                  </p>
                  <p className="text-xs text-gray-400 truncate">
                    {user?.email ? (
                      user.email.length > 22 ? (
                        `${user.email.substring(0, 22)}...`
                      ) : (
                        user.email
                      )
                    ) : (
                      <span className="text-gray-400">Loading...</span>
                    )}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </>
  );
};

export default Sidebar;
