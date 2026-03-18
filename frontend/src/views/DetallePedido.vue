<template>
  <div class="container">
    <h2 class="title">Detalle del Pedido</h2>

    <div v-for="item in detalles" :key="item.id" class="detalle-card">
      <img
        v-if="item.imagen_url"
        :src="`http://localhost:3000${item.imagen_url}`"
        class="producto-img"
      />

      <div class="detalle-info">
        <h4>{{ item.producto_nombre }}</h4>

        <p>Cantidad: {{ item.cantidad }}</p>

        <p>Precio: {{ item.precio_unitario }}</p>

        <p class="subtotal">Subtotal: {{ item.subtotal }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { getDetalleByPedidoId } from "../services/api";
import "../assets/styles/detallepedido.css";

const route = useRoute();
const detalles = ref([]);

const loadDetalle = async () => {
  const id = route.params.id;

  detalles.value = await getDetalleByPedidoId(id);
};

onMounted(loadDetalle);
</script>
