<template>
  <div class="login-container">
    <div class="login-card">
      <h2>Iniciar Sesión</h2>

      <form @submit.prevent="login">
        <input v-model="username" type="text" placeholder="Usuario" required />
        <input
          v-model="password"
          type="password"
          placeholder="Contraseña"
          required
        />
        <button type="submit">Ingresar</button>
      </form>

      <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

      <p>
        ¿No tienes cuenta?
        <router-link to="/register">Registrarse</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { loginUser } from "../services/api";
import "../assets/styles/login.css";

const username = ref("");
const password = ref("");
const router = useRouter();

const errorMessage = ref("");

const login = async () => {
  errorMessage.value = "";

  if (!username.value || !password.value) {
    errorMessage.value = "Por favor completa todos los campos";
    return;
  }

  try {
    const data = await loginUser({
      username: username.value,
      password: password.value,
    });

    localStorage.setItem("token", data.token);
    localStorage.setItem("user_id", data.user.id);
    localStorage.setItem("username", data.user.username);
    localStorage.setItem("rol_id", data.user.rol_id);

    router.push("/dashboard/inicio");
  } catch (err) {
    errorMessage.value =
      err.response?.data?.error || "Usuario o contraseña incorrectos";
  }
};
</script>
