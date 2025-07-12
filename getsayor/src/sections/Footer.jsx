import { AiFillInstagram } from "react-icons/ai";
import { BsYoutube } from "react-icons/bs";
import { FaFacebookSquare } from "react-icons/fa";
import { FaMapMarkerAlt } from "react-icons/fa";
import { FiMail, FiPhone } from "react-icons/fi";
import Logo from "../assets/logo.png";

const Footer = () => {
  return (
    <footer className="relative w-full py-8 md:mt-0 mt-[120px] bg-gradient-to-br from-[#5c9a4f] via-[#4a8642] to-[#3e7138] z-0">
      {/* Decorative Top Wave */}
      <div className="absolute md:top-[-70px] top-[-40px] w-[317px] h-[70px] overflow-hidden left-1/2 transform -translate-x-1/2 hidden md:block">
        <svg
          width="317"
          height="100"
          viewBox="0 0 317 100"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M0 116C18 104.5 44.5 75.5 63.5 54.5C91.5 23.5 123.5 0 158.5 0C193.5 0 225.5 23.5 253.5 54.5C272.5 75.5 299 104.5 317 116H0Z"
            fill="url(#gradient)"
          />
          <defs>
            <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#5c9a4f" />
              <stop offset="50%" stopColor="#4a8642" />
              <stop offset="100%" stopColor="#3e7138" />
            </linearGradient>
          </defs>
        </svg>
      </div>

      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-10 left-10 w-32 h-32 bg-white rounded-full blur-xl"></div>
        <div className="absolute bottom-20 right-20 w-40 h-40 bg-white rounded-full blur-xl"></div>
        <div className="absolute top-1/2 left-1/4 w-24 h-24 bg-white rounded-full blur-xl"></div>
      </div>

      {/* Main Content */}
      <div className="relative z-10 md:w-4/5 w-11/12 mx-auto">
        {/* Top Section */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-12">
          {/* Brand Section */}
          <div className="lg:col-span-2">
            <div className="flex gap-3 items-center mb-6">
              <div className="relative">
                <img src={Logo} alt="logo" className="w-12 h-12 rounded-xl shadow-lg" />
                <div className="absolute -inset-1 bg-white/20 rounded-xl blur-sm"></div>
              </div>
              <h1 className="font-urbanist text-2xl font-bold text-white">
                Getsayor
              </h1>
            </div>
            <p className="text-white/90 text-sm leading-relaxed mb-6 max-w-md">
              Your trusted partner for premium quality ingredients. We source the finest products from trusted suppliers worldwide to bring you the best culinary experience.
            </p>
            
            {/* Social Media Links */}
            <div className="flex gap-4">
              <a
                href="#"
                className="group w-10 h-10 bg-white/10 backdrop-blur-sm rounded-full text-white flex items-center justify-center cursor-pointer hover:bg-white hover:text-orange-600 transition-all duration-300 hover:scale-110 hover:shadow-lg"
              >
                <AiFillInstagram size={20} />
              </a>
              <a
                href="#"
                className="group w-10 h-10 bg-white/10 backdrop-blur-sm rounded-full text-white flex items-center justify-center cursor-pointer hover:bg-white hover:text-red-600 transition-all duration-300 hover:scale-110 hover:shadow-lg"
              >
                <BsYoutube size={20} />
              </a>
              <a
                href="#"
                className="group w-10 h-10 bg-white/10 backdrop-blur-sm rounded-full text-white flex items-center justify-center cursor-pointer hover:bg-white hover:text-blue-600 transition-all duration-300 hover:scale-110 hover:shadow-lg"
              >
                <FaFacebookSquare size={20} />
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div className="space-y-4">
            <h3 className="font-urbanist text-lg font-semibold text-white mb-4 relative">
              Quick Links
              <div className="absolute bottom-0 left-0 w-8 h-0.5 bg-white/60 rounded-full"></div>
            </h3>
            <div className="space-y-3">
              <a href="#" className="group flex items-center font-urbanist text-white/90 text-sm hover:text-white transition-colors duration-200">
                <span className="w-1.5 h-1.5 bg-white/60 rounded-full mr-3 group-hover:bg-white transition-colors"></span>
                Home
              </a>
              <a href="#categories" className="group flex items-center font-urbanist text-white/90 text-sm hover:text-white transition-colors duration-200">
                <span className="w-1.5 h-1.5 bg-white/60 rounded-full mr-3 group-hover:bg-white transition-colors"></span>
                Categories
              </a>
              <a href="#best-quality" className="group flex items-center font-urbanist text-white/90 text-sm hover:text-white transition-colors duration-200">
                <span className="w-1.5 h-1.5 bg-white/60 rounded-full mr-3 group-hover:bg-white transition-colors"></span>
                Best Quality
              </a>
              <a href="#why-choose-us" className="group flex items-center font-urbanist text-white/90 text-sm hover:text-white transition-colors duration-200">
                <span className="w-1.5 h-1.5 bg-white/60 rounded-full mr-3 group-hover:bg-white transition-colors"></span>
                Why Choose Us
              </a>
              <a href="#about" className="group flex items-center font-urbanist text-white/90 text-sm hover:text-white transition-colors duration-200">
                <span className="w-1.5 h-1.5 bg-white/60 rounded-full mr-3 group-hover:bg-white transition-colors"></span>
                About Us
              </a>
            </div>
          </div>

          {/* Contact Info */}
          <div className="space-y-4">
            <h3 className="font-urbanist text-lg font-semibold text-white mb-4 relative">
              Contact Info
              <div className="absolute bottom-0 left-0 w-8 h-0.5 bg-white/60 rounded-full"></div>
            </h3>
            <div className="space-y-4">
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 bg-white/10 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                  <FaMapMarkerAlt size={14} className="text-white" />
                </div>
                <div>
                  <p className="font-urbanist text-white text-sm font-medium">Address</p>
                  <p className="font-urbanist text-white/90 text-sm">
                    Manado, Sulawesi Utara, Indonesia
                  </p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 bg-white/10 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                  <FiPhone size={14} className="text-white" />
                </div>
                <div>
                  <p className="font-urbanist text-white text-sm font-medium">Phone</p>
                  <p className="font-urbanist text-white/90 text-sm">
                    +62 896 7375 1717
                  </p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 bg-white/10 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                  <FiMail size={14} className="text-white" />
                </div>
                <div>
                  <p className="font-urbanist text-white text-sm font-medium">Email</p>
                  <a
                    href="mailto:contact@getsayor.com"
                    className="font-urbanist text-white/90 text-sm hover:text-white transition-colors duration-200"
                  >
                    contact@getsayor.com
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Divider */}
        <div className="border-t border-white/20 my-8"></div>

        {/* Bottom Section */}
        <div className="flex flex-col md:flex-row justify-between items-center gap-4">
          <div className="font-urbanist text-white/90 text-sm">
            &copy; {new Date().getFullYear()} PT. Digital Terang Bercahaya. All rights reserved.
          </div>
          
          <div className="flex items-center gap-6">
            <a href="#" className="font-urbanist text-white/90 text-sm hover:text-white transition-colors duration-200">
              Privacy Policy
            </a>
            <a href="#" className="font-urbanist text-white/90 text-sm hover:text-white transition-colors duration-200">
              Terms of Service
            </a>
            <a href="#" className="font-urbanist text-white/90 text-sm hover:text-white transition-colors duration-200">
              Sitemap
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;