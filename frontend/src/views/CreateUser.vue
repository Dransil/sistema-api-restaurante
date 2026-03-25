<template>
  <div class="usuario-container">
    <h2 class="title">Crear Usuario</h2>

    <form class="form" @submit.prevent="createUser">
      <input class="input" v-model="username" placeholder="Username" />

      <input
        class="input"
        type="password"
        v-model="password"
        placeholder="Password"
        required
      />

      <select class="input" v-model="rol">
        <option value="">Seleccione un rol</option>

        <option v-for="role in roles" :key="role.id" :value="role.id">
          {{ role.nombre }}
        </option>
      </select>

      <input class="input" v-model="name" placeholder="Nombre" />

      <input class="input" v-model="first_name" placeholder="Primer apellido" />

      <input
        class="input"
        v-model="second_name"
        placeholder="Segundo apellido"
      />

      <input class="input" type="date" v-model="fecha_nac" />

      <input class="input" v-model="celular" placeholder="Celular" />

      <input class="input" v-model="email" placeholder="Email" />

      <label>
        Activo
        <input type="checkbox" v-model="activo" />
      </label>

      <button class="btn btn-save" type="submit">Guardar</button>

      <button class="btn btn-cancel" type="button" @click="goBack">
        Cancelar
      </button>
    </form>
  </div>
</template>

<script setup>
import "../assets/styles/users.css";
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { registerUser, getRoles } from "../services/api";

const router = useRouter();

const username = ref("");
const password = ref("");
const rol = ref("");
const activo = ref(true);

const name = ref("");
const first_name = ref("");
const second_name = ref("");
const fecha_nac = ref("");
const celular = ref("");
const email = ref("");
const roles = ref([]);

const loadRoles = async () => {
  roles.value = await getRoles();
};

onMounted(() => {
  loadRoles();
});

const createUser = async () => {
  const data = {
    username: username.value,
    password: password.value,
    rol_id: rol.value,
  };

  await registerUser(data);

  router.push("/dashboard/users");
};

const goBack = () => {
  router.push("/dashboard/users");
};
</script>
