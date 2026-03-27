<template>
  <div class="register-container">
    <div class="register-card">
      <h2>Crear Cuenta</h2>

      <form @submit.prevent="register">
        <input v-model="username" type="text" placeholder="Usuario" required />
        <input
          v-model="password"
          type="password"
          placeholder="Contraseña"
          required
        />

        <button type="submit">Registrarse</button>
      </form>

      <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

      <p>
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

const username = ref("");
const password = ref("");
const router = useRouter();

const errorMessage = ref("");

const register = async () => {
  errorMessage.value = "";

  if (!username.value || !password.value) {
    errorMessage.value = "Por favor completa todos los campos";
    return;
  }

  try {
    await registerUser({
      username: username.value,
      password: password.value,
    });

    router.push("/login");
  } catch (err) {
    errorMessage.value =
      err.response?.data?.error || "Error registrando usuario";
  }
};
</script>
