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

     <select class="input" v-model="rol">
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
</template>

<script setup>
import "../assets/styles/users.css"
import { ref, onMounted } from "vue"
import { useRoute, useRouter } from "vue-router"
import { updateUsuario } from "../services/api"
import { getRoles } from "../services/api"

const API_URL = import.meta.env.VITE_API_URL

const route = useRoute()
const router = useRouter()

const id = route.params.id

const username = ref("")
const password = ref("")
const rol = ref("")
const activo = ref(true)

const name = ref("")
const first_name = ref("")
const second_name = ref("")
const fecha_nac = ref("")
const celular = ref("")
const email = ref("")
const roles = ref([])

const loadUser = async () => {
  const res = await fetch(`${API_URL}/usuarios`)
  const users = await res.json()

  const user = users.find(u => u.id == id)
if (user) {
  username.value = user.username
  rol.value = user.rol_id
  activo.value = user.activo

  name.value = user.name
  first_name.value = user.first_name
  second_name.value = user.second_name
  fecha_nac.value = user.fecha_nac
  celular.value = user.celular
  email.value = user.email
}
}
const loadRoles = async () => {
  roles.value = await getRoles()
}
onMounted(() => {
  loadUser()
  loadRoles()
})

const updateUser = async () => {

  const data = {
    username: username.value,
    rol_id: rol.value,
    activo: activo.value,
    name: name.value,
    first_name: first_name.value,
    second_name: second_name.value,
    fecha_nac: fecha_nac.value,
    celular: celular.value,
    email: email.value
  }

  if (password.value && password.value.trim() !== "") {
    data.password = password.value
  }

  await updateUsuario(id, data)

  router.push("/dashboard/users")
}

const goBack = () => {
  router.push("/dashboard/users")
}
</script>