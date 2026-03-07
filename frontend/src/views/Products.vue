<template>
  <div class="container">

    <h1 class="title">Productos</h1>

    <form class="form" @submit.prevent="addProduct">
      <input v-model="name" placeholder="Nombre del producto" />
      <input v-model="price" type="number" placeholder="Precio" />
      <input type="file" @change="handleFileChange" />
      <button type="submit">Agregar Producto</button>
    </form>

    <div class="grid">

      <div class="card" v-for="prod in products" :key="prod.id">

        <img
          :src="`http://localhost:3000/uploads/${prod.imagen_url}`"
          class="product-img"
        />

        <h3>{{ prod.nombre }}</h3>

        <p class="price">${{ prod.precio }}</p>

      </div>

    </div>

  </div>
</template>

<script setup>
import "../assets/styles/products.css";
import { ref, onMounted } from 'vue';
import { getProductos, addProducto } from '../services/api';

const name = ref('');
const price = ref('');
const image = ref(null);

const products = ref([]);

const loadProducts = async () => {
  try {
    products.value = await getProductos();
  } catch (err) {

    console.error("Error cargando productos:", err);
  }
};

onMounted(loadProducts);

const handleFileChange = (e) => {

  const file = e.target.files[0];

  if(
    file.type === "image/png" ||
    file.type === "image/jpeg" ||
    file.type === "image/jpg"
  ){
    image.value = file;
  }else{
    alert("Solo se permiten imágenes JPG o PNG");
  }

};

const addProduct = async () => {

  if (!name.value || !price.value || !image.value) {
    alert("Completa todos los campos");
    return;
  }

  const formData = new FormData();

  formData.append("nombre", name.value);
  formData.append("precio", price.value);
 formData.append("imagen_url", image.value);

  try {

    await addProducto(formData);

    name.value = '';
    price.value = '';
    image.value = null;

    await loadProducts();

  } catch (err) {
    console.error('Error agregando producto:', err);
    alert('No se pudo agregar el producto');
  }

};

onMounted(loadProducts);

const addProduct = async () => {
  if (!name.value || !price.value) return;

  try {
    await addProducto({ nombre: name.value, precio: price.value });
    name.value = "";
    price.value = "";
    await loadProducts();
  } catch (err) {
    console.error("Error agregando producto:", err);
    alert("No se pudo agregar el producto");
  }
};
</script>
