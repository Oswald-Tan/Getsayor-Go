import { useState, useEffect } from "react";
import { ChevronLeft, Search } from "lucide-react";
import { useParams, useNavigate } from "react-router-dom";
import PropTypes from "prop-types";
import products from "../data/mockData";

const Explore = () => {
  const navigate = useNavigate();
  const { categoryName } = useParams();
  const [category, setCategory] = useState("");
  const [productsList, setProductsList] = useState([]);
  const [filteredProducts, setFilteredProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortBy, setSortBy] = useState("name");
  const [categoryExists, setCategoryExists] = useState(true);
  const [hasProducts, setHasProducts] = useState(true);

  useEffect(() => {
    // Simulate data loading
    setTimeout(() => {
      const formattedCategory = categoryName.replace(/-/g, " ");
      const capitalizedCategory = formattedCategory
        .split(" ")
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
        .join(" ");

      setCategory(capitalizedCategory);

      // Get products by category
      const categoryKey = formattedCategory.toLowerCase();
      
      if (products[categoryKey] && products[categoryKey].length > 0) {
        setProductsList(products[categoryKey]);
        setFilteredProducts(products[categoryKey]);
        setCategoryExists(true);
        setHasProducts(true);
      } else {
        // Category doesn't exist or has no products
        setProductsList([]);
        setFilteredProducts([]);
        setHasProducts(false);
        
        if (products[categoryKey] === undefined) {
          setCategoryExists(false);
        } else {
          setCategoryExists(true); // Category exists but has no products
        }
      }

      setLoading(false);
    }, 800);
  }, [categoryName]);

  useEffect(() => {
    if (!hasProducts) return; // Skip if category has no products

    let filtered = productsList.filter(
      (product) =>
        product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        product.description.toLowerCase().includes(searchQuery.toLowerCase())
    );

    // Sorting
    filtered.sort((a, b) => {
      switch (sortBy) {
        case "price-low":
          return a.price - b.price;
        case "price-high":
          return b.price - a.price;
        case "rating":
          return b.rating - a.rating;
        case "name":
        default:
          return a.name.localeCompare(b.name);
      }
    });

    setFilteredProducts(filtered);
  }, [searchQuery, sortBy, productsList, hasProducts]);

  const ProductCard = ({ product }) => (
    <div className="group bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-2xl transition-all duration-500 transform hover:-translate-y-2">
      <div className="relative overflow-hidden">
        <img
          src={product.image}
          alt={product.name}
          className="w-full md:h-56 h-48 object-contain group-hover:scale-110 transition-transform duration-700"
        />
      </div>

      <div className="p-6">
        <h3 className="font-bold text-xl text-gray-800 group-hover:text-emerald-600 transition-colors mb-3">
          {product.name}
        </h3>

        <p className="text-gray-600 text-sm leading-relaxed">
          {product.description}
        </p>
      </div>
    </div>
  );

  const renderContent = () => {
    if (!categoryExists) {
      // Category doesn't exist
      return (
        <div className="text-center py-20">
          <div className="mb-4">
            <svg
              className="mx-auto h-16 w-16 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              ></path>
            </svg>
          </div>
          <h3 className="text-2xl font-bold text-gray-700 mb-2">
            Category not found
          </h3>
          <p className="text-gray-500 mb-6">
            Sorry, the category &quot;{category}&quot; is not available at the moment.
          </p>
          <button
            onClick={() => navigate("/")}
            className="bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-3 rounded-xl transition-colors"
          >
            Back to Home
          </button>
        </div>
      );
    }

    if (!hasProducts) {
      // Category exists but has no products
      return (
        <div className="text-center py-20">
          <div className="mb-4">
            <svg
              className="mx-auto h-16 w-16 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
              />
            </svg>
          </div>
          <h3 className="text-2xl font-bold text-gray-700 mb-2">
            No products available
          </h3>
          <p className="text-gray-500 mb-6">
            We&apos;re currently out of stock for &quot;{category}&quot;. Check back soon!
          </p>
          <button
            onClick={() => navigate("/")}
            className="bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-3 rounded-xl transition-colors"
          >
            Browse Other Categories
          </button>
        </div>
      );
    }

    // Category has products
    return (
      <>
        <div className="bg-white rounded-2xl shadow-lg p-6 mb-8">
          <div className="flex flex-row gap-4 items-center justify-between">
            <div className="flex-1 relative">
              <Search
                className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"
                size={20}
              />
              <input
                type="text"
                placeholder={`Search ${category.toLowerCase()}...`}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-12 pr-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>

            <div className="text-gray-500 text-sm font-medium">
              {filteredProducts.length} products found
            </div>
          </div>
        </div>

        {loading ? (
          <div className="flex flex-col items-center justify-center py-32">
            <div className="relative">
              <div className="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-emerald-500"></div>
              <div className="absolute inset-0 rounded-full border-4 border-emerald-100"></div>
            </div>
            <p className="mt-4 text-gray-600 text-lg">
              Loading amazing products...
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
            {filteredProducts.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        )}

        {/* Empty search results */}
        {!loading && filteredProducts.length === 0 && (
          <div className="text-center py-20">
            <div className="mb-4">
              <Search size={64} className="mx-auto text-gray-300" />
            </div>
            <h3 className="text-2xl font-bold text-gray-700 mb-2">
              No products found
            </h3>
            <p className="text-gray-500 mb-6">
              Try adjusting your search or filter criteria
            </p>
            <button
              onClick={() => {
                setSearchQuery("");
                setSortBy("name");
              }}
              className="bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-3 rounded-xl transition-colors"
            >
              Clear Filters
            </button>
          </div>
        )}
      </>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-emerald-50">
      <div className="bg-gradient-to-r from-emerald-600 via-green-600 to-teal-700 text-white py-16 md:py-20 relative overflow-hidden">
        <div className="absolute inset-0 bg-black opacity-10"></div>
        <div className="absolute top-0 left-0 w-full h-full">
          <div className="absolute top-10 left-10 w-32 h-32 bg-white opacity-5 rounded-full"></div>
          <div className="absolute bottom-10 right-10 w-48 h-48 bg-white opacity-5 rounded-full"></div>
        </div>

        <div className="container mx-auto px-4 md:px-8 relative z-10">
          <div className="flex items-center mb-6">
            <button
              onClick={() => navigate(-1)}
              className="flex items-center text-white hover:text-emerald-100 transition-colors group"
            >
              <ChevronLeft
                size={24}
                className="mr-2 group-hover:-translate-x-1 transition-transform"
              />
              <span className="text-lg">Back to Categories</span>
            </button>
          </div>

          <div className="text-center">
            <h1 className="text-4xl md:text-5xl font-bold mb-4 text-white">
              Explore {category}
            </h1>
            <p className="text-xl text-emerald-100 mb-8 max-w-2xl mx-auto">
              {hasProducts
                ? `Discover our premium selection of ${category.toLowerCase()} with unmatched quality and freshness`
                : `We're preparing amazing ${category.toLowerCase()} products for you`}
            </p>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-4 md:px-8 py-8">
        {renderContent()}
      </div>
    </div>
  );
};

Explore.propTypes = {
  product: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string.isRequired,
    image: PropTypes.string.isRequired,
    description: PropTypes.string.isRequired,
  }).isRequired,
};

export default Explore;