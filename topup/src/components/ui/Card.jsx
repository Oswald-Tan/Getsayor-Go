import PropTypes from "prop-types";

const Card = ({ 
  title, 
  count, 
  icon, 
  iconColor = "text-blue-500"
}) => {
  return (
    <div className="flex flex-col p-5 bg-white dark:bg-[#282828] rounded-3xl">
      <div className={`text-2xl bg-gray-100 dark:bg-[#3f3f3f] w-10 p-2 rounded-full ${iconColor}`}>{icon}</div>
      <div className="mt-10">
        <h5 className="text-sm text-gray-700 dark:text-white max-w-[100px] uppercase">{title}</h5>
        <p className="text-[40px] font-normal text-gray-900 dark:text-white mt-4">{count}</p>
      </div>
      
    </div>
  );
};

Card.propTypes = {
  title: PropTypes.string.isRequired,
  count: PropTypes.number.isRequired,
  icon: PropTypes.element.isRequired,
  iconColor: PropTypes.string,
};

export default Card;
