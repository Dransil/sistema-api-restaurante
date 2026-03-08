<template>
  <div class="register-container">
    <div class="register-card">
      <h2>Crear Cuenta</h2>

      <form @submit.prevent="register">
        <input v-model="username" type="text" placeholder="Usuario" required />
        <input v-model="password" type="password" placeholder="Contraseña" required />

        <button type="submit">Registrarse</button>
      </form>

      <p>
        ¿Ya tienes cuenta?
        <router-link to="/login">Iniciar sesión</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { registerUser } from '../services/api';
import '../assets/styles/register.css'; // <- tu CSS

const username = ref('');
const password = ref('');
const router = useRouter();

const register = async () => {
  try {
    await registerUser({
      username: username.value,
      password: password.value,
    
    });
    alert('Usuario registrado correctamente');
    router.push('/login');
  } catch (err) {
    console.error('Error registrando usuario:', err);
    alert(err.response?.data?.error || 'Error registrando usuario');
  }
};
</script>