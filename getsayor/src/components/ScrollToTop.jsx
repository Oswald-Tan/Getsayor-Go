import { useState, useEffect } from "react";

const ScrollToTop = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [scrollProgress, setScrollProgress] = useState(0);

  // Show button and calculate scroll progress
  const toggleVisibility = () => {
    const scrolled = window.pageYOffset;
    const maxHeight =
      document.documentElement.scrollHeight - window.innerHeight;
    const progress = (scrolled / maxHeight) * 100;

    setScrollProgress(progress);

    if (scrolled > 300) {
      setIsVisible(true);
    } else {
      setIsVisible(false);
    }
  };

  // Scroll to top smoothly
  const scrollToTop = () => {
    window.scrollTo({
      top: 0,
      behavior: "smooth",
    });
  };

  useEffect(() => {
    window.addEventListener("scroll", toggleVisibility);
    return () => window.removeEventListener("scroll", toggleVisibility);
  }, []);

  return (
    <div className="fixed bottom-8 right-8 z-50">
      {isVisible && (
        <div className="relative group">
          {/* Progress Circle Background */}
          <svg
            className="absolute inset-0 md:w-12 md:h-12 w-10 h-10 transform -rotate-90 transition-all duration-300 group-hover:scale-110"
            viewBox="0 0 56 56"
          >
            {/* Background Circle */}
            <circle
              cx="28"
              cy="28"
              r="26"
              fill="none"
              stroke="rgba(255, 255, 255, 0.1)"
              strokeWidth="2"
            />
            {/* Progress Circle */}
            <circle
              cx="28"
              cy="28"
              r="26"
              fill="none"
              stroke="url(#gradient)"
              strokeWidth="2"
              strokeLinecap="round"
              strokeDasharray={`${2 * Math.PI * 26}`}
              strokeDashoffset={`${
                2 * Math.PI * 26 * (1 - scrollProgress / 100)
              }`}
              className="transition-all duration-300"
            />
            {/* Gradient Definition */}
            <defs>
              <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#3B82F6" />
                <stop offset="100%" stopColor="#1D4ED8" />
              </linearGradient>
            </defs>
          </svg>

          {/* Button */}
          <button
            onClick={scrollToTop}
            className="relative md:w-12 md:h-12 w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white rounded-full shadow-lg transition-all duration-300 ease-in-out transform hover:scale-110 hover:shadow-xl focus:outline-none focus:ring-4 focus:ring-blue-500 focus:ring-opacity-30 backdrop-blur-sm"
            aria-label="Scroll to top"
          >
            {/* Icon Container with Animation */}
            <div className="flex items-center justify-center w-full h-full">
              <svg
                className="md:w-5 md:h-5 w-4 h-4 transform transition-transform duration-300 group-hover:-translate-y-1"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2.5}
                  d="M5 15l7-7 7 7"
                />
              </svg>
            </div>

            {/* Ripple Effect */}
            <div className="absolute inset-0 rounded-full bg-blue-600 opacity-0 group-hover:opacity-20 group-hover:animate-ping"></div>
          </button>
        </div>
      )}
    </div>
  );
};

export default ScrollToTop;
