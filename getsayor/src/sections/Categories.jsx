import { useEffect, useRef, useState } from "react";
import AOS from "aos";
import throttle from "lodash.throttle";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { useNavigate } from "react-router-dom";

import Fruit from "../assets/fruit.webp";
import Meat from "../assets/meats.webp";
import Fish from "../assets/fish.webp";
import Spice from "../assets/spices.webp";
import Vegetable from "../assets/Vegetable.webp";
import Seafood from "../assets/seafood.webp";
import Tubers from "../assets/tubers.webp";
import Protein from "../assets/protein.webp";

const categories = [
  {
    name: "Vegetables",
    image: Vegetable,
    count: 15,
    bgColor: "from-emerald-50 to-green-100",
    iconBg: "bg-emerald-500",
    description: "Fresh & Organic",
  },
  {
    name: "Spices",
    image: Spice,
    count: 10,
    bgColor: "from-amber-50 to-yellow-100",
    iconBg: "bg-amber-500",
    description: "Aromatic & Pure",
  },
  {
    name: "Fruits",
    image: Fruit,
    count: 2,
    bgColor: "from-rose-50 to-pink-100",
    iconBg: "bg-rose-500",
    description: "Sweet & Juicy",
  },
  {
    name: "Meat",
    image: Meat,
    count: 10,
    bgColor: "from-red-50 to-red-100",
    iconBg: "bg-red-500",
    description: "Premium Quality",
  },
  {
    name: "Fish",
    image: Fish,
    count: 15,
    bgColor: "from-blue-50 to-cyan-100",
    iconBg: "bg-blue-500",
    description: "Fresh & Sustainable",
  },
  {
    name: "Seafood",
    image: Seafood,
    count: 25,
    bgColor: "from-cyan-50 to-teal-100",
    iconBg: "bg-cyan-500",
    description: "Ocean's Best",
  },
  {
    name: "Tubers",
    image: Tubers,
    count: 1,
    bgColor: "from-orange-50 to-amber-100",
    iconBg: "bg-orange-500",
    description: "Earthy & Nutritious",
  },
  {
    name: "Protein",
    image: Protein,
    count: 2,
    bgColor: "from-purple-50 to-indigo-100",
    iconBg: "bg-purple-500",
    description: "Power Packed",
  },
];

const Categories = () => {
  const navigate = useNavigate();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isVisible, setIsVisible] = useState(false);
  const [hoveredIndex, setHoveredIndex] = useState(null);
  const [itemsPerView, setItemsPerView] = useState(5);
  const sectionRef = useRef(null);
  const sliderRef = useRef(null);

  // Calculate items per view based on screen size
  useEffect(() => {
    const updateItemsPerView = () => {
      if (window.innerWidth >= 1280) {
        setItemsPerView(5);
      } else if (window.innerWidth >= 1024) {
        setItemsPerView(4);
      } else if (window.innerWidth >= 768) {
        setItemsPerView(3);
      } else if (window.innerWidth >= 640) {
        setItemsPerView(2);
      } else {
        setItemsPerView(1);
      }
    };

    updateItemsPerView();
    window.addEventListener("resize", updateItemsPerView);
    return () => window.removeEventListener("resize", updateItemsPerView);
  }, []);

  // Visibility detection
  useEffect(() => {
    const handleScroll = () => {
      if (!sectionRef.current) return;

      const sectionTop = sectionRef.current.getBoundingClientRect().top;
      const viewportHeight = window.innerHeight;

      if (
        sectionTop < viewportHeight * 0.8 &&
        sectionTop > -viewportHeight * 0.2
      ) {
        setIsVisible(true);
      }
    };

    window.addEventListener("scroll", handleScroll);
    handleScroll();

    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const nextSlide = () => {
    const maxIndex = Math.max(0, categories.length - itemsPerView);
    setCurrentIndex((prev) => (prev >= maxIndex ? 0 : prev + 1));
  };

  const prevSlide = () => {
    const maxIndex = Math.max(0, categories.length - itemsPerView);
    setCurrentIndex((prev) => (prev <= 0 ? maxIndex : prev - 1));
  };

  const goToSlide = (index) => {
    const maxIndex = Math.max(0, categories.length - itemsPerView);
    setCurrentIndex(Math.min(index, maxIndex));
  };

  const maxIndex = Math.max(0, categories.length - itemsPerView);

  const handleExplore = (categoryName) => {
    navigate(
      `/explore/${encodeURIComponent(
        categoryName.toLowerCase().replace(/\s+/g, "-")
      )}`
    );
  };

  return (
    <section
      id="categories"
      ref={sectionRef}
      className="relative py-20 md:py-28 lg:py-36 min-h-screen flex items-center justify-center overflow-hidden"
    >
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-10 left-10 w-32 h-32 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full blur-xl"></div>
        <div className="absolute bottom-20 right-20 w-40 h-40 bg-gradient-to-br from-blue-400 to-cyan-400 rounded-full blur-xl"></div>
        <div className="absolute top-1/2 left-1/4 w-24 h-24 bg-gradient-to-br from-green-400 to-emerald-400 rounded-full blur-xl"></div>
      </div>

      <div className="container md:w-4/5 w-11/12 mx-auto relative z-10">
        <div className="text-center w-full max-w-7xl mx-auto">
          {/* Header Section */}
          <div
            className={`mb-16 md:mb-20 transition-all duration-1000 ${
              isVisible
                ? "opacity-100 translate-y-0"
                : "opacity-0 translate-y-8"
            }`}
          >
            <div className="inline-flex items-center bg-gradient-to-r from-purple-100 to-pink-100 rounded-full px-4 py-2 mb-6">
              <span className="text-purple-600 font-medium text-sm">
                🍎 Premium Categories
              </span>
            </div>
            <h1 className="font-bold text-4xl md:text-5xl lg:text-5xl mb-6 bg-gradient-to-r from-gray-900 via-gray-800 to-gray-900 bg-clip-text text-transparent leading-tight">
              Discover Our
              <br />
              <span className="bg-gradient-to-r from-[#74B11A] via-green-500 to-emerald-600 bg-clip-text text-transparent">
                Premium Selection
              </span>
            </h1>
            <p className="text-gray-700 text-lg md:text-xl max-w-2xl mx-auto leading-relaxed">
              Explore our carefully curated collection of the finest
              ingredients, sourced from trusted suppliers worldwide.
            </p>
          </div>

          {/* Slider Container */}
          <div className="relative">
            {/* Navigation Buttons */}
            <button
              onClick={prevSlide}
              disabled={currentIndex === 0}
              className={`absolute md:left-0 left-4 top-1/2 transform -translate-y-1/2 -translate-x-4 z-20 md:p-3 p-1 rounded-full bg-white shadow-lg hover:shadow-xl transition-all duration-300 ${
                currentIndex === 0
                  ? "opacity-50 cursor-not-allowed"
                  : "hover:bg-gray-50 hover:scale-110"
              }`}
            >
              <ChevronLeft className="md:w-6 md:h-6 w-5 h-5 text-gray-600" />
            </button>

            <button
              onClick={nextSlide}
              disabled={currentIndex >= maxIndex}
              className={`absolute md:right-0 right-4 top-1/2 transform -translate-y-1/2 translate-x-4 z-20 md:p-3 p-1 rounded-full bg-white shadow-lg hover:shadow-xl transition-all duration-300 ${
                currentIndex >= maxIndex
                  ? "opacity-50 cursor-not-allowed"
                  : "hover:bg-gray-50 hover:scale-110"
              }`}
            >
              <ChevronRight className="md:w-6 md:h-6 w-5 h-5 text-gray-600" />
            </button>

            {/* Slider */}
            <div className="overflow-hidden mx-8">
              <div
                ref={sliderRef}
                className="flex transition-transform duration-500 ease-in-out"
                style={{
                  transform: `translateX(-${
                    currentIndex * (100 / itemsPerView)
                  }%)`,
                }}
              >
                {categories.map((cat, index) => (
                  <div
                    key={index}
                    className={`flex-none transition-all duration-700 md:px-3 px-4 py-3 ${
                      isVisible
                        ? "opacity-100 translate-y-0"
                        : "opacity-0 translate-y-12"
                    }`}
                    style={{
                      width: `${100 / itemsPerView}%`,
                      transitionDelay: `${(index % itemsPerView) * 150}ms`,
                    }}
                    onMouseEnter={() => setHoveredIndex(index)}
                    onMouseLeave={() => setHoveredIndex(null)}
                  >
                    <div
                      className={`group relative bg-gradient-to-br ${cat.bgColor} rounded-3xl transition-all duration-500 p-8 h-full border border-white/20 backdrop-blur-sm group-hover:scale-[1.02] group-hover:-translate-y-2`}
                    >
                      {/* Floating Badge */}
                      <div className="absolute -top-3 -right-3 bg-white rounded-full px-3 py-1 shadow-lg border border-gray-100">
                        <span className="text-xs font-semibold text-gray-700">
                          {cat.count}
                        </span>
                      </div>

                      {/* Icon Container */}
                      <div className="relative mb-6">
                        <div
                          className={`w-20 h-20 mx-auto rounded-2xl ${cat.iconBg} p-4 shadow-lg group-hover:shadow-xl transition-all duration-300 group-hover:scale-110`}
                        >
                          <img
                            src={cat.image}
                            alt={cat.name}
                            className="w-full h-full object-cover rounded-xl"
                          />
                        </div>

                        {/* Pulse Effect */}
                        <div
                          className={`absolute inset-0 w-20 h-20 mx-auto rounded-2xl ${cat.iconBg} opacity-20 scale-110 animate-pulse`}
                        ></div>
                      </div>

                      {/* Content */}
                      <div className="text-center space-y-2">
                        <h3 className="font-bold text-xl md:text-2xl text-gray-800 group-hover:text-gray-900 transition-colors">
                          {cat.name}
                        </h3>
                        <p className="text-gray-600 text-sm font-medium">
                          {cat.description}
                        </p>
                        <div className="flex items-center justify-center space-x-2 text-sm text-gray-500">
                          <span>{cat.count} items</span>
                          <span className="w-1 h-1 bg-gray-400 rounded-full"></span>
                          <span>In stock</span>
                        </div>
                      </div>

                      {/* Hover Effect Overlay */}
                      <div className="absolute inset-0 bg-gradient-to-t from-black/5 to-transparent rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>

                      {/* Action Button */}
                      <div className="absolute bottom-6 left-1/2 transform -translate-x-1/2 translate-y-8 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-300">
                        <button
                          className="bg-white/90 backdrop-blur-sm text-gray-800 px-4 py-2 rounded-full text-sm font-medium hover:bg-white transition-all duration-200 shadow-lg"
                          onClick={() => handleExplore(cat.name)}
                        >
                          Explore →
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Dots Indicator */}
            <div className="flex justify-center mt-8 space-x-2">
              {Array.from({ length: maxIndex + 1 }).map((_, index) => (
                <button
                  key={index}
                  onClick={() => goToSlide(index)}
                  className={`w-2 h-2 rounded-full transition-all duration-300 ${
                    index === currentIndex
                      ? "bg-[#74B11A] scale-110"
                      : "bg-gray-300 hover:bg-gray-400"
                  }`}
                />
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Categories;
