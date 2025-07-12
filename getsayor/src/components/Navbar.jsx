import { useState, useEffect } from "react";
import { FiX } from "react-icons/fi";
import { CgMenuRight } from "react-icons/cg";
import { motion, AnimatePresence } from "framer-motion";
import { HiOutlineSparkles } from "react-icons/hi";
import { Link } from "react-router-dom";
import Logo from "../assets/logo-nav.webp"; 

const Navbar = () => {
  const [isOpen, setIsOpen] = useState(false);

  // Lock body scroll when sidebar open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
  }, [isOpen]);

  const menuItems = [
    { href: "#", label: "Home", id: "home" },
    { href: "#categories", label: "Categories", id: "categories" },
    { href: "#about", label: "About Us", id: "about" },
    { href: "#best-quality", label: "Best Quality", id: "best-quality" },
    { href: "#why-choose-us", label: "Why Us", id: "why-choose-us" },
  ];

  return (
    // Gunakan absolute positioning dan z-index tinggi
    <nav className="w-full absolute top-0 left-0 bg-transparent z-50">
      <div className="container md:w-4/5 w-11/12 mx-auto py-4 flex justify-between items-center">
        {/* Logo */}
        <a href="#" className="flex items-center space-x-2 group">
          <div className="relative">
            <img 
              src={Logo} 
              className="w-[100px] h-auto transition-transform duration-300 group-hover:scale-105" 
              alt="Logo" 
            />
            <div className="absolute -inset-1 bg-gradient-to-r from-[#74B11A] to-green-600 rounded-lg blur opacity-0 group-hover:opacity-20 transition-opacity duration-300"></div>
          </div>
        </a>

        {/* Desktop Menu */}
        <div className="hidden lg:flex items-center space-x-8">
          {menuItems.map((item) => (
            <a
              key={item.id}
              href={item.href}
              className="relative text-sm font-semibold transition-all duration-300 group text-gray-700 hover:text-[#74B11A]"
            >
              {item.label}
              <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-gradient-to-r from-[#74B11A] to-green-600 transition-all duration-300 group-hover:w-full"></span>
            </a>
          ))}
        </div>

        {/* Desktop CTA Button */}
        <div className="hidden lg:flex items-center space-x-4">
          <Link to="/register" className="relative group">
            <div className="absolute -inset-0.5 bg-gradient-to-r from-[#74B11A] to-green-600 rounded-full blur opacity-30 group-hover:opacity-100 transition duration-300"></div>
            <div className="relative bg-gradient-to-r from-[#74B11A] to-green-600 text-white px-6 py-3 rounded-full text-sm font-semibold hover:shadow-lg transition-all duration-300 group-hover:scale-105 flex items-center space-x-2">
              <HiOutlineSparkles className="w-4 h-4" />
              <span>Get Started</span>
            </div>
          </Link>
        </div>

        {/* Mobile Menu Button */}
        <button
          onClick={() => setIsOpen(true)}
          className="lg:hidden p-2 rounded-lg transition-all duration-300 text-gray-700 hover:bg-white/20"
        >
          <CgMenuRight size={24} />
        </button>
      </div>

      {/* Overlay dan Sidebar dengan Framer Motion */}
      <AnimatePresence>
        {isOpen && (
          <>
            {/* Overlay */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 0.5 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.3 }}
              onClick={() => setIsOpen(false)}
              className="fixed inset-0 bg-black z-40 lg:hidden"
            />

            {/* Sidebar */}
            <motion.div
              initial={{ x: "-100%" }}
              animate={{ x: 0 }}
              exit={{ x: "-100%" }}
              transition={{ duration: 0.3, ease: "easeInOut" }}
              className="fixed top-0 left-0 h-full w-4/5 max-w-[280px] bg-white shadow-2xl z-50 p-6 flex flex-col"
            >
              {/* Header */}
              <div className="flex justify-between items-center mb-8">
                <a href="#" className="flex items-center space-x-2">
                  <img 
                    src={Logo} 
                    className="w-[90px] h-auto" 
                    alt="Logo" 
                  />
                </a>
                <button
                  onClick={() => setIsOpen(false)}
                  className="p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors duration-200"
                >
                  <FiX size={24} />
                </button>
              </div>

              {/* Navigation Links */}
              <nav className="flex flex-col space-y-2 flex-1">
                {menuItems.map((item, index) => (
                  <a
                    key={item.id}
                    href={item.href}
                    onClick={() => setIsOpen(false)}
                    className="group relative p-4 rounded-xl transition-all duration-300 text-gray-700 hover:bg-gray-50 hover:text-[#74B11A]"
                    style={{ animationDelay: `${index * 0.1}s` }}
                  >
                    <div className="flex items-center space-x-3">
                      <span className="w-2 h-2 rounded-full bg-gray-300 group-hover:bg-[#74B11A] transition-all duration-300"></span>
                      <span className="font-semibold text-sm">{item.label}</span>
                    </div>
                  </a>
                ))}
              </nav>

              {/* Mobile CTA Button */}
              <div className="mt-6 pt-6 border-t border-gray-200">
                <Link to="/register"
                  onClick={() => setIsOpen(false)}
                  className="w-full group relative"
                >
                  <div className="absolute -inset-0.5 bg-gradient-to-r from-[#74B11A] to-green-600 rounded-xl blur opacity-30 group-hover:opacity-100 transition duration-300"></div>
                  <div className="relative bg-gradient-to-r from-[#74B11A] to-green-600 text-white py-4 rounded-xl text-sm font-semibold hover:shadow-lg transition-all duration-300 flex items-center justify-center space-x-2">
                    <HiOutlineSparkles className="w-4 h-4" />
                    <span>Get Started</span>
                  </div>
                </Link>
              </div>

              {/* Footer */}
              <div className="mt-6 pt-6 border-t border-gray-200">
                <p className="text-xs text-gray-500 text-center">
                  © 2024 Getsayor. All rights reserved.
                </p>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </nav>
  );
};

export default Navbar;