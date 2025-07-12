import { Link } from 'react-router-dom';

const NotFoundPage = () => {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center items-center px-4 dark:bg-gray-900">
      <div className="max-w-lg w-full text-center space-y-8">
        {/* Illustrasi */}
        <div className="flex justify-center">
          <svg
            className="w-64 h-64 text-indigo-600 dark:text-indigo-400"
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
            />
          </svg>
        </div>

        {/* Konten Teks */}
        <div className="space-y-4">
          <h1 className="text-9xl font-bold text-gray-900 dark:text-white">404</h1>
          <h2 className="text-3xl font-semibold text-gray-800 dark:text-gray-200">
            Oops! Page not found
          </h2>
          <p className="text-gray-600 dark:text-gray-400">
            The page your&apos;re looking for dosn&apos;nt exist or has been moved. 
            Please return to the homepage.
          </p>
        </div>

        {/* Tombol Kembali */}
        <Link
          to="/"
          className="inline-block px-6 py-3 text-white bg-indigo-600 rounded-md 
          hover:bg-indigo-700 transition-colors duration-300 font-medium
          focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2
          dark:focus:ring-offset-gray-900"
        >
          Go Back Home
        </Link>
      </div>
    </div>
  );
};

export default NotFoundPage;