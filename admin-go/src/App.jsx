import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import AdminLayout from "./layout/Layout";
import Dashboard from "./pages/Admin/Dashboard";
import Login from "./pages/Login/Login";
import User from "./pages/Admin/Users";
import UserTrash from "./pages/Admin/UserTrash";
import UserApprove from "./pages/Admin/UsersApprove";
import UserDetail from "./pages/Admin/UserDetail";
import UserStats from "./pages/Admin/UserStats";
import Products from "./pages/Admin/Products";
import AddUser from "./pages/Admin/AddUser";
import EditUser from "./pages/Admin/EditUser";
import AddProduct from "./pages/Admin/AddProduct";
import EditProduct from "./pages/Admin/EditProduct";
import HargaPoin from "./pages/Admin/HargaPoin";
import AddHargaPoin from "./pages/Admin/AddHargaPoin";
import EditHargaPoin from "./pages/Admin/EditHargaPoin";
import Poin from "./pages/Admin/Poin";
import AddPoin from "./pages/Admin/AddPoin";
import EditPoin from "./pages/Admin/EditPoin";
import DiscountPoin from "./pages/Admin/DiscountPoin";
import EditDiscountPoin from "./pages/Admin/EditDiscountPoin";
import AddDiscountPoin from "./pages/Admin/AddDiscountPoin";
import TopUpPoin from "./pages/Admin/TopUpPoin";
import EditTopUpPoin from "./pages/Admin/EditTopUpPoin";
import Pesanan from "./pages/Admin/Pesanan";
import EditPesanan from "./pages/Admin/EditPesanan";
import HargaPoinProduct from "./pages/Admin/HargaPoinProduct";
import EditHargaPoinProduct from "./pages/Admin/EditHargaPoinProduct";
import AddHargaPoinProduct from "./pages/Admin/AddHargaPoinProduct";
import AddCityProvince from "./pages/Admin/AddCityProvince";
import CityProvince from "./pages/Admin/CityProvince";
import LupaPassword from "./pages/LupaPassword";
import NotFound from "./components/404";
import Unauthorized from "./components/Unauthorized";
import ShippingRates from "./pages/Admin/ShippingRates";
import EditShippingRates from "./pages/Admin/EditShippingRates";
import AddShippingRates from "./pages/Admin/AddShippingRates";
import UserPoints from "./pages/Admin/UserPoints";
import AfiliasiBonus from "./pages/Admin/AfiliasiBonus";

import KurirLayout from "./layout/LayoutKurir";
import DashboardKurir from "./pages/Kurir/Dashboard";
import PesananKurir from "./pages/Kurir/Pesanan";
import EditPesananKurir from "./pages/Kurir/EditPesanan";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="*" element={<NotFound />} />
        <Route path="/unauthorized" element={<Unauthorized />} />
        <Route path="/" element={<Login />} />
        <Route path="/forgot/password" element={<LupaPassword />} />

        {/*Admin Layout*/}
      
          <Route element={<AdminLayout />}>
            <Route path="/dashboard" element={<Dashboard />} />

            <Route path="/users" element={<User />} exact />
            <Route path="/users/trash" element={<UserTrash />} exact />
            <Route path="/users/approve" element={<UserApprove />} exact />
            <Route path="/users/add" element={<AddUser />} exact />
            <Route path="/users/edit/:id" element={<EditUser />} exact />
            <Route path="/users/:id/details" element={<UserDetail />} exact />
            <Route path="/users/:id/points" element={<UserPoints />} exact />
            <Route path="/users/:id/stats" element={<UserStats />} exact />

            <Route path="/products" element={<Products />} exact />
            <Route path="/products/add" element={<AddProduct />} exact />
            <Route path="/products/edit/:id" element={<EditProduct />} exact />

            <Route path="/harga/poin" element={<HargaPoin />} exact />
            <Route path="/harga/poin/add" element={<AddHargaPoin />} exact />
            <Route
              path="/harga/poin/edit/:id"
              element={<EditHargaPoin />}
              exact
            />

            <Route path="/poin" element={<Poin />} exact />
            <Route path="/poin/add" element={<AddPoin />} exact />
            <Route
              path="/poin/add/discount/:id"
              element={<AddDiscountPoin />}
              exact
            />
            <Route path="/poin/edit/:id" element={<EditPoin />} exact />

            <Route path="/discount/poin" element={<DiscountPoin />} exact />
            <Route
              path="/discount/poin/add"
              element={<AddDiscountPoin />}
              exact
            />
            <Route
              path="/discount/poin/edit/:id"
              element={<EditDiscountPoin />}
              exact
            />

            <Route path="/topup/poin" element={<TopUpPoin />} exact />
            <Route
              path="/topup/poin/edit/:id"
              element={<EditTopUpPoin />}
              exact
            />

            <Route path="/pesanan" element={<Pesanan />} exact />
            <Route path="/pesanan/edit/:id" element={<EditPesanan />} exact />

            <Route
              path="/harga/poin/product"
              element={<HargaPoinProduct />}
              exact
            />
            <Route
              path="/harga/poin/product/edit"
              element={<AddHargaPoinProduct />}
              exact
            />
            <Route
              path="/harga/poin/product/edit/:id"
              element={<EditHargaPoinProduct />}
              exact
            />

            <Route path="/city/province" element={<CityProvince />} exact />
            <Route
              path="/city/province/add"
              element={<AddCityProvince />}
              exact
            />

            <Route path="/shipping/rates" element={<ShippingRates />} exact />
            <Route
              path="/shipping/rates/add"
              element={<AddShippingRates />}
              exact
            />
            <Route
              path="/shipping/rates/edit/:id"
              element={<EditShippingRates />}
              exact
            />
            <Route path="/afiliasi/bonus" element={<AfiliasiBonus />} exact />
          </Route>

        {/*Layout Kurir*/}
        <Route element={<KurirLayout />}>
          <Route path="/dashboard/kurir" element={<DashboardKurir />} />

          <Route path="/pesanan/kurir" element={<PesananKurir />} exact />
          <Route
            path="/pesanan/edit/kurir/:id"
            element={<EditPesananKurir />}
            exact
          />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
