<template>
  <div class="usuario-container">
    <h2 class="title">Editar Usuario</h2>

    <form class="form" @submit.prevent="updateUser">
      <input
        class="input"
        v-model="username"
        placeholder="Username"
      />

      <input
        class="input"
        v-model="password"
        placeholder="Nueva contraseña (opcional)"
      />

    <select class="input" v-model.number="rol">
  <option value="">Seleccione un rol</option>

  <option
    v-for="role in roles"
    :key="role.id"
    :value="role.id"
  >
    {{ role.nombre }}
  </option>

</select>

      <input class="input" v-model="name" placeholder="Nombre" />

<input class="input" v-model="first_name" placeholder="Primer apellido" />

<input class="input" v-model="second_name" placeholder="Segundo apellido" />

<input class="input" type="date" v-model="fecha_nac" />

<input class="input" v-model="celular" placeholder="Celular" />

<input class="input" v-model="email" placeholder="Email" />

      <label>
        Activo
        <input type="checkbox" v-model="activo" />
      </label>

      <button class="btn btn-save" type="submit">
        Guardar
      </button>

      <button class="btn btn-cancel" type="button" @click="goBack">
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


</template>

<script setup>
import "../assets/styles/users.css"
import { ref, onMounted } from "vue"
import { useRoute, useRouter } from "vue-router"
import { updateUsuario } from "../services/api"
import { getRoles } from "../services/api"
import { getUsuarios } from "../services/api"
const API_URL = import.meta.env.VITE_API_URL

const route = useRoute()
const router = useRouter()

const id = Number(route.params.id)

const username = ref("")
const password = ref("")
const rol = ref(null)
const activo = ref(true)
const showModal = ref(false)
const modalMessage = ref("")
const name = ref("")
const first_name = ref("")
const second_name = ref("")
const fecha_nac = ref("")
const celular = ref("")
const email = ref("")
const roles = ref([])

const normalizeUsers = (data) => {
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.usuarios)) return data.usuarios;
  if (Array.isArray(data?.rows)) return data.rows;
  return [];
};

const showConfirmModal = ref(false)
const confirmMessage = ref("")
let confirmCallback = null
const loadUser = async () => {
  try {
    const data = await getUsuarios()
    const users = normalizeUsers(data)

    const user = users.find(u => u.id === id)

    if (!user) {
      console.error("Usuario no encontrado")
      return
    }

    username.value = user.username
    rol.value = user.rol_id
    activo.value = user.activo

    name.value = user.name || ""
    first_name.value = user.first_name || ""
    second_name.value = user.second_name || ""
    fecha_nac.value = user.fecha_nac || ""
    celular.value = user.celular || ""
    email.value = user.email || ""

  } catch (error) {
    console.error("Error cargando usuario:", error)
  }
}
const loadRoles = async () => {
  roles.value = await getRoles()
}
onMounted(() => {
  loadUser()
  loadRoles()
})

const openModal = (message) => {
  modalMessage.value = message
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  modalMessage.value = ""
}
const updateUser = async () => {
  
  if (!username.value) {
    openModal("El username es obligatorio");
    return;
  }
  if (!rol.value) {
    openModal("Debes seleccionar un rol");
    return;
  }
  if (!email.value) {
      openModal("El email es obligatorio");
    return;
  }

  
  const data = {
    username: username.value,
    rol_id: Number(rol.value), 
    activo: activo.value,
    email: email.value
  };

  if (name.value) data.name = name.value;
  if (first_name.value) data.first_name = first_name.value;
  if (second_name.value) data.second_name = second_name.value;
  if (fecha_nac.value) data.fecha_nac = fecha_nac.value; 
  if (celular.value) data.celular = celular.value;
  if (password.value && password.value.trim() !== "") {
    data.password = password.value;
  }

  try {
    await updateUsuario(id, data);
    router.push("/dashboard/users");
  } catch (error) {
    console.error("Error actualizando usuario:", error);
   openModal("Ocurrió un error al actualizar el usuario. Revisa los datos.");

  }
}
const goBack = () => {
  router.push("/dashboard/users")
}
</script>