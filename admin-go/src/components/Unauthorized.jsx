import { Link } from "react-router-dom";

const Unauthorized = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-red-600 mb-4">403 - Unauthorized</h1>
        <p className="text-lg text-gray-700 mb-8">
          You don&apos;t have permission to access this page.
        </p>
        <Link 
          to="/" 
          className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
        >
          Back to Login
        </Link>
      </div>
    </div>
  );
};

export default Unauthorized;