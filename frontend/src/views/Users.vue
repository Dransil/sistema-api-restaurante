<template>
  <div class="usuarios-container">
    <h2 class="title">Gestión de Usuarios</h2>
    <button class="btn btn-save" @click="goToCreate">Nuevo Usuario</button>
    <div class="filters">
      <button class="btn" @click="loadUsers">Todos</button>
      <button class="btn" @click="loadActivos">Activos</button>
      <button class="btn" @click="loadInactivos">Inactivos</button>
    </div>
    <div class="user-card">
      <table class="user-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Usuario</th>
            <th>Rol</th>
            <th>Estado</th>
            <th>Acciones</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="user in paginatedUsers" :key="user.id">
            <td>{{ user.id }}</td>
            <td>{{ user.username }}</td>
            <td>{{ getRoleName(user.rol_id) }}</td>

            <td>
              <span :class="user.activo ? 'estado-activo' : 'estado-inactivo'">
                {{ user.activo ? "Activo" : "Inactivo" }}
              </span>
            </td>
            <td>
              <button class="btn btn-edit" @click="goToEdit(user.id)">
                Editar
              </button>

              <button class="btn btn-toggle" @click="toggleUser(user)">
                {{ user.activo ? "Desactivar" : "Activar" }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="pagination-container">
        <div class="pagination-info">
          Showing {{ startItem }}-{{ endItem }} of {{ users.length }}
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

    <h3 v-if="editingId">Editar Usuario</h3>

    <form v-if="editingId" class="form" @submit.prevent="updateUser">
      <input class="input" v-model="username" placeholder="Username" />

      <input
        class="input"
        v-model="password"
        placeholder="Nueva contraseña (opcional)"
      />

      <input class="input" v-model="rol" type="number" placeholder="Rol ID" />

      <label>
        Activo
        <input type="checkbox" v-model="activo" />
      </label>

      <button class="btn btn-save" type="submit">Guardar</button>

      <button class="btn btn-cancel" type="button" @click="cancelEdit">
        Cancelar
      </button>
    </form>
  </div>

  <div v-if="showModal" class="modal-overlay" @click="closeModal">
    <div class="modal-content" @click.stop>
      <p>{{ modalMessage }}</p>
      <button @click="closeModal">Cerrar</button>
    </div>
  </div>
  <div v-if="showConfirmModal" class="modal-overlay" @click="cancelToggle">
    <div class="modal-content" @click.stop>
      <p>{{ confirmMessage }}</p>
      <div class="modal-buttons">
        <button class="btn btn-confirm" @click="confirmToggle">Aceptar</button>
        <button class="btn btn-cancel" @click="cancelToggle">Cancelar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import "../assets/styles/users.css";
import { ref, onMounted, computed } from "vue";
import {
  updateUsuario,
  cambiarEstadoUsuario,
  getRoles,
  getUsuariosActivos,
  getUsuariosInactivos,
} from "../services/api";
import { useRouter } from "vue-router";
import { getUsuarios } from "../services/api";

const normalizeUsers = (data) => {
  if (Array.isArray(data)) return data;

  if (Array.isArray(data?.data)) return data.data;

  if (Array.isArray(data?.usuarios)) return data.usuarios;

  if (Array.isArray(data?.rows)) return data.rows;

  return [];
};

const API_URL = import.meta.env.VITE_API_URL;
const router = useRouter();
const users = ref([]);
const currentPage = ref(1);
const usersPerPage = 10;
const roles = ref([]);
const username = ref("");
const password = ref("");
const rol = ref("");
const activo = ref(true);
const showModal = ref(false);
const modalMessage = ref("");

const userToToggle = ref(null);
const confirmMessage = ref("");
const showConfirmModal = ref(false);

const editingId = ref(null);
const goToCreate = () => {
  router.push("/dashboard/users/create");
};
const loadUsers = async () => {
  try {
    const data = await getUsuarios();
    users.value = normalizeUsers(data);
    currentPage.value = 1;
  } catch (error) {
    openModal("Error cargando usuarios ");
  }
};
onMounted(() => {
  loadUsers();
  loadRoles();
});
const openModal = (message) => {
  modalMessage.value = message;
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  modalMessage.value = "";
};
const startItem = computed(() => {
  return (currentPage.value - 1) * usersPerPage + 1;
});

const endItem = computed(() => {
  if (!Array.isArray(users.value)) return 0;

  const end = currentPage.value * usersPerPage;
  return end > users.value.length ? users.value.length : end;
});
const paginatedUsers = computed(() => {
  if (!Array.isArray(users.value)) return [];

  const start = (currentPage.value - 1) * usersPerPage;
  const end = start + usersPerPage;
  return users.value.slice(start, end);
});
const totalPages = computed(() => {
  if (!Array.isArray(users.value)) return 0;

  return Math.ceil(users.value.length / usersPerPage);
});

const loadActivos = async () => {
  const data = await getUsuariosActivos();

  users.value = normalizeUsers(data);
  currentPage.value = 1;
};

const loadInactivos = async () => {
  const data = await getUsuariosInactivos();

  users.value = normalizeUsers(data);
  currentPage.value = 1;
};

const getRoleName = (rol_id) => {
  const role = roles.value.find((r) => r.id === rol_id);
  return role ? role.nombre : "Sin rol";
};
const editUser = (user) => {
  username.value = user.username;
  rol.value = user.rol_id;
  activo.value = user.activo;
  password.value = "";
  editingId.value = user.id;
};

const cancelEdit = () => {
  username.value = "";
  password.value = "";
  rol.value = "";
  activo.value = true;
  editingId.value = null;
};

const updateUser = async () => {
  try {
    await updateUsuario(editingId.value, {
      username: username.value,
      password: password.value,
      rol_id: rol.value,
      activo: activo.value,
    });

    openModal("Usuario actualizado correctamente ");

    cancelEdit();
    await loadUsers();
  } catch (error) {
    openModal("Error al actualizar usuario ");
  }
};

const toggleUser = (user) => {
  userToToggle.value = user;
  confirmMessage.value = user.activo
    ? "¿Deseas desactivar este usuario?"
    : "¿Deseas activar este usuario?";
  showConfirmModal.value = true;
};

const confirmToggle = async () => {
  try {
    const user = userToToggle.value;
    await cambiarEstadoUsuario(user.id, !user.activo);

    openModal(user.activo ? "Usuario desactivado" : "Usuario activado");
    await loadUsers();
  } catch (error) {
    openModal("Error al cambiar estado");
  } finally {
    showConfirmModal.value = false;
    userToToggle.value = null;
  }
};

const cancelToggle = () => {
  showConfirmModal.value = false;
  userToToggle.value = null;
};

const loadRoles = async () => {
  roles.value = await getRoles();
};
const goToEdit = (id) => {
  router.push(`/dashboard/users/${id}/edit`);
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
