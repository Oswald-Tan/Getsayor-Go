import { useState, useEffect, useRef } from "react";
import Phone from "../assets/Phone.webp";
import Selada from "../assets/Selada.webp";
import throttle from "lodash.throttle";
import AOS from "aos";

const Download = () => {
  const [rotation, setRotation] = useState(0);
  const [isHovered, setIsHovered] = useState(false);
  const prevScrollY = useRef(0);
  const totalRotation = useRef(0);
  const sectionRef = useRef(null);

  useEffect(() => {
    AOS.init({ duration: 800, once: false });

    const handleScroll = throttle(() => {
      if (!sectionRef.current) return;

      const sectionTop = sectionRef.current.getBoundingClientRect().top;
      const viewportHeight = window.innerHeight;

      if (sectionTop < viewportHeight && sectionTop > -viewportHeight) {
        const currentScrollY = window.scrollY;
        const rotationDelta = (currentScrollY - prevScrollY.current) * 0.3;

        totalRotation.current += rotationDelta;
        setRotation(totalRotation.current);
        prevScrollY.current = currentScrollY;
      }
    }, 50);

    window.addEventListener("scroll", handleScroll);
    return () => {
      handleScroll.cancel();
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);

  return (
    <section
      id="download"
      ref={sectionRef}
      className="relative min-h-[80vh] md:min-h-screen flex items-center justify-center md:mt-0 mt-[120px] overflow-hidden py-16 md:py-0"
    >
      {/* Background with gradient */}
      <div className="absolute inset-0"></div>

      {/* Animated background elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 right-1/4 w-72 h-72 bg-gradient-to-br from-green-100/40 to-blue-100/40 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-1/4 left-1/4 w-64 h-64 bg-gradient-to-br from-yellow-100/40 to-orange-100/40 rounded-full blur-3xl animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 right-1/2 w-48 h-48 bg-gradient-to-br from-purple-100/40 to-pink-100/40 rounded-full blur-3xl animate-pulse delay-2000"></div>
      </div>

      <div className="container md:w-4/5 w-11/12 mx-auto relative z-10">
        <div className="relative w-full max-w-7xl mx-auto">
          <div className="grid md:grid-cols-2 grid-cols-1 gap-12 items-center">
            {/* Content Section */}
            <div
              className="flex flex-col md:items-start items-center justify-center space-y-6"
              data-aos="fade-right"
              data-aos-offset="100"
            >
              {/* Badge */}
              <div className="inline-flex items-center bg-gradient-to-r from-green-100 to-blue-100 rounded-full px-4 py-2 border border-green-200/50">
                <span className="text-green-700 font-medium text-sm mr-2">
                  📱
                </span>
                <span className="text-sm font-semibold text-green-700">
                  Mobile App
                </span>
              </div>

              {/* Main heading */}
              <h1 className="font-bold text-4xl md:text-5xl lg:text-5xl lg:text-[52px] max-w-[490px] text-gray-900 text-center md:text-start leading-tight md:leading-[1.2]">
                Download Our{" "}
                <span className="bg-gradient-to-r from-[#74B11A] via-green-500 to-emerald-600 bg-clip-text text-transparent">
                  Grocery Mobile App
                </span>{" "}
                and Save Time, Money
              </h1>

              {/* Description */}
              <p className="text-gray-700 text-lg md:text-xl leading-relaxed max-w-[500px] md:text-start text-center">
                Belanja kebutuhan dapur kini lebih cepat dan praktis! Unduh
                sekarang dan nikmati kemudahan belanja langsung dari
                genggamanmu.
              </p>

              {/* Features list */}
              <div className="flex flex-col space-y-3 w-full max-w-[500px]">
                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center">
                    <span className="text-white text-sm">✓</span>
                  </div>
                  <span className="text-gray-700 text-lg md:text-xl">
                    Belanja 24/7 dengan mudah
                  </span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-full flex items-center justify-center">
                    <span className="text-white text-sm">✓</span>
                  </div>
                  <span className="text-gray-700 text-lg md:text-xl">
                    Promo dan diskon eksklusif
                  </span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center">
                    <span className="text-white text-sm">✓</span>
                  </div>
                  <span className="text-gray-700 text-lg md:text-xl">
                    Pengiriman cepat ke rumah
                  </span>
                </div>
              </div>

              {/* CTA Buttons */}
              <div className="flex flex-col sm:flex-row gap-4 mt-8 w-full max-w-[500px]">
                <a
                  href="#"
                  className="flex-1"
                  data-aos="fade-up"
                  data-aos-delay="200"
                >
                  <button
                    className="group w-full font-bold text-base bg-gradient-to-r from-yellow-400 to-orange-400 text-white px-8 py-4 rounded-2xl shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all duration-300 relative overflow-hidden"
                    onMouseEnter={() => setIsHovered(true)}
                    onMouseLeave={() => setIsHovered(false)}
                  >
                    <span className="flex items-center justify-center space-x-2">
                      <span>Download Now</span>
                    </span>
                  </button>
                </a>

                <button className="flex-1 border-2 border-gray-300 text-gray-700 font-semibold rounded-2xl hover:border-green-400 hover:text-green-600 hover:shadow-lg transition-all duration-300 py-4">
                  View Features
                </button>
              </div>

              {/* Stats */}
              <div className="flex items-center gap-8 mt-8 pt-6 border-t border-gray-200">
                <div className="text-center">
                  <div className="text-2xl font-bold text-gray-900">100K+</div>
                  <div className="text-gray-600 text-sm">Downloads</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-gray-900">4.8★</div>
                  <div className="text-gray-600 text-sm">App Rating</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-gray-900">24/7</div>
                  <div className="text-gray-600 text-sm">Support</div>
                </div>
              </div>
            </div>

            {/* Phone Image Section */}
            <div
              className="flex justify-center md:justify-end relative"
              data-aos="fade-left"
              data-aos-offset="100"
            >
              <div className="relative">
                {/* Background decoration */}
                <div className="absolute inset-0 "></div>

                {/* Phone container */}
                <div
                  className={`relative bg-white/10 backdrop-blur-sm rounded-3xl p-8  transition-all duration-500 ${
                    isHovered ? "scale-105" : "scale-100"
                  }`}
                >
                  <img
                    src={Phone}
                    alt="Grocery Mobile App"
                    className="w-[260px] sm:w-[300px] md:w-[350px] lg:w-[374px] object-contain relative z-10"
                    style={{
                      filter: "drop-shadow(0 20px 40px rgba(0,0,0,0.15))",
                    }}
                  />

                  {/* Floating elements */}
                  <div className="absolute -top-4 -right-4 w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center shadow-lg animate-bounce">
                    <span className="text-white font-bold text-lg">📱</span>
                  </div>

                  <div className="absolute -bottom-4 -left-4 w-16 h-16 bg-gradient-to-br from-yellow-400 to-orange-400 rounded-full flex items-center justify-center shadow-lg animate-pulse">
                    <span className="text-white font-bold text-xl">🛒</span>
                  </div>
                </div>

                {/* Additional floating badges */}
                <div className="absolute top-1/4 -left-6 bg-white rounded-2xl p-3 shadow-xl border border-gray-100 animate-pulse">
                  <div className="flex items-center space-x-2">
                    <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-xs">✓</span>
                    </div>
                    <div>
                      <div className="font-bold text-gray-900 text-sm">
                        Fast
                      </div>
                      <div className="text-gray-600 text-xs">Delivery</div>
                    </div>
                  </div>
                </div>

                <div className="absolute bottom-1/4 -right-6 bg-white rounded-2xl p-3 shadow-xl border border-gray-100 animate-pulse delay-1000">
                  <div className="flex items-center space-x-2">
                    <div className="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-xs">%</span>
                    </div>
                    <div>
                      <div className="font-bold text-gray-900 text-sm">50%</div>
                      <div className="text-gray-600 text-xs">Discount</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Decorative Selada Image with Scroll Rotation - TETAP SAMA */}
      <img
        src={Selada}
        alt="Selada"
        className="absolute top-10 md:top-0 md:bottom-auto bottom-[20%] md:left-[-115px] left-[-40px] w-[80px] sm:w-[100px] md:w-[150px] lg:w-[220px] z-10"
        style={{
          transform: `rotate(${rotation}deg)`,
          transition: "transform 0.1s ease-out",
          filter: "drop-shadow(0 10px 20px rgba(0,0,0,0.1))",
        }}
        data-aos="zoom-in"
        data-aos-delay="400"
      />
    </section>
  );
};

export default Download;
