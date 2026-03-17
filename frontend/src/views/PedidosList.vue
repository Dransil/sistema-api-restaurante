<template>
  <div class="pedidos-container">
    <div class="pedidos-content">
      <h2 class="title">Lista de Pedidos</h2>

      <table class="pedido-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Usuario</th>
            <th>Total</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pedido in paginatedPedidos" :key="pedido.id">
            <td>{{ pedido.id }}</td>
            <td>{{ pedido.usuario_id }}</td>
            <td>{{ pedido.total }}</td>
            <td>
              <button class="btn-view" @click="verDetalle(pedido.id)">
                Ver detalle
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- PAGINACIÓN -->
      <div class="pagination-container">
        <div class="pagination-info">
          Mostrando {{ startItem }}-{{ endItem }} de {{ pedidos.length }}
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
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import { getPedidos } from "../services/api";
import "../assets/styles/pedidoslist.css";

const pedidos = ref([]);
const router = useRouter();

const currentPage = ref(1);
const pedidosPerPage = 10;

const loadPedidos = async () => {
  pedidos.value = await getPedidos();
};

onMounted(loadPedidos);

const startItem = computed(() => (currentPage.value - 1) * pedidosPerPage + 1);
const endItem = computed(() => {
  const end = currentPage.value * pedidosPerPage;
  return end > pedidos.value.length ? pedidos.value.length : end;
});

const paginatedPedidos = computed(() => {
  const start = (currentPage.value - 1) * pedidosPerPage;
  const end = start + pedidosPerPage;
  return pedidos.value.slice(start, end);
});

const totalPages = computed(() =>
  Math.ceil(pedidos.value.length / pedidosPerPage),
);

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++;
};

const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--;
};

const goToPage = (page) => {
  currentPage.value = page;
};

const verDetalle = (id) => {
  router.push(`/dashboard/pedidos/${id}`);
};
</script>
