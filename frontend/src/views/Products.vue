<template>
  <div class="products-container">
    <h1 class="title">Productos</h1>

    <form class="form" @submit.prevent="addProduct" v-if="esAdmin">
      <input v-model="name" placeholder="Nombre del producto" />
      <input v-model="price" type="number" placeholder="Precio" />
      <input v-model="stock" type="number" placeholder="Stock" />
      <input type="file" @change="handleFileChange" />
      <select v-model="selectedCategory">
        <option value="" disabled>Selecciona una categoría</option>
        <option v-for="cat in categories" :key="cat.id" :value="cat.id">
          {{ cat.nombre }}
        </option>
      </select>
      <button type="submit">
        {{ editingId ? "Actualizar Producto" : "Agregar Producto" }}
      </button>
      <button v-if="editingId" type="button" @click="cancelEdit">
        Cancelar
      </button>
    </form>
    <div class="filters">
      <button
        :class="{ active: filter === 'todos' }"
        @click="setFilter('todos')"
      >
        Todos
      </button>

      <button
        :class="{ active: filter === 'activos' }"
        @click="setFilter('activos')"
      >
        Activos
      </button>

      <button
        :class="{ active: filter === 'noactivos' }"
        @click="setFilter('noactivos')"
      >
        No Activos
      </button>
    </div>
    <div class="grid">
      <div class="card" v-for="prod in paginatedProducts" :key="prod.id">
        <img
          v-if="prod.imagen_url"
          :src="`http://localhost:3000${prod.imagen_url}`"
          class="product-img"
        />

        <div
          class="stock-label"
          :class="{
            available: prod.stock > 5,
            low: prod.stock > 0 && prod.stock <= 5,
            out: prod.stock === 0,
          }"
        >
          <i
            v-if="prod.stock > 0 && prod.stock <= 5"
            class="fas fa-exclamation-triangle"
          ></i>
          {{
            prod.stock === 0
              ? "Agotado"
              : prod.stock <= 5
                ? "Stock Bajo"
                : "Disponible"
          }}
        </div>

        <h3>{{ prod.nombre }}</h3>
        <p>
          Estado:
          <strong>{{ prod.activo ? "Activo" : "Inactivo" }}</strong>
        </p>
        <p class="category">
          {{
            categories.find((cat) => cat.id === prod.categoria_id)?.nombre ||
            "Sin categoría"
          }}
        </p>
        <button v-if="esAdmin" @click="editProduct(prod)">Editar</button>
        <button v-if="esAdmin" @click="toggleEstado(prod)">
          {{ prod.activo ? "Desactivar" : "Activar" }}
        </button>
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

    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <p>{{ modalMessage }}</p>
        <button @click="closeModal">Cerrar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import "../assets/styles/products.css";
import { ref, onMounted, computed } from "vue";
import {
  getProductos,
  addProducto,
  updateProducto,
  getCategorias,
  getProductosActivos,
  getProductosNoActivos,
  cambiarEstadoProducto,
} from "../services/api";
const rol = Number(localStorage.getItem("rol_id"));
const esAdmin = rol === 1;
const name = ref("");
const price = ref("");
const stock = ref("");
const image = ref(null);
const editingId = ref(null);
const categories = ref([]);
const selectedCategory = ref("");
const products = ref([]);
const currentPage = ref(1);
const productsPerPage = 10;
const showModal = ref(false);
const modalMessage = ref("");
const editProduct = (prod) => {
  name.value = prod.nombre;
  price.value = prod.precio;
  stock.value = prod.stock;
  editingId.value = prod.id;
  selectedCategory.value = prod.categoria_id;
};

const filter = ref("todos");

const setFilter = async (type) => {
  filter.value = type;

  if (type === "todos") {
    await loadProducts();
  } else if (type === "activos") {
    await verActivos();
  } else if (type === "noactivos") {
    await verNoActivos();
  }

  currentPage.value = 1;
};

const verActivos = async () => {
  products.value = await getProductosActivos();
  currentPage.value = 1;
};

const verNoActivos = async () => {
  products.value = await getProductosNoActivos();
  currentPage.value = 1;
};
const openModal = (message) => {
  modalMessage.value = message;
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  modalMessage.value = "";
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
    currentPage.value = 1;
  } catch (err) {
    console.error("Error cargando productos:", err);
  }
};

const loadCategories = async () => {
  try {
    categories.value = await getCategorias();
  } catch (err) {
    console.error("Error cargando categorías:", err);
  }
};
onMounted(() => {
  loadProducts();
  loadCategories();
});
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
  return Math.max(1, Math.ceil(products.value.length / productsPerPage));
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
    openModal("Completa los campos");
    return;
  }

  if (!selectedCategory.value) {
    openModal("Selecciona una categoría");
    return;
  }

  try {
    if (editingId.value) {
      const formData = new FormData();
      formData.append("nombre", name.value);
      formData.append("precio", price.value);
      formData.append("stock", stock.value);
      if (image.value) formData.append("imagen_url", image.value);
      formData.append("categoria_id", selectedCategory.value);

      await updateProducto(editingId.value, formData);
      editingId.value = null;
    } else {
      const formData = new FormData();
      formData.append("nombre", name.value);
      formData.append("precio", price.value);
      formData.append("stock", stock.value);
      formData.append("imagen_url", image.value);
      formData.append("categoria_id", selectedCategory.value);

      await addProducto(formData);
    }

    name.value = "";
    price.value = "";
    stock.value = "";
    image.value = null;
    selectedCategory.value = "";

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

const toggleEstado = async (prod) => {
  try {
    await cambiarEstadoProducto(prod.id, !prod.activo);

    openModal(prod.activo ? "Producto desactivado" : "Producto activado");

    await loadProducts();
  } catch (error) {
    openModal("Error al cambiar estado");
  }
};
</script>
