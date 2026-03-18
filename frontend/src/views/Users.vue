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

const editingId = ref(null);
const goToCreate = () => {
  router.push("/dashboard/users/create");
};
const loadUsers = async () => {
  const res = await fetch(`${API_URL}/usuarios`);
  users.value = await res.json();
  currentPage.value = 1;
};
onMounted(() => {
  loadUsers();
  loadRoles();
});

const startItem = computed(() => {
  return (currentPage.value - 1) * usersPerPage + 1;
});

const endItem = computed(() => {
  const end = currentPage.value * usersPerPage;
  return end > users.value.length ? users.value.length : end;
});

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * usersPerPage;
  const end = start + usersPerPage;
  return users.value.slice(start, end);
});

const totalPages = computed(() => {
  return Math.ceil(users.value.length / usersPerPage);
});

const loadActivos = async () => {
  users.value = await getUsuariosActivos();
  currentPage.value = 1;
};

const loadInactivos = async () => {
  users.value = await getUsuariosInactivos();
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
  await updateUsuario(editingId.value, {
    username: username.value,
    password: password.value,
    rol_id: rol.value,
    activo: activo.value,
  });

  cancelEdit();
  await loadUsers();
};

const toggleUser = async (user) => {
  const confirmacion = confirm(
    user.activo
      ? "¿Deseas desactivar este usuario?"
      : "¿Deseas activar nuevamente este usuario?",
  );

  if (!confirmacion) return;

  await cambiarEstadoUsuario(user.id, !user.activo);

  await loadUsers();
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
