<template>
  <div class="products-container">
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
   <div class="card" v-for="prod in paginatedProducts" :key="prod.id">
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

 <div class="pagination-container">

  <div class="pagination-info">
    Showing {{ startItem }}-{{ endItem }} of {{ products.length }}
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
</template>

<script setup>
import "../assets/styles/products.css";
import { ref, onMounted, computed } from "vue";
import { getProductos, addProducto, updateProducto } from "../services/api";

const name = ref("");
const price = ref("");
const stock = ref("");
const image = ref(null);
const editingId = ref(null);

const products = ref([]);
const currentPage = ref(1);
const productsPerPage = 10;

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
const startItem = computed(() => {
  return (currentPage.value - 1) * productsPerPage + 1;
});

const endItem = computed(() => {
  const end = currentPage.value * productsPerPage;
  return end > products.value.length ? products.value.length : end;
});

const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * productsPerPage;
  const end = start + productsPerPage;
  return products.value.slice(start, end);
});

const totalPages = computed(() => {
  return Math.ceil(products.value.length / productsPerPage);
});
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
const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++;
  }
};

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--;
  }
};

const goToPage = (page) => {
  currentPage.value = page;
};


</script>
