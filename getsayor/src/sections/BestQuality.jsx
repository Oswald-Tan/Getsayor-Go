import { useEffect, useRef, useState } from "react";
import BestQ from "../assets/BestQ.webp";
import Checklist from "../assets/Checklist.svg";

const BestQuality = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [hoveredFeature, setHoveredFeature] = useState(null);
  const sectionRef = useRef(null);

  const features = [
    {
      id: 1,
      text: "Best services than others",
      icon: "🏆",
      description: "Pelayanan terbaik dengan standar internasional",
      color: "from-blue-500 to-cyan-500",
    },
    {
      id: 2,
      text: "100% organic & natural process",
      icon: "🌿",
      description: "Proses organik alami tanpa bahan kimia berbahaya",
      color: "from-green-500 to-emerald-500",
    },
    {
      id: 3,
      text: "100% return & refunds",
      icon: "💰",
      description: "Jaminan uang kembali 100% jika tidak puas",
      color: "from-purple-500 to-pink-500",
    },
    {
      id: 4,
      text: "User friendly mobile apps",
      icon: "📱",
      description: "Aplikasi mobile yang mudah digunakan untuk semua",
      color: "from-orange-500 to-red-500",
    },
  ];

  useEffect(() => {
    const handleScroll = () => {
      if (sectionRef.current) {
        const rect = sectionRef.current.getBoundingClientRect();
        setIsVisible(rect.top < window.innerHeight * 0.8);
      }
    };

    window.addEventListener("scroll", handleScroll);
    handleScroll();
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <section
      id="best-quality"
      ref={sectionRef}
      className="relative py-20 md:py-28 lg:py-36 min-h-screen flex items-center justify-center overflow-hidden"
    >
      {/* Background Elements */}
      <div className="absolute inset-0"></div>

      {/* Animated Background Shapes */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 left-1/4 w-64 h-64 bg-gradient-to-br from-green-200/20 to-blue-200/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-1/4 right-1/4 w-72 h-72 bg-gradient-to-br from-orange-200/20 to-yellow-200/20 rounded-full blur-3xl animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/2 w-48 h-48 bg-gradient-to-br from-purple-200/20 to-pink-200/20 rounded-full blur-3xl animate-pulse delay-2000"></div>
      </div>

      <div className="container md:w-4/5 w-11/12 mx-auto relative z-10">
        <div className="max-w-7xl mx-auto">
          <div className="lg:grid lg:grid-cols-2 lg:gap-16 xl:gap-20 items-center">
            {/* Left Side - Image */}
            <div
              className={`relative transition-all duration-1000 ${
                isVisible
                  ? "opacity-100 translate-x-0"
                  : "opacity-0 -translate-x-8"
              }`}
            >
              <div className="relative">
                {/* Main Image Container */}
                <div className="relative bg-gradient-to-br from-green-100 to-yellow-100 rounded-3xl pt-16 shadow-2xl hover:shadow-3xl transition-all duration-500 hover:scale-[1.02]">
                  <img
                    src={BestQ}
                    alt="Best Quality Delivery"
                    className="w-full max-w-[410px] mx-auto relative z-10"
                  />

                </div>

                {/* Stats Cards */}
                <div className="absolute z-10 -bottom-8 -left-4 bg-white rounded-2xl p-4 shadow-xl border border-gray-100">
                  <div className="flex items-center space-x-3">
                    <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-500 rounded-xl flex items-center justify-center">
                      <span className="text-white font-bold text-lg">✓</span>
                    </div>
                    <div>
                      <p className="font-bold text-gray-900">1000+</p>
                      <p className="text-gray-600 text-sm">Happy Customers</p>
                    </div>
                  </div>
                </div>

                <div className="absolute -top-8 -right-4 bg-white rounded-2xl p-4 shadow-xl border border-gray-100">
                  <div className="flex items-center space-x-3">
                    <div className="w-12 h-12 bg-gradient-to-br from-orange-500 to-yellow-500 rounded-xl flex items-center justify-center">
                      <span className="text-white font-bold text-lg">⭐</span>
                    </div>
                    <div>
                      <p className="font-bold text-gray-900">4.9/5</p>
                      <p className="text-gray-600 text-sm">Rating</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Right Side - Content */}
            <div
              className={`mt-16 lg:mt-0 transition-all duration-1000 delay-300 ${
                isVisible
                  ? "opacity-100 translate-x-0"
                  : "opacity-0 translate-x-8"
              }`}
            >
              {/* Header */}
              <div className="mb-10">
                <div className="inline-flex items-center bg-gradient-to-r from-orange-100 to-yellow-100 rounded-full px-4 py-2 mb-6">
                  <span className="text-orange-700 font-medium text-sm">
                    🥇 Premium Quality
                  </span>
                </div>

                <h1 className="font-bold text-4xl md:text-5xl lg:text-5xl mb-4 leading-tight">
                  <span className="bg-gradient-to-r from-gray-900 to-gray-700 bg-clip-text text-transparent">
                    Best Quality Healthy And
                  </span>
                  <br />
                  <span className="bg-gradient-to-r from-[#74B11A] via-green-500 to-emerald-600 bg-clip-text text-transparent">
                    Fresh Grocery
                  </span>
                </h1>
              </div>

              {/* Description */}
              <p className="text-gray-700 text-lg md:text-xl leading-relaxed mb-10 max-w-[500px]">
                We prioritizes quality in each of our grocery, below are the
                <span className="font-semibold text-gray-900">
                  {" "}
                  advantage of our product
                </span>
                . Organic food is food produced with sustainable farming
                practices.
              </p>

              {/* Features List */}
              <div className="space-y-4 mb-10">
                {features.map((feature, index) => (
                  <div
                    key={feature.id}
                    className={`group relative p-4 rounded-2xl border border-gray-100 hover:border-gray-200 transition-all duration-300 hover:shadow-lg cursor-pointer ${
                      hoveredFeature === index
                        ? "bg-gradient-to-r from-gray-50 to-white shadow-lg"
                        : "bg-white/50 backdrop-blur-sm"
                    }`}
                    onMouseEnter={() => setHoveredFeature(index)}
                    onMouseLeave={() => setHoveredFeature(null)}
                    style={{
                      transitionDelay: `${index * 100}ms`,
                      opacity: isVisible ? 1 : 0,
                      transform: `translateY(${isVisible ? "0" : "0px"})`,
                    }}
                  >
                    <div className="flex items-start gap-4">
                      {/* Custom Icon */}
                      <div className="relative">
                        <div
                          className={`w-12 h-12 rounded-xl bg-gradient-to-br ${feature.color} flex items-center justify-center shadow-lg group-hover:shadow-xl transition-all duration-300 group-hover:scale-110`}
                        >
                          <span className="text-white text-lg">
                            {feature.icon}
                          </span>
                        </div>

                        {/* Original Checklist Icon */}
                        <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-md">
                          <img
                            src={Checklist}
                            alt="Checklist"
                            className="w-4 h-4"
                          />
                        </div>
                      </div>

                      {/* Content */}
                      <div className="flex-1">
                        <h4 className="font-semibold text-gray-900 mb-1 group-hover:text-gray-800 transition-colors">
                          {feature.text}
                        </h4>
                        <p
                          className={`text-gray-600 text-sm leading-relaxed transition-all duration-300 ${
                            hoveredFeature === index
                              ? "opacity-100"
                              : "opacity-0 overflow-hidden"
                          }`}
                        >
                          {feature.description}
                        </p>
                      </div>

                      {/* Hover Arrow */}
                      <div
                        className={`text-gray-400 transition-all duration-300 ${
                          hoveredFeature === index
                            ? "opacity-100 translate-x-0"
                            : "opacity-0 translate-x-2"
                        }`}
                      >
                        →
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              {/* CTA Buttons */}
              <div className="flex flex-col sm:flex-row gap-4">
                <a href="#download" className="block w-full">
                  <button className="group bg-gradient-to-r from-orange-500 to-yellow-500 text-white px-8 py-4 rounded-2xl font-bold text-lg shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-[1.02] relative overflow-hidden w-full">
                    <span className="relative z-10 flex items-center justify-center space-x-2">
                      <span>Order Now</span>
                      <span className="group-hover:translate-x-1 transition-transform">
                        🛒
                      </span>
                    </span>
                    <div className="absolute inset-0 bg-gradient-to-r from-yellow-500 to-orange-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                  </button>
                </a>

                <button className="border-2 border-gray-300 text-gray-700 px-8 py-4 rounded-2xl font-semibold text-lg hover:border-orange-400 hover:text-orange-600 hover:shadow-lg transition-all duration-300 w-full">
                  Learn More
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

     
    </section>
  );
};

export default BestQuality;
