import Navbar from "../components/Navbar";
import ScrollToTop from "../components/ScrollToTop";
import About from "../sections/About";
import BestQuality from "../sections/BestQuality";
import Card from "../sections/Card";
import Categories from "../sections/Categories";
import Download from "../sections/Download";
import Footer from "../sections/Footer";
import Hero from "../sections/Hero";
import WhyChooseUs from "../sections/WhyChooseUs";

const LandingPage = () => {
  return (
    <>
      <div className="relative">
        <Navbar />
        <Hero className="w-full" />
      </div>

      <Categories />
      <About />
      <Card />
      <BestQuality />
      <Download />
      <WhyChooseUs />
      <Footer className="w-full" />
      <ScrollToTop />
    </>
  );
};

export default LandingPage;
