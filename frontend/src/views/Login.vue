<template>
  <div class="login-container">

    <!-- Card -->
    <div class="login-card">

      <!-- Ícono -->
      <div class="login-icon">
        <i class="fas fa-utensils"></i>
      </div>

      <h2>Bienvenido</h2>
      <p class="login-subtitle">Inicia sesión para continuar</p>

      <form @submit.prevent="login">
        <div class="input-wrapper">
          <i class="fas fa-user input-icon"></i>
          <input v-model="username" type="text" placeholder="Usuario" required />
        </div>

        <div class="input-wrapper">
          <i class="fas fa-lock input-icon"></i>
          <input v-model="password" type="password" placeholder="Contraseña" required />
        </div>

        <button type="submit">
          <i class="fas fa-arrow-right-to-bracket me-2"></i> Ingresar
        </button>
      </form>

      <p v-if="errorMessage" class="error-message">
        <i class="fas fa-circle-exclamation me-1"></i> {{ errorMessage }}
      </p>

      <p class="login-footer">
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

const username     = ref("");
const password     = ref("");
const errorMessage = ref("");
const router       = useRouter();

const login = async () => {
  errorMessage.value = "";
  if (!username.value || !password.value) {
    errorMessage.value = "Por favor completa todos los campos";
    return;
  }
  try {
    const data = await loginUser({ username: username.value, password: password.value });
    localStorage.setItem("token",    data.token);
    localStorage.setItem("user_id",  data.user.id);
    localStorage.setItem("username", data.user.username);
    localStorage.setItem("rol_id",   data.user.rol_id);
    router.push("/dashboard/inicio");
  } catch (err) {
    errorMessage.value = err.response?.data?.error || "Usuario o contraseña incorrectos";
  }
};
</script>