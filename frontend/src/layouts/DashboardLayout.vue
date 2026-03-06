<template>
  <div class="dashboard">
    <aside class="sidebar">
      <h2>Mi Panel</h2>
      <router-link to="/dashboard">Inicio</router-link>
      <router-link to="/dashboard/users">Usuarios</router-link>
      <router-link to="/dashboard/reports">Reportes</router-link>
      <router-link to="/dashboard/categories">Categorías</router-link>
      <router-link to="/dashboard/products">Productos</router-link>
    </aside>

    <div class="main">
      <header class="header">
        <span>Bienvenida </span>
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
  methods: {
    logout() {
      localStorage.removeItem("token");
      this.$router.push("/login");
    },
  },
};
</script>
