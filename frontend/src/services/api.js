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

//--- ACTUALIZAR USUARIO ---
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

export const getUsuariosActivos = async () => {
  const res = await axios.get(`${API_URL}/usuarios/activos`);
  return res.data;
};

export const getUsuariosInactivos = async () => {
  const res = await axios.get(`${API_URL}/usuarios/noactivos`);
  return res.data;
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

//  PRODUCTOS ACTIVOS
export const getProductosActivos = async () => {
  try {
    const res = await axios.get(`${API_URL}/productos/activos`);
    return res.data;
  } catch (err) {
    console.error("Error obteniendo productos activos:", err.response?.data || err);
    throw err;
  }
};

//  PRODUCTOS NO ACTIVOS
export const getProductosNoActivos = async () => {
  try {
    const res = await axios.get(`${API_URL}/productos/noactivos`);
    return res.data;
  } catch (err) {
    console.error("Error obteniendo productos no activos:", err.response?.data || err);
    throw err;
  }
};

//  CAMBIAR ESTADO
export const cambiarEstadoProducto = async (id, activo) => {
  try {
    const res = await axios.patch(`${API_URL}/productos/${id}/estado`, {
      activo
    });
    return res.data;
  } catch (err) {
    console.error("Error cambiando estado:", err.response?.data || err);
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

export const updateProducto = async (id, data) => {
  const res = await axios.put(`${API_URL}/productos/${id}`, data, {
    headers: {
      "Content-Type": "multipart/form-data"
    }
  });
  return res.data;
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

export const updateCategoria = async (id, categoria) => {
  try {
    const res = await axios.put(`${API_URL}/categorias/${id}`, categoria);
    return res.data;
  } catch (err) {
    console.error("Error actualizando categoría:", err.response?.data || err);
    throw err;
  }
};

// Obtener productos por categoría
export const getProductosByCategoria = async (id) => {
  try {
    const res = await axios.get(`${API_URL}/categorias/productos/${id}`)
    return res.data
  } catch (err) {
    console.error("Error filtrando productos:", err.response?.data || err)
    throw err
  }
}

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
export const getPedidos = async () => {
  const res = await axios.get(`${API_URL}/pedidos`);
  return res.data;
};

export const registrarPedido = async (pedido) => {
  const res = await axios.post(`${API_URL}/pedidos`, pedido);
  return res.data;
};

// --- DETALLE-PEDIDOS ---
export const getDetallePedidos = async () => {
  const res = await axios.get(`${API_URL}/detallepedido`)
  return res.data
}

export const getDetalleByPedidoId = async (id) => {
  const res = await axios.get(`${API_URL}/detallepedido/${id}`)
  return res.data
}
// --- REPORTES ---

export const getResumenDiario = async () => {
  const res = await axios.get(`${API_URL}/reportes/diario`);
  return res.data;
};

export const getTopProductos = async () => {
  const res = await axios.get(`${API_URL}/reportes/top`);
  return res.data;
};

export const getVentasPorRango = async (inicio, fin) => {
  const res = await axios.get(`${API_URL}/reportes/rango`, {
    params: { inicio, fin }
  });
  return res.data;
};

export const getReporteFacturacion = async (inicio, fin) => {
  const res = await axios.get(`${API_URL}/reportes/factura`, {
    params: { inicio, fin }
  });
  return res.data;
};

export const getFacturaDetalle = async (id) => {
  const res = await axios.get(`${API_URL}/reportes/factura/${id}`);
  return res.data;
};