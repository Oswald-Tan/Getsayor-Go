import { useEffect } from "react";
import AOS from "aos";

import Buah from "../assets/hero-buah.webp";
import Bag from "../assets/bag.webp";
import Leaf3 from "../assets/leaf3.webp";

const Hero = () => {
  useEffect(() => {
    AOS.init({
      duration: 1000,
      once: true,
      offset: 0,
    });
  }, []);

  // Simulasi imports untuk demo

  return (
    <section className="relative lg:h-screen h-[950px] w-full bg-gradient-to-br from-[#efffd7] via-[#f8fff4] to-white overflow-hidden">
      {/* Main Content */}
      <div className="flex lg:items-center lg:justify-normal sm:justify-center lg:mt-[25px] mt-[100px] h-full lg:w-4/5 w-11/12 mx-auto relative z-10">
        <div className="max-w-2xl">
          {/* Badge */}
          <div className="animate-fadeInDown">
            <div className="flex items-center justify-center lg:justify-normal mb-8">
              <div className="bg-white/80 backdrop-blur-sm p-3 rounded-full shadow-lg border border-white/20">
                <div className="flex items-center gap-4">
                  <div className="bg-gradient-to-r from-green-100 to-green-200 rounded-full p-3">
                    <img src={Bag} className="lg:w-8 w-6" alt="Bag" />
                  </div>
                  <p className="font-medium text-gray-700 mr-6 lg:text-lg text-sm">
                    Belanja Online Kebutuhan Dapur
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Hero Text */}
          <div className="animate-fadeInUp">
            <h1 className="text-[#1E1E1E] lg:text-[64px] text-[36px] font-bold leading-tight mt-4 lg:text-start text-center">
              Fresh Ingredients
            </h1>
            <h2 className="bg-gradient-to-r from-[#74B11A] via-green-500 to-emerald-600 bg-clip-text text-transparent lg:text-[64px] text-[36px] font-bold leading-tight lg:text-start text-center">
              Hassle Free Shopping
            </h2>
          </div>

          {/* Description */}
          <p className="text-gray-600 lg:text-lg text-base max-w-[550px] mt-8 lg:text-start text-center leading-relaxed animate-fadeInUp delay-200">
            Belanja Kebutuhan Dapur Jadi Lebih Mudah! Download Aplikasi Kami &
            Nikmati Kemudahan Berbelanja di Genggaman Tangan.
          </p>

          {/* CTA Buttons */}
          <div className="flex justify-center lg:justify-start gap-4 mt-10 animate-fadeInUp delay-400">
            <a href="#download">
              <button className="group relative overflow-hidden bg-gradient-to-r from-[#FFBC00] to-[#FFD700] hover:from-[#FFD700] hover:to-[#FFBC00] transition-all duration-300 text-white px-8 py-4 rounded-full font-medium shadow-lg hover:shadow-xl transform hover:-translate-y-1">
                <span className="relative z-10">Shop Now</span>
                <div className="absolute inset-0 bg-white/20 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left"></div>
              </button>
            </a>
            <a href="#about">
              <button className="relative overflow-hidden bg-white/80 backdrop-blur-sm border-2 border-gray-300 hover:border-green-400 transition-all duration-300 text-gray-700 hover:text-green-600 px-8 py-4 rounded-full font-medium shadow-lg hover:shadow-xl transform hover:-translate-y-1">
                Learn More
              </button>
            </a>
          </div>

          {/* Trust Indicators */}
          <div className="flex items-center justify-center lg:justify-start gap-8 mt-12 animate-fadeInUp delay-600">
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
              <span className="text-sm text-gray-600">Fresh Daily</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-yellow-500 rounded-full animate-pulse"></div>
              <span className="text-sm text-gray-600">Fast Delivery</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-blue-500 rounded-full animate-pulse"></div>
              <span className="text-sm text-gray-600">Best Quality</span>
            </div>
          </div>
        </div>
      </div>

      {/* Fruit Image - Kept in original position */}
      <div className="absolute lg:bottom-5 bottom-0 z-10 lg:right-[-50px] lg:left-auto left-1/2 -translate-x-1/2 lg:translate-x-0">
        <div className="lg:w-[660px] w-[340px] animate-fadeInUp delay-500">
          <img
            src={Buah}
            alt="Buah"
            className="w-full h-full object-contain drop-shadow-lg"
          />
        </div>
      </div>

     

      {/* Leaf - Enhanced */}
      <img
        src={Leaf3}
        alt="Leaf3"
        className="hidden lg:block absolute bottom-0 left-[-30px] lg:w-[90px] w-[60px] animate-bounce opacity-80"
      />
    </section>
  );
};

export default Hero;
