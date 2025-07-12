import { useState, useEffect, useRef } from "react";
import About1 from "../assets/About1.webp";
import About2 from "../assets/About2.webp";
import About3 from "../assets/About3.webp";

const About = () => {
  const [activeTab, setActiveTab] = useState("agriculture");
  const [isVisible, setIsVisible] = useState(false);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const sectionRef = useRef(null);

  const descriptions = {
    agriculture: {
      title: "Sustainable Agriculture Excellence",
      subtitle: "From Farm to Table with Care",
      description: "Sebagai penyedia hasil pertanian terdepan, kami berkomitmen menghadirkan produk organik berkualitas premium langsung dari petani lokal terpercaya. Setiap produk melalui proses seleksi ketat untuk memastikan kesegaran dan nutrisi optimal.",
      features: [
        { 
          icon: "🌱", 
          title: "100% Organic", 
          desc: "Bebas pestisida kimia, dipanen dengan metode alami",
          color: "text-green-600 bg-green-50"
        },
        { 
          icon: "🚜", 
          title: "Sustainable Farming", 
          desc: "Dukung pertanian berkelanjutan",
          color: "text-amber-600 bg-amber-50"
        },
        { 
          icon: "🤝", 
          title: "Local Partnership", 
          desc: "Kemitraan langsung dengan petani lokal Indonesia",
          color: "text-blue-600 bg-blue-50"
        },
        { 
          icon: "🏆", 
          title: "Quality Assured", 
          desc: "Standar kualitas internasional, harga lokal",
          color: "text-purple-600 bg-purple-50"
        }
      ],
      stats: [
        { number: "500+", label: "Petani Mitra" },
        { number: "10k+", label: "Pelanggan Puas" },
        { number: "50+", label: "Produk Organik" }
      ]
    },
    vegetables: {
      title: "Fresh Vegetables & Fruits",
      subtitle: "Harvested Daily for Maximum Freshness",
      description: "Koleksi sayur dan buah organik terlengkap dengan kesegaran terjamin. Dipetik langsung dari kebun, diproses dengan teknologi modern, dan dikirim dalam kondisi optimal untuk mempertahankan nutrisi alami.",
      features: [
        { 
          icon: "🍊", 
          title: "Daily Harvest", 
          desc: "Sayur dan buah segar dipanen setiap hari",
          color: "text-orange-600 bg-orange-50"
        },
        { 
          icon: "🚚", 
          title: "Fast Delivery", 
          desc: "Pengiriman cepat, produk tetap segar",
          color: "text-indigo-600 bg-indigo-50"
        },
        { 
          icon: "❄️", 
          title: "Cold Chain", 
          desc: "Sistem rantai dingin untuk menjaga kesegaran",
          color: "text-cyan-600 bg-cyan-50"
        },
        { 
          icon: "📦", 
          title: "Smart Packaging", 
          desc: "Kemasan ramah lingkungan dan higienis",
          color: "text-emerald-600 bg-emerald-50"
        }
      ],
      stats: [
        { number: "24h", label: "Pengiriman" },
        { number: "95%", label: "Kesegaran" },
        { number: "100+", label: "Varietas" }
      ]
    }
  };

  useEffect(() => {
    const handleScroll = () => {
      if (sectionRef.current) {
        const rect = sectionRef.current.getBoundingClientRect();
        setIsVisible(rect.top < window.innerHeight * 0.8);
      }
    };

    window.addEventListener('scroll', handleScroll);
    handleScroll();
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentImageIndex((prev) => (prev + 1) % 3);
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  const currentContent = descriptions[activeTab];

  return (
    <section
      id="about"
      ref={sectionRef}
      className="relative py-20 md:py-28 lg:py-36 min-h-screen flex items-center overflow-hidden"
    >
      {/* Background Elements */}
      <div className="absolute inset-0 bg-gradient-to-br from-slate-50 via-white to-gray-50"></div>
      <div className="absolute top-0 left-0 w-full h-full">
        <div className="absolute top-20 left-10 w-72 h-72 bg-gradient-to-br from-green-200/30 to-blue-200/30 rounded-full blur-3xl"></div>
        <div className="absolute bottom-20 right-10 w-80 h-80 bg-gradient-to-br from-purple-200/30 to-pink-200/30 rounded-full blur-3xl"></div>
      </div>

      <div className="container md:w-4/5 w-11/12 mx-auto relative z-10">
        <div className="max-w-7xl mx-auto">
          <div className="lg:grid lg:grid-cols-2 lg:gap-16 lg:items-start">
            
            {/* Left Content */}
            <div className={`transition-all duration-1000 ${isVisible ? 'opacity-100 translate-x-0' : 'opacity-0 -translate-x-8'}`}>
              
              {/* Header */}
              <div className="mb-10">
                <div className="inline-flex items-center bg-gradient-to-r from-green-100 to-blue-100 rounded-full px-4 py-2 mb-4">
                  <span className="text-green-700 font-medium text-sm">🌿 About Our Mission</span>
                </div>
                
                <h1 className="font-bold text-4xl md:text-5xl lg:text-5xl mb-4 bg-gradient-to-r from-gray-900 to-gray-700 bg-clip-text text-transparent leading-tight pb-2">
                  {currentContent.title}
                </h1>
                
                <p className="text-xl md:text-2xl text-gray-600 font-medium mb-6">
                  {currentContent.subtitle}
                </p>
              </div>

              {/* Tab Navigation */}
              <div className="flex space-x-2 mb-10 p-1 bg-gray-100 rounded-xl w-fit">
                {Object.keys(descriptions).map((tab) => (
                  <button
                    key={tab}
                    className={`px-6 py-3 rounded-lg font-semibold text-sm transition-all duration-300 ${
                      activeTab === tab
                        ? "bg-white text-gray-900 shadow-lg"
                        : "text-gray-600 hover:text-gray-900"
                    }`}
                    onClick={() => setActiveTab(tab)}
                  >
                    {tab === "agriculture" ? "🌾 Agriculture & Foods" : "🥬 Vegetables & Fruits"}
                  </button>
                ))}
              </div>

              {/* Content - Fixed height container */}
              <div className="min-h-[600px] lg:min-h-[700px]">
                <div
                  key={activeTab}
                  className={`transition-all duration-500 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'}`}
                >
                  <p className="text-gray-700 text-lg md:text-xl leading-relaxed mb-8">
                    {currentContent.description}
                  </p>

                  {/* Features Grid - Fixed height */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-8 min-h-[280px]">
                    {currentContent.features.map((feature, index) => (
                      <div
                        key={index}
                        className={`group p-4 rounded-2xl border border-gray-100 hover:border-gray-200 transition-all duration-300 hover:shadow-lg ${feature.color.split(' ')[1]} hover:scale-[1.02] h-fit`}
                      >
                        <div className="flex items-start space-x-3">
                          <div className={`w-10 h-10 rounded-xl ${feature.color.split(' ')[1]} flex items-center justify-center text-lg group-hover:scale-110 transition-transform duration-300 flex-shrink-0`}>
                            {feature.icon}
                          </div>
                          <div className="flex-1">
                            <h4 className={`font-semibold ${feature.color.split(' ')[0]} mb-1`}>
                              {feature.title}
                            </h4>
                            <p className="text-gray-600 text-sm leading-relaxed">
                              {feature.desc}
                            </p>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>

                  {/* Stats */}
                  {/* <div className="flex flex-wrap gap-6 mb-8">
                    {currentContent.stats.map((stat, index) => (
                      <div key={index} className="text-center">
                        <div className="text-3xl font-bold text-gray-900 mb-1">
                          {stat.number}
                        </div>
                        <div className="text-gray-600 text-sm font-medium">
                          {stat.label}
                        </div>
                      </div>
                    ))}
                  </div> */}

                  {/* CTA Button */}
                  <div className="flex flex-col sm:flex-row gap-4">
                    <button className="group bg-gradient-to-r from-[#74B11A] via-yellow-500 to-orange-500 text-white px-8 py-4 rounded-xl font-semibold text-lg hover:shadow-xl transition-all duration-300 hover:scale-[1.02]">
                      <span className="flex items-center justify-center space-x-2">
                        <span>{activeTab === "agriculture" ? "Jelajahi Produk" : "Lihat Produk Segar"}</span>
                        <span className="group-hover:translate-x-1 transition-transform">→</span>
                      </span>
                    </button>
                    
                    <button className="border-2 border-gray-300 text-gray-700 px-8 py-4 rounded-xl font-semibold text-lg hover:border-gray-400 hover:shadow-lg transition-all duration-300">
                      Hubungi Kami
                    </button>
                  </div>
                </div>
              </div>
            </div>

            {/* Right Images - Fixed position */}
            <div className={`mt-16 lg:mt-0 lg:sticky lg:top-20 transition-all duration-1000 delay-300 ${isVisible ? 'opacity-100 translate-x-0' : 'opacity-0 translate-x-8'}`}>
              <div className="relative">
                {/* Main Image Container */}
                <div className="relative rounded-3xl overflow-hidden shadow-2xl">
                  <img
                    src={About3}
                    alt="Main farming image"
                    className="w-full h-[500px] object-cover"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent"></div>
                  
                  {/* Floating Card */}
                  <div className="absolute bottom-6 left-6 right-6 bg-white/90 backdrop-blur-sm rounded-2xl p-4 shadow-xl">
                    <div className="flex items-center justify-between">
                      <div>
                        <h4 className="font-semibold text-gray-900 mb-1">Fresh from Farm</h4>
                        <p className="text-gray-600 text-sm">Daily harvest guarantee</p>
                      </div>
                      <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                        <span className="text-green-600 text-xl">✓</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Side Images */}
                <div className="flex gap-4 mt-6">
                  <div className="flex-1 relative rounded-2xl overflow-hidden shadow-lg hover:shadow-xl transition-shadow duration-300">
                    <img
                      src={About1}
                      alt="Farming process"
                      className="w-full h-[200px] object-cover"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/10 to-transparent"></div>
                  </div>
                  <div className="flex-1 relative rounded-2xl overflow-hidden shadow-lg hover:shadow-xl transition-shadow duration-300">
                    <img
                      src={About2}
                      alt="Fresh produce"
                      className="w-full h-[200px] object-cover"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/10 to-transparent"></div>
                  </div>
                </div>

                {/* Decorative Elements */}
                <div className="absolute -top-4 -right-4 w-16 h-16 bg-gradient-to-br from-yellow-400 to-orange-400 rounded-full opacity-20 animate-pulse"></div>
                <div className="absolute -bottom-4 -left-4 w-12 h-12 bg-gradient-to-br from-green-400 to-blue-400 rounded-full opacity-20 animate-bounce"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Floating Elements */}
      <div className="absolute top-1/4 right-10 w-8 h-8 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full opacity-20 animate-pulse"></div>
      <div className="absolute bottom-1/4 left-10 w-6 h-6 bg-gradient-to-br from-blue-400 to-cyan-400 rounded-full opacity-20 animate-bounce"></div>
    </section>
  );
};

export default About;