<script>
import { getClientes } from "../services/api";
import "../assets/styles/clientes.css";
export default {
  data() {
    return {
      clientes: [],
      loading: false,
      error: null,
    };
  },

  async mounted() {
    this.cargarClientes();
  },

  methods: {
    async cargarClientes() {
      try {
        this.loading = true;
        this.clientes = await getClientes();
        console.log(this.clientes);
      } catch (err) {
        this.error = "Error cargando clientes";
        console.error(err);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<template>
  <div class="clientes-container">
    <h2>Clientes</h2>

    <div class="clientes-card">
      <button class="clientes-button">Nuevo Cliente</button>

      <p v-if="loading">Cargando clientes...</p>
      <p v-else-if="error">{{ error }}</p>

      <table class="clientes-table" v-else-if="clientes.length">
        <tr>
          <th>ID</th>
          <th>CI</th>
          <th>Razón Social</th>
        </tr>

        <tr v-for="cliente in clientes" :key="cliente.id">
          <td>{{ cliente.id }}</td>
          <td>{{ cliente.ci }}</td>
          <td>{{ cliente.razon_social }}</td>
        </tr>
      </table>

      <p v-else>No hay clientes registrados</p>
    </div>
  </div>
</template>
