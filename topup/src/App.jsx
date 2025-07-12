import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import AdminLayout from "./layout/Layout";
import Login from "./pages/Login/Login";

import LupaPassword from "./pages/LupaPassword";
import NotFound from "./components/404";
import TopUpPage from "./pages/TopUp";
import InvoicePage from "./components/Invoice";
import TopUpHistory from "./components/TopUpHistory";

function App() {
 

  return (
    <Router>
      <Routes>
        <Route path="*" element={<NotFound />} />
        <Route path="/" element={<Login />} />

        <Route path="/forgot/password" element={<LupaPassword />} />

        <Route element={<AdminLayout />}>
            <Route path="/topup" element={<TopUpPage />} />
            <Route path="/topup-history" element={<TopUpHistory />} />
            <Route path="/invoice" element={<InvoicePage />} />
          
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
