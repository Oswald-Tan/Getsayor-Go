import Wortel from "../assets/product_item/wortel.webp";
import SawiPutih from "../assets/product_item/sawi_putih.webp";
import SawiHijau from "../assets/product_item/sawi_hijau.webp";
import Kol from "../assets/product_item/kol.webp";
import Tomat from "../assets/product_item/tomat.webp";
import Buncis from "../assets/product_item/buncis.webp";
import KacangPanjang from "../assets/product_item/kacang_panjang.webp";
import LabuSiam from "../assets/product_item/labu_siam.webp";
import Kangkung from "../assets/product_item/kangkung.webp";
import Pakcoy from "../assets/product_item/pakcoy.webp";
import Seledri from "../assets/product_item/seledri.webp";
import BungaPepaya from "../assets/product_item/bunga_pepaya.webp";
import DaunPepaya from "../assets/product_item/daun_pepaya.webp";
import Bayam from "../assets/product_item/bayam.webp";
import Selada from "../assets/product_item/selada.webp";

import BawangPutih from "../assets/product_item/bawang_putih.webp";
import BawangMerah from "../assets/product_item/bawang_merah.webp";
import CabaiMerah from "../assets/product_item/cabai_merah.webp";
import DaunBawang from "../assets/product_item/daun_bawang.webp";
import BawangBombay from "../assets/product_item/bawang_bombay.webp";
import CabaiKeriting from "../assets/product_item/cabai_keriting.webp";
import Jahe from "../assets/product_item/jahe.webp";
import JerukNipis from "../assets/product_item/jeruk_nipis.webp";
import RampaCampur from "../assets/product_item/rampa_campur.webp";
import JerukIkan from "../assets/product_item/jeruk_ikan.webp";

import Kentang from "../assets/product_item/kentang.webp";

import Tempe from "../assets/product_item/tempe.webp";
import Tahu from "../assets/product_item/tahu.webp";

import Jagung from "../assets/product_item/jagung.webp";
import LabuKuning from "../assets/product_item/labu_kuning.webp";

const products = {
  vegetables: [
    {
      id: 1,
      name: "Tomat",
      description:
        "Tomat segar kaya akan vitamin C dan antioksidan, cocok untuk salad, jus, atau masakan harian.",
      image: Tomat,
      price: 12500,
      rating: 4.8,
      reviews: 124,
      discount: 15,
      badge: "Organic",
    },
    {
      id: 2,
      name: "Buncis",
      description:
        "Buncis segar yang renyah dan bergizi, sempurna untuk tumisan atau pelengkap sayur sop.",
      image: Buncis,
      price: 18000,
      rating: 4.6,
      reviews: 89,
      discount: 0,
      badge: "Fresh",
    },
    {
      id: 3,
      name: "Kacang Panjang",
      description:
        "Kacang panjang hijau dan renyah, ideal untuk sayur asem, tumisan, atau lalapan.",
      image: KacangPanjang,
      price: 8500,
      rating: 4.9,
      reviews: 201,
      discount: 20,
      badge: "Premium",
    },
    {
      id: 4,
      name: "Wortel",
      description:
        "Wortel manis dan kaya beta-karoten, baik untuk kesehatan mata dan cocok untuk berbagai olahan.",
      image: Wortel,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 5,
      name: "Labu Siam",
      description:
        "Labu siam lembut dan rendah kalori, cocok untuk sayur lodeh atau tumisan.",
      image: LabuSiam,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 6,
      name: "Kangkung",
      description:
        "Kangkung segar dan lembut, favorit untuk cah kangkung atau masakan tumis pedas.",
      image: Kangkung,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 7,
      name: "Sawi Putih",
      description:
        "Sawi putih renyah dan juicy, sering digunakan dalam sup atau tumisan oriental.",
      image: SawiPutih,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 8,
      name: "Sawi Hijau",
      description:
        "Sawi hijau dengan rasa khas yang segar, cocok untuk sayur bening atau ditumis.",
      image: SawiHijau,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 9,
      name: "Kol",
      description:
        "Kol atau kubis dengan tekstur renyah, ideal untuk salad, sup, atau digoreng.",
      image: Kol,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 10,
      name: "Pakcoy",
      description:
        "Pakcoy segar dengan batang renyah dan daun lembut, kaya serat dan vitamin.",
      image: Pakcoy,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 11,
      name: "Seledri",
      description:
        "Seledri wangi dan segar, sering digunakan sebagai penyedap alami dan garnish.",
      image: Seledri,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 12,
      name: "Bayam",
      description:
        "Bayam hijau lembut, kaya zat besi dan cocok untuk sayur bening atau smoothie sehat.",
      image: Bayam,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 13,
      name: "Selada",
      description:
        "Selada hijau segar, renyah dan cocok untuk salad, burger, atau lalapan.",
      image: Selada,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 14,
      name: "Daun Pepaya",
      description:
        "Daun pepaya muda dengan rasa khas, baik untuk ditumis atau sebagai lalapan.",
      image: DaunPepaya,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
    {
      id: 15,
      name: "Bunga Pepaya",
      description:
        "Bunga pepaya segar dengan rasa sedikit pahit, lezat jika ditumis dengan ikan teri.",
      image: BungaPepaya,
      price: 15000,
      rating: 4.7,
      reviews: 156,
      discount: 10,
      badge: "Organic",
    },
  ],

  spices: [
    {
      id: 1,
      name: "Bawang Putih",
      description:
        "Bawang putih segar dengan aroma khas yang kuat, cocok untuk bumbu dasar masakan Indonesia.",
      image: BawangPutih,
      price: 25000,
      rating: 4.9,
      reviews: 78,
      discount: 0,
      badge: "Premium",
    },
    {
      id: 2,
      name: "Cabai Merah",
      description:
        "Cabai merah segar dengan rasa pedas menyengat, ideal untuk sambal dan bumbu masakan.",
      image: CabaiMerah,
      price: 32000,
      rating: 4.8,
      reviews: 143,
      discount: 25,
      badge: "Best Seller",
    },
    {
      id: 3,
      name: "Bawang Merah",
      description:
        "Bawang merah pilihan dengan rasa manis dan aroma khas, sempurna untuk tumisan dan sambal.",
      image: BawangMerah,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
    {
      id: 4,
      name: "Daun Bawang",
      description:
        "Daun bawang segar dengan aroma ringan, cocok untuk taburan sup, mie, dan hidangan lainnya.",
      image: DaunBawang,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
    {
      id: 5,
      name: "Bawang Bombay",
      description:
        "Bawang bombay besar dengan tekstur renyah dan rasa manis, ideal untuk salad dan masakan tumis.",
      image: BawangBombay,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
    {
      id: 6,
      name: "Cabai Keriting",
      description:
        "Cabai keriting segar berwarna merah cerah dengan tingkat kepedasan sedang, pas untuk sambal.",
      image: CabaiKeriting,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
    {
      id: 7,
      name: "Jahe",
      description:
        "Jahe segar dengan rasa pedas hangat, bermanfaat untuk kesehatan dan bahan dasar rempah.",
      image: Jahe,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
    {
      id: 8,
      name: "Jeruk Nipis",
      description:
        "Jeruk nipis segar dengan rasa asam menyegarkan, sempurna untuk pelengkap masakan dan minuman.",
      image: JerukNipis,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
    {
      id: 9,
      name: "Rampa-Rampa Campur",
      description:
        "Campuran rempah segar khas Sulawesi seperti serai, daun jeruk, dan kemangi untuk aroma masakan.",
      image: RampaCampur,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
    {
      id: 10,
      name: "Jeruk Ikan",
      description:
        "Daun jeruk khas untuk ikan dengan aroma citrus kuat yang memperkaya rasa masakan laut.",
      image: JerukIkan,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
  ],

  fruits: [
    {
      id: 1,
      name: "Jagung",
      description:
        "Jagung manis segar dengan biji-biji penuh, cocok untuk direbus, dibakar, atau dijadikan bahan makanan sehat.",
      image: Jagung,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
    {
      id: 2,
      name: "Labu Kuning",
      description:
        "Labu kuning kaya vitamin dan serat, cocok untuk sup, kolak, atau bahan kue yang menyehatkan.",
      image: LabuKuning,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
  ],

  tubers: [
    {
      id: 1,
      name: "Kentang",
      description:
        "Kentang segar berkualitas tinggi dengan tekstur lembut, cocok untuk digoreng, direbus, atau dipanggang.",
      image: Kentang,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
  ],

  protein: [
    {
      id: 1,
      name: "Tempe",
      description:
        "Tempe segar hasil fermentasi kedelai, kaya protein nabati dan cocok untuk berbagai olahan tradisional.",
      image: Tempe,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
    {
      id: 2,
      name: "Tahu",
      description:
        "Tahu lembut berkualitas tinggi, sumber protein nabati yang serbaguna untuk digoreng, ditumis, atau direbus.",
      image: Tahu,
      price: 28000,
      rating: 4.6,
      reviews: 67,
      discount: 15,
      badge: "Premium",
    },
  ],
};

export default products;
