<template>
  <div class="roles-container">
    <h2 class="title">Roles</h2>
<div v-if="loading">Cargando roles...</div>
    <table class="tabla">
      <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
        </tr>
      </thead>

     <tbody>
  <tr v-if="roles.length === 0">
    <td colspan="2">No hay roles disponibles</td>
  </tr>

  <tr v-for="rol in roles" :key="rol.id">
    <td>{{ rol.id }}</td>
    <td>{{ rol.nombre }}</td>
  </tr>
</tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { getRoles } from "../services/api";
import "../assets/styles/roles.css";

const roles = ref([]);
const loading = ref(true);
const loadRoles = async () => {
  try {
    roles.value = await getRoles();
  } catch (err) {
    console.error("Error cargando roles:", err);
  } finally {
    loading.value = false;
  }
};

onMounted(loadRoles);
</script>