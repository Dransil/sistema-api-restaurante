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
      { path: "inicio", component: DashboardHome },
      { path: "users", component: Users, meta: { role: 1 } },
      { path: "users/:id/edit", component: EditUser, meta: { role: 1 } },
      { path: "users/create", component: CreateUser, meta: { role: 1 } },
      { path: "reportes", component: Reportes, meta: { role: 1 } },
      { path: "categories", component: Categories },
      { path: "products", component: Products },
      { path: "clientes", component: Clientes },
      { path: "pedidos", component: Pedidos },
      { path: "pedidos-list", component: PedidosList, meta: { role: 1 } },
      { path: "pedidos/:id", component: DetallePedido, meta: { role: 1 } },
      { path: "roles", component: Roles, meta: { role: 1 } },
      { path: "configlocal", component: ConfigLocal, meta: { role: 1 } },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem("token");
  const rol = Number(localStorage.getItem("rol_id"));

  if (to.meta.requiresAuth && !token) {
    return next("/login");
  }

  if (to.meta.role && to.meta.role !== rol) {
    return next("/dashboard");
  }

  next();
});
export default router;
