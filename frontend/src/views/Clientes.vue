<script>
import { getClientes, getClienteByCI, addCliente, updateCliente } from "../services/api";
import "../assets/styles/clientes.css";

export default {
  data() {
    return {
      clientes: [],
      loading: false,
      error: null,
      ci: "",
      razon_social: "",
      cliente_id: null,
      showModal: false,
      modalTitle: "",
      modalMessage: "",
      currentPage: 1,
      clientsPerPage: 10
    };
  },

  mounted() {
    this.cargarClientes();
  },

  computed: {
    paginatedClientes() {
      const start = (this.currentPage - 1) * this.clientsPerPage;
      const end = start + this.clientsPerPage;
      return this.clientes.slice(start, end);
    },
    totalPages() {
      return Math.max(1, Math.ceil(this.clientes.length / this.clientsPerPage));
    },
    startItem() {
      return (this.currentPage - 1) * this.clientsPerPage + 1;
    },
    endItem() {
      const end = this.currentPage * this.clientsPerPage;
      return end > this.clientes.length ? this.clientes.length : end;
    }
  },

  methods: {
    abrirModal(titulo, mensaje) {
      this.modalTitle = titulo;
      this.modalMessage = mensaje;
      this.showModal = true;
    },

    cerrarModal() {
      this.showModal = false;
    },

    async cargarClientes() {
      try {
        this.loading = true;
        this.clientes = await getClientes();
      } catch (err) {
        this.error = "Error cargando clientes";
        console.error(err);
      } finally {
        this.loading = false;
      }
    },

    async buscarCliente() {
      if (!this.ci) return;
      try {
        const cliente = await getClienteByCI(this.ci);
        this.razon_social = cliente.razon_social;
        this.cliente_id = cliente.id;
      } catch (err) {
        this.razon_social = "";
        this.cliente_id = null;
        this.abrirModal("Info", "Cliente no encontrado, puedes crearlo");
      }
    },

    async guardarCliente() {
      if (!this.ci || !this.razon_social) {
        this.abrirModal("Error", "CI y Razón Social son obligatorios");
        return;
      }
      try {
        if (this.cliente_id) {
          await updateCliente(this.cliente_id, { ci: this.ci, razon_social: this.razon_social });
          this.abrirModal("Éxito", "Cliente actualizado correctamente");
        } else {
          const nuevoCliente = await addCliente({ ci: this.ci, razon_social: this.razon_social });
          this.cliente_id = nuevoCliente.id;
          this.abrirModal("Éxito", "Cliente creado correctamente");
        }
        this.ci = "";
        this.razon_social = "";
        this.cliente_id = null;
        this.cargarClientes();
      } catch (err) {
        const mensaje = err.response?.data?.error || "Error al guardar cliente";
        this.abrirModal("Error", mensaje);
      }
    },

    editarCliente(cliente) {
      this.cliente_id = cliente.id;
      this.ci = cliente.ci;
      this.razon_social = cliente.razon_social;
    },

    
    nextPage() { if (this.currentPage < this.totalPages) this.currentPage++; },
    prevPage() { if (this.currentPage > 1) this.currentPage--; },
    goToPage(page) { this.currentPage = page; }
  }
};
</script>

<template>
  <div class="clientes-container">
    <h2>Clientes</h2>

    <div class="clientes-card">
   
      <div class="form-box">
        <input v-model="ci" class="form-control" placeholder="CI" @blur="buscarCliente" />
        <input v-model="razon_social" class="form-control" placeholder="Razón Social" />
        <button class="clientes-button" @click="guardarCliente">
          {{ cliente_id ? "Actualizar Cliente" : "Crear Cliente" }}
        </button>
      </div>

      <p v-if="loading">Cargando clientes...</p>
      <p v-else-if="error">{{ error }}</p>

      <table class="clientes-table" v-else-if="clientes.length">
        <tr>
          <th>ID</th>
          <th>CI</th>
          <th>Razón Social</th>
          <th>Acciones</th>
        </tr>

        <tr v-for="cliente in paginatedClientes" :key="cliente.id">
          <td>{{ cliente.id }}</td>
          <td>{{ cliente.ci }}</td>
          <td>{{ cliente.razon_social }}</td>
          <td>
            <button class="btn btn-edit" @click="editarCliente(cliente)">
              Editar
            </button>
          </td>
        </tr>
      </table>

      <p v-else>No hay clientes registrados</p>

  
      <div class="pagination-container" v-if="totalPages > 1">

        <div class="pagination-info">
          Showing {{ startItem }}-{{ endItem }} of {{ clientes.length }}
        </div>

        <div class="pagination">
          <button
            class="page-btn"
            @click="prevPage"
            :disabled="currentPage === 1"
          >
            ‹
          </button>

          <button
            v-for="page in totalPages"
            :key="page"
            class="page-btn"
            :class="{ active: page === currentPage }"
            @click="goToPage(page)"
          >
            {{ page }}
          </button>

          <button
            class="page-btn"
            @click="nextPage"
            :disabled="currentPage === totalPages"
          >
            ›
          </button>
        </div>

      </div>
    </div>

    <!-- MODAL -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal-box">
        <h3>{{ modalTitle }}</h3>
        <p>{{ modalMessage }}</p>
        <button class="btn btn-finish" @click="cerrarModal">OK</button>
      </div>
    </div>
  </div>
</template>