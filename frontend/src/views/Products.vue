<template>
  <div class="products-container">
    <div class="page-header">
      <h1 class="title">Productos</h1>
      <button v-if="esAdmin" class="btn btn-primary d-flex align-items-center gap-2" @click="openCreateModal">
        <i class="fas fa-plus"></i> Nuevo Producto
      </button>
    </div>

    <!-- Filtros -->
    <div class="filters">
      <button class="btn" :class="filter === 'todos' ? 'btn-primary' : 'btn-outline-secondary'"
        @click="setFilter('todos')">Todos</button>
      <button class="btn" :class="filter === 'activos' ? 'btn-primary' : 'btn-outline-secondary'"
        @click="setFilter('activos')">Activos</button>
      <button class="btn" :class="filter === 'noactivos' ? 'btn-primary' : 'btn-outline-secondary'"
        @click="setFilter('noactivos')">No Activos</button>
    </div>

    <!-- Grid de productos -->
    <div class="grid">
      <div class="card" v-for="prod in paginatedProducts" :key="prod.id">
        <img v-if="prod.imagen_url" :src="`http://localhost:3000${prod.imagen_url}`" class="product-img" />
        <div class="stock-label" :class="{
          available: prod.stock > 5,
          low: prod.stock > 0 && prod.stock <= 5,
          out: prod.stock === 0,
        }">
          <i v-if="prod.stock > 0 && prod.stock <= 5" class="fas fa-exclamation-triangle"></i>
          {{ prod.stock === 0 ? "Agotado" : prod.stock <= 5 ? "Stock Bajo" : "Disponible" }} </div>

            <h3>{{ prod.nombre }}</h3>
            <p><strong>Cantidad:</strong> {{ prod.stock }} unidades</p>

            <p>Estado: <strong>{{ prod.activo ? "Activo" : "Inactivo" }}</strong></p>
            <p class="category">Categoría: 
              {{categories.find((cat) => cat.id === prod.categoria_id)?.nombre || "Sin categoría"}}
            </p>

            <div class="card-actions" v-if="esAdmin">
              <button class="btn btn-outline-primary btn-sm flex-fill" @click="openEditModal(prod)">
                <i class="fas fa-pen"></i> Editar
              </button>
              <button class="btn btn-sm flex-fill" :class="prod.activo ? 'btn-outline-danger' : 'btn-outline-success'"
                @click="toggleEstado(prod)">
                <i :class="prod.activo ? 'fas fa-ban' : 'fas fa-check'"></i>
                {{ prod.activo ? "Desactivar" : "Activar" }}
              </button>
            </div>
        </div>
      </div>

      <!-- Paginación -->
      <div class="pagination-container">
        <div class="pagination-info">
          Mostrando {{ startItem }}-{{ endItem }} de {{ products.length }}
        </div>
        <div class="pagination">
          <button class="page-btn" @click="prevPage" :disabled="currentPage === 1">‹</button>
          <button v-for="page in totalPages" :key="page" class="page-btn" :class="{ active: page === currentPage }"
            @click="goToPage(page)">
            {{ page }}
          </button>
          <button class="page-btn" @click="nextPage" :disabled="currentPage === totalPages">›</button>
        </div>
      </div>

      <!-- ===================== -->
      <!-- MODAL CREAR / EDITAR  -->
      <!-- ===================== -->
      <div v-if="showFormModal" class="modal-overlay" @click.self="closeFormModal">
        <div class="modal-content form-modal">
          <div class="modal-header">
            <h2>{{ editingId ? "Editar Producto" : "Nuevo Producto" }}</h2>
            <button class="modal-close" @click="closeFormModal">
              <i class="fas fa-times"></i>
            </button>
          </div>

          <div class="modal-body">
            <div class="form-group">
              <label>Nombre del producto</label>
              <input v-model="name" placeholder="Ej: Hamburguesa clásica" />
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Precio</label>
                <input v-model="price" type="number" placeholder="0.00" />
              </div>
              <div class="form-group">
                <label>Stock</label>
                <input v-model="stock" type="number" placeholder="0" />
              </div>
            </div>

            <div class="form-group">
              <label>Categoría</label>
              <select v-model="selectedCategory">
                <option value="" disabled>Selecciona una categoría</option>
                <option v-for="cat in categories" :key="cat.id" :value="cat.id">
                  {{ cat.nombre }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label>Imagen {{ editingId ? "(opcional al editar)" : "" }}</label>
              <div class="file-upload-area" @click="triggerFileInput">
                <input ref="fileInputRef" type="file" accept="image/png, image/jpeg" @change="handleFileChange"
                  style="display: none" />
                <div v-if="imagePreview" class="preview-container">
                  <img :src="imagePreview" class="image-preview" />
                  <span class="change-image-text">Cambiar imagen</span>
                </div>
                <div v-else class="upload-placeholder">
                  <i class="fas fa-cloud-upload-alt fa-2x"></i>
                  <p>Haz clic para subir una imagen</p>
                  <span>JPG o PNG</span>
                </div>
              </div>
            </div>
          </div>

          <div class="modal-footer">
            <button class="btn btn-outline-secondary" @click="closeFormModal">Cancelar</button>
            <button class="btn btn-primary" @click="addProduct" :disabled="loadingSubmit">
              <span v-if="loadingSubmit"><i class="fas fa-spinner fa-spin"></i> Guardando...</span>
              <span v-else>{{ editingId ? "Actualizar" : "Agregar" }} Producto</span>
            </button>
          </div>
        </div>
      </div>

      <!-- ===================== -->
      <!-- MODAL DE MENSAJE      -->
      <!-- ===================== -->
      <div v-if="showModal" class="modal-overlay" @click="closeModal">
        <div class="modal-content message-modal" @click.stop>
          <i class="fas fa-info-circle modal-icon"></i>
          <p>{{ modalMessage }}</p>
          <button class="btn btn-primary px-4" @click="closeModal">Entendido</button>
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

// ─── Auth ───────────────────────────────────────────
const rol = Number(localStorage.getItem("rol_id"));
const esAdmin = rol === 1;

// ─── Estado del formulario ──────────────────────────
const name = ref("");
const price = ref("");
const stock = ref("");
const image = ref(null);
const imagePreview = ref(null);
const editingId = ref(null);
const selectedCategory = ref("");
const loadingSubmit = ref(false);
const fileInputRef = ref(null);

// ─── Estado general ─────────────────────────────────
const categories = ref([]);
const products = ref([]);
const filter = ref("todos");

// ─── Paginación ──────────────────────────────────────
const currentPage = ref(1);
const productsPerPage = 10;

// ─── Modales ─────────────────────────────────────────
const showFormModal = ref(false);
const showModal = ref(false);
const modalMessage = ref("");

// ─── Modal mensaje ───────────────────────────────────
const openModal = (message) => {
  modalMessage.value = message;
  showModal.value = true;
};
const closeModal = () => {
  showModal.value = false;
  modalMessage.value = "";
};

// ─── Modal formulario ────────────────────────────────
const openCreateModal = () => {
  resetForm();
  showFormModal.value = true;
};

const openEditModal = (prod) => {
  name.value = prod.nombre;
  price.value = prod.precio;
  stock.value = prod.stock;
  editingId.value = prod.id;
  selectedCategory.value = prod.categoria_id;
  imagePreview.value = prod.imagen_url
    ? `http://localhost:3000${prod.imagen_url}`
    : null;
  image.value = null;
  showFormModal.value = true;
};

const closeFormModal = () => {
  showFormModal.value = false;
  resetForm();
};

const resetForm = () => {
  name.value = "";
  price.value = "";
  stock.value = "";
  image.value = null;
  imagePreview.value = null;
  editingId.value = null;
  selectedCategory.value = "";
};

// ─── Imagen ──────────────────────────────────────────
const triggerFileInput = () => {
  fileInputRef.value?.click();
};

const handleFileChange = (e) => {
  const file = e.target.files[0];
  if (!file) return;

  if (["image/png", "image/jpeg", "image/jpg"].includes(file.type)) {
    image.value = file;
    imagePreview.value = URL.createObjectURL(file);
  } else {
    openModal("Solo se permiten imágenes JPG o PNG");
  }
};

// ─── CRUD ────────────────────────────────────────────
const addProduct = async () => {
  if (!name.value || !price.value || (!editingId.value && !image.value)) {
    openModal("Completa todos los campos obligatorios");
    return;
  }
  if (!selectedCategory.value) {
    openModal("Selecciona una categoría");
    return;
  }

  loadingSubmit.value = true;
  try {
    const formData = new FormData();
    formData.append("nombre", name.value);
    formData.append("precio", price.value);
    formData.append("stock", stock.value);
    formData.append("categoria_id", selectedCategory.value);
    if (image.value) formData.append("imagen_url", image.value);

    if (editingId.value) {
      await updateProducto(editingId.value, formData);
      openModal("Producto actualizado correctamente");
    } else {
      await addProducto(formData);
      openModal("Producto agregado correctamente");
    }

    closeFormModal();
    await loadProducts();
  } catch (err) {
    console.error("Error guardando producto:", err);
    openModal("Error al guardar el producto");
  } finally {
    loadingSubmit.value = false;
  }
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

// ─── Carga de datos ──────────────────────────────────
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

// ─── Filtros ─────────────────────────────────────────
const setFilter = async (type) => {
  filter.value = type;
  if (type === "todos") await loadProducts();
  else if (type === "activos") products.value = await getProductosActivos();
  else if (type === "noactivos") products.value = await getProductosNoActivos();
  currentPage.value = 1;
};

// ─── Paginación ──────────────────────────────────────
const startItem = computed(() => (currentPage.value - 1) * productsPerPage + 1);
const endItem = computed(() => Math.min(currentPage.value * productsPerPage, products.value.length));
const totalPages = computed(() => Math.max(1, Math.ceil(products.value.length / productsPerPage)));
const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * productsPerPage;
  return products.value.slice(start, start + productsPerPage);
});

const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const prevPage = () => { if (currentPage.value > 1) currentPage.value--; };
const goToPage = (page) => { currentPage.value = page; };

onMounted(() => {
  loadProducts();
  loadCategories();
});
</script>

<style scoped>
/* ── Layout principal ── */
.products-container {
  padding: 1.5rem;
  background: #f4f6f9;
  min-height: 100vh;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.title {
  font-size: 1.8rem;
  font-weight: 700;
  color: #1a202c;
  margin: 0;
}

/* ── Filtros ── */
.filters {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
}

/* ── Grid cards ── */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 1.2rem;
  margin-bottom: 1.5rem;
  align-items: stretch;
}

/* Cada card ocupa el alto completo de su celda */
.card {
  background: white;
  border-radius: 16px;
  padding: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.07);
  display: flex;
  flex-direction: column;
  height: 100%;
  /* todas iguales dentro del grid */
  transition: transform 0.2s;
}

.card:hover {
  transform: translateY(-3px);
}

/* Imagen fija */
.product-img {
  width: 100%;
  height: 140px;
  object-fit: cover;
  border-radius: 10px;
  margin-bottom: 0.5rem;
  flex-shrink: 0;
}

/* Espacio vacío cuando no hay imagen */
.card:not(:has(.product-img)) .stock-label {
  margin-top: 0;
}

.card h3 {
  font-size: 1rem;
  font-weight: 700;
  margin: 0 0 0.2rem;
  color: #1a202c;
}

.card p {
  font-size: 0.85rem;
  color: #6c757d;
  margin: 0;
}

.category {
  font-size: 0.78rem;
  background: #e9ecef;
  padding: 2px 8px;
  border-radius: 6px;
  display: inline-block;
}

/* Empuja los botones al fondo de la card */
.card-actions {
  display: flex;
  gap: 0.4rem;
  margin-top: auto;
  padding-top: 0.75rem;
}

.stock-label {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 3px 10px;
  border-radius: 8px;
  font-size: 0.78rem;
  font-weight: 700;
  width: fit-content;
  margin-bottom: 0.3rem;
}

.available {
  background: #d1fae5;
  color: #065f46;
}

.low {
  background: #fef3c7;
  color: #92400e;
}

.out {
  background: #fee2e2;
  color: #991b1b;
}

/* ── Paginación ── */
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
}

.pagination-info {
  font-size: 0.85rem;
  color: #6c757d;
}

.pagination {
  display: flex;
  gap: 0.3rem;
}

.page-btn {
  width: 34px;
  height: 34px;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s;
}

.page-btn.active {
  background: #4e73df;
  color: white;
  border-color: #4e73df;
}

.page-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

/* ── Modal overlay ── */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.55);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(3px);
  animation: fadeOverlay 0.2s ease;
}

@keyframes fadeOverlay {
  from {
    opacity: 0;
  }

  to {
    opacity: 1;
  }
}

.modal-content {
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
  animation: slideUp 0.25s ease;
  width: 100%;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.form-modal {
  max-width: 480px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.2rem 1.5rem;
  border-bottom: 1px solid #e9ecef;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.2rem;
  font-weight: 700;
  color: #1a202c;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.1rem;
  color: #6c757d;
  cursor: pointer;
  padding: 0.2rem 0.5rem;
  border-radius: 6px;
  transition: background 0.2s;
}

.modal-close:hover {
  background: #f1f3f5;
}

.modal-body {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.form-group label {
  font-size: 0.85rem;
  font-weight: 600;
  color: #495057;
}

.form-group input,
.form-group select {
  padding: 0.55rem 0.9rem;
  border: 1.5px solid #dee2e6;
  border-radius: 10px;
  font-size: 0.95rem;
  color: #1a202c;
  transition: border-color 0.2s;
  outline: none;
}

.form-group input:focus,
.form-group select:focus {
  border-color: #4e73df;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

/* ── Upload imagen ── */
.file-upload-area {
  border: 2px dashed #dee2e6;
  border-radius: 12px;
  padding: 1.2rem;
  text-align: center;
  cursor: pointer;
  transition: border-color 0.2s, background 0.2s;
}

.file-upload-area:hover {
  border-color: #4e73df;
  background: #f0f4ff;
}

.upload-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.4rem;
  color: #adb5bd;
}

.upload-placeholder p {
  margin: 0;
  font-size: 0.9rem;
  color: #6c757d;
  font-weight: 500;
}

.upload-placeholder span {
  font-size: 0.75rem;
}

.preview-container {
  position: relative;
  display: inline-block;
  width: 100%;
}

.image-preview {
  width: 100%;
  max-height: 160px;
  object-fit: cover;
  border-radius: 8px;
}

.change-image-text {
  display: block;
  font-size: 0.78rem;
  color: #4e73df;
  margin-top: 0.4rem;
  font-weight: 600;
}

/* ── Footer modal ── */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  padding: 1rem 1.5rem;
  border-top: 1px solid #e9ecef;
}

/* ── Modal mensaje ── */
.message-modal {
  max-width: 340px;
  padding: 2rem;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.modal-icon {
  font-size: 2.5rem;
  color: #4e73df;
}

.message-modal p {
  margin: 0;
  font-size: 1rem;
  color: #1a202c;
  font-weight: 500;
}
</style>