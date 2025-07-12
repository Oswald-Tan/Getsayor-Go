import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LandingPage from "./Layout/LandingPage";
import Register from "./pages/Register";
import NotFoundPage from "./pages/404";
import DeleteAccountPage from "./pages/DeleteAcount";
import Explore from "./pages/Explore";


function App() {
  return (
    <Router>
      <Routes>
        <Route path="*" element={<NotFoundPage />} />
        <Route path="/" element={<LandingPage />} />
        <Route path="/register" element={<Register />} />
        <Route path="/delete-account" element={<DeleteAccountPage />} />
        <Route path="/explore/:categoryName" element={<Explore />} />
      </Routes>
    </Router>
  )
}

export default App;