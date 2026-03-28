<template>
  <div class="d-flex overflow-hidden" style="height: 100vh;">

    <aside :class="['sidebar d-flex flex-column p-3 text-white shadow', { closed: isClosed }]">

      <div class="d-flex align-items-center mb-4">
        <button class="btn text-white p-0 border-0 shadow-none me-3" @click="toggleSidebar">
          <i class="fas fa-bars fs-4"></i>
        </button>
        <h2 v-if="!isClosed" class="h5 mb-0 fw-bold">Mi Panel</h2>
      </div>

      <nav class="nav flex-column gap-1 flex-grow-1">
        <router-link to="/dashboard/inicio" class="nav-link text-white d-flex align-items-center gap-3 rounded">
          <i class="fas fa-home"></i> <span>Inicio</span>
        </router-link>

        <template v-if="rol === 1">
          <router-link to="/dashboard/users" class="nav-link text-white d-flex align-items-center gap-3 rounded">
            <i class="fas fa-users"></i> <span>Usuarios</span>
          </router-link>
          <router-link to="/dashboard/roles" class="nav-link text-white d-flex align-items-center gap-3 rounded">
            <i class="fas fa-user-shield"></i> <span>Roles</span>
          </router-link>
        </template>

        <router-link to="/dashboard/categories" class="nav-link text-white d-flex align-items-center gap-3 rounded">
          <i class="fas fa-list"></i> <span>Categorías</span>
        </router-link>

        <router-link to="/dashboard/products" class="nav-link text-white d-flex align-items-center gap-3 rounded">
          <i class="fas fa-box"></i> <span>Productos</span>
        </router-link>

        <router-link to="/dashboard/pedidos" class="nav-link text-white d-flex align-items-center gap-3 rounded">
          <i class="fas fa-shopping-cart"></i> <span>Pedidos</span>
        </router-link>

        <router-link v-if="rol === 1" to="/dashboard/pedidos-list"
          class="nav-link text-white d-flex align-items-center gap-3 rounded">
          <i class="fas fa-receipt"></i> <span>Lista Pedidos</span>
        </router-link>

        <router-link to="/dashboard/clientes" class="nav-link text-white d-flex align-items-center gap-3 rounded">
          <i class="fas fa-user"></i> <span>Clientes</span>
        </router-link>

        <router-link v-if="rol === 1" to="/dashboard/reportes"
          class="nav-link text-white d-flex align-items-center gap-3 rounded">
          <i class="fas fa-chart-bar"></i> <span>Reportes</span>
        </router-link>

        <router-link v-if="rol === 1" to="/dashboard/configlocal"
          class="nav-link text-white d-flex align-items-center gap-3 rounded">
          <i class="fas fa-cog"></i> <span>Configuración</span>
        </router-link>
      </nav>

      <button @click="logout" class="btn btn-outline-danger d-flex align-items-center border-0 w-100 mt-auto p-3"
        :class="isClosed ? 'justify-content-center' : 'justify-content-start gap-3'">
        <i class="fas fa-sign-out-alt"></i>
        <span v-if="!isClosed" class="fw-medium">Cerrar sesión</span>
      </button>

    </aside>

    <main class="main-content">
      <div class="container-fluid p-4">
        <router-view />
      </div>
    </main>
  </div>
</template>
<script>

export default {
  data() {
    return {
      isClosed: false,
      rol: Number(localStorage.getItem("rol_id")),
      logoUrl: localStorage.getItem("logo_url") || "",
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
