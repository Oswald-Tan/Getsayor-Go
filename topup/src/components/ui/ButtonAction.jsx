import PropTypes from "prop-types";
import { Link } from "react-router-dom";

const ButtonAction = ({ text, icon, iconPosition = "left", onClick, className, to, width }) => {
  const content = (
    <>
      {iconPosition === "left" && icon && <span className="icon">{icon}</span>}
      <span className="text">{text}</span>
      {iconPosition === "right" && icon && <span className="icon">{icon}</span>}
    </>
  );

  const buttonClasses = `flex items-center justify-center px-3 py-2 text-sm rounded-lg text-white transition-all duration-150 ${className} ${width ? width : 'w-auto'}`;

  if (to) {
    return (
      <Link to={to} className={buttonClasses}>
        {content}
      </Link>
    );
  }

  return (
    <button onClick={onClick} className={buttonClasses}>
      {content}
    </button>
  );
};

ButtonAction.propTypes = {
  text: PropTypes.string,
  icon: PropTypes.node,
  iconPosition: PropTypes.oneOf(["left", "right"]),
  onClick: PropTypes.func,
  className: PropTypes.string,
  to: PropTypes.string, // 'to' adalah prop opsional untuk link
  width: PropTypes.string, // Opsional untuk mengatur lebar button
};

export default ButtonAction;
