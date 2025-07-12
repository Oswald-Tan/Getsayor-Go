// components/Loading.jsx
import { FaSpinner, FaCircleNotch } from "react-icons/fa";
import PropTypes from "prop-types";

const Loading = ({ type = "spinner", fullScreen = true }) => {
  const loaderContainerClass = fullScreen 
    ? "fixed inset-0 bg-white bg-opacity-90 z-50 flex items-center justify-center min-h-screen"
    : "w-full h-full flex items-center justify-center py-8";

  const Loader = () => {
    switch(type) {
      case 'spinner':
        return (
          <div className="relative">
            <div className="w-12 h-12 rounded-full absolute border-4 border-solid border-gray-200"></div>
            <div className="w-12 h-12 rounded-full animate-spin absolute border-4 border-solid border-blue-500 border-t-transparent"></div>
          </div>
        );
        
      case 'dots':
        return (
          <div className="flex space-x-2">
            <div className="w-3 h-3 bg-blue-500 rounded-full animate-bounce"></div>
            <div className="w-3 h-3 bg-blue-500 rounded-full animate-bounce delay-100"></div>
            <div className="w-3 h-3 bg-blue-500 rounded-full animate-bounce delay-200"></div>
          </div>
        );

      case 'progress':
        return (
          <div className="w-48 h-2 bg-gray-200 rounded-full overflow-hidden">
            <div className="w-full h-full bg-blue-500 origin-left animate-progress"></div>
          </div>
        );

      case 'logo':
        return (
          <div className="flex flex-col items-center space-y-4">
            <FaCircleNotch className="w-12 h-12 text-blue-500 animate-spin-slow" />
            <div className="text-sm text-gray-600 font-medium">Memuat...</div>
          </div>
        );

      default:
        return <FaSpinner className="animate-spin text-blue-500 text-4xl" />;
    }
  };

  return (
    <div className={loaderContainerClass}>
      <div className="flex flex-col items-center space-y-3">
        <Loader />
        <span className="sr-only">Loading...</span>
      </div>
    </div>
  );
};

Loading.propTypes = {
  type: PropTypes.oneOf(["spinner", "dots", "progress", "logo"]),
  fullScreen: PropTypes.bool
};

export default Loading;