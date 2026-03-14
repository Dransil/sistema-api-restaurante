<template>
  <div class="container">
    <h1 class="title">Productos</h1>

    <form class="form" @submit.prevent="addProduct">
      <input v-model="name" placeholder="Nombre del producto" />
      <input v-model="price" type="number" placeholder="Precio" />
      <input v-model="stock" type="number" placeholder="Stock" />
      <input type="file" @change="handleFileChange" />
      <button type="submit">
  {{ editingId ? "Actualizar Producto" : "Agregar Producto" }}
</button>
  <button v-if="editingId" type="button" @click="cancelEdit">
    Cancelar
  </button>
    </form>

  <div class="grid">
  <div class="card" v-for="prod in products" :key="prod.id">
    <img v-if="prod.imagen_url" :src="`http://localhost:3000${prod.imagen_url}`" class="product-img" />

    <!-- ETIQUETA DE STOCK -->
    <div class="stock-label" :class="prod.stock > 0 ? 'available' : 'out'">
      {{ prod.stock > 0 ? 'Disponible' : 'Agotado' }}
    </div>

    <h3>{{ prod.nombre }}</h3>
    <p class="price">${{ prod.precio }}</p>
    <button @click="editProduct(prod)">Editar</button>
  </div>
</div>
  </div>
</template>

<script setup>
import "../assets/styles/products.css";
import { ref, onMounted } from "vue";
import { getProductos, addProducto, updateProducto } from "../services/api";

const name = ref("");
const price = ref("");
const stock = ref("");
const image = ref(null);
const editingId = ref(null);

const products = ref([]);

const editProduct = (prod) => {
  name.value = prod.nombre;
  price.value = prod.precio;
  stock.value = prod.stock;
  editingId.value = prod.id;
};

const cancelEdit = () => {
  name.value = "";
  price.value = "";
  stock.value = "";
  image.value = null;
  editingId.value = null;
};

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

  if (
    file.type === "image/png" ||
    file.type === "image/jpeg" ||
    file.type === "image/jpg"
  ) {
    image.value = file;
  } else {
    alert("Solo se permiten imágenes JPG o PNG");
  }
};

const addProduct = async () => {
  if (!name.value || !price.value || (!editingId.value && !image.value)) {
  alert("Completa los campos");
  return;
}

  try {

    if (editingId.value) {

      const formData = new FormData();
      formData.append("nombre", name.value);
      formData.append("precio", price.value);
      formData.append("stock", stock.value);

      if (image.value) {
        formData.append("imagen_url", image.value);
      }

      await updateProducto(editingId.value, formData);

      editingId.value = null;

    } else {

      const formData = new FormData();
      formData.append("nombre", name.value);
      formData.append("precio", price.value);
      formData.append("stock", stock.value);
     formData.append("imagen_url", image.value);

      await addProducto(formData);

    }

    name.value = "";
    price.value = "";
    stock.value = "";
    image.value = null;

    await loadProducts();

  } catch (err) {
    console.error("Error guardando producto:", err);
  }
};
</script>
