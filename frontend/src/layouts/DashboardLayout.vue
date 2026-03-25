<template>
  <div class="dashboard">
    <aside :class="['sidebar', { closed: isClosed }]">
      <h2>Mi Panel</h2>
      <button class="menu-btn" @click="toggleSidebar">☰</button>

      <router-link to="/dashboard">
        <i class="fas fa-home"></i> <span>Inicio</span>
      </router-link>

      <router-link v-if="rol == 1" to="/dashboard/users">
        <i class="fas fa-users"></i> <span>Usuarios</span>
      </router-link>


      <router-link v-if="rol == 1" to="/dashboard/roles">
        <i class="fas fa-user-shield"></i> <span>Roles</span>
      </router-link>

      <router-link to="/dashboard/categories">
        <i class="fas fa-list"></i> <span>Categorías</span>
      </router-link>

      <router-link to="/dashboard/products">
        <i class="fas fa-box"></i> <span>Productos</span>
      </router-link>

      <router-link to="/dashboard/pedidos">
        <i class="fas fa-shopping-cart"></i> <span>Pedidos</span>
      </router-link>
      <router-link to="/dashboard/pedidos-list">
        <i class="fas fa-receipt"></i> <span>Lista Pedidos</span>
      </router-link>

      <router-link to="/dashboard/clientes">
        <i class="fas fa-user"></i> <span>Clientes</span>
      </router-link>

      <router-link to="/dashboard/reportes">
        <i class="fas fa-chart-bar"></i> <span>Reportes</span>
      </router-link>

      <router-link v-if="rol == 1" to="/dashboard/configlocal">
        <i class="fas fa-cog"></i> <span>Configuración Local</span>
      </router-link>

      <button @click="logout">Cerrar sesión</button>

    </aside>

    <div class="main">


      <section class="content">
        <router-view />
      </section>
    </div>
  </div>
</template>

<script>
import "../assets/styles/dashboard.css";

export default {
  data() {
    return {
      isClosed: false,
      rol: localStorage.getItem("rol_id"),
    };
  },
  methods: {
    toggleSidebar() {
      this.isClosed = !this.isClosed;
    },
    logout() {
      localStorage.removeItem("token");
      localStorage.removeItem("rol_id");
      localStorage.removeItem("user_id");
      localStorage.removeItem("username");

      this.$router.push("/login");
    },
  },
};
</script>
