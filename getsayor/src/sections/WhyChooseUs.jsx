import Why from "../assets/why.webp";
import { useEffect } from "react";

import { FaFacebookSquare } from "react-icons/fa";

import { FaInstagram, FaYoutube } from "react-icons/fa";

const features = [
  {
    icon: "🍃",
    title: "ALWAYS FRESH",
    description:
      "Produk kami selalu dipanen tepat waktu dan dikirim dalam kondisi segar langsung ke tangan Anda. Kualitas kesegaran yang terjaga dari kebun ke meja makan.",
    position: "top-left",
  },
  {
    icon: "❤️‍🩹",
    title: "SUPER HEALTHY",
    description:
      "Ditanam tanpa bahan kimia berbahaya, kaya nutrisi untuk mendukung gaya hidup sehat. Setiap gigitan penuh manfaat untuk tubuh dan pikiran Anda.",
    position: "top-right",
  },
  {
    icon: "🌿",
    title: "100% NATURAL",
    description:
      "Murni dari alam tanpa tambahan pengawet, pewarna, atau bahan buatan. Kami menjaga keaslian rasa dan kebaikan alam dalam setiap produk.",
    position: "bottom-left",
  },
  {
    icon: "🏅",
    title: "PREMIUM QUALITY",
    description:
      "Hanya yang terbaik yang kami pilih untuk Anda. Standar kualitas tinggi dari pemilihan bibit hingga proses pengemasan untuk kepuasan pelanggan.",
    position: "bottom-right",
  },
];

const WhyChooseUs = () => {
  useEffect(() => {
    // AOS animation simulation
    const elements = document.querySelectorAll('[data-aos]');
    elements.forEach((el, index) => {
      setTimeout(() => {
        el.style.opacity = '1';
        el.style.transform = 'translateY(0)';
      }, index * 200);
    });
  }, []);

  return (
    <section
      id="why-choose-us"
      className="relative py-20 text-center md:w-4/5 w-11/12 mx-auto overflow-hidden z-0"
    >
      {/* Background gradient */}
      <div className="absolute inset-0"></div>
      
      {/* Floating decoration elements */}
      <div className="absolute top-10 left-10 w-20 h-20 bg-green-100 rounded-full opacity-20 animate-pulse"></div>
      <div className="absolute top-32 right-20 w-12 h-12 bg-orange-100 rounded-full opacity-30 animate-bounce"></div>
      <div className="absolute bottom-20 left-1/4 w-16 h-16 bg-yellow-100 rounded-full opacity-25 animate-pulse"></div>

      <div>
        <h2
          className="font-bold text-4xl md:text-5xl lg:text-5xl text-center text-gray-800 mb-6 leading-tight"
          data-aos="fade-up"
          style={{ opacity: 0, transform: 'translateY(30px)', transition: 'all 0.8s ease' }}
        >
          Why Choose{" "}
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#74B11A] via-green-500 to-emerald-600">
            Us
          </span>
        </h2>
        
        <p
          className="text-gray-600 max-w-3xl mx-auto italic md:text-lg text-base leading-relaxed"
          data-aos="fade-up"
          data-aos-delay="100"
          style={{ opacity: 0, transform: 'translateY(30px)', transition: 'all 0.8s ease' }}
        >
          Menyediakan produk organik segar langsung dari petani lokal dengan
          kualitas terbaik. Diolah secara alami tanpa bahan kimia untuk
          kesehatan keluarga Anda.
        </p>

        {/* Enhanced Social Media Icons */}
        <div
          className="flex justify-center space-x-6 mt-8 text-2xl cursor-pointer z-10 relative"
          data-aos="fade-up"
          data-aos-delay="200"
          style={{ opacity: 0, transform: 'translateY(30px)', transition: 'all 0.8s ease' }}
        >
          <a href="#" className="text-blue-600 hover:text-blue-700 transform hover:scale-110 transition-all duration-300 p-3 rounded-full bg-white shadow-lg hover:shadow-xl">
            <FaFacebookSquare />
          </a>
          <a href="#" className="text-red-600 hover:text-red-700 transform hover:scale-110 transition-all duration-300 p-3 rounded-full bg-white shadow-lg hover:shadow-xl">
            <FaYoutube />
          </a>
          <a href="#" className="text-pink-600 hover:text-pink-700 transform hover:scale-110 transition-all duration-300 p-3 rounded-full bg-white shadow-lg hover:shadow-xl">
            <FaInstagram />
          </a>
        </div>

        {/* Mobile layout */}
        <div className="md:hidden grid grid-cols-1 gap-6 mt-16">
          <div className="relative">
            <img
              src={Why}
              alt="Fresh Vegetables"
              className="w-[280px] h-[280px] object-contain mx-auto mb-8 drop-shadow-xl"
              data-aos="zoom-in"
              style={{ opacity: 0, transform: 'scale(0.8)', transition: 'all 0.8s ease' }}
            />
            <div className="absolute inset-0 bg-gradient-to-t from-green-100/20 to-transparent rounded-full"></div>
          </div>
          
          {features.map((item, index) => (
            <div
              key={index}
              className="group bg-white p-6 rounded-2xl shadow-lg hover:shadow-2xl border border-green-50 text-left transform hover:-translate-y-2 transition-all duration-300 relative overflow-hidden"
              data-aos="fade-up"
              data-aos-delay={index * 100}
              style={{ opacity: 0, transform: 'translateY(30px)', transition: 'all 0.8s ease' }}
            >
              <div className="absolute top-0 right-0 w-20 h-20 bg-gradient-to-br from-green-100 to-transparent rounded-bl-full opacity-50"></div>
              <div className="text-4xl mb-4 filter drop-shadow-sm">{item.icon}</div>
              <h3 className="font-bold text-lg text-gray-800 mb-3 group-hover:text-green-600 transition-colors duration-300">
                {item.title}
              </h3>
              <p className="text-gray-600 leading-relaxed">
                {item.description}
              </p>
            </div>
          ))}
        </div>

        {/* Desktop radial layout */}
        <div className="hidden md:block relative min-h-[600px] mt-20">
          {features.map((item, index) => (
            <div
              key={index}
              className={`absolute z-20 w-[350px] ${
                item.position === "top-left"
                  ? "top-[-50px] left-16"
                  : item.position === "top-right"
                  ? "top-[-50px] right-16"
                  : item.position === "bottom-left"
                  ? "bottom-[120px] left-0"
                  : "bottom-[120px] right-0"
              }`}
              data-aos={
                item.position === "top-left"
                  ? "fade-right"
                  : item.position === "top-right"
                  ? "fade-left"
                  : item.position === "bottom-left"
                  ? "fade-right"
                  : "fade-left"
              }
              data-aos-delay={index * 200}
              style={{ opacity: 0, transform: 'translateX(50px)', transition: 'all 0.8s ease' }}
            >
              <div
                className={`group bg-white p-6 rounded-2xl shadow-sm hover:shadow-md border border-green-100 transform hover:-translate-y-3 transition-all duration-500 relative overflow-hidden ${
                  item.position === "top-left" || item.position === "bottom-left"
                    ? "ml-auto"
                    : "mr-auto"
                }`}
              >
                {/* Gradient overlay */}
                <div className="absolute inset-0 bg-gradient-to-br from-green-50/0 via-green-50/20 to-green-50/0 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                
                {/* Icon background */}
                <div className="absolute top-4 right-4 w-16 h-16 bg-gradient-to-br from-green-100 to-transparent rounded-full opacity-30"></div>
                
                <div className="text-4xl mb-4 filter drop-shadow-sm relative z-10">{item.icon}</div>
                <h3 className="font-bold text-lg text-gray-800 mb-3 group-hover:text-green-600 transition-colors duration-300 relative z-10">
                  {item.title}
                </h3>
                <p className="text-gray-600 leading-relaxed relative z-10">
                  {item.description}
                </p>
              </div>
            </div>
          ))}

          {/* Enhanced border circles */}
          <div className="absolute bottom-0 flex items-center justify-center z-0 left-1/2 transform -translate-x-1/2">
            <div
              className="border-2 border-dashed border-green-300 rounded-full w-[650px] h-[650px] opacity-40 animate-pulse"
              data-aos="zoom-in"
              data-aos-delay="600"
              style={{ opacity: 0, transform: 'scale(0.8)', transition: 'all 1s ease' }}
            ></div>
            <div
              className="border border-dotted border-green-200 rounded-full w-[550px] h-[550px] opacity-30 absolute animate-spin"
              style={{ animationDuration: '20s' }}
            ></div>
          </div>

          {/* Enhanced center image */}
          <div className="absolute md:bottom-[-100px] bottom-[-20px] left-1/2 transform -translate-x-1/2 z-10">
            <div className="relative">
              <img
                src={Why}
                alt="Fresh Vegetables"
                className="w-[500px] h-[500px] object-contain drop-shadow-2xl"
                style={{ filter: 'brightness(1.1) contrast(1.1) saturate(1.2)' }}
              />
              {/* Glow effect */}
              {/* <div className="absolute inset-0 bg-gradient-to-t from-green-100/30 via-transparent to-transparent rounded-full blur-xl"></div> */}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default WhyChooseUs;