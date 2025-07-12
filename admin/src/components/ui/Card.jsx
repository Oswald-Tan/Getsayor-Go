import PropTypes from "prop-types";
import { useState } from "react";
import { Link } from "react-router-dom";
import { HiArrowRight } from "react-icons/hi";

const Card = ({ 
  title, 
  count, 
  icon, 
  iconColor = "text-blue-500",
  to = "/" // Prop baru untuk link tujuan
}) => {
  const [isHovered, setIsHovered] = useState(false);
  
  // Fungsi untuk mengonversi kelas warna teks menjadi kelas warna background
  const getBarColorClass = () => {
    if (iconColor.includes("blue")) return "bg-blue-500";
    if (iconColor.includes("teal")) return "bg-teal-500";
    if (iconColor.includes("orange")) return "bg-orange-500";
    if (iconColor.includes("purple")) return "bg-purple-500";
    if (iconColor.includes("red")) return "bg-red-500";
    if (iconColor.includes("green")) return "bg-green-500";
    if (iconColor.includes("yellow")) return "bg-yellow-500";
    if (iconColor.includes("pink")) return "bg-pink-500";
    if (iconColor.includes("indigo")) return "bg-indigo-500";
    return "bg-blue-500"; // Warna default
  };

  const barColorClass = getBarColorClass();

  return (
    <Link 
      to={to}
      className="block"
    >
      <div 
        className={`flex flex-col p-5 bg-white dark:bg-[#282828] rounded-3xl relative overflow-hidden transition-all duration-300 ${
          isHovered ? "shadow-lg" : "shadow"
        }`}
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        {/* Header dengan ikon utama dan ikon panah */}
        <div className="flex justify-between items-start">
          <div className={`text-2xl bg-gray-100 dark:bg-[#3f3f3f] w-10 p-2 rounded-full ${iconColor}`}>
            {icon}
          </div>
          
          {/* Ikon panah */}
          <div className={`transition-transform duration-300 ${isHovered ? "translate-x-1" : ""}`}>
            <HiArrowRight className={`text-xl ${iconColor}`} />
          </div>
        </div>
        
        {/* Garis bawah yang muncul saat hover */}
        <div 
          className={`absolute bottom-0 left-0 h-0.5 transition-all duration-500 ${
            isHovered ? "w-full" : "w-0"
          } ${barColorClass}`}
        ></div>
        
        <div className="mt-10">
          <h5 className="text-sm text-gray-700 dark:text-white uppercase">{title}</h5>
          <p className="text-[40px] font-normal text-gray-900 dark:text-white mt-4">{count}</p>
        </div>
      </div>
    </Link>
  );
};

Card.propTypes = {
  title: PropTypes.string.isRequired,
  count: PropTypes.number.isRequired,
  icon: PropTypes.element.isRequired,
  iconColor: PropTypes.string,
  to: PropTypes.string, // Prop baru untuk link
};

Card.defaultProps = {
  to: "/", // Default link ke homepage
};

export default Card;