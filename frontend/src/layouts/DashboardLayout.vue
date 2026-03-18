<template>
  <div class="dashboard">

    <aside :class="['sidebar', { closed: isClosed }]">
      <h2>Mi Panel</h2>

 <router-link to="/dashboard">
  <i class="fas fa-home"></i> <span>Inicio</span>
</router-link>

<router-link to="/dashboard/users">
  <i class="fas fa-users"></i> <span>Usuarios</span>
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

    </aside>

    <div class="main">
      <header class="header">

        <!-- botón drawer -->
        <button class="menu-btn" @click="toggleSidebar">☰</button>

        <span>Bienvenida</span>
        <button @click="logout">Cerrar sesión</button>

      </header>

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
      isClosed: false
    };
  },
  methods: {
    toggleSidebar() {
      this.isClosed = !this.isClosed;
    },
    logout() {
      localStorage.removeItem("token");
      this.$router.push("/login");
    }
  }
};
</script>