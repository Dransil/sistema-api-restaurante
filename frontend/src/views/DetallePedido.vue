<template>
  <div class="container">
   <h2 class="title">Detalle del Pedido #{{ pedidoId }}</h2>

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
import { ref, watch } from "vue";

import { getDetalleByPedidoId } from "../services/api";
import "../assets/styles/detallepedido.css";

const props = defineProps({
  pedidoId: Number
})
const detalles = ref([]);

const loadDetalle = async () => {
  const id = props.pedidoId;

  detalles.value = await getDetalleByPedidoId(id);
};

watch(() => props.pedidoId, async (newId) => {
  if (newId) {
    detalles.value = await getDetalleByPedidoId(newId);
  }
}, { immediate: true });
</script>
