<template>
  <div class="categories-container">
    <h2 class="title">Categorías</h2>

    <div class="form-card">
      <div class="form-group">
        <label>Nombre Categoría:</label>
        <input v-model="newCategory" placeholder="Nueva Categoria" />
      </div>

      <div class="buttons">
        <button class="btn-save" @click="addCategory">Guardar</button>

        <button class="btn-cancel" @click="newCategory = ''">Cancelar</button>
      </div>
    </div>
    <table class="tabla">
      <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>Acciones</th>
        </tr>
      </thead>

      <tbody>
        <tr v-for="cat in paginatedCategories" :key="cat.id">
          <td>{{ cat.id }}</td>

          <td v-if="editandoId !== cat.id">
            {{ cat.nombre }}
          </td>

          <td v-else>
            <input v-model="nombreEditado" />
          </td>

          <td>
            <button v-if="editandoId !== cat.id" @click="empezarEditar(cat)">
              Editar
            </button>

            <button v-else @click="guardarEdicion(cat)">Guardar</button>

            <button v-if="editandoId === cat.id" @click="cancelarEdicion">
              Cancelar
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
  <div class="pagination-container">
    <div class="pagination-info">
      Mostrando {{ startItem }}-{{ endItem }} de {{ categories.length }}
    </div>

    <div class="pagination">
      <button @click="prevPage" :disabled="currentPage === 1" class="page-btn">
        ‹
      </button>

      <button
        v-for="page in totalPages"
        :key="page"
        @click="goToPage(page)"
        :class="['page-btn', { active: page === currentPage }]"
      >
        {{ page }}
      </button>

      <button
        @click="nextPage"
        :disabled="currentPage === totalPages"
        class="page-btn"
      >
        ›
      </button>
    </div>
  </div>

  <div v-if="showModal" class="modal-overlay">
    <div class="modal-box">
      <p>{{ modalMessage }}</p>
      <button class="btn-save" @click="cerrarModal">Aceptar</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { getCategorias, addCategoria, updateCategoria } from "../services/api";
import "../assets/styles/categorias.css";

const newCategory = ref("");
const image = ref(null);
const categories = ref([]);
const editandoId = ref(null);
const nombreEditado = ref("");
const currentPage = ref(1);
const categoriesPerPage = 10;
const showModal = ref(false);
const modalMessage = ref("");
const startItem = computed(
  () => (currentPage.value - 1) * categoriesPerPage + 1,
);

const endItem = computed(() => {
  const end = currentPage.value * categoriesPerPage;
  return end > categories.value.length ? categories.value.length : end;
});

const paginatedCategories = computed(() => {
  const start = (currentPage.value - 1) * categoriesPerPage;
  const end = start + categoriesPerPage;
  return categories.value.slice(start, end);
});

const totalPages = computed(() =>
  Math.ceil(categories.value.length / categoriesPerPage),
);
const loadCategories = async () => {
  try {
    categories.value = await getCategorias();
  } catch (err) {
    console.error("Error cargando categorías:", err);
  }
};

onMounted(loadCategories);

const handleFileChange = (e) => {
  const file = e.target.files[0];

  if (!file) return;

  if (
    file.type === "image/png" ||
    file.type === "image/jpeg" ||
    file.type === "image/jpg"
  ) {
    image.value = file;
  } else {
    abrirModal("Solo se permiten imágenes JPG o PNG");
  }
};

const addCategory = async () => {
  if (!newCategory.value) {
    abrirModal("Ingresa el nombre de la categoría");
    return;
  }

  try {
    await addCategoria({
      nombre: newCategory.value,
    });

    newCategory.value = "";

    await loadCategories();

    abrirModal("Categoría creada correctamente");
  } catch (err) {
    console.error("Error agregando categoría:", err);
  }
};

const empezarEditar = (cat) => {
  editandoId.value = cat.id;
  nombreEditado.value = cat.nombre;
};

const cancelarEdicion = () => {
  editandoId.value = null;
  nombreEditado.value = "";
};

const guardarEdicion = async (cat) => {
  if (!nombreEditado.value.trim()) {
    abrirModal("El nombre no puede estar vacío");
    return;
  }

  try {
    await updateCategoria(cat.id, {
      nombre: nombreEditado.value,
    });

    await loadCategories();

    editandoId.value = null;
    nombreEditado.value = "";

    abrirModal("Categoría actualizada correctamente");
  } catch (err) {
    console.error("Error actualizando categoría:", err);
  }
};

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++;
};

const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--;
};

const goToPage = (page) => {
  currentPage.value = page;
};

const abrirModal = (mensaje) => {
  modalMessage.value = mensaje;
  showModal.value = true;
};

const cerrarModal = () => {
  showModal.value = false;
};
</script>
