<template>
  <div class="login-container">
    <div class="login-card">
      <h2>Iniciar Sesión</h2>

      <form @submit.prevent="login">
        <input v-model="username" type="text" placeholder="Usuario" required />
        <input v-model="password" type="password" placeholder="Contraseña" required />
        <button type="submit">Ingresar</button>
      </form>

      <p>
        ¿No tienes cuenta?
        <router-link to="/register">Registrarse</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { loginUser } from '../services/api';
import '../assets/styles/login.css'; 

const username = ref('');
const password = ref('');
const router = useRouter();

const login = async () => {
  try {
    const data = await loginUser({ username: username.value, password: password.value });
    localStorage.setItem('token', data.token);
    alert('Login exitoso');
    router.push('/dashboard');
  } catch (err) {
    console.error('Error al iniciar sesión:', err);
    alert(err.response?.data?.error || 'Usuario o contraseña incorrectos');
  }
};
</script>