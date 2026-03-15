// src/services/api.js
import axios from "axios";

const API_URL = import.meta.env.VITE_API_URL; // http://localhost:3000

// --- USUARIOS ---
export const registerUser = async (userData) => {
  try {
    const res = await axios.post(`${API_URL}/usuarios/register`, userData);
    return res.data;
  } catch (err) {
    console.error("Error registrando usuario:", err.response?.data || err);
    throw err;
  }
};

export const loginUser = async (userData) => {
  try {
    const res = await axios.post(`${API_URL}/usuarios/login`, userData);
    return res.data;
  } catch (err) {
    console.error("Error login:", err.response?.data || err);
    throw err;
  }
};

// --- ROLES ---
export const getRoles = async () => {
  try {
    const res = await axios.get(`${API_URL}/roles`);
    return res.data;
  } catch (err) {
    console.error("Error obteniendo roles:", err.response?.data || err);
    throw err;
  }
};

// --- PRODUCTOS ---
export const getProductos = async () => {
  try {
    const res = await axios.get(`${API_URL}/productos`);
    return res.data;
  } catch (err) {
    console.error("Error obteniendo productos:", err.response?.data || err);
    throw err;
  }
};

export const addProducto = async (producto) => {
  try {
    const res = await axios.post(`${API_URL}/productos`, producto, {
      headers: {
        "Content-Type": "multipart/form-data"
      }
    });
    return res.data;
  } catch (err) {
    console.error("Error agregando producto:", err.response?.data || err);
    throw err;
  }
};

export const deleteProducto = async (id) => {
  try {
    const res = await axios.delete(`${API_URL}/productos/${id}`);
    return res.data;
  } catch (err) {
    console.error('Error eliminando producto:', err.response?.data || err);
    throw err;
  }
};


// --- CATEGORÍAS ---
export const getCategorias = async () => {
  try {
    const res = await axios.get(`${API_URL}/categorias`);
    return res.data;
  } catch (err) {
    console.error("Error obteniendo categorías:", err.response?.data || err);
    throw err;
  }
};

export const addCategoria = async (categoria) => {
  try {
    const res = await axios.post(`${API_URL}/categorias`, categoria);
    return res.data;
  } catch (err) {
    console.error("Error agregando categoría:", err.response?.data || err);
    throw err;
  }
};
export const deleteCategoria = async (id) => {
  try {
    const res = await axios.delete(`${API_URL}/categorias/${id}`);
    return res.data;
  } catch (err) {
    console.error('Error eliminando categoría:', err.response?.data || err);
    throw err;
  }
};

export const updateProducto = async (id, data) => {
  const res = await axios.put(`${API_URL}/productos/${id}`, data, {
    headers: {
      "Content-Type": "multipart/form-data"
    }
  });
  return res.data;
};

export const updateUsuario = async (id, data) => {
  const res = await axios.put(`${API_URL}/usuarios/${id}`, data);
  return res.data;
};

export const cambiarEstadoUsuario = async (id, activo) => {
  const res = await axios.patch(`${API_URL}/usuarios/${id}/estado`, {
    activo
  });
  return res.data;
};


// --- CLIENTES ---
export const getClientes = async () => {
  const res = await axios.get(`${API_URL}/clientes`);
  return res.data;
};

export const addCliente = async (cliente) => {
  const res = await axios.post(`${API_URL}/clientes`, cliente);
  return res.data;
};

export const getClienteByCI = async (ci) => {
  const res = await axios.get(`${API_URL}/clientes/${ci}`);
  return res.data;
};

export const updateCliente = async (id, cliente) => {
  const res = await axios.put(`${API_URL}/clientes/${id}`, cliente);
  return res.data;
};

// --- PEDIDOS ---
export const registrarPedido = async (pedido) => {
  const res = await axios.post(`${API_URL}/pedidos`, pedido);
  return res.data;
};