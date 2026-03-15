import { createRouter, createWebHistory } from "vue-router";
import Login from "../views/Login.vue";
import Register from "../views/Register.vue";

import DashboardLayout from "../layouts/DashboardLayout.vue";
import DashboardHome from "../views/DashboardHome.vue";
import Users from "../views/Users.vue";
import Reports from "../views/Reports.vue";
import Categories from "../views/Categories.vue";
import Products from "../views/Products.vue";
import Clientes from "../views/Clientes.vue";
import EditUser from "../views/EditUser.vue";
import Pedidos from "../views/Pedidos.vue"
const routes = [
  { path: "/", redirect: "/login" },
  { path: "/login", component: Login },
  { path: "/register", component: Register },

  {
    path: "/dashboard",
    component: DashboardLayout,
    children: [
      { path: "", component: DashboardHome },
      { path: "users", component: Users },
      { path: "users/:id/edit", component: EditUser },
      { path: "reports", component: Reports },
      { path: "categories", component: Categories },
      { path: "products", component: Products },
      { path: "clientes", component: Clientes },
      { path: "/dashboard/pedidos",component: Pedidos},
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
