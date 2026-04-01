<template>
  <div class="usuarios-container">

    <!-- Encabezado -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2 class="title mb-0">Gestión de Usuarios</h2>
      <button class="btn btn-success px-4 shadow-sm d-flex align-items-center gap-2" @click="openCreateModal">
        <i class="bi bi-plus-lg"></i>
        <span class="fw-bold">Nuevo Usuario</span>
      </button>
    </div>

    <!-- Filtros -->
    <div class="filters mb-3 d-flex gap-2">
      <button class="btn shadow-sm" :class="currentFilter === 'todos' ? 'btn-primary' : 'btn-outline-primary'"
        @click="loadUsers">Todos</button>
      <button class="btn shadow-sm" :class="currentFilter === 'activos' ? 'btn-primary' : 'btn-outline-primary'"
        @click="loadActivos">Activos</button>
      <button class="btn shadow-sm" :class="currentFilter === 'inactivos' ? 'btn-primary' : 'btn-outline-primary'"
        @click="loadInactivos">Inactivos</button>
    </div>

    <!-- Tabla -->
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
              <div class="d-flex gap-2 justify-content-center">
                <button class="btn btn-outline-primary btn-sm" @click="openEditModal(user)">
                  <i class="bi bi-pencil-square"></i> Editar
                </button>
                <button class="btn btn-sm" :class="user.activo ? 'btn-outline-danger' : 'btn-outline-success'"
                  @click="toggleUser(user)">
                  {{ user.activo ? "Desactivar" : "Activar" }}
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="pagination-container">
        <div class="pagination-info">Mostrando {{ startItem }}-{{ endItem }} de {{ users.length }}</div>
        <div class="pagination">
          <button class="page-btn" @click="prevPage" :disabled="currentPage === 1">‹</button>
          <button v-for="page in totalPages" :key="page" class="page-btn" :class="{ active: page === currentPage }"
            @click="goToPage(page)">{{ page }}</button>
          <button class="page-btn" @click="nextPage" :disabled="currentPage === totalPages">›</button>
        </div>
      </div>
    </div>

    <!-- ── MODAL CREAR USUARIO ── -->
    <Teleport to="body">
      <div v-if="showCreateModal" class="modal-overlay" @click.self="closeCreateModal">
        <div class="modal-content form-modal">

          <div class="modal-header-custom">
            <h5 class="mb-0 fw-bold">Nuevo Usuario</h5>
            <button class="modal-close-btn" @click="closeCreateModal">
              <i class="bi bi-x-lg"></i>
            </button>
          </div>

          <div class="modal-body-custom">
            <div class="mb-3">
              <label class="form-label fw-semibold">Username</label>
              <input class="form-control" v-model="newUsername" placeholder="Username" />
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">Contraseña</label>
              <input class="form-control" v-model="newPassword" type="password" placeholder="Contraseña" />
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">Nombre</label>
              <input class="form-control" v-model="newName" placeholder="Nombre" />
            </div>

            <div class="form-row mb-3">
              <div>
                <label class="form-label fw-semibold">Primer Apellido</label>
                <input class="form-control" v-model="newFirstName" placeholder="Primer apellido" />
              </div>
              <div>
                <label class="form-label fw-semibold">Segundo Apellido</label>
                <input class="form-control" v-model="newSecondName" placeholder="Segundo apellido" />
              </div>
            </div>

            <div class="form-row mb-3">
              <div>
                <label class="form-label fw-semibold">Fecha de Nacimiento</label>
                <input class="form-control" v-model="newFechaNac" type="date" />
              </div>
              <div>
                <label class="form-label fw-semibold">Celular</label>
                <input class="form-control" v-model="newCelular" placeholder="Celular" />
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">Email</label>
              <input class="form-control" v-model="newEmail" type="email" placeholder="correo@ejemplo.com" />
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">Rol</label>
              <select class="form-select" v-model="newRol">
                <option value="" disabled>Selecciona un rol</option>
                <option v-for="r in roles" :key="r.id" :value="r.id">{{ r.nombre }}</option>
              </select>
            </div>
          </div>

          <div class="modal-footer-custom">
            <button class="btn btn-outline-secondary" @click="closeCreateModal">Cancelar</button>
            <button class="btn btn-success" @click="createUser">
              <i class="bi bi-plus-lg me-1"></i> Crear Usuario
            </button>
          </div>

        </div>
      </div>
    </Teleport>

    <!-- ── MODAL EDITAR USUARIO ── -->
    <Teleport to="body">
      <div v-if="showEditModal" class="modal-overlay" @click.self="closeEditModal">
        <div class="modal-content form-modal">

          <div class="modal-header-custom">
            <h5 class="mb-0 fw-bold">Editar Usuario</h5>
            <button class="modal-close-btn" @click="closeEditModal">
              <i class="bi bi-x-lg"></i>
            </button>
          </div>

          <div class="modal-body-custom">
            <div class="mb-3">
              <label class="form-label fw-semibold">Username</label>
              <input class="form-control" v-model="username" placeholder="Username" />
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">Nueva contraseña <span
                  class="text-muted fw-normal">(opcional)</span></label>
              <input class="form-control" v-model="password" type="password"
                placeholder="Dejar vacío para no cambiar" />
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">Nombre</label>
              <input class="form-control" v-model="editName" placeholder="Nombre" />
            </div>

            <div class="form-row mb-3">
              <div>
                <label class="form-label fw-semibold">Primer Apellido</label>
                <input class="form-control" v-model="editFirstName" placeholder="Primer apellido" />
              </div>
              <div>
                <label class="form-label fw-semibold">Segundo Apellido</label>
                <input class="form-control" v-model="editSecondName" placeholder="Segundo apellido" />
              </div>
            </div>

            <div class="form-row mb-3">
              <div>
                <label class="form-label fw-semibold">Fecha de Nacimiento</label>
                <input class="form-control" v-model="editFechaNac" type="date" />
              </div>
              <div>
                <label class="form-label fw-semibold">Celular</label>
                <input class="form-control" v-model="editCelular" placeholder="Celular" />
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">Email</label>
              <input class="form-control" v-model="editEmail" type="email" placeholder="correo@ejemplo.com" />
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">Rol</label>
              <select class="form-select" v-model="rol">
                <option value="" disabled>Selecciona un rol</option>
                <option v-for="r in roles" :key="r.id" :value="r.id">{{ r.nombre }}</option>
              </select>
            </div>

            <div class="mb-3 d-flex align-items-center gap-2">
              <input type="checkbox" class="form-check-input" id="activoCheck" v-model="activo" />
              <label class="form-check-label fw-semibold" for="activoCheck">Usuario activo</label>
            </div>
          </div>

          <div class="modal-footer-custom">
            <button class="btn btn-outline-secondary" @click="closeEditModal">Cancelar</button>
            <button class="btn btn-primary" @click="updateUser">
              <i class="bi bi-floppy me-1"></i> Guardar cambios
            </button>
          </div>

        </div>
      </div>
    </Teleport>

    <!-- ── MODAL MENSAJE ── -->
    <Teleport to="body">
      <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
        <div class="modal-content" @click.stop>
          <p>{{ modalMessage }}</p>
          <button class="btn btn-primary px-4" @click="closeModal">Entendido</button>
        </div>
      </div>
    </Teleport>

    <!-- ── MODAL CONFIRMAR TOGGLE ── -->
    <Teleport to="body">
      <div v-if="showConfirmModal" class="modal-overlay" @click.self="cancelToggle">
        <div class="modal-content" @click.stop>
          <p>{{ confirmMessage }}</p>
          <div class="modal-buttons">
            <button class="btn btn-confirm" @click="confirmToggle">Sí, confirmar</button>
            <button class="btn btn-cancel" @click="cancelToggle">Cancelar</button>
          </div>
        </div>
      </div>
    </Teleport>

  </div>
</template>

<script setup>
import "../assets/styles/users.css";
import { ref, onMounted, computed } from "vue";
import {
  createUsuario,
  updateUsuario,
  cambiarEstadoUsuario,
  getRoles,
  getUsuariosActivos,
  getUsuariosInactivos,
  getUsuarios,
} from "../services/api";

const normalizeUsers = (data) => {
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.usuarios)) return data.usuarios;
  if (Array.isArray(data?.rows)) return data.rows;
  return [];
};

const users = ref([]);
const roles = ref([]);
const currentPage = ref(1);
const usersPerPage = 10;
const currentFilter = ref("todos");

// ─── Modal crear ─────────────────────────────────────
const showCreateModal = ref(false);
const newUsername = ref("");
const newPassword = ref("");
const newName = ref("");
const newFirstName = ref("");
const newSecondName = ref("");
const newFechaNac = ref("");
const newCelular = ref("");
const newEmail = ref("");
const newRol = ref("");

const openCreateModal = () => {
  newUsername.value = "";
  newPassword.value = "";
  newName.value = "";
  newFirstName.value = "";
  newSecondName.value = "";
  newFechaNac.value = "";
  newCelular.value = "";
  newEmail.value = "";
  newRol.value = "";
  showCreateModal.value = true;
};

const closeCreateModal = () => { showCreateModal.value = false; };

const createUser = async () => {
  if (!newUsername.value || !newPassword.value || !newRol.value || !newName.value) {
    openModal("Username, contraseña, nombre y rol son obligatorios"); return;
  }
  try {
    await createUsuario({
      username: newUsername.value,
      password: newPassword.value,
      rol_id: newRol.value,
      name: newName.value,
      first_name: newFirstName.value,
      second_name: newSecondName.value,
      fecha_nac: newFechaNac.value,
      celular: newCelular.value,
      email: newEmail.value,
    });
    closeCreateModal();
    openModal("Usuario creado correctamente");
    await loadUsers();
  } catch {
    openModal("Error al crear usuario");
  }
};

// ─── Modal editar ─────────────────────────────────────
const showEditModal = ref(false);
const editingId = ref(null);
const username = ref("");
const password = ref("");
const rol = ref("");
const activo = ref(true);
const editName       = ref("");
const editFirstName  = ref("");
const editSecondName = ref("");
const editFechaNac   = ref("");
const editCelular    = ref("");
const editEmail      = ref("");

const openEditModal = (user) => {
  editingId.value     = user.id;
  username.value      = user.username;
  password.value      = "";
  rol.value           = user.rol_id;
  activo.value        = user.activo;
  editName.value      = user.name        || "";
  editFirstName.value = user.first_name  || "";
  editSecondName.value= user.second_name || "";
  editFechaNac.value  = user.fecha_nac   ? user.fecha_nac.split("T")[0] : "";
  editCelular.value   = user.celular     || "";
  editEmail.value     = user.email       || "";
  showEditModal.value = true;
};

const closeEditModal = () => {
  showEditModal.value  = false;
  editingId.value      = null;
  username.value       = "";
  password.value       = "";
  rol.value            = "";
  activo.value         = true;
  editName.value       = "";
  editFirstName.value  = "";
  editSecondName.value = "";
  editFechaNac.value   = "";
  editCelular.value    = "";
  editEmail.value      = "";
};

const updateUser = async () => {
  try {
    await updateUsuario(editingId.value, {
      username:    username.value,
      password:    password.value,
      rol_id:      rol.value,
      activo:      activo.value,
      name:        editName.value,
      first_name:  editFirstName.value,
      second_name: editSecondName.value,
      fecha_nac:   editFechaNac.value,
      celular:     editCelular.value,
      email:       editEmail.value,
    });
    closeEditModal();
    openModal("Usuario actualizado correctamente");
    await loadUsers();
  } catch {
    openModal("Error al actualizar usuario");
  }
};

// ─── Modal mensaje ────────────────────────────────────
const showModal = ref(false);
const modalMessage = ref("");
const openModal = (msg) => { modalMessage.value = msg; showModal.value = true; };
const closeModal = () => { showModal.value = false; modalMessage.value = ""; };

// ─── Modal confirmar toggle ───────────────────────────
const showConfirmModal = ref(false);
const confirmMessage = ref("");
const userToToggle = ref(null);

const toggleUser = (user) => {
  userToToggle.value = user;
  confirmMessage.value = user.activo ? "¿Deseas desactivar este usuario?" : "¿Deseas activar este usuario?";
  showConfirmModal.value = true;
};

const confirmToggle = async () => {
  try {
    const user = userToToggle.value;
    await cambiarEstadoUsuario(user.id, !user.activo);
    openModal(user.activo ? "Usuario desactivado" : "Usuario activado");
    await loadUsers();
  } catch {
    openModal("Error al cambiar estado");
  } finally {
    showConfirmModal.value = false;
    userToToggle.value = null;
  }
};
const cancelToggle = () => { showConfirmModal.value = false; userToToggle.value = null; };

// ─── Carga de datos ───────────────────────────────────
const loadUsers = async () => {
  currentFilter.value = "todos";
  try {
    users.value = normalizeUsers(await getUsuarios());
    currentPage.value = 1;
  } catch { openModal("Error cargando usuarios"); }
};

const loadActivos = async () => {
  currentFilter.value = "activos";
  users.value = normalizeUsers(await getUsuariosActivos());
  currentPage.value = 1;
};

const loadInactivos = async () => {
  currentFilter.value = "inactivos";
  users.value = normalizeUsers(await getUsuariosInactivos());
  currentPage.value = 1;
};

const loadRoles = async () => { roles.value = await getRoles(); };

onMounted(() => { loadUsers(); loadRoles(); });

// ─── Helpers ──────────────────────────────────────────
const getRoleName = (rol_id) => roles.value.find((r) => r.id === rol_id)?.nombre || "Sin rol";

// ─── Paginación ───────────────────────────────────────
const startItem = computed(() => (currentPage.value - 1) * usersPerPage + 1);
const endItem = computed(() => {
  const end = currentPage.value * usersPerPage;
  return end > users.value.length ? users.value.length : end;
});
const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * usersPerPage;
  return users.value.slice(start, start + usersPerPage);
});
const totalPages = computed(() => Math.ceil(users.value.length / usersPerPage));
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const prevPage = () => { if (currentPage.value > 1) currentPage.value--; };
const goToPage = (page) => { currentPage.value = page; };
</script>