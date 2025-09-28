export const roleRoutes = {
  admin: "/dashboard",
  kurir: "/dashboard/kurir",
};

export const getDashboardPathByRole = (role) => roleRoutes[role] || "/";
