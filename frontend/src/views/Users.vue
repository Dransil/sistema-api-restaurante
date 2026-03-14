<template>
  <div class="container">
    <h2 class="title">Gestión de Usuarios</h2>

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
        <tr v-for="user in users" :key="user.id">
          <td>{{ user.id }}</td>
          <td>{{ user.username }}</td>
         <td>{{ getRoleName(user.rol_id) }}</td>

          <td>
            {{ user.activo ? "Activo" : "Inactivo" }}
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

    <h3 v-if="editingId">Editar Usuario</h3>

    <form v-if="editingId" class="form" @submit.prevent="updateUser">
      <input class="input" v-model="username" placeholder="Username" />

      <input
        class="input"
        v-model="password"
        placeholder="Nueva contraseña (opcional)"
      />

      <input
        class="input"
        v-model="rol"
        type="number"
        placeholder="Rol ID"
      />

      <label>
        Activo
        <input type="checkbox" v-model="activo" />
      </label>

      <button class="btn btn-save" type="submit">
        Guardar
      </button>

      <button class="btn btn-cancel" type="button" @click="cancelEdit">
        Cancelar
      </button>
    </form>
  </div>
</template>

<script setup>
import "../assets/styles/users.css"
import { ref, onMounted } from "vue"
import { updateUsuario, cambiarEstadoUsuario, getRoles } from "../services/api"
import { useRouter } from "vue-router"

const API_URL = import.meta.env.VITE_API_URL
const router = useRouter()
const users = ref([])
const roles = ref([])
const username = ref("")
const password = ref("")
const rol = ref("")
const activo = ref(true)

const editingId = ref(null)

const loadUsers = async () => {
  const res = await fetch(`${API_URL}/usuarios`)
  users.value = await res.json()
}

onMounted(() => {
  loadUsers()
  loadRoles()
})

const getRoleName = (rol_id) => {
  const role = roles.value.find(r => r.id === rol_id)
  return role ? role.nombre : "Sin rol"
}
const editUser = (user) => {
  username.value = user.username
  rol.value = user.rol_id
  activo.value = user.activo
  password.value = ""
  editingId.value = user.id
}

const cancelEdit = () => {
  username.value = ""
  password.value = ""
  rol.value = ""
  activo.value = true
  editingId.value = null
}

const updateUser = async () => {
  await updateUsuario(editingId.value, {
    username: username.value,
    password: password.value,
    rol_id: rol.value,
    activo: activo.value
  })

  cancelEdit()
  await loadUsers()
}

const toggleUser = async (user) => {
  await cambiarEstadoUsuario(user.id, !user.activo)
  await loadUsers()
}
const loadRoles = async () => {
  roles.value = await getRoles()
}
const goToEdit = (id) => {
  router.push(`/dashboard/users/${id}/edit`)
}

</script>