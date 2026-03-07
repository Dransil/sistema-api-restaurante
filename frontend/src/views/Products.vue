<template>
  <div>
    <h2>Productos</h2>

    <form @submit.prevent="addProduct">
      <input v-model="name" placeholder="Nombre del producto" />
      <input v-model="price" type="number" placeholder="Precio" />
      <button type="submit">Agregar</button>
    </form>

    <ul>
      <li v-for="prod in products" :key="prod.id">
        {{ prod.nombre }} - ${{ prod.precio }}
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { getProductos, addProducto } from '../services/api';

const name = ref('');
const price = ref('');
const products = ref([]);

const loadProducts = async () => {
  try {
    products.value = await getProductos();
  } catch (err) {
    console.error('Error cargando productos:', err);
  }
};

onMounted(loadProducts);

const addProduct = async () => {
  if (!name.value || !price.value) return;

  try {
    await addProducto({ nombre: name.value, precio: price.value });
    name.value = '';
    price.value = '';
    await loadProducts(); 
  } catch (err) {
    console.error('Error agregando producto:', err);
    alert('No se pudo agregar el producto');
  }
};
</script>