<template>
  <div class="register-container">
    <div class="register-card">

      <div class="register-icon">
        <i class="fas fa-user-plus"></i>
      </div>

      <h2>Crear Cuenta</h2>
      <p class="register-subtitle">Completa los datos para registrarte</p>

      <form @submit.prevent="register">
        <div class="input-wrapper">
          <i class="fas fa-user input-icon"></i>
          <input v-model="username" type="text" placeholder="Usuario" required />
        </div>

        <div class="input-wrapper">
          <i class="fas fa-lock input-icon"></i>
          <input v-model="password" type="password" placeholder="Contraseña" required />
        </div>

        <button type="submit">
          <i class="fas fa-user-check me-2"></i> Registrarse
        </button>
      </form>

      <p v-if="errorMessage" class="error-message">
        <i class="fas fa-circle-exclamation me-1"></i> {{ errorMessage }}
      </p>

      <p class="register-footer">
        ¿Ya tienes cuenta?
        <router-link to="/login">Iniciar sesión</router-link>
      </p>

    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { registerUser } from "../services/api";
import "../assets/styles/register.css";

const username     = ref("");
const password     = ref("");
const errorMessage = ref("");
const router       = useRouter();

const register = async () => {
  errorMessage.value = "";
  if (!username.value || !password.value) {
    errorMessage.value = "Por favor completa todos los campos";
    return;
  }
  try {
    await registerUser({ username: username.value, password: password.value });
    router.push("/login");
  } catch (err) {
    errorMessage.value = err.response?.data?.error || "Error registrando usuario";
  }
};
</script>