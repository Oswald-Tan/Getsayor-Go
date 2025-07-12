import { useEffect, useState } from "react";
import AOS from "aos";
import CardImg from "../assets/card-buah.webp";

const Card = () => {
  const [isHovered, setIsHovered] = useState(false);

  useEffect(() => {
    AOS.init({ duration: 800, once: false });
  }, []);

  return (
    <section className="flex items-center justify-center md:mt-20 mt-[300px] md:w-4/5 w-11/12 mx-auto">
      <div 
        className="relative overflow-hidden rounded-3xl w-full shadow-2xl hover:shadow-3xl transition-all duration-500 transform hover:scale-[1.02]"
        data-aos="fade-up"
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        {/* Background with enhanced gradient */}
        <div className="absolute inset-0 bg-gradient-to-br from-[#0B8005] via-[#4A9D2A] to-[#74B11A]"></div>
        
        {/* Animated background elements */}
        <div className="absolute inset-0 overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-br from-white/5 via-transparent to-black/10"></div>
          <div className="absolute -top-20 -left-20 w-40 h-40 bg-white/10 rounded-full blur-xl animate-pulse"></div>
          <div className="absolute -bottom-20 -right-20 w-60 h-60 bg-yellow-400/20 rounded-full blur-2xl animate-pulse delay-1000"></div>
          <div className="absolute top-1/2 left-1/4 w-32 h-32 bg-green-300/10 rounded-full blur-xl animate-pulse delay-2000"></div>
        </div>

        {/* Main content container */}
        <div className="relative z-10 md:p-16 p-8">
          <div className="grid md:grid-cols-2 grid-cols-1 gap-8 items-center">
            
            {/* Left side - Content */}
            <div className="flex flex-col md:items-start md:justify-start items-center justify-center space-y-6">
              
              {/* Badge */}
              <div 
                className="inline-flex items-center bg-gradient-to-r from-yellow-400/20 to-orange-400/20 backdrop-blur-sm rounded-full px-4 py-2 border border-yellow-400/30"
                data-aos="fade-right"
                data-aos-delay="100"
              >
                <span className="text-yellow-400 font-semibold text-sm mr-2">🔥</span>
                <span className=" text-sm font-semibold text-yellow-400">
                  Weekly Deals
                </span>
              </div>

              {/* Main heading */}
              <div className="space-y-2">
                <h1
                  className=" md:text-4xl lg:text-5xl text-2xl font-bold text-white md:text-left text-center leading-tight"
                  data-aos="fade-up"
                  data-aos-delay="200"
                >
                  Unbeatable Offers: Your
                </h1>
                <h1
                  className=" md:text-4xl lg:text-5xl text-2xl font-bold bg-gradient-to-r from-yellow-400 to-orange-400 bg-clip-text text-transparent md:text-left text-center leading-tight"
                  data-aos="fade-up"
                  data-aos-delay="300"
                >
                  Weekly Grocery Specials
                </h1>
              </div>

              {/* Description */}
              <p
                className=" md:text-lg text-base text-white/90 leading-relaxed max-w-[520px] md:text-left text-center"
                data-aos="fade-up"
                data-aos-delay="400"
              >
                Discover amazing deals on fresh, organic groceries delivered right to your doorstep. Quality meets affordability every week.
              </p>

              {/* CTA Button */}
              <div
                className="flex flex-col sm:flex-row gap-4 mt-8"
                data-aos="zoom-in"
                data-aos-delay="500"
              >
                <button className="group relative bg-gradient-to-r from-yellow-400 to-orange-400 text-white  font-bold px-8 py-4 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 overflow-hidden">
                  <span className="relative z-10 flex items-center justify-center space-x-2">
                    <span>Shop Now</span>
                    <span className="group-hover:translate-x-1 transition-transform duration-300">🛒</span>
                  </span>
                  <div className="absolute inset-0 bg-gradient-to-r from-orange-400 to-yellow-400 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                </button>
                
                <button className="border-2 border-white/30 text-white  font-semibold px-8 py-4 rounded-2xl hover:border-white/50 hover:bg-white/10 backdrop-blur-sm transition-all duration-300">
                  View All Deals
                </button>
              </div>

              {/* Trust indicators */}
              <div className="flex items-center gap-6 mt-8 pt-6 border-t border-white/20">
                <div className="text-center">
                  <div className="text-2xl font-bold text-white">50%</div>
                  <div className="text-white/70 text-sm">Off Sale</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-white">24/7</div>
                  <div className="text-white/70 text-sm">Delivery</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-white">100%</div>
                  <div className="text-white/70 text-sm">Fresh</div>
                </div>
              </div>
            </div>

            {/* Right side - Image */}
            <div className="relative md:block hidden">
              <div className="relative">
                {/* Main image container */}
                <div className={`transition-all duration-500 ${isHovered ? 'scale-105' : 'scale-100'}`}>
                  <img
                    src={CardImg}
                    alt="Fresh Grocery Bag"
                    className="w-full max-w-[600px] ml-auto object-contain relative z-10"
                    style={{
                      filter: 'drop-shadow(0 20px 40px rgba(0,0,0,0.3))'
                    }}
                  />
                </div>

                {/* Floating elements */}
                <div className="absolute -top-6 -right-6 w-12 h-12 bg-gradient-to-br from-yellow-400 to-orange-400 rounded-full flex items-center justify-center shadow-lg animate-bounce">
                  <span className="text-white font-bold text-lg">%</span>
                </div>
                
                {/* <div className="absolute -bottom-4 -left-4 w-16 h-16 bg-gradient-to-br from-green-400 to-emerald-400 rounded-full flex items-center justify-center shadow-lg animate-pulse">
                  <span className="text-white font-bold text-xl">🥬</span>
                </div> */}

                {/* Discount badge */}
                <div className="absolute top-1/4 -left-8 bg-red-500 text-white px-4 py-2 rounded-full transform -rotate-12 shadow-lg animate-pulse">
                  <span className="font-bold text-sm">UP TO 50% OFF</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Mobile image */}
        <div className="md:hidden relative mt-8 px-8 pb-8">
          <img
            src={CardImg}
            alt="Fresh Grocery Bag"
            className="w-full max-w-[300px] mx-auto object-contain"
            style={{
              filter: 'drop-shadow(0 10px 20px rgba(0,0,0,0.3))'
            }}
          />
        </div>

        {/* Decorative patterns */}
        <div className="absolute bottom-0 left-0 w-full h-32 bg-gradient-to-t from-black/10 to-transparent"></div>
      </div>
    </section>
  );
};

export default Card;