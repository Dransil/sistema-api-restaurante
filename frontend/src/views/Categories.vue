<template>
  <div>
    <h2>Categorías</h2>

    <form @submit.prevent="addCategory">
      <input v-model="newCategory" placeholder="Nueva categoría" />
      <button type="submit">Agregar</button>
    </form>

    <ul>
      <li v-for="cat in categories" :key="cat.id">
        {{ cat.nombre }}
        <button @click="removeCategory(index)">Eliminar</button>

      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { getCategorias, addCategoria } from '../services/api';

const newCategory = ref('');
const categories = ref([]);

const loadCategories = async () => {
  try {
    categories.value = await getCategorias();
  } catch (err) {
    console.error('Error cargando categorías:', err);
  }
};

onMounted(loadCategories);

const addCategory = async () => {
  if (!newCategory.value) return;

  try {
    await addCategoria(newCategory.value);
    newCategory.value = '';
    await loadCategories(); 
  } catch (err) {
    console.error('Error agregando categoría:', err);
    alert('No se pudo agregar la categoría');
  }
};
</script>