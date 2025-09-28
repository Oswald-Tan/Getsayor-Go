import { useState, useEffect, useRef } from "react";
import Phone from "../assets/Phone.webp";
import Selada from "../assets/Selada.webp";
import GP from "../assets/google-play.webp";
import throttle from "lodash.throttle";
import AOS from "aos";

const Download = () => {
  const [rotation, setRotation] = useState(0);
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
                  href="https://play.google.com/store/apps/details?id=com.getsayor.app&pcampaignid=web_share"
                  className="flex-1"
                  data-aos="fade-up"
                  data-aos-delay="200"
                >
                  <img src={GP} alt="Google Play" className="md:w-[210px] w-[190px]" />
                </a>
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
                  className={`relative bg-white/10 backdrop-blur-sm rounded-3xl p-8  transition-all duration-500`}
                >
                  <img
                    src={Phone}
                    alt="Grocery Mobile App"
                    className="w-[260px] sm:w-[300px] md:w-[350px] lg:w-[374px] object-contain relative z-10"
                    style={{
                      filter: "drop-shadow(0 20px 40px rgba(0,0,0,0.15))",
                    }}
                  />
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
