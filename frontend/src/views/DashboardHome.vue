<template>
  <div class="home">

    <!-- CONFIG DEL LOCAL -->
    <div v-if="config" class="header-config">
      <img 
        v-if="config.logo_url"
        :src="config.logo_url"
        class="logo-dashboard"
      />

      <h1 class="restaurant-name">
        {{ config.nombre_restaurante }}
      </h1>
    </div>

    <h2 class="home-title">Inicio del Panel</h2>

    <!-- CARDS -->
    <div class="cards">

      <div class="card" @click="goTo('/dashboard/users')">
        <i class="fas fa-users card-icon"></i>
        <h3>Usuarios</h3>
        <p>{{ totalUsuarios }}</p>
      </div>

      <div class="card" @click="goTo('/dashboard/products')">
        <i class="fas fa-box card-icon"></i>
        <h3>Productos</h3>
        <p>{{ totalProductos }}</p>
      </div>

      <div class="card" @click="goTo('/dashboard/clientes')">
        <i class="fas fa-user card-icon"></i>
        <h3>Clientes</h3>
        <p>{{ totalClientes }}</p>
      </div>

    </div>

    <div class="banner-container"></div>

  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { 
  getConfigLocal, 
  getUsuarios, 
  getProductos, 
  getClientes 
} from "../services/api";

const router = useRouter();

const config = ref(null);

const totalUsuarios = ref(0);
const totalProductos = ref(0);
const totalClientes = ref(0);


const goTo = (ruta) => {
  router.push(ruta);
};


const loadConfig = async () => {
  try {
    const data = await getConfigLocal();
    if (data && data.length > 0) {
      config.value = data[0];
    }
  } catch (err) {
    console.error("Error cargando config:", err);
  }
};

const loadStats = async () => {
  try {
    const usuarios = await getUsuarios();
    const productos = await getProductos();
    const clientes = await getClientes();

    totalUsuarios.value = usuarios.length;
    totalProductos.value = productos.length;
    totalClientes.value = clientes.length;
  } catch (err) {
    console.error("Error cargando estadísticas:", err);
  }
};

onMounted(() => {
  loadConfig();
  loadStats();
});
</script>