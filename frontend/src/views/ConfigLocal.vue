<template>
  <div class="config-container">
    <h2 class="title">Configuración Local</h2>

    <div v-if="loading">Cargando configuración...</div>

    <div v-else-if="config.length === 0">
      No hay configuración disponible
    </div>

    <div v-else>
      <ul>
        <li v-for="(item, index) in config" :key="index">
          <strong>ID:</strong> {{ item.id }} |
          <strong>Nombre Local:</strong> {{ item.nombre_local }} |
          <strong>Dirección:</strong> {{ item.direccion }}
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { getConfigLocal } from "../services/api";
import "../assets/styles/configlocal.css";

const config = ref([]);
const loading = ref(true);

const loadConfig = async () => {
  try {
    config.value = await getConfigLocal();
  } catch (err) {
    console.error("Error cargando configuración local:", err);
  } finally {
    loading.value = false;
  }
};

onMounted(loadConfig);
</script>