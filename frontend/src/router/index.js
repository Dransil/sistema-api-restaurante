import { createRouter, createWebHistory } from "vue-router";
import Login from "../views/Login.vue";
import Register from "../views/Register.vue";

import DashboardLayout from "../layouts/DashboardLayout.vue";
import DashboardHome from "../views/DashboardHome.vue";
import Users from "../views/Users.vue";
import Reportes from "../views/Reportes.vue";
import Categories from "../views/Categories.vue";
import Products from "../views/Products.vue";
import Clientes from "../views/Clientes.vue";
import EditUser from "../views/EditUser.vue";
import CreateUser from "../views/CreateUser.vue";
import Pedidos from "../views/Pedidos.vue";
import PedidosList from "../views/PedidosList.vue";
import DetallePedido from "../views/DetallePedido.vue";
import Roles from "../views/Roles.vue";
import ConfigLocal from "../views/ConfigLocal.vue";
const routes = [
  { path: "/", redirect: "/login" },
  { path: "/login", component: Login },
  { path: "/register", component: Register },

  {
    path: "/dashboard",
    component: DashboardLayout,
    meta: { requiresAuth: true },
    children: [
      { path: "", component: DashboardHome },
      { path: "users", component: Users },
      { path: "users/:id/edit", component: EditUser },
      { path: "users/create", component: CreateUser },
      { path: "reportes", component: Reportes },
      { path: "categories", component: Categories },
      { path: "products", component: Products },
      { path: "clientes", component: Clientes },
      { path: "pedidos", component: Pedidos },
      { path: "pedidos-list", component: PedidosList },
      { path: "pedidos/:id", component: DetallePedido },
      { path: "roles", component: Roles },
      { path: "configlocal", component: ConfigLocal },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem("token");

  if (to.meta.requiresAuth && !token) {
    next("/login");
  } else {
    next();
  }
});
export default router;
