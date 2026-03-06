// src/services/api.js
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL; // debe ser http://localhost:3000

// --- USUARIOS ---
export const registerUser = async (userData) => {
  try {
    const res = await axios.post(`${API_URL}/usuarios/register`, userData);
    return res.data;
  } catch (err) {
    console.error('Error registrando usuario:', err.response?.data || err);
    throw err;
  }
};

export const loginUser = async (userData) => {
  try {
    const res = await axios.post(`${API_URL}/usuarios/login`, userData);
    return res.data;
  } catch (err) {
    console.error('Error login:', err.response?.data || err);
    throw err;
  }
};

// --- ROLES ---
export const getRoles = async () => {
  try {
    const res = await axios.get(`${API_URL}/roles`);
    return res.data;
  } catch (err) {
    console.error('Error obteniendo roles:', err.response?.data || err);
    throw err;
  }
};

// --- PRODUCTOS ---
export const getProductos = async () => {
  try {
    const res = await axios.get(`${API_URL}/productos`);
    return res.data;
  } catch (err) {
    console.error('Error obteniendo productos:', err.response?.data || err);
    throw err;
  }
};